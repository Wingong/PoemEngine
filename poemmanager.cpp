#include "poemmanager.h"
#include <QThread>

#include <QFile>
#include <QDebug>
#include <QRegularExpression>
#include <QSet>
#include <QJsonDocument>
#include <QPair>
#include <QDateTime>

const QStringList PoemManager::dataHeadersJu = {"詩句", "句序", "平仄"};
const QStringList PoemManager::dataHeadersVarJu = {"ju", "juind", "pz"};
const QStringList PoemManager::dataHeadersPoem = {"題目", "作者", "言數", "句數", "體裁", "韻腳", "id"};
const QStringList PoemManager::dataHeadersVarPoem = {"title", "author", "yan", "jushu", "ticai", "yun", "id"};

const QStringList PoemManager::dataHeader = dataHeadersPoem + dataHeadersJu;
const QStringList PoemManager::dataHeaderVar = dataHeadersVarPoem + dataHeadersVarJu;

PoemManager::PoemManager(QObject *parent)
    : QObject{parent}
{
}

QList<QStringList> PoemManager::splitString(const QString &str, bool var)
{
    static QRegularExpression rSep("[,，; \t]+");

    auto lst = str.split(rSep);
    QList<QStringList> ret;
    lst = QSet<QString>(lst.begin(), lst.end()).values();
    for(auto &key : lst)
    {
        QStringList ziList;
        if(key == "")
            continue;
        for(auto &zi : key)
        {
            ziList.append(zi);
            if(var)
            {
                ziList.last() += xvariants[zi];
                ziList.last() += tradsimps[zi];
            }
        }
        ret.append(ziList);
    }
    return ret;
}

QList<QStringList> PoemManager::splitNums(const QString &str)
{
    static QRegularExpression rMinus("^(\\d+)\\s*-\\s*(\\d+)$"), rSep("[,，; \t]+");
    bool ok;

    auto indSep = str.split(rSep);
    QSet<QStringList> indexes;

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
                    indexes.insert({QString::number(i)});
            }
        }

        i.toInt(&ok);
        if(ok)
            indexes.insert({i});

    }

    return indexes.values();
}

void PoemManager::load(const QString &qts_path, const QString &psy_path, const QString &psy_yunbu_path, const QString var_path)
{
    QSet<std::pair<QString, int>> a;

    {
        emit progSet(tr("读取全唐诗……"), 0);
        QFile file(qts_path);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            qWarning() << "无法打开文件:" << file.errorString();
            emit progSet(tr("无法打开文件 ") + qts_path + file.errorString(), 0);
            return;
        }

        QTextStream in(&file);

        // 读入首行标题
        QString lineHeader = in.readLine();
        qts.setHeaders(lineHeader.split(',', Qt::KeepEmptyParts));


        int ju_col = qts("內容");
        int pz_col = qts("平仄");
        auto &csvField_2_csvCol = qts.headers();
        qCritical() << csvField_2_csvCol;
        QMap<QString, std::pair<qsizetype, qsizetype>> field_2_datCol_csvCol_Poem, field_2_datCol_csvCol_Ju;
        QMap<QString, qsizetype> field_2_dataCol_Ju;

        // csv，诗，字段 - 列号映射
        for(auto &[field, col] : csvField_2_csvCol.toStdMap())
        {
            if (dataHeadersPoem.contains(field))
                field_2_datCol_csvCol_Poem[field] = std::make_pair(dataHeader.indexOf(field), col);
        }

        for(int i=0; i<dataHeadersJu.size(); i++)
        {
            field_2_datCol_csvCol_Ju[dataHeadersJu[i]] = std::make_pair(dataHeadersPoem.size()+i, i);
        }

        qCritical() << "field_2_datCol_csvCol_Poem" << field_2_datCol_csvCol_Poem;

        for (int i=0; i<dataHeader.size(); i++)
        {
            // 句，字段 - data列映射
            if(dataHeadersJu.contains(dataHeader[i]))
                field_2_dataCol_Ju[dataHeader[i]] = i;
        }

        emit dataHeaderLoaded(dataHeader, dataHeaderVar);

        qint64 t0;
        t0 = QDateTime::currentMSecsSinceEpoch();
        QStringList lines;
        while (!in.atEnd()) {
            lines.append(in.readLine());
        }
        file.close();
        qCritical() << "文件读取：" << double(QDateTime::currentMSecsSinceEpoch() - t0)/1000 << "s";

        QList<QStringList> juTable;
        jubiaoSize = 0;
        qsizetype colNum = dataHeader.size();

        t0 = QDateTime::currentMSecsSinceEpoch();
        for(const auto &line : lines)
        {
            // 使用逗号分割每一行的数据
            auto [poemIndex, poem] = qts.emplace_back(line.split(',', Qt::KeepEmptyParts));

            // 制作句表

            // 制作句三元素列表
            QList<QStringList> dataPerJu(dataHeadersJu.size());

            auto jus = poem[ju_col].split('|');

            if(jus.size() == 1 && jus[0] == "")
            {
                jus.clear();
            }
            else
            {

                for(int i=0; i<jus.size(); i++)
                {
                    dataPerJu[0].append(!jus[i].isEmpty() ? jus[i].chopped(1) : "");
                    dataPerJu[1].append(QString::number(i+1));
                }

                dataPerJu[2] = poem[pz_col].split('|');
            }

            for(int i=0; i<jus.size(); i ++)
            {
                QStringList dataLine(colNum);

                // 诗映射
                for(auto &[field, cols] : field_2_datCol_csvCol_Poem.toStdMap())
                {
                    // 完整句
                    auto &dat = poem[cols.second];
                    auto dat_size = dat.size();
                    auto &sets = mapToJubiao[field];
                    if(sets.size() < dat_size)
                        sets.resize(dat_size);

                    // 逐字插入
                    for (int i=0; i<dat_size-1; i++)
                    {
                        sets[i][dat[i]].insert(jubiaoSize);
                    }

                    // 末字负数
                    if(dat_size > 0)
                        sets[dat_size-1][dat[dat_size-1]].insert(-jubiaoSize-1);

                    // 插入数据行
                    dataLine[cols.first] = dat;

                }

                // 句映射
                for(auto &[field, cols] : field_2_datCol_csvCol_Ju.toStdMap())
                {
                    // 完整句
                    auto &dat = dataPerJu[cols.second][i];
                    auto dat_size = dat.size();
                    auto &sets = mapToJubiao[field];

                    if(sets.size() < dat_size)
                        sets.resize(dat_size);

                    // 逐字插入
                    for (int i=0; i<dat_size-1; i++)
                    {
                        sets[i][dat[i]].insert(jubiaoSize);
                    }
                    // 末字负数
                    sets[dat_size-1][dat[dat_size-1]].insert(-jubiaoSize-1);

                    // 插入数据行
                    dataLine[cols.first] = dat;
                }

                // qCritical() << "句映射" << field_2_datCol_csvCol_Ju << i << dataLine;

                juTable.append(dataLine);
                jubiaoSize ++;

                if(juTable.size() >= 1000)
                {
                    emit dataLoaded(juTable);
                    juTable.clear();
                }
            }

            int len = qts.size();
            if((len % 100) == 0)
            {
                emit progSet(tr("读取全唐诗……%1 首，%2 句").arg(len).arg(jubiaoSize), 0);
            }
        }

        qCritical() << "句表构建" << double(QDateTime::currentMSecsSinceEpoch() - t0)/1000 << "s";
        for(auto it = mapToJubiao.constBegin(); it != mapToJubiao.constEnd(); ++it)
        {
            QDebug debug(qDebug());
            QDebugStateSaver saver(debug); // 避免污染状态
            debug << it.key() << it.value().size() << "Sets{";
            for(int i=0; i<it.value().size(); i++)
            {
                debug << it.value()[i].size() << ", ";
            }
            debug << "}";
        }
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

void PoemManager::onQuery(const QVariantList &values, const QVariantList &stricts, bool varSearch)
{
    auto setAt = [&](const QString &field, qsizetype i, const QString &keyVars, bool end = false)
    {
        QSet<qsizetype> ret;
        for(auto &key : keyVars)
        {
            if (key == '*')
            {
                for (auto &set_c : mapToJubiao[field][i])
                {
                    for(auto &val : set_c)
                    {
                        if (val > 0 && !end)
                            ret.insert(val);
                        else if (val < 0)
                            ret.insert(-val-1);
                    }
                }
            }
            else
            {
                for(auto &val : mapToJubiao[field][i][key])
                {
                    if (val > 0 && !end)
                        ret.insert(val);
                    else if (val < 0)
                        ret.insert(-val-1);
                }
            }
        }
        return ret;
    };

    auto match = [&](const QList<QStringList> &keys, const QString field)
    {
        QSet<qsizetype> set;
        if(!keys.isEmpty())
        {
            for(auto &key: keys)
            {
                for(int begin_i=0; begin_i<mapToJubiao[field].size()-key.size()+1; begin_i++)
                {
                    if(!key.isEmpty())
                    {
                        QSet<qsizetype> set_sub = setAt(field, begin_i, key[0]);
                        for(int i=1; i<key.size(); i++)
                        {
                            set_sub &= setAt(field, i+begin_i, key[i]);
                            if(set_sub.isEmpty())
                                break;
                        }
                        set |= set_sub;
                    }
                }
                qDebug() << key;
            }
            // qCritical() << set << jubiao[(*set.constBegin())] << qts[jubiao[(*set.constBegin())].first];
        }
        return set;
    };

    auto fullMatch = [&](const QList<QStringList> &keys, const QString field)
    {
        QSet<qsizetype> set;
        if(!keys.isEmpty())
        {
            for(auto &key: keys)
            {
                if(!key.isEmpty())
                {
                    QSet<qsizetype> set_sub = setAt(field, 0, key[0]);
                    for(int i=1; i<key.size()-1; i++)
                    {
                        set_sub &= setAt(field, i, key[i]);
                        if(set_sub.isEmpty())
                            break;
                    }
                    set_sub &= setAt(field, key.size()-1, key[key.size()-1], true);
                    set |= set_sub;
                }
            }
            // qCritical() << set << jubiao[(*set.constBegin())] << qts[jubiao[(*set.constBegin())].first];
        }
        return set;
    };

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

    QSet<qsizetype> juIndexSet;
    QSet<qsizetype> juIndexSetTemp;

    auto yans = splitNums(yan);
    auto shus = splitNums(shu);
    auto indexes = splitNums(index);

    auto authors = splitString(author, varSearch);
    auto pzs = splitString(pz.replace("通", "*"), varSearch);
    auto ticais = splitString(ticai, varSearch);

    auto titles = splitString(title, varSearch);
    auto jus = splitString(ju, varSearch);
    qCritical() << jus;

    auto t0 = QDateTime::currentMSecsSinceEpoch();

    // 全集
    for(int i=0; i<jubiaoSize; i++)
        juIndexSet.insert(i);

    if(!pzs.isEmpty())
    {
        if(strict_pz)
            juIndexSetTemp = fullMatch(pzs, "平仄");
        else
        {
            juIndexSetTemp.clear();
            for(auto &key: pzs)
            {
                if(!key.isEmpty())
                {
                    QSet<qsizetype> set_sub = setAt("平仄", 0, key[0]);
                    set_sub |= setAt("平仄", 0, "通");
                    for(int i=1; i<key.size()-1; i++)
                    {
                        set_sub &= (setAt("平仄", i, key[i]) | setAt("平仄", i, "通"));
                        if(set_sub.isEmpty())
                            break;
                    }
                    set_sub &= (setAt("平仄", key.size()-1, key[key.size()-1], true) | setAt("平仄", key.size()-1, "通", true));
                    juIndexSetTemp |= set_sub;
                }
            }
        }
        juIndexSet &= juIndexSetTemp;
    }

    if(!jus.isEmpty())
    {
        if(strict_ju)
            juIndexSetTemp = fullMatch(jus, "詩句");
        else
            juIndexSetTemp = match(jus, "詩句");
        juIndexSet &= juIndexSetTemp;
    }

    if(!titles.isEmpty())
    {
        if(strict_title)
            juIndexSetTemp = fullMatch(titles, "題目");
        else
            juIndexSetTemp = match(titles, "題目");
        juIndexSet &= juIndexSetTemp;
    }

    if(!authors.isEmpty())
    {
        if(strict_author)
            juIndexSetTemp = fullMatch(authors, "作者");
        else
            juIndexSetTemp = match(authors, "作者");
        juIndexSet &= juIndexSetTemp;
    }

    if(!ticais.isEmpty())
    {
        if(strict_ticai)
            juIndexSetTemp = fullMatch(ticais, "體裁");
        else
            juIndexSetTemp = match(ticais, "體裁");
        juIndexSet &= juIndexSetTemp;
    }

    if(!yans.isEmpty())
    {
        juIndexSetTemp = fullMatch(yans, "言數");
        juIndexSet &= juIndexSetTemp;
    }

    if(!shus.isEmpty())
    {
        juIndexSetTemp = fullMatch(shus, "句數");
        juIndexSet &= juIndexSetTemp;
    }

    if(!indexes.isEmpty())
    {
        juIndexSetTemp = fullMatch(indexes, "句序");
        juIndexSet &= juIndexSetTemp;
    }


    qCritical() << "Trie子串搜索" << double(QDateTime::currentMSecsSinceEpoch()-t0)/1000 << "s" << juIndexSet;

    emit queryEnd(juIndexSet.values());
    emit progSet(tr("結果數量：%1句").arg(juIndexSet.size()), 0);
}

void PoemManager::onSearchById(const QString &index)
{
    qCritical() << index;
    auto poem = qts[index.toInt()];
    QVariantMap ret;
    for(auto &[field, col] : qts.headers().toStdMap())
        ret[field] = poem[col];

    ret["詩句"] = poem[qts("內容")].split('|');

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
