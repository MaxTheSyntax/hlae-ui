cmake_minimum_required(VERSION 3.16)

project(hlae_ui VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.10)

qt_add_executable(appqt_hlae
    main.cpp
)

set_source_files_properties(
    qml/themes/Colors.qml
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

set_source_files_properties(
    third_party/libvconsole/messages.h
    third_party/libvconsole/platform.h
    third_party/libvconsole/vconsole.h
    PROPERTIES SKIP_AUTOMOC ON
)

qt_add_qml_module(appqt_hlae
    URI hlae_ui

    QML_FILES
        Main.qml
        qml/App.qml
        qml/pages/Overview.qml
        qml/pages/Console.qml
        qml/pages/Settings.qml
        qml/pages/Streams.qml
        qml/pages/Timeline.qml
        qml/themes/Colors.qml

    SOURCES
        main.cpp
        src/ConsoleBridge.cpp
        src/ConsoleBridge.h
        third_party/libvconsole/platform.h
        third_party/libvconsole/messages.h
        third_party/libvconsole/vconsole.cpp
        third_party/libvconsole/vconsole.h
)

target_include_directories(appqt_hlae
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
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
    PRIVATE Qt6::Quick
)

if(WIN32)
    target_link_libraries(appqt_hlae PRIVATE ws2_32)
endif()

install(TARGETS appqt_hlae
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
