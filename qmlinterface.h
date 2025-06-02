#ifndef QMLINTERFACE_H
#define QMLINTERFACE_H

#include "juproxymodel.h"
#include <QObject>
#include <QStandardItemModel>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>

class QmlInterface : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString labText READ labText NOTIFY labTextChanged)
    Q_PROPERTY(QVariantMap psy READ psy CONSTANT)
    Q_PROPERTY(QStandardItemModel* model READ model CONSTANT)
    Q_PROPERTY(JuProxyModel* proxyModel READ proxyModel CONSTANT)
public:
    explicit QmlInterface(QGuiApplication &app, QQmlApplicationEngine &engine, const QString &psy_yunbu_path, QObject *parent = nullptr);

    QString labText() const {return m_labText;}
    QVariantMap psy() const {return psy_yunbu;}
    QStandardItemModel *model() {return &m_model;}
    JuProxyModel *proxyModel() {return &m_proxyModel;}

    // Q_INVOKABLE void query(const QString &ju,
    //                        const QString &pz,
    //                        const QString &title,
    //                        const QString &author,
    //                        const QString &yan,
    //                        const QString &shu,
    //                        const QString &ticai,
    //                        const QString &index)
    Q_INVOKABLE void query(const QVariantList &values, const QVariantList &stricts)
    {
        emit querySent(values, stricts);
    }

    Q_INVOKABLE void searchById(const QString &id)
    {
        emit searchSent(id);
    }

    Q_INVOKABLE void searchYunsByZi(const QChar &zi)
    {
        emit yunsSearchSent(zi);
    }

    Q_INVOKABLE void setLanguage(const QString &languageCode);
    Q_INVOKABLE void sort(const QVariantList &sortFields);

signals:
    void labTextChanged();
    void poemResultReceived(QVariantMap poem);
    void yunsResultReceived(QVariantList yuns);

    void querySent(const QVariantList &values, const QVariantList &stricts);
    void searchSent(const QString &id);
    void yunsSearchSent(const QChar &zi);

public slots:
    void onTableFirst(const QStringList &header, const QStringList &headerVar, const QList<QStringList> &result);
    void onTable(const QList<QStringList> &result);
    void onFilter(const QList<int> &lines);
    void onPoemSearched(const QVariantMap &poem);
    void onYunsSearched(const QList<QVariantMap> &yuns);
    void onFormat(const QString &format, int max);
    void onEnd();

private:
    QGuiApplication &m_app;
    QQmlApplicationEngine &m_engine;

    QString m_labText;
    QVariantMap m_poemResult;
    QStandardItemModel m_model;
    JuProxyModel m_proxyModel;
    QTranslator m_translator;

    QVariantMap psy_yunbu;
};

#endif // QMLINTERFACE_H
