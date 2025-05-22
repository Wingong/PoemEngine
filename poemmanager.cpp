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
    emit progSet(QString("读取全唐诗……"), 0);
    QFile file(qts_path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "无法打开文件:" << file.errorString();
        emit progSet("无法打开文件 " + qts_path + file.errorString(), 0);
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
            emit progSet(QString("读取全唐诗……%1 首").arg(len), 0);
        }
    }

    file.close();

    emit progSet(QString("读取句表……"), 0);
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
        }
        else
        {
            jubiao.append(fields);
            int index = jubiao.size()-1;
            for(int i=0; i<fields.size()-1; i++)
            {
                to_jubiao[header[i]][fields[i]].append(index);
            }
        }

        int len = jubiao.size();
        if((len % 1000) == 0)
        {
            emit progSet(QString("读取句表……%1 句").arg(len), 0);
        }
    }

    f_jubiao.close();
    emit progEnd();
}

void PoemManager::onQuery(const QString &ju,
                          const QString &pz,
                          const QString &title,
                          const QString &author,
                          const QString &yan,
                          const QString &shu,
                          const QString &ticai,
                          const QString &index)
{
    emit progSet("检索中……", 0);

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
        for(auto const &[key, val] : to_jubiao["句"].toStdMap())
            if(key.contains(ju))
                jumap_search["句"] += val;
    }

    if(pz != "")
    {
        for(auto const &[key, val] : to_jubiao["平仄"].toStdMap())
        {
            if(key.contains("通") || key.contains("？"))
                continue;

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

    QStringList header;
    QList<QStringList> result;

    for(auto &key : qts_header.keys())
        if(key != "id")
            header.append(key);
    for(auto &key : jubiao_header.keys())
        if(key != "id")
            header.append(key);

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

        if(!yans.empty() && !yans.contains(poem[qts_header["言"]]))
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

        QStringList line;

        for(auto &key : qts_header.keys())
            if(key != "id")
                line.append(poem[qts_header[key]]);
        for(auto &key : jubiao_header.keys())
            if(key != "id")
                line.append(ju[jubiao_header[key]]);

        result.append(line);
    }

    emit searchEnd(header, result);
    emit progSet(QString("結果數量：%1句").arg(result.size()), 0);
}
