#include "poemmanager.h"
#include <QThread>

#include <QFile>
#include <QDebug>
#include <QRegularExpression>
#include <QSet>

PoemManager::PoemManager(QObject *parent)
    : QObject{parent}
{
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

void PoemManager::load(const QString &qts_path, const QString &jubiao_path)
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
    QStringList dataHeader = {"題目", "作者", "詩句", "言數", "句數", "體裁", "句序", "平仄", "id"};
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
                emit dataHeaderLoaded(dataHeader, data);
                first_signal = false;
            }
            else
            {
                emit dataLoaded(data);
            }

            data.clear();
        }
    }

    // emit dataHeaderLoaded(dataHeader, data);
    f_jubiao.close();

    if(!data.isEmpty())
        emit dataLoaded(data);

    emit progSet("", 0);
}

void PoemManager::onQuery(const QVariantList &values, const QVariantList &stricts)
{
// ju,
// pz,
// title,
// author
// yan,
// shu,
// ticai,
// index)
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

    static QRegularExpression rSep("[,，; \t]+");

    QMap<QString, QList<int>> jumap_search;

    auto yans = splitNums(yan);
    auto shus = splitNums(shu);

    auto ticais = ticai.split(rSep);
    ticais = QSet<QString>(ticais.begin(), ticais.end()).values();
    ticais.removeAll("");
    auto indexes = splitNums(index);

    if(ju != "")
    {
        if(strict_ju)
        {
            for(auto const &[key, val] : to_jubiao["詩句"].toStdMap())
                if(key == ju)
                    jumap_search["詩句"] += val;
        }
        else
        {
            for(auto const &[key, val] : to_jubiao["詩句"].toStdMap())
                if(key.contains(ju))
                    jumap_search["詩句"] += val;
        }
    }

    if(pz != "")
    {
        if(strict_pz)
        {
            for(auto const &[key, val] : to_jubiao["平仄"].toStdMap())
            {
                // if(key.contains("通") || key.contains("？"))
                //     continue;

                if(key.size() != pz.size())
                    continue;

                bool match = false;
                for(int i = 0; i < key.size(); i ++)
                {
                    if(key[i] != pz[i] && pz[i] != "通")
                    {
                        match = true;
                        break;
                    }
                }
                if(!match)
                    jumap_search["平仄"] += val;
            }
        }
        else
        {
            for(auto const &[key, val] : to_jubiao["平仄"].toStdMap())
            {
                if(key.size() != pz.size())
                    continue;

                bool match = false;
                for(int i = 0; i < key.size(); i ++)
                {
                    if(key[i] != pz[i] && pz[i] != "通")
                    {
                        match = true;
                        break;
                    }
                }
                if(!match)
                    jumap_search["平仄"] += val;
            }
        }
    }

    if(index != "")
    {
        auto indexes = splitNums(index);
        for(auto const &[key, val] : to_jubiao["句序"].toStdMap())
            for(auto &index : indexes)
                if(key == index)
                    jumap_search["句序"] += val;
    }

    QSet<int> juSet;
    bool begin = false;

    for(auto &lst : jumap_search)
    {
        if(!begin)
        {
            juSet = QSet<int>(lst.begin(), lst.end());
            begin = true;
        }
        else
        {
            juSet.intersect(QSet<int>(lst.begin(), lst.end()));
        }
    }

    if(juSet.empty())
    {
        for(int i=0; i<jubiao.size(); i++)
            juSet.insert(i);
    }

    QList<int> lines;
    for(auto &index : juSet)
    {
        auto &ju = jubiao[index];
        auto &id = jubiao[index][jubiao_header["id"]];
        auto &poem = qts[id];

        if(title != "" && poem[qts_header["題目"]] != title)
        {
            continue;
        }

        if(author != "" && poem[qts_header["作者"]] != author)
        {
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

        if(!ticais.empty() && !ticais.contains(poem[qts_header["體裁"]]))
        {
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
    QMap<QString, QString> ret;
    for(auto &[key, val] : qts_header.toStdMap())
        ret[key] = poem[val];

    emit searchEnd(ret);
}
