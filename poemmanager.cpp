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
const QStringList PoemManager::dataHeadersPoem = {"題目", "作者", "言數", "句數", "體裁", "韻腳"};
const QStringList PoemManager::dataHeadersVarPoem = {"title", "author", "yan", "jushu", "ticai", "yun"};

const QStringList PoemManager::dataHeader = dataHeadersPoem + dataHeadersJu;
const QStringList PoemManager::dataHeaderVar = dataHeadersVarPoem + dataHeadersVarJu;

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
        QMap<QString, qsizetype> field_2_csvCol_Poem;
        QMap<qsizetype, qsizetype> dataCol_2_csvCol_Poem;
        QMap<QString, qsizetype> field_2_dataCol_Ju;

        // csv，诗，字段 - 列号映射
        for(auto it = csvField_2_csvCol.constBegin(); it != csvField_2_csvCol.constEnd(); ++it)
        {
            if (dataHeadersPoem.contains(it.key()))
                field_2_csvCol_Poem[it.key()] = it.value();
        }

        for (int i=0; i<dataHeader.size(); i++)
        {
            // 诗，data列 - csv列映射
            if(field_2_csvCol_Poem.contains(dataHeader[i]))
                dataCol_2_csvCol_Poem[i] = field_2_csvCol_Poem[dataHeader[i]];

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

        QList<QStringList> data;
        qsizetype colNum = dataHeader.size();

        t0 = QDateTime::currentMSecsSinceEpoch();
        for(const auto &line : lines)
        {
            // 使用逗号分割每一行的数据
            auto [poemIndex, poem] = qts.emplace_back(line.split(',', Qt::KeepEmptyParts));

            // 诗映射
            for(auto &[field, col] : field_2_csvCol_Poem.toStdMap())
            {
                // 完整句
                auto &dat = poem[col];
                auto &node = mapToQts[field][dat];
                node.data.insert(poemIndex);
                node.complete = true;

                // 后缀子句
                for(int i=1; i<dat.size(); i++)
                {
                    auto &node = mapToQts[field][dat.right(i)];
                    node.data.insert(poemIndex);
                }
            }

            // 制作句表
            auto jus = poem[ju_col].split('|');
            auto pzs = poem[pz_col].split('|');
            for(int i=0; i<jus.size(); i ++)
            {
                auto ju = jus[i].chopped(1);
                auto pz = pzs[i];
                auto juind = QString::number(i);

                qsizetype index = jubiao.size();
                jubiao.emplace_back(poemIndex, i);


                QStringList dataLine(colNum);

                // 句映射
                {
                    auto &node = mapToJubiao["詩句"][ju];
                    node.data.insert(index);
                    // 后缀子句
                    for(int i=1; i<ju.size(); i++)
                    {
                        auto &node = mapToJubiao["詩句"][ju.right(i)];
                        node.data.insert(index);
                    }
                    dataLine[field_2_dataCol_Ju["詩句"]] = ju;
                }

                {
                    auto &node = mapToJubiao["平仄"][pz];
                    node.data.insert(index);
                    dataLine[field_2_dataCol_Ju["平仄"]] = pz;
                }

                {
                    auto &node = mapToJubiao["句序"][juind];
                    node.data.insert(index);
                    dataLine[field_2_dataCol_Ju["句序"]] = juind;
                }

                // 制作数据行，遍历 poem 和 ju 表头的键
                for(const auto &[colData, colCsv] : dataCol_2_csvCol_Poem.toStdMap())
                {
                    dataLine[colData] = poem[colCsv];
                }

                data.append(dataLine);

                if(data.size() >= 1000)
                {
                    emit dataLoaded(data);
                    data.clear();
                }
            }

            int len = qts.size();
            if((len % 100) == 0)
            {
                // for(auto it = mapToJubiao.constBegin(); it != mapToJubiao.constEnd(); ++it)
                // {
                //     qCritical() << it.key() << it.value();
                // }
                // for(auto it = mapToQts.constBegin(); it != mapToQts.constEnd(); ++it)
                // {
                //     qCritical() << it.key() << it.value();
                // }
                // qCritical() << mapToJubiao;
                // break;
                emit progSet(tr("读取全唐诗……%1 首，%2 句").arg(len).arg(jubiao.size()), 0);
            }
        }

        qCritical() << "句表构建" << double(QDateTime::currentMSecsSinceEpoch() - t0)/1000 << "s";

        qCritical() << "句表" << jubiao[9999] << qts[jubiao[9999].first];
        qCritical() << "句表" << (mapToJubiao["詩句"]["歌聲且潛弄"]);

        for(auto it = mapToJubiao.constBegin(); it != mapToJubiao.constEnd(); ++it)
        {
            QDebug debug(qDebug());
            QDebugStateSaver saver(debug); // 避免污染状态
            debug.nospace() << it.key() << it.value().size << "Trie{";
            auto list = trieEndList(it.value().root);
            for(auto &[key, node] : list)
            {
                debug << key << ", ";
            }
            debug << "}";
        }
        for(auto it = mapToQts.constBegin(); it != mapToQts.constEnd(); ++it)
        {
            QDebug debug(qDebug());
            QDebugStateSaver saver(debug); // 避免污染状态
            debug.nospace() << it.key() << it.value().size << "Trie{";
            auto list = trieEndList(it.value().root);
            for(auto &[key, node] : list)
            {
                debug << key << ", ";
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

    auto yans = splitNums(yan);
    auto shus = splitNums(shu);
    auto indexes = splitNums(index);

    auto authors = splitString(author);
    auto pzs = splitString(pz);
    auto ticais = splitString(ticai);

    auto titles = splitString(title);
    auto jus = splitString(ju);

    auto t0 = QDateTime::currentMSecsSinceEpoch();

    if(!jus.isEmpty())
    {
        jumap_search["詩句"].clear();
        QSet<qsizetype> set;
        for(auto &ju: jus)
        {
            set |= mapToJubiao["詩句"].findAll(ju);
        }
        // qCritical() << set << jubiao[(*set.constBegin())] << qts[jubiao[(*set.constBegin())].first];
        juIndexSet = set;
    }

    qCritical() << "Trie子串搜索" << double(QDateTime::currentMSecsSinceEpoch()-t0)/1000 << "s";

    // if(!pzs.isEmpty())
    // {
    //     jumap_search["平仄"].clear();
    //     if(strict_pz)
    //     {
    //         for(auto &pz : pzs)
    //         {
    //             for(auto const &[key, val] : to_jubiao["平仄"].toStdMap())
    //             {
    //                 // if(key.contains("通") || key.contains("？"))
    //                 //     continue;

    //                 if(key.size() != pz.size())
    //                     continue;

    //                 bool notmatch = false;
    //                 for(int i = 0; i < key.size(); i ++)
    //                 {
    //                     if(key[i] != pz[i] && pz[i] != "通")
    //                     {
    //                         notmatch = true;
    //                         break;
    //                     }
    //                 }
    //                 if(!notmatch)
    //                     jumap_search["平仄"] += QSet<int>(val.begin(), val.end());
    //             }
    //         }
    //     }
    //     else
    //     {
    //         for(auto &pz : pzs)
    //         {
    //             for(auto const &[key, val] : to_jubiao["平仄"].toStdMap())
    //             {
    //                 if(key.size() != pz.size())
    //                     continue;

    //                 bool notmatch = false;
    //                 for(int i = 0; i < key.size(); i ++)
    //                 {
    //                     if(key[i] != pz[i] && pz[i] != "通" && key[i] != "通")
    //                     {
    //                         notmatch = true;
    //                         break;
    //                     }
    //                 }
    //                 if(!notmatch)
    //                     jumap_search["平仄"] += QSet<int>(val.begin(), val.end());
    //             }
    //         }
    //     }
    // }

    // if(!indexes.isEmpty())
    // {
    //     jumap_search["句序"].clear();
    //     for(auto const &[key, val] : to_jubiao["句序"].toStdMap())
    //         for(auto &index : indexes)
    //             if(key == index)
    //                 jumap_search["句序"] += QSet<int>(val.begin(), val.end());
    // }

    // QSet<int> juSet;

    // bool empty = false;
    // for(auto &[key, val] : jumap_search.toStdMap())
    // {
    //     empty = true;
    //     if(!val.isEmpty())
    //     {
    //         empty = false;
    //         break;
    //     }
    // }

    // if(!empty)
    // {
    //     for(int i=0; i<jubiao.size(); i++)
    //         juSet.insert(i);
    // }

    // for(auto &set : jumap_search)
    // {
    //     juSet.intersect(set);
    // }

    // // qCritical() << juSet.size() << strict_title << titles << values << stricts;
    // // qCritical() << strict_title << poem[qts_header["題目"]] << titles;

    // QList<int> lines;
    // for(auto &index : juSet)
    // {
    //     auto &ju = jubiao[index];
    //     auto &id = jubiao[index][jubiao_header["id"]];
    //     auto &poem = qts[id];

    //     if(!titles.isEmpty())
    //     {
    //         bool cont = true;
    //         for(auto &title : titles)
    //         {
    //             if(strict_title && poem[qts_header["題目"]] == title)
    //             {
    //                 cont = false;
    //                 break;
    //             }
    //             else if(!strict_title && poem[qts_header["題目"]].contains(title))
    //             {
    //                 cont = false;
    //                 break;
    //             }
    //         }
    //         if(cont)
    //             continue;
    //     }

    //     if(!authors.isEmpty())
    //     {
    //         bool cont = true;
    //         for(auto &author : authors)
    //         {
    //             if(strict_author && poem[qts_header["作者"]] == author)
    //             {
    //                 cont = false;
    //                 break;
    //             }
    //             else if(!strict_author && poem[qts_header["作者"]].contains(author))
    //             {
    //                 cont = false;
    //                 break;
    //             }
    //         }
    //         if(cont)
    //             continue;
    //     }

    //     if(!yans.empty() && !yans.contains(poem[qts_header["言數"]]))
    //     {
    //         continue;
    //     }

    //     if(!shus.empty() && !shus.contains(poem[qts_header["句數"]]))
    //     {
    //         continue;
    //     }

    //     if(!ticais.isEmpty())
    //     {
    //         bool cont = true;
    //         for(auto &ticai : ticais)
    //         {
    //             if(strict_ticai && poem[qts_header["體裁"]] == ticai)
    //             {
    //                 cont = false;
    //                 break;
    //             }
    //             else if(!strict_ticai && poem[qts_header["體裁"]].contains(ticai))
    //             {
    //                 cont = false;
    //                 break;
    //             }
    //         }
    //         if(cont)
    //             continue;
    //     }
    //     lines.append(index);
    // }

    emit queryEnd(juIndexSet.values());
    emit progSet(tr("結果數量：%1句").arg(juIndexSet.size()), 0);
}

void PoemManager::onSearchById(const QString &id)
{
    // TO_FIX
    // auto poem = qts[id];
    // QVariantMap ret;
    // for(auto &[key, val] : qts_header.toStdMap())
    //     ret[key] = poem[val];

    // QVariantMap yuns_map;

    // for(auto &zi : ret["內容"].toString())
    // {
    //     if (!yuns_map.contains(zi))
    //     {
    //         yuns_map[zi] = searchYunsByZi(zi);
    //     }
    // }

    // ret["韻目"] = yuns_map;

    // emit searchEnd(ret);
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
