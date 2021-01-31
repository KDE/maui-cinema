# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

cmake_minimum_required(VERSION 3.14)

set(CLIP_VERSION 1.1.0)
project(clip VERSION ${CLIP_VERSION})

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(REQUIRED_QT_VERSION 5.14.0)
set(REQUIRED_KF5_VERSION 5.60)

find_package(ECM ${REQUIRED_KF5_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})

find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS Qml Quick Sql Svg QuickControls2 Concurrent)
find_package(KF5 ${REQUIRED_KF5_VERSION} REQUIRED COMPONENTS I18n CoreAddons)

if(ANDROID)
    find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS AndroidExtras QuickControls2)
    set(ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android_files)
    set(ANDROID_ABIS "armeabi-v7a")
elseif(UNIX)
    find_package(KF5 ${REQUIRED_KF5_VERSION} REQUIRED COMPONENTS Config KIO)
endif()

find_package(MauiKit REQUIRED)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    include(KDEInstallDirs)
    include(KDECMakeSettings)
    include(ECMInstallIcons)
    include(ECMAddAppIcon)
endif()

include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDEClangFormat)
include(ECMSetupVersion)
include(FeatureSummary)

set(clipSRCS
    src/main.cpp
    src/models/videosmodel.cpp
    src/models/tagsmodel.cpp
    src/models/playlistmodel.cpp
    src/utils/clip.cpp
    )

set(clipHDRS
    src/models/videosmodel.h
    src/models/tagsmodel.h
    src/models/playlistmodel.h
    src/utils/clip.h
    )

set(clipASSETS
    src/qml.qrc
    )

if(ANDROID)
    add_library(${PROJECT_NAME} SHARED
        ${clipSRCS}
        ${clipHDRS}
        ${clipASSETS}
        )
else()
    add_executable(${PROJECT_NAME}
        ${clipSRCS}
        ${clipHDRS}
        ${clipASSETS}
        )
endif()

ecm_setup_version(${CLIP_VERSION}
    VARIABLE_PREFIX CLIP
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/clip_version.h"
    )

if (ANDROID)
    target_link_libraries(${PROJECT_NAME} Qt5::AndroidExtras Qt5::QuickControls2)
elseif(UNIX)
    target_link_libraries(${PROJECT_NAME} KF5::ConfigCore KF5::KIOCore KF5::KIOFileWidgets KF5::KIONTLM KF5::KIOWidgets)
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_link_libraries(${PROJECT_NAME} MauiKit Qt5::Sql Qt5::Quick Qt5::Qml Qt5::Svg KF5::CoreAddons KF5::I18n)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install (TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES src/org.maui.clip.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
    #TODO: port to ecm_install_icons()
    install(FILES src/assets/clip.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()

#qt5_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})
