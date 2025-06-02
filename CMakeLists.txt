cmake_minimum_required(VERSION 3.16)

project(PoemEngine VERSION 0.0.7 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS LinguistTools)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appPoemEngine
    main.cpp
    MANUAL_FINALIZATION
)

qt_add_translations(appPoemEngine
    TS_FILES
        translations/zh_CN.ts
        translations/zh_MO.ts
    RESOURCE_PREFIX "/translations"
)

qt_add_qml_module(appPoemEngine
    URI PoemEngine
    VERSION 1.0
    QML_FILES
        PoemEngineUi/Main.qml
        PoemEngineUi/PopupInfo.qml
        PoemEngineUi/PopupPoem.qml
        PoemEngineUi/SettingsDialog.qml
        PoemEngineUi/PzTextItem.qml

    SOURCES
        poemmanager.cpp
        poemmanager.h
        qmlinterface.cpp
        qmlinterface.h
        juproxymodel.cpp
        juproxymodel.h
        appsettings.h
        appsettings.cpp
    RESOURCES
        CHANGELOG.md
        LICENSE.md
        THIRD_PARTY_LICENSES.txt
        QML_FILES
        RESOURCES
        QML_FILES PoemEngineUi/DebugOutline.qml
)

set_source_files_properties(AppSettings.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

# qt_add_resources(appPoemEngine "qtquickcontrols2_conf_resource"
#     PREFIX "/"
#     FILES
#         PoemEngineUi/qtquickcontrols2.conf
# )

qt_add_resources(appPoemEngine "resources"
    PREFIX "/"
    FILES
        data/qts.csv
        data/ju-tab.csv
        data/psy-map.json
        data/psy-yunbu.json
        data/unihan-extend.json
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appPoemEngine PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appPoemEngine
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

set_property(TARGET appPoemEngine APPEND PROPERTY
    QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android
)

qt_finalize_executable(appPoemEngine)

target_link_libraries(appPoemEngine
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appPoemEngine
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# if(CMAKE_BUILD_TYPE STREQUAL "Release")
#     add_custom_command(TARGET appPoemEngine POST_BUILD
#         COMMAND ${CMAKE_COMMAND} -E copy
#             "${CMAKE_BINARY_DIR}/android-build-appPoemEngine/build/outputs/apk/release/android-build-appPoemEngine-release-signed.apk"
#             "${CMAKE_BINARY_DIR}/PoemEngine_v${PROJECT_VERSION}.apk"
#     )
# endif()

