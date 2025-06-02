#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>

#include "poemmanager.h"
#include "qmlinterface.h"

void listResources(const QString &path, int depth = 0) {
    QDir dir(path);
    if (!dir.exists()) {
        qWarning() << "路径不存在：" << path;
        return;
    }

    QString indent(depth * 2, ' ');

    // 输出目录中的文件
    QFileInfoList entries = dir.entryInfoList(QDir::NoDotAndDotDot | QDir::AllEntries);
    for (const QFileInfo &entry : entries) {
        qCritical() << "C++ DEBUG:" << __func__ << ":" << indent << (entry.isDir() ? "[Dir] " : "[File]") << entry.filePath();
        if (entry.isDir()) {
            listResources(entry.filePath(), depth + 1);
        }
    }
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setOrganizationName("Drail Ins");
    app.setOrganizationDomain("www.drail-2023.asia");
    app.setApplicationName("Poem Engine");

    QQmlApplicationEngine engine;

    // 子线程诗歌检索器
    QThread *thread(new QThread);
    PoemManager *manager(new PoemManager);
    manager->moveToThread(thread);
    thread->start();

    // 接口类
    QmlInterface *interf = new QmlInterface(app, engine, QString(":/data/psy-yunbu.json"));

    QObject::connect(manager, &PoemManager::progSet, interf, &QmlInterface::onFormat);
    QObject::connect(manager, &PoemManager::dataHeaderLoaded, interf, &QmlInterface::onTableFirst);
    QObject::connect(manager, &PoemManager::dataLoaded, interf, &QmlInterface::onTable);

    QObject::connect(interf, &QmlInterface::querySent, manager, &PoemManager::onQuery);
    QObject::connect(interf, &QmlInterface::searchSent, manager, &PoemManager::onSearchById);
    // QObject::connect(interf, &QmlInterface::yunsSearchSent, manager, &PoemManager::searchYunsByZi);
    QObject::connect(manager, &PoemManager::queryEnd, interf, &QmlInterface::onFilter);
    QObject::connect(manager, &PoemManager::searchEnd, interf, &QmlInterface::onPoemSearched);
    QObject::connect(manager, &PoemManager::yunsSearchEnd, interf, &QmlInterface::onYunsSearched);


    qmlRegisterType<JuProxyModel>("JuProxyModel", 1, 0, "JuProxyModel");

    engine.rootContext()->setContextProperty("interf", interf);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("PoemEngine", "Main");



    QMetaObject::invokeMethod(manager, &PoemManager::load,
                              QString(":/data/qts.csv"),
                              QString(":/data/ju-tab.csv"),
                              QString(":/data/psy-map.json"),
                              QString(":/data/psy-yunbu.json"),
                              QString(":/data/unihan-extend.json"));
    return app.exec();
}
