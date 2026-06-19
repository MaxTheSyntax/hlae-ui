cmake_minimum_required(VERSION 3.16)

project(hlae_ui VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.10)

add_library(libvconsole STATIC
    third_party/libvconsole/vconsole.cpp
)

target_include_directories(libvconsole
    SYSTEM PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/third_party
)

if(MSVC)
    target_compile_options(libvconsole PRIVATE /w)
else()
    target_compile_options(libvconsole PRIVATE -w)
endif()

if(WIN32)
    target_link_libraries(libvconsole PRIVATE ws2_32)
endif()

qt_add_executable(appqt_hlae
    main.cpp
)

set_source_files_properties(
    qml/themes/Colors.qml
    qml/themes/Sizes.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

set_source_files_properties(
    third_party/libvconsole/messages.h
    third_party/libvconsole/platform.h
    third_party/libvconsole/vconsole.h
    PROPERTIES SKIP_AUTOMOC ON
)

file(GLOB MAP_ASSET_FILES CONFIGURE_DEPENDS
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    assets/images/maps/icons/*
    assets/images/maps/previews/*
)


# DO NOT TRY ORGANISING THIS!!
# Qt Creator does not care about this looking nice so it *will* slowly mess it up the more files are added
qt_add_qml_module(appqt_hlae
    URI hlae_ui

    QML_FILES
        Main.qml
        qml/App.qml
        qml/pages/OverviewPage.qml
        qml/pages/ConsolePage.qml
        qml/pages/SettingsPage.qml
        qml/pages/StreamsPage.qml
        qml/pages/TimelinePage.qml
        qml/themes/Colors.qml
        qml/themes/Sizes.qml
        qml/controls/AppTextField.qml
        qml/controls/AppLabelTextField.qml
        qml/controls/AppValidatedTextField.qml
        qml/controls/AppSettingTextField.qml
        qml/pages/LauncherPage.qml
        qml/controls/AppButton.qml
        qml/controls/AppMenu.qml

    SOURCES
        main.cpp
        src/ConsoleBridge.cpp
        src/ConsoleBridge.h
        src/PathValidator.cpp
        src/PathValidator.h
        src/HlaeRunner.h
        src/HlaeRunner.cpp
        src/ProjectManager.h
        src/ProjectManager.cpp

    RESOURCES
        ${MAP_ASSET_FILES}
        assets/images/icons/dropdown.svg
        assets/images/icons/new.svg
        RESOURCES assets/images/icons/mapIcon.svg
        RESOURCES assets/images/icons/ellipsis.svg
)

target_include_directories(appqt_hlae
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appqt_hlae PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appqt_hlae
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appqt_hlae
    PRIVATE
        Qt6::Quick
        libvconsole
)

install(TARGETS appqt_hlae
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
