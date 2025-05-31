#include "appsettings.h"
#include <QCoreApplication>

AppSettings::AppSettings(QObject *parent)
    : QObject{parent}
    , m_settings(QCoreApplication::organizationName(),
                 QCoreApplication::applicationName())
{}
