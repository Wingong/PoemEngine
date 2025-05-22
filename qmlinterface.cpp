#include "qmlinterface.h"

QmlInterface::QmlInterface(QObject *parent)
    : QObject(parent)
{}

void QmlInterface::onTable(const QStringList &header, const QList<QStringList> &result)
{
    m_model.clear();
    // m_model.setColumnCount(header.size());
    // m_model.setHorizontalHeaderLabels(header);

    qCritical() << header << result;

    QHash<int, QByteArray> roles;
    for(int i=0; i<header.size(); i ++)
    {
        roles[Qt::UserRole+i+1] = QString("col%1").arg(i).toLatin1();
    }
    m_model.setItemRoleNames(roles);   // Qt 6 中这样设定角色名

    qDebug() << m_model.roleNames();

    for (const auto& row : result) {
        QList<QStandardItem*> items{new QStandardItem};

        for (int i=0; i<row.size(); i++) {
            auto &text = row[i];
            items.first()->setData(text, Qt::UserRole+i+1);
        }
        m_model.appendRow(items);
    }
}

void QmlInterface::onFormat(const QString &format, int max)
{
    m_labText = format;
    emit labTextChanged();
}

void QmlInterface::onEnd()
{
    m_labText = "";
    emit labTextChanged();
}
