#ifndef QMLINTERFACE_H
#define QMLINTERFACE_H

#include <QObject>
#include <QStandardItemModel>

class QmlInterface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString labText READ labText NOTIFY labTextChanged)
    Q_PROPERTY(QStandardItemModel* model READ model CONSTANT)
public:
    explicit QmlInterface(QObject *parent = nullptr);

    QString labText() const {return m_labText;}
    QStandardItemModel *model() {return &m_model;}

    Q_INVOKABLE void onQuery(const QString &ju,
                             const QString &pz,
                             const QString &title,
                             const QString &author,
                             const QString &yan,
                             const QString &shu,
                             const QString &ticai,
                             const QString &index)
    {
        emit query(ju, pz, title, author, yan, shu, ticai, index);
    }

signals:
    void labTextChanged();
    void query(const QString &ju,
               const QString &pz,
               const QString &title,
               const QString &author,
               const QString &yan,
               const QString &shu,
               const QString &ticai,
               const QString &index);

public slots:
    void onTable(const QStringList &header, const QList<QStringList> &result);
    void onFormat(const QString &format, int max);
    void onEnd();

private:
    QString m_labText;
    QStandardItemModel m_model;
};

#endif // QMLINTERFACE_H
