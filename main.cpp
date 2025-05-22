#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "poemmanager.h"
#include "qmlinterface.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QThread *thread(new QThread);
    PoemManager *manager(new PoemManager);
    manager->moveToThread(thread);
    thread->start();

    QmlInterface *interf = new QmlInterface;

    QObject::connect(manager, &PoemManager::progSet, interf, &QmlInterface::onFormat);
    QObject::connect(manager, &PoemManager::progEnd, interf, &QmlInterface::onEnd);

    QObject::connect(interf, &QmlInterface::query, manager, &PoemManager::onQuery);
    QObject::connect(manager, &PoemManager::searchEnd, interf, &QmlInterface::onTable);

    QMetaObject::invokeMethod(manager, &PoemManager::load, QString(":/data/qts.csv"), QString(":/data/ju_tab.csv"));
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("interf", interf);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("PoemEngine", "Main");

    return app.exec();
}
