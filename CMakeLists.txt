cmake_minimum_required(VERSION 3.16)

project(PoemEngine VERSION 0.0.3 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appPoemEngine
    main.cpp
    # resource.qrc
    MANUAL_FINALIZATION
)

qt_add_qml_module(appPoemEngine
    URI PoemEngine
    VERSION 1.0
    QML_FILES
        PoemEngineUi/Main.qml
    SOURCES
        poemmanager.cpp
        poemmanager.h
        qmlinterface.h
        qmlinterface.cpp
    RESOURCES
        CHANGELOG.md
        # qtquickcontrols2.conf
        # RESOURCES android/AndroidManifest.xml android/build.gradle android/res/values/libs.xml android/res/xml/qtprovider_paths.xml
)

qt_add_resources(appPoemEngine "qtquickcontrols2_conf_resource"
    PREFIX "/"
    FILES
        PoemEngineUi/qtquickcontrols2.conf
)

qt_add_resources(appPoemEngine "resources"
    PREFIX "/"
    FILES
        data/qts.csv
        data/ju_tab.csv
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

add_custom_command(TARGET appPoemEngine POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
        "${CMAKE_BINARY_DIR}/android-build-appPoemEngine/build/outputs/apk/release/android-build-appPoemEngine-release-signed.apk"
        "${CMAKE_BINARY_DIR}/诗句检索_v${PROJECT_VERSION}.apk"
)
