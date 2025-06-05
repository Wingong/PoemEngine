#ifndef JUPROXYMODEL_H
#define JUPROXYMODEL_H

#include <QSortFilterProxyModel>
#include "poemmanager.h"

class JuProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

public:
    using CompareFunction = std::function<bool(const QVariant &, const QVariant &)>;

    explicit JuProxyModel(QObject *parent = nullptr)
        : QSortFilterProxyModel(parent)
    {}

    void setFilter(const QList<qsizetype> &lines)
    {
        this->m_lines = QSet<qsizetype>(lines.begin(), lines.end());
        this->invalidateFilter();
    }

    void setSort(QList<std::pair<int, bool> > sortFields)
    {
        qCritical() << "C++ DEBUG:" << __func__ << ":" << sortFields;
        m_sortFields = sortFields;
        // for(auto &i : sortCols)
        //     qCritical() << data(index(10, 0), Qt::UserRole + i);
        beginResetModel();
        this->sort(0);
        endResetModel();
    }

protected:
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override {
        // qDebug() << source_left << source_right;
        bool ok;

        for(auto &field : m_sortFields)
        {
            auto col = field.first + Qt::UserRole + 1;
            auto asc = field.second;

            auto leftData = sourceModel()->data(source_left, col).toString();
            auto rightData = sourceModel()->data(source_right, col).toString();

            if(leftData == rightData)
            {
                auto left_id = sourceModel()->data(source_left, 8+Qt::UserRole+1).toString();
                auto right_id = sourceModel()->data(source_right, 8+Qt::UserRole+1).toString();

                if(col != 0+Qt::UserRole+1 || left_id == right_id)
                    continue;

                // qCritical() << "C++ DEBUG:" << __func__ << ":" << left_id << right_id;

                return asc ^ (left_id > right_id);
            }

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
    QSet<qsizetype> m_lines;
    // QList<int> m_sortCols = {1, 0, 6};
    // QList<bool> m_ascs = {true, true, true};
    QList<std::pair<int, bool>> m_sortFields = {};
};

#endif // JUPROXYMODEL_H
