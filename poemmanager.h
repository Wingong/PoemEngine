#ifndef POEMMANAGER_H
#define POEMMANAGER_H

#include <QObject>
#include <QMap>
#include <QVariant>
#include <QQueue>
#include <QDebug>

enum VariantType
{
    XVariant,
    TradSimp,
};

// Trie 树节点
template <typename T>
struct TrieNode
{
    TrieNode(const T &emptyValue = T()) : data(emptyValue) {}
    QHash<QChar, TrieNode<T>*> children;
    T data; // 如果 data >= 0，则这个 key 指向对应的 data ，否则不指向。
};

// Trie 树
template <typename T>
class Trie
{
public:
    TrieNode<T>* root;
    const T emptyValue;

    // 构造函数
    Trie(const T &emptyValue = T())
        : root(new TrieNode<T>(emptyValue))
        , emptyValue(emptyValue)
    {}

    // 插入一个key
    void insert(const QString& key, const T &data) {
        auto node = root;
        for (const QChar& ch : key) {
            auto &child = node->children[ch];
            if (!child) {
                child = new TrieNode<T>(emptyValue);
            }
            node = child;
        }
        node->data = data;
    }

    T &operator[](const QString &key) {
        auto node = root;
        for (const QChar& ch : key) {
            auto &child = node->children[ch];
            if (!child) {
                child = new TrieNode<T>(emptyValue);
            }
            node = child;
        }
        return node->data;
    }

    // 查询data
    bool contains(const QString &key)
    {
        auto node = root;
        for (const QChar& ch : key) {
            auto it = node->children.find(ch);
            if (it == node->children.end()) {
                return false;
            }
            node = node->children[ch];
        }
        return node->data != emptyValue;
    }
};

template <typename T>
using PSet = QSet<T>*;

template <typename T>
using TriePSet = Trie<PSet<T>>;

template <typename T>
using NodePSet = TrieNode<PSet<T>>;

template <typename T>
inline QDebug operator<<(QDebug debug, const TriePSet<T> &obj) {
    QDebugStateSaver saver(debug); // 避免污染状态
    debug.nospace() << "Trie{";
    QQueue<std::pair<QString, NodePSet<T>*>> queue;
    queue.enqueue(std::make_pair("", obj.root));
    QString key = "";
    while(!queue.isEmpty())
    {
        auto [key, node] = queue.dequeue();
        if(node->data != obj.emptyValue)
            debug << key << ": " << *(node->data) << ", ";
        for(auto it = node->children.constBegin(); it != node->children.constEnd(); ++it)
        {
            queue.enqueue({key + it.key(), it.value()});
        }
    }
    debug << "}";
    return debug;
}

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
        data[id] = lineData;
        return std::make_pair(id, data[id]);
    }

    const auto &headers() const {return fieldToCol;}
    const QStringList &operator[](const QString &id) const {return data.find(id).value();}
    const int &operator()(const QString &field) const {return fieldToCol.find(field).value();}
    const QString &operator()(const QString &id, const QString &field) const {return data.find(id).value().at(fieldToCol.value(field));}
    const int &mapToCol(const QString &field) const {return fieldToCol.find(field).value();}

    auto begin() const {return data.begin();}
    auto end() const {return data.end();}

    auto size() const {return data.size();}

private:
    int id_col = -1;
    QHash<QString, int> fieldToCol;
    QHash<QString, QStringList> data;
};

class PoemManager : public QObject
{
    Q_OBJECT
public:
    explicit PoemManager(QObject *parent = nullptr);
    QStringList splitNums(const QString &str);
    QStringList splitString(const QString &str);

    // 标题名
    static QStringList dataHeader;
    // 标题变量名，作为Role Names
    static QStringList dataHeaderVar;
    // 可查询项
    static QStringList queryFieldsJu;
    static QStringList queryFieldsPoem;
public slots:
    void load(const QString &qts_path = "://data/qts.csv",
              const QString &psy_path = "://data/psy-map.json",
              const QString &psy_yunbu_path = "://data/psy-yunbu.json",
              const QString var_path = "://data/unihan-extend.json");

    void onQuery(const QVariantList &values, const QVariantList &stricts);
    void onSearchById(const QString &id);
    QString searchYunsByZi(const QChar &zi);
signals:
    void debug(const QString information);
    void loadEnd(int lines);
    void progSet(const QString &format, int max);
    void progVal(int val);
    void dataHeaderLoaded(const QStringList &header, const QStringList &headerVar, const QList<QStringList> &result);
    void dataLoaded(const QList<QStringList> &result);
    void queryEnd(const QList<int> &lines);
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
    QList<std::pair<QString, int>> jubiao;
    QHash<QString, TriePSet<qsizetype>> mapToJubiao;
    QHash<QString, TriePSet<QString>> mapToQts;

    // QMap<QString, QMap<QString, std::pair<Trie<>, QList<int>>>> to_jubiao;

    QMap<QChar, QString> psy_tab;
    QMap<QChar, QVariantMap> psy_yunbu;
    QMap<QChar, QString> xvariants;
    QMap<QChar, QString> tradsimps;
};

#endif // POEMMANAGER_H
