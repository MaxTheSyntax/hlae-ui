pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui
import "themes"
import "pages"

RowLayout {
    id: app

    property string activeProject

    anchors.fill: parent
    spacing: Sizes.spacingNone

    ConsoleBridge {
        id: sourceConsole
    }

    property int currentPageIdx: 0
    property var pageNames: [
        "Launcher",
        "Overview", 
        "Streams", 
        "cmd Timeline",
        "Console",
        "Settings"
    ]

    // Sidebar
    Rectangle {
        Layout.preferredWidth: Sizes.sidebarWidth
        Layout.fillHeight: true
        color: Colors.secondaryBackground

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Sizes.sidebarMargin
            spacing: Sizes.spacingMedium

            Label {
                text: "HLAE"
                font.pixelSize: Sizes.textAppTitle
                Layout.bottomMargin: Sizes.sidebarTitleBottomMargin
            }

            Repeater {
                model: app.pageNames.length

                Button {
                    required property int modelData
                    property bool isCurrentPage: modelData == app.currentPageIdx
                    id: sidebarButton

                    Layout.fillWidth: true
                    onClicked: app.currentPageIdx = modelData

                    background: Rectangle {
                        color: sidebarButton.hovered ? Colors.hoverBackground : Colors.secondaryBackground
                        topLeftRadius: Sizes.controlRadiusLarge
                        topRightRadius: Sizes.controlRadiusLarge
                        bottomRightRadius: sidebarButton.isCurrentPage ? 0 : Sizes.controlRadiusLarge

                        Behavior on color {
                            ColorAnimation {
                                duration: 500
                                easing.type: Easing.OutExpo
                            }
                        }
                        Behavior on bottomRightRadius {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutCubic
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            height: sidebarButton.isCurrentPage ? Sizes.sidebarUnderlineHeight : Sizes.sidebarUnderlineHeightInactive
                            width: sidebarButton.hovered && !sidebarButton.isCurrentPage ? parent.width * 0.9 : parent.width

                            color: Colors.selectedAccent
                            opacity: sidebarButton.hovered || sidebarButton.isCurrentPage ? 1 : 0.2

                            Behavior on width {
                                NumberAnimation {
                                    duration: 500
                                    easing.type: Easing.OutExpo
                                }
                            }
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    contentItem: Text {
                        font.pixelSize: Sizes.text
                        text: app.pageNames[sidebarButton.modelData]
                        color: Colors.text
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

    // Main content
    StackLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        currentIndex: app.currentPageIdx

        LauncherPage {
            id: launcherPage

            consoleBridge: sourceConsole
            onProjectLoaded: function(projectId) {
                app.activeProject = projectId
            }
        }
        OverviewPage {}
        StreamsPage {}
        TimelinePage {}
        ConsolePage {
            consoleBridge: sourceConsole
        }
        SettingsPage {
            onRefreshProjectsRequested: launcherPage.refreshProjects()
        }
    }
}
