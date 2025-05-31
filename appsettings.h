#ifndef APPSETTINGS_H
#define APPSETTINGS_H

#include <QtCore/QObject>
#include <QtQml/QQmlEngine>
#include <QSettings>
#include <QDebug>

class AppSettings : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

#define SETTING_ACCESSOR(TYPE, CATEGORY, NAME, NAMECAP, DEFAULT) \
    Q_PROPERTY(TYPE NAME READ NAME WRITE set##NAMECAP NOTIFY NAME##Changed) \
    TYPE NAME() const { \
        return m_settings.value(QStringLiteral(#CATEGORY "/" #NAME), DEFAULT).value<TYPE>(); \
    } \
    void set##NAMECAP(TYPE value) { \
        if (value != NAME()) { \
            m_settings.setValue(QStringLiteral(#CATEGORY "/" #NAME), value); \
            emit NAME##Changed(); \
        } \
    } \
     Q_SIGNAL void NAME##Changed();

public:
    explicit AppSettings(QObject *parent = nullptr);

    SETTING_ACCESSOR(QString        , Ui    , languageCode  , LanguageCode  , ""    )
    SETTING_ACCESSOR(int            , Ui    , theme         , Theme         , 2     )
    SETTING_ACCESSOR(QVariantList   , Sort  , sortFields    , SortFields    , {}    )
    SETTING_ACCESSOR(bool           , Query , strictJu      , StrictJu      , false )
    SETTING_ACCESSOR(bool           , Query , strictPz      , StrictPz      , false )
    SETTING_ACCESSOR(bool           , Query , strictTitle   , StrictTitle   , true  )
    SETTING_ACCESSOR(bool           , Query , strictAuthor  , StrictAuthor  , true  )
    SETTING_ACCESSOR(bool           , Query , strictTicai   , StrictTicai   , true  )
    SETTING_ACCESSOR(bool           , Query , variantSearch , VariantSearch , true  )
    SETTING_ACCESSOR(bool           , Disp  , dispPz        , DispPz        , true  )

private:
    QSettings m_settings;
};

#endif // APPSETTINGS_H
