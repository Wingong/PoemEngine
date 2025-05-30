#ifndef POEMMANAGER_H
#define POEMMANAGER_H

#include <QObject>
#include <QMap>
#include <QVariant>

enum VariantType
{
    XVariant,
    TradSimp,
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
public slots:
    void load(const QString &qts_path = "://data/qts.csv",
              const QString &jubiao_path = "://data/ju_tab.csv",
              const QString &psy_path = "://data/psy.json",
              const QString var_path = "://data/unihan-extend.json");

    void onQuery(const QVariantList &values, const QVariantList &stricts);
    void onSearchById(const QString &id);
    void osSearchYunsByZi(const QChar &zi);
signals:
    void debug(const QString information);
    void loadEnd(int lines);
    void progSet(const QString &format, int max);
    void progVal(int val);
    void dataHeaderLoaded(const QStringList &header, const QStringList &headerVar, const QList<QStringList> &result);
    void dataLoaded(const QList<QStringList> &result);
    void queryEnd(const QList<int> &lines);
    void searchEnd(const QMap<QString, QString> &poem);
    void yunsSearchEnd(const QList<QVariantMap> &yuns);

private:
    QMap<QString, QStringList> qts;
    QMap<QString, int> qts_header;
    QList<QStringList> jubiao;
    QMap<QString, int>jubiao_header;

    QMap<QString, QMap<QString, QList<int>>> to_jubiao;

    QMap<QChar, QList<QVariantMap>> psy;
    QMap<QChar, QString> xvariants;
    QMap<QChar, QString> tradsimps;
};

#endif // POEMMANAGER_H
