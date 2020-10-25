# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

QT *= core \
    quick \
    multimedia \
    qml \
    quickcontrols2

CONFIG += ordered
CONFIG += c++17

TARGET = cinema
TEMPLATE = app

VERSION_MAJOR = 1
VERSION_MINOR = 0
VERSION_BUILD = 0

VERSION = $${VERSION_MAJOR}.$${VERSION_MINOR}.$${VERSION_BUILD}

DEFINES += CINEMA_VERSION_STRING=\\\"$$VERSION\\\"

linux:unix:!android {
} else {
    message(Building helpers for Android Windows or Mac)
    DEFINES += STATIC_KIRIGAMI

#DEFAULT COMPONENTS DEFINITIONS
    DEFINES *= \
        COMPONENT_FM \
        COMPONENT_EDITOR \
        COMPONENT_TAGGING \
        MAUIKIT_STYLE

    DEFINES -= COMPONENT_STORE

    include($$PWD/3rdparty/kirigami/kirigami.pri)
    include($$PWD/3rdparty/mauikit/mauikit.pri)
}

ios {
    QMAKE_INFO_PLIST = $$PWD/ios_files/Info.plist
}

macos {
    ICON = $$PWD/macos_files/cinema.icns
}

win32 {
    RC_ICONS = $$PWD/windows_files/cinema.ico
}


# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    $$PWD/src/main.cpp \
    $$PWD/src/models/videosmodel.cpp \
    $$PWD/src/models/tagsmodel.cpp \
    $$PWD/src/models/playlistmodel.cpp \
    $$PWD/src/utils/cinema.cpp

HEADERS += \
    $$PWD/src/models/videosmodel.h \
    $$PWD/src/models/tagsmodel.h \
    $$PWD/src/models/playlistmodel.h \
    $$PWD/src/utils/cinema.h

RESOURCES += \
    $$PWD/src/qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =
# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

#include($$PWD/install.pri)

ANDROID_ABIS = armeabi-v7a

DISTFILES += \
    android_files/AndroidManifest.xml \
    android_files/build.gradle \
    android_files/gradle/wrapper/gradle-wrapper.jar \
    android_files/gradle/wrapper/gradle-wrapper.properties \
    android_files/gradlew \
    android_files/gradlew.bat \
    android_files/res/values/libs.xml

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android_files
