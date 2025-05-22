#ifndef POEMMANAGER_H
#define POEMMANAGER_H

#include <QObject>
#include <QMap>

class PoemManager : public QObject
{
    Q_OBJECT
public:
    explicit PoemManager(QObject *parent = nullptr);
    QStringList splitNums(const QString &str);

public slots:
    void load(const QString &qts_path = "://data/qts.csv", const QString &jubiao_path = "://data/ju_tab.csv");

    void onQuery(const QString &ju,
                 const QString &pz,
                 const QString &title,
                 const QString &author,
                 const QString &yan,
                 const QString &shu,
                 const QString &ticai,
                 const QString &index);

signals:
    void debug(const QString information);
    void loadEnd(int lines);
    void progSet(const QString &format, int max);
    void progVal(int val);
    void progEnd();
    void searchEnd(const QStringList &header, const QList<QStringList> &result);

private:
    QMap<QString, QStringList> qts;
    QMap<QString, int> qts_header;
    QList<QStringList> jubiao;
    QMap<QString, int>jubiao_header;

    QMap<QString, QMap<QString, QList<int>>> to_jubiao;
};

#endif // POEMMANAGER_H
