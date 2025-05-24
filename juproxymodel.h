#ifndef JUPROXYMODEL_H
#define JUPROXYMODEL_H

#include <QSortFilterProxyModel>

class JuProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

public:
    using CompareFunction = std::function<bool(const QVariant &, const QVariant &)>;

    explicit JuProxyModel(QObject *parent = nullptr)
        : QSortFilterProxyModel(parent)
    {}

    void setFilter(const QList<int> &lines)
    {
        this->m_lines = QSet<int>(lines.begin(), lines.end());
        this->invalidateFilter();
    }

    void setSort(const QList<int> &sortCols, const QList<bool> &ascs)
    {
        qCritical() << sortCols << ascs;
        m_sortCols = sortCols;
        m_ascs = ascs;
        for(auto &i : sortCols)
            qCritical() << data(index(10, 0), Qt::UserRole + i);
        beginResetModel();
        this->sort(0);
        endResetModel();
    }

protected:
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override {
        // qDebug() << source_left << source_right;
        bool ok;

        for(int i=0; i<m_sortCols.size(); i++)
        {
            auto col = m_sortCols[i]+Qt::UserRole+1;
            auto &asc = m_ascs[i];

            auto leftData = sourceModel()->data(source_left, col).toString();
            auto rightData = sourceModel()->data(source_right, col).toString();

            if(leftData == rightData)
                continue;

            auto leftVal = leftData.toInt(&ok);

            if(ok)
            {
                return asc ^ (leftVal > rightData.toInt());
            }

            return asc ^ (leftData > rightData);
        }

        return QSortFilterProxyModel::lessThan(source_left, source_right);  // 默认行为
    }

    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override {
        return m_lines.contains(sourceRow);
    }

private:
    QSet<int> m_lines;
    QList<int> m_sortCols = {1, 0, 6};
    QList<bool> m_ascs = {true, true, true};
};

#endif // JUPROXYMODEL_H
