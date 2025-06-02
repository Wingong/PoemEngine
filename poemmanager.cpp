#include "poemmanager.h"
#include <QThread>

#include <QFile>
#include <QDebug>
#include <QRegularExpression>
#include <QSet>
#include <QJsonDocument>

QStringList PoemManager::dataHeader = {"題目", "作者", "詩句", "言數", "句數", "體裁", "句序", "平仄", "id", "韻腳"};
QStringList PoemManager::dataHeaderVar = {"title", "author", "ju", "yan", "jushu", "ticai", "juind", "pz", "id", "yun"};

PoemManager::PoemManager(QObject *parent)
    : QObject{parent}
{
}

QStringList PoemManager::splitString(const QString &str)
{
    static QRegularExpression rSep("[,，; \t]+");

    auto lst = str.split(rSep);
    lst = QSet<QString>(lst.begin(), lst.end()).values();
    lst.removeAll("");
    return lst;
}

QStringList PoemManager::splitNums(const QString &str)
{
    static QRegularExpression rMinus("^(\\d+)\\s*-\\s*(\\d+)$"), rSep("[,，; \t]+");
    bool ok;

    auto indSep = str.split(rSep);
    QSet<QString> indexes;

    for(auto &i : indSep)
    {
        if(i.contains("-"))
        {
            auto indMin = rMinus.match(i).capturedTexts();
            if(indMin.size() == 3)
            {
                int begin = indMin[1].toInt(&ok);
                int end = indMin[2].toInt(&ok);
                for(int i = begin; i <= end; i ++)
                    indexes.insert(QString::number(i));
            }
        }

        i.toInt(&ok);
        if(ok)
            indexes.insert(i);

    }

    return indexes.values();
}

void PoemManager::load(const QString &qts_path, const QString &jubiao_path, const QString &psy_path, const QString &psy_yunbu_path, const QString var_path)
{
    {
        emit progSet(tr("读取全唐诗……"), 0);
        QFile file(qts_path);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            qWarning() << "无法打开文件:" << file.errorString();
            emit progSet(tr("无法打开文件 ") + qts_path + file.errorString(), 0);
            return;
        }

        QTextStream in(&file);
        qts_header.clear();
        while (!in.atEnd()) {
            QString line = in.readLine();
            // 使用逗号分割每一行的数据
            QStringList fields = line.split(',', Qt::KeepEmptyParts);
            if(qts_header.empty())
            {
                for(int i=0; i<fields.size(); i++)
                    qts_header[fields[i]] = i;
            }
            else
                qts[fields[0]] = fields;

            int len = qts.size();
            if((len % 100) == 0)
            {
                emit progSet(tr("读取全唐诗……%1 首").arg(len), 0);
            }
        }

        file.close();
    }

    {
        emit progSet(tr("读取句表……"), 0);
        QFile f_jubiao(jubiao_path);
        if (!f_jubiao.open(QIODevice::ReadOnly | QIODevice::Text)) {
            qWarning() << "无法打开文件:" << f_jubiao.errorString();
            emit debug("无法打开文件：" + f_jubiao.errorString());
            return;
        }

        QTextStream in_jubiao(&f_jubiao);
        jubiao_header.clear();
        QStringList header;
        bool begin = false;
        bool first_signal = true;

        int id_col = -1;
        QList<QStringList> data;
        qsizetype colNum = dataHeader.size();
        QMap<int, int> headerMapPoem, headerMapJu;
        for(auto &[key, i] : qts_header.toStdMap())
        {
            if(dataHeader.contains(key))
            {
                headerMapPoem[i] = dataHeader.indexOf(key);
            }
        }

        while (!in_jubiao.atEnd()) {
            QString line = in_jubiao.readLine();
            // 使用逗号分割每一行的数据
            QStringList fields = line.split(',', Qt::KeepEmptyParts);
            if(!begin)
            {
                begin = true;
                header = fields;
                for(int i=0; i<fields.size(); i++)
                    jubiao_header[fields[i]] = i;
                id_col = jubiao_header["id"];

                for(auto &[key, i] : jubiao_header.toStdMap())
                {
                    if(dataHeader.contains(key) && key != "id")
                    {
                        headerMapJu[i] = dataHeader.indexOf(key);
                    }
                }

                // qCritical() << id_col << headerMapJu << headerMapPoem << dataHeader;
            }
            else
            {
                jubiao.append(fields);
                int index = jubiao.size()-1;
                for(int i=0; i<fields.size()-1; i++)
                {
                    to_jubiao[header[i]][fields[i]].append(index);
                }

                auto &id = fields[id_col];
                auto &poem = qts[id];
                QStringList dataLine(colNum);

                for(auto &[idxSrc, idxTgt] : headerMapPoem.toStdMap())
                {
                    dataLine[idxTgt] = poem[idxSrc];
                }
                for(auto &[idxSrc, idxTgt] : headerMapJu.toStdMap())
                {
                    dataLine[idxTgt] = fields[idxSrc];
                }

                data.append(dataLine);
            }

            int len = jubiao.size();
            if((len % 1000) == 0)
            {
                emit progSet(tr("读取句表……%1 句").arg(len), 0);
                if(first_signal)
                {
                    emit dataHeaderLoaded(dataHeader, dataHeaderVar, data);
                    first_signal = false;
                }
                else
                {
                    emit dataLoaded(data);
                }

                data.clear();
            }
        }

        if(!data.isEmpty())
            emit dataLoaded(data);

        // emit dataHeaderLoaded(dataHeader, data);
        f_jubiao.close();
    }

    {
        emit progSet(tr("读取平水韵……"), 0);
        QFile f_psy(psy_path);
        f_psy.open(QIODevice::ReadOnly);
        QByteArray jsonData = f_psy.readAll();
        QJsonDocument doc = QJsonDocument::fromJson(jsonData);
        auto psy_vmap = doc.toVariant().toMap();
        f_psy.close();

        for(auto &[zi, yun] : psy_vmap.toStdMap())
        {
            if(psy_tab.size() % 100 == 0)
                emit progSet(tr("读取平水韵……%1/%2字").arg(psy_tab.size()).arg(psy_vmap.size()), 0);

            psy_tab[zi[0]] = yun.toString();
        }
        // qDebug() << "psy: " << psy;
    }

    {
        emit progSet(tr("读取平水韵韵部……"), 0);
        QFile f_yunbu(psy_yunbu_path);
        f_yunbu.open(QIODevice::ReadOnly);
        QByteArray jsonData = f_yunbu.readAll();
        QJsonDocument doc = QJsonDocument::fromJson(jsonData);
        auto psy_yunbu = doc.toVariant().toMap();
        f_yunbu.close();

        for(auto &[zi, yun] : psy_yunbu.toStdMap())
        {
            if(psy_yunbu.size() % 100 == 0)
                emit progSet(tr("读取平水韵韵部……%1/%2").arg(psy_yunbu.size()).arg(psy_yunbu.size()), 0);

            psy_yunbu[zi[0]] = yun.toMap();
        }
        // qDebug() << "韵部: " << psy_yunbu;
    }

    {
        emit progSet(tr("读取繁简、异体字……"), 0);
        QFile f_var(var_path);
        f_var.open(QIODevice::ReadOnly);
        QByteArray jsonData = f_var.readAll();
        QJsonDocument doc = QJsonDocument::fromJson(jsonData);
        auto tradsimp_vmap = doc.toVariant().toMap();
        f_var.close();

        for(auto &[zi, var_map_qvariant] : tradsimp_vmap.toStdMap())
        {
            auto var_map = var_map_qvariant.toMap();
            xvariants[zi[0]] = var_map["kXSemantic"].toStringList().join("");
            tradsimps[zi[0]] = var_map["kTradSimp"].toStringList().join("");
            if(xvariants.size() % 1000 == 0)
                emit progSet(tr("读取繁简、异体字……%1/%2字").arg(xvariants.size()).arg(tradsimp_vmap.size()), 0);
        }
        // qCritical() << "C++ DEBUG:" << __func__ << ":" << psy;
        // qDebug() << "异体字: " << xvariants;
        // qDebug() << "繁体字: " << tradsimps;
    }

    emit progSet("", 0);
}

void PoemManager::onQuery(const QVariantList &values, const QVariantList &stricts)
{
    QString ju      = (values.size() > 0) ? values[0].toString() : "";
    QString pz      = (values.size() > 1) ? values[1].toString() : "";
    QString title   = (values.size() > 2) ? values[2].toString() : "";
    QString author  = (values.size() > 3) ? values[3].toString() : "";
    QString yan     = (values.size() > 4) ? values[4].toString() : "";
    QString shu     = (values.size() > 5) ? values[5].toString() : "";
    QString ticai   = (values.size() > 6) ? values[6].toString() : "";
    QString index   = (values.size() > 7) ? values[7].toString() : "";

    bool strict_ju       = (stricts.size() > 0) ? stricts[0].toBool() : false;
    bool strict_pz       = (stricts.size() > 1) ? stricts[1].toBool() : false;
    bool strict_title    = (stricts.size() > 2) ? stricts[2].toBool() : false;
    bool strict_author   = (stricts.size() > 3) ? stricts[3].toBool() : false;
    bool strict_yan      = (stricts.size() > 4) ? stricts[4].toBool() : false;
    bool strict_shu      = (stricts.size() > 5) ? stricts[5].toBool() : false;
    bool strict_ticai    = (stricts.size() > 6) ? stricts[6].toBool() : false;
    bool strict_index    = (stricts.size() > 7) ? stricts[7].toBool() : false;

    emit progSet(tr("检索中……"), 0);

    QMap<QString, QSet<int>> jumap_search;

    auto yans = splitNums(yan);
    auto shus = splitNums(shu);
    auto indexes = splitNums(index);

    auto authors = splitString(author);
    auto pzs = splitString(pz);
    auto ticais = splitString(ticai);

    auto titles = splitString(title);
    auto jus = splitString(ju);


    if(!jus.isEmpty())
    {
        jumap_search["詩句"].clear();
        if(strict_ju)
        {
            for(auto &ju: jus)
            {
                for(auto const &[key, val] : to_jubiao["詩句"].toStdMap())
                    if(key == ju)
                        jumap_search["詩句"] += QSet<int>(val.begin(), val.end());
            }
        }
        else
        {
            for(auto &ju: jus)
            {
                for(auto const &[key, val] : to_jubiao["詩句"].toStdMap())
                    if(key.contains(ju))
                        jumap_search["詩句"] += QSet<int>(val.begin(), val.end());
            }
        }
    }

    if(!pzs.isEmpty())
    {
        jumap_search["平仄"].clear();
        if(strict_pz)
        {
            for(auto &pz : pzs)
            {
                for(auto const &[key, val] : to_jubiao["平仄"].toStdMap())
                {
                    // if(key.contains("通") || key.contains("？"))
                    //     continue;

                    if(key.size() != pz.size())
                        continue;

                    bool notmatch = false;
                    for(int i = 0; i < key.size(); i ++)
                    {
                        if(key[i] != pz[i] && pz[i] != "通")
                        {
                            notmatch = true;
                            break;
                        }
                    }
                    if(!notmatch)
                        jumap_search["平仄"] += QSet<int>(val.begin(), val.end());
                }
            }
        }
        else
        {
            for(auto &pz : pzs)
            {
                for(auto const &[key, val] : to_jubiao["平仄"].toStdMap())
                {
                    if(key.size() != pz.size())
                        continue;

                    bool notmatch = false;
                    for(int i = 0; i < key.size(); i ++)
                    {
                        if(key[i] != pz[i] && pz[i] != "通" && key[i] != "通")
                        {
                            notmatch = true;
                            break;
                        }
                    }
                    if(!notmatch)
                        jumap_search["平仄"] += QSet<int>(val.begin(), val.end());
                }
            }
        }
    }

    if(!indexes.isEmpty())
    {
        jumap_search["句序"].clear();
        for(auto const &[key, val] : to_jubiao["句序"].toStdMap())
            for(auto &index : indexes)
                if(key == index)
                    jumap_search["句序"] += QSet<int>(val.begin(), val.end());
    }

    QSet<int> juSet;

    bool empty = false;
    for(auto &[key, val] : jumap_search.toStdMap())
    {
        empty = true;
        if(!val.isEmpty())
        {
            empty = false;
            break;
        }
    }

    if(!empty)
    {
        for(int i=0; i<jubiao.size(); i++)
            juSet.insert(i);
    }

    for(auto &set : jumap_search)
    {
        juSet.intersect(set);
    }

    // qCritical() << juSet.size() << strict_title << titles << values << stricts;
    // qCritical() << strict_title << poem[qts_header["題目"]] << titles;

    QList<int> lines;
    for(auto &index : juSet)
    {
        auto &ju = jubiao[index];
        auto &id = jubiao[index][jubiao_header["id"]];
        auto &poem = qts[id];

        if(!titles.isEmpty())
        {
            bool cont = true;
            for(auto &title : titles)
            {
                if(strict_title && poem[qts_header["題目"]] == title)
                {
                    cont = false;
                    break;
                }
                else if(!strict_title && poem[qts_header["題目"]].contains(title))
                {
                    cont = false;
                    break;
                }
            }
            if(cont)
                continue;
        }

        if(!authors.isEmpty())
        {
            bool cont = true;
            for(auto &author : authors)
            {
                if(strict_author && poem[qts_header["作者"]] == author)
                {
                    cont = false;
                    break;
                }
                else if(!strict_author && poem[qts_header["作者"]].contains(author))
                {
                    cont = false;
                    break;
                }
            }
            if(cont)
                continue;
        }

        if(!yans.empty() && !yans.contains(poem[qts_header["言數"]]))
        {
            continue;
        }

        if(!shus.empty() && !shus.contains(poem[qts_header["句數"]]))
        {
            continue;
        }

        if(!ticais.isEmpty())
        {
            bool cont = true;
            for(auto &ticai : ticais)
            {
                if(strict_ticai && poem[qts_header["體裁"]] == ticai)
                {
                    cont = false;
                    break;
                }
                else if(!strict_ticai && poem[qts_header["體裁"]].contains(ticai))
                {
                    cont = false;
                    break;
                }
            }
            if(cont)
                continue;
        }
        lines.append(index);
    }

    emit queryEnd(lines);
    // emit progSet(tr("結果數量：%1句").arg(lines.size()), 0);
}

void PoemManager::onSearchById(const QString &id)
{
    auto poem = qts[id];
    QVariantMap ret;
    for(auto &[key, val] : qts_header.toStdMap())
        ret[key] = poem[val];

    QVariantMap yuns_map;

    for(auto &zi : ret["內容"].toString())
    {
        if (!yuns_map.contains(zi))
        {
            yuns_map[zi] = searchYunsByZi(zi);
        }
    }

    ret["韻目"] = yuns_map;

    emit searchEnd(ret);
}

QString PoemManager::searchYunsByZi(const QChar &zi)
{
    auto yuns = psy_tab[zi];
    QString ret;
    if(yuns.isEmpty())
    {
        // 异体字
        for(auto var : xvariants[zi])
        {
            if(psy_tab.contains(var))
            {
                yuns = psy_tab[var];
                break;
            }
        }
    }
    if(yuns.isEmpty())
    {
        // 繁体字
        QString zi_list = tradsimps[zi];
        for(auto &var : tradsimps[zi])
        {
            if(psy_tab.contains(var))
            {
                yuns = psy_tab[var];
                break;
            }
            else
            {
                for(auto &var_tradsimp : xvariants[var])
                {
                    // 繁体字的异体字
                    if(psy_tab.contains(var_tradsimp))
                    {
                        yuns = psy_tab[var_tradsimp];
                        break;
                    }
                }
                if(!yuns.isEmpty())
                {
                    break;
                }
            }
        }
    }

    return yuns;

    // emit yunsSearchEnd(yuns);
}
