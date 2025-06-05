#include "qmlinterface.h"
#include <QFile>
#include <QJsonDocument>

QmlInterface::QmlInterface(QGuiApplication &app, QQmlApplicationEngine &engine, const QString &psy_yunbu_path, QObject *parent)
    : QObject(parent)
    , m_app(app)
    , m_engine(engine)
{
    m_poemResult["內容"] = QString();
    m_proxyModel.setSourceModel(&m_model);

    {
        QFile f_yunbu(psy_yunbu_path);
        f_yunbu.open(QIODevice::ReadOnly);
        QByteArray jsonData = f_yunbu.readAll();
        QJsonDocument doc = QJsonDocument::fromJson(jsonData);
        auto yunbu_map = doc.toVariant().toMap();
        f_yunbu.close();

        for(auto &[zi, yun] : yunbu_map.toStdMap())
        {
            psy_yunbu[zi] = yun.toMap();
        }
        qDebug() << "韵部: " << psy_yunbu;
    }
}

void QmlInterface::setLanguage(const QString &languageCode)
{
    m_app.removeTranslator(&m_translator);

    qCritical()<< "C++ DEBUG:" << __func__ << ":" << ":/translations/" + languageCode + ".qm" << m_translator.load(":/translations/" + languageCode + ".qm");
    if (m_translator.load(":/translations/" + languageCode + ".qm")) {
        qCritical() << "TRANSLATION";
        m_app.installTranslator(&m_translator);
        m_engine.retranslate();
    }
}

void QmlInterface::sort(const QVariantList &sortFields)
{
    QList<std::pair<int, bool>> ret;
    for(auto &var : sortFields)
    {
        auto pair = var.toMap();
        ret.append({pair["col"].toInt(), pair["asc"].toBool()});
    }
    m_proxyModel.setSort(ret);
}

void QmlInterface::onTableHeader(const QStringList &header, const QStringList &headerVar)
{
    m_model.clear();

    qCritical() << "C++ DEBUG:" << __func__ << ":" << header << headerVar;

    QHash<int, QByteArray> roles;
    for(int i=0; i<header.size(); i ++)
    {
        roles[Qt::UserRole+i+1] = headerVar[i].toLatin1();
    }
    m_model.setItemRoleNames(roles);   // Qt 6 中这样设定角色名
}

void QmlInterface::onTable(const QList<QStringList> &result)
{
    // qCritical() << "C++ DEBUG:" << __func__ << ":" << "header << result";
    for (const auto& row : result) {
        QList<QStandardItem*> items{new QStandardItem};

        for (int i=0; i<row.size(); i++) {
            auto &text = row[i];
            items.first()->setData(text, Qt::UserRole+i+1);
        }
        m_model.appendRow(items);
    }

    if (m_model.rowCount() == 10000)
        qCritical() << "句模型" << result.last() << m_model.data(m_model.index(9999, 0), Qt::UserRole+6+1).toString();
}

void QmlInterface::onFilter(const QList<qsizetype> &lines)
{
    onFormat(tr("设置中……"), 0);
    m_proxyModel.setFilter(lines);

    onFormat(tr("检索结果：%1句").arg(lines.size()), 0);
    m_proxyModel.sort(0);
}

void QmlInterface::onPoemSearched(const QVariantMap &poem)
{
    // m_poemResult.clear();
    // for(auto &[key, val] : poem.toStdMap())
    //     m_poemResult[key] = val;
    // qCritical() << "C++ DEBUG:" << __func__ << ":" << poem;
    emit poemResultReceived(poem);
}

void QmlInterface::onYunsSearched(const QList<QVariantMap> &yuns)
{
    QVariantList ret;
    for(auto &yun : yuns)
    {
        ret.append(QVariant(yun));
    }

    qCritical() << "C++ DEBUG:" << __func__ << ":" << yuns;
    emit yunsResultReceived(ret);
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
