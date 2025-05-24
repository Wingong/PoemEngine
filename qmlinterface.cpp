#include "qmlinterface.h"

QmlInterface::QmlInterface(QGuiApplication &app, QQmlApplicationEngine &engine, QObject *parent)
    : QObject(parent)
    , m_app(app)
    , m_engine(engine)
{
    m_poemResult["內容"] = QString();
    m_proxyModel.setSourceModel(&m_model);
}

void QmlInterface::setLanguage(const QString &languageCode)
{
    m_app.removeTranslator(&m_translator);

    qCritical() << ":/translations/" + languageCode + ".qm" << m_translator.load(":/translations/" + languageCode + ".qm");
    if (m_translator.load(":/translations/" + languageCode + ".qm")) {
        qCritical() << "TRANSLATION";
        m_app.installTranslator(&m_translator);
        m_engine.retranslate();
    }
}

void QmlInterface::sort(QList<int> sortCols, QList<bool> ascs)
{
    m_proxyModel.setSort(sortCols, ascs);
}

void QmlInterface::onTableFirst(const QStringList &header, const QList<QStringList> &result)
{
    m_model.clear();

    qCritical() << header << result;

    QHash<int, QByteArray> roles;
    for(int i=0; i<header.size(); i ++)
    {
        roles[Qt::UserRole+i+1] = QString("col%1").arg(i).toLatin1();
    }
    m_model.setItemRoleNames(roles);   // Qt 6 中这样设定角色名

    for (const auto& row : result) {
        QList<QStandardItem*> items{new QStandardItem};

        for (int i=0; i<row.size(); i++) {
            auto &text = row[i];
            items.first()->setData(text, Qt::UserRole+i+1);
        }
        m_model.appendRow(items);
    }
}

void QmlInterface::onTable(const QList<QStringList> &result)
{
    // qCritical() << "header << result";
    for (const auto& row : result) {
        QList<QStandardItem*> items{new QStandardItem};

        for (int i=0; i<row.size(); i++) {
            auto &text = row[i];
            items.first()->setData(text, Qt::UserRole+i+1);
        }
        m_model.appendRow(items);
    }
}

void QmlInterface::onFilter(const QList<int> &lines)
{
    onFormat(tr("设置中……"), 0);
    m_proxyModel.setFilter(lines);

    onFormat(tr("检索结果：%1句").arg(lines.size()), 0);
    m_proxyModel.sort(0);
}

void QmlInterface::onPoemSearched(const QMap<QString, QString> &poem)
{
    m_poemResult.clear();
    for(auto &[key, val] : poem.toStdMap())
        m_poemResult[key] = val;
    qCritical() << m_poemResult;
    emit poemResultReceived(m_poemResult);
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
