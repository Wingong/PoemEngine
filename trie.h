#ifndef TRIE_H
#define TRIE_H

#include <QString>
#include <QSet>
#include <QDebug>

template<typename T>
concept QSetType = requires{
    requires std::is_same_v<T, QSet<typename T::value_type>>;
};

// Trie 树节点
template <typename T>
struct TrieNode
{
    TrieNode(const T &emptyValue = T()) : data(emptyValue) {}
    QHash<QChar, TrieNode<T>*> children;
    bool end = false;
    bool complete = false;
    T data; // 如果 data >= 0，则这个 key 指向对应的 data ，否则不指向。
};

// Trie 树
template <typename T>
class Trie
{
public:
    TrieNode<T>* root;
    const T emptyValue;
    qsizetype size;

    // 构造函数
    Trie(const T &emptyValue = T())
        : root(new TrieNode<T>(emptyValue))
        , emptyValue(emptyValue)
        , size(1)
    {}

    // 插入一个key
    void insert(const QString& key, const T &data) {
        auto node = root;
        for (const QChar& ch : key) {
            auto &child = node->children[ch];
            if (!child) {
                child = new TrieNode<T>(emptyValue);
                size ++;
            }
            node = child;
        }
        node->data = data;
        node->end = true;
    }

    TrieNode<T> &operator[](const QString &key) {
        auto node = root;
        for (const QChar& ch : key) {
            auto &child = node->children[ch];
            if (!child) {
                child = new TrieNode<T>(emptyValue);
                size ++;
            }
            node = child;
        }
        node->end = true;
        return *node;
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
        return node->end;
    }

    T findAll(const QString &key)
        requires QSetType<T>
    {
        T ret;
        auto node = root;
        for (const QChar& ch : key) {
            auto it = node->children.find(ch);
            qCritical() << QString(ch) << (it == node->children.end());
            if (it == node->children.end()) {
                return ret;
            }
            // qCritical() << ch << node->children;
            node = node->children[ch];
        }
        ret = node->data;
        // qCritical() << key << node->data << node->end;

        // if(!node->end)
        // {
            auto list = trieEndList(node);
            for(auto &[key, node] : list)
            {
                ret |= node->data;
            }
        // }
        qCritical() << key << node->data;

        return ret;
    }
};

// 获取Trie的有效节点列表
template <typename T>
QList<std::pair<QString, TrieNode<T>*>> trieEndList(TrieNode<T> *root)
{
    QList<std::pair<QString, TrieNode<T>*>> ret;
    QQueue<std::pair<QString, TrieNode<T>*>> queue;
    queue.enqueue({"", root});
    QString key = "";
    while(!queue.isEmpty())
    {
        auto [key, node] = queue.dequeue();
        if(node->end)
            ret.append({key, node});
        for(auto it = node->children.constBegin(); it != node->children.constEnd(); ++it)
        {
            queue.enqueue({key + it.key(), it.value()});
        }
    }
    return ret;
}

template <typename T>
inline QDebug operator<<(QDebug debug, const Trie<T> &obj) {
    QDebugStateSaver saver(debug); // 避免污染状态
    debug.nospace() << "Trie{";
    auto list = trieEndList(obj);
    for(auto &[key, node] : list)
    {
        debug << key << ": " << *(node->data) << ", ";
    }
    debug << "}";
    return debug;
}

template <typename T>
inline QDebug operator<<(QDebug debug, const TrieNode<T> &node) {
    QDebugStateSaver saver(debug); // 避免污染状态
    debug.nospace() << "TrieNode{";
    debug << node.complete << ", " << node.end << ", " << node.children << ", " << node.data << "}";
    return debug;
}

#endif // TRIE_H
