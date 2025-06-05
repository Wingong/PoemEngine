#ifndef POEMMANAGER_H
#define POEMMANAGER_H

#include <QObject>
#include <QMap>
#include <QVariant>
#include <QQueue>
#include <QDebug>
#include "trie.h"

enum VariantType
{
    XVariant,
    TradSimp,
};

template <typename T>
using Set = QSet<T>;

template <typename T>
using TrieSet = Trie<Set<T>>;

template <typename T>
using NodeSet = TrieNode<Set<T>>;

// 诗歌表格
class PoemsTable
{
public:
    void clear()
    {
        id_col = -1;
        fieldToCol.clear();
        data.clear();
    }
    void setHeaders(const QStringList &fields)
    {
        clear();
        for (int i=0; i<fields.size(); i++)
        {
            fieldToCol[fields[i]] = i;
            if(fields[i] == "id")
                id_col = i;
        }
    }
    auto emplace_back(const QStringList &line)
    {
        bool isInt, isDouble;
        QVariant num;
        QStringList lineData;
        QString id;
        for(int i=0; i<line.size(); i++)
        {
            auto &field = line[i];
            if(i == id_col)
            {
                id = field;
            }
            // if(field.contains('|'))
            //     lineData.append(field.split('|'));
            // else
            // {
            //     num = field.toInt(&isInt);
            //     if(isInt)
            //         lineData.append(num);
            //     else
            //     {
            //         num = field.toDouble(&isDouble);
            //         if(isDouble)
            //             lineData.append(num);
            //         else
            //             lineData.append(field);
            //     }
                lineData.append(field);
            // }
        }
        qsizetype index = data.size();
        data.append(lineData);
        return std::make_pair(index, lineData);
    }

    const auto &headers() const {return fieldToCol;}
    const QStringList &operator[](int index) const {return data[index];}
    const int &operator()(const QString &field) const {return fieldToCol.find(field).value();}
    const QString &operator()(int index, const QString &field) const {return data[index][fieldToCol.value(field)];}
    const int &mapToCol(const QString &field) const {return fieldToCol.find(field).value();}

    auto begin() const {return data.begin();}
    auto end() const {return data.end();}

    auto size() const {return data.size();}

private:
    int id_col = -1;
    QHash<QString, int> fieldToCol;
    QList<QStringList> data;
};

class PoemManager : public QObject
{
    Q_OBJECT
public:
    explicit PoemManager(QObject *parent = nullptr);
    QStringList splitNums(const QString &str);
    QStringList splitString(const QString &str);

    // 标题名
    const static QStringList dataHeader;
    // 标题变量名，作为Role Names
    const static QStringList dataHeaderVar;
    // 可查询项
    const static QStringList dataHeadersJu;
    const static QStringList dataHeadersVarJu;
    const static QStringList dataHeadersPoem;
    const static QStringList dataHeadersVarPoem;
public slots:
    void load(const QString &qts_path = "://data/qts.csv",
              const QString &psy_path = "://data/psy-map.json",
              const QString &psy_yunbu_path = "://data/psy-yunbu.json",
              const QString var_path = "://data/unihan-extend.json");

    void onQuery(const QVariantList &values, const QVariantList &stricts, bool varSearch);
    void onSearchById(const QString &id);
    QString searchYunsByZi(const QChar &zi);
signals:
    void debug(const QString information);
    void loadEnd(int lines);
    void progSet(const QString &format, int max);
    void progVal(int val);
    void dataHeaderLoaded(const QStringList &header, const QStringList &headerVar);
    void dataLoaded(const QList<QStringList> &result);
    void queryEnd(const QList<qsizetype> &lines);
    void searchEnd(const QVariantMap &poem);
    void yunsSearchEnd(const QList<QVariantMap> &yuns);

private:
    bool contains(bool strict, const QStringList &patterns, const QString &source)
    {
        if(!patterns.isEmpty())
        {
            for(auto &pattern : patterns)
            {
                if(strict && source == pattern)
                    return true;
                if(!strict && source.contains(pattern))
                    return true;
            }
            return false;
        }
        return true;
    }

    PoemsTable qts;
    QList<std::pair<qsizetype, qsizetype>> jubiao;
    QHash<QString, TrieSet<qsizetype>> mapToJubiao;
    QHash<QString, TrieSet<qsizetype>> mapToQts;

    // QMap<QString, QMap<QString, std::pair<Trie<>, QList<int>>>> to_jubiao;

    QMap<QChar, QString> psy_tab;
    QMap<QChar, QVariantMap> psy_yunbu;
    QMap<QChar, QString> xvariants;
    QMap<QChar, QString> tradsimps;
};

#endif // POEMMANAGER_H
