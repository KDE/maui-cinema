cmake_minimum_required(VERSION 3.5)

set(CINEMA_VERSION 1.0.0)
project(cinema VERSION ${CINEMA_VERSION})

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# QtCreator supports the following variables for Android, which are identical to qmake Android variables.
# Check http://doc.qt.io/qt-5/deployment-android.html for more information.
# They need to be set before the find_package(Qt5 ...) call.

#if(ANDROID)
#    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
#    if (ANDROID_ABI STREQUAL "armeabi-v7a")
#        set(ANDROID_EXTRA_LIBS
#            ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libcrypto.so
#            ${CMAKE_CURRENT_SOURCE_DIR}/path/to/libssl.so)
#    endif()
#endif()

find_package(ECM 1.7.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})

find_package(MauiKit REQUIRED)
find_package(Qt5 COMPONENTS Sql Qml Svg Core Quick LinguistTools REQUIRED)
include(ECMInstallIcons)
include(ECMAddAppIcon)
include(ECMSetupVersion)
find_package(KF5 ${KF5_VERSION} REQUIRED COMPONENTS I18n Notifications Config KIO Attica)
include(KDEInstallDirs)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDECMakeSettings)

#set(TS_FILES translations/cinema_en_001.ts)

if(ANDROID)
    add_library(cinema SHARED
      src/main.cpp
      src/qml.qrc
      ${TS_FILES}
    )
else()
    add_executable(cinema
      src/main.cpp
      src/models/videosmodel.cpp
      src/utils/fileloader.h
      src/utils/cinema.cpp
      src/utils/thumbnailer.cpp
      src/qml.qrc
      ${TS_FILES}
    )

ecm_setup_version(${CINEMA_VERSION}
    VARIABLE_PREFIX CINEMA
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/cinema_version.h"
    )
endif()

install (TARGETS cinema ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})

target_compile_definitions(cinema
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(cinema
  PRIVATE MauiKit  Qt5::Sql Qt5::Core Qt5::Quick  Qt5::Qml Qt5::Svg KF5::ConfigCore KF5::Notifications KF5::KIOCore KF5::I18n KF5::Attica)

#qt5_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})
