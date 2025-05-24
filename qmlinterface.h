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
    Q_PROPERTY(QStandardItemModel* model READ model CONSTANT)
    Q_PROPERTY(JuProxyModel* proxyModel READ proxyModel CONSTANT)
public:
    explicit QmlInterface(QGuiApplication &app, QQmlApplicationEngine &engine, QObject *parent = nullptr);

    QString labText() const {return m_labText;}
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

    Q_INVOKABLE void setLanguage(const QString &languageCode);
    Q_INVOKABLE void sort(QList<int> sortCols, QList<bool> ascs);

signals:
    void labTextChanged();
    void poemResultReceived(QVariantMap poem);

    void querySent(const QVariantList &values, const QVariantList &stricts);
    void searchSent(const QString &id);

public slots:
    void onTableFirst(const QStringList &header, const QList<QStringList> &result);
    void onTable(const QList<QStringList> &result);
    void onFilter(const QList<int> &lines);
    void onPoemSearched(const QMap<QString, QString> &poem);
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
};

#endif // QMLINTERFACE_H
