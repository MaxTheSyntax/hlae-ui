pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "themes"
import "pages"

RowLayout {
    id: app
    anchors.fill: parent
    spacing: 0

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
        Layout.preferredWidth: 180
        Layout.fillHeight: true
        color: Colors.secondaryBackground

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Label {
                text: "HLAE"
                font.pixelSize: 22
                Layout.bottomMargin: 16
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
                        topLeftRadius: 8
                        topRightRadius: 8
                        bottomRightRadius: sidebarButton.isCurrentPage ? 0 : 8

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
                            height: sidebarButton.isCurrentPage ? 3 : 2
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
                        font.pixelSize: 16
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

        Launcher {}
        Overview {}
        Streams {}
        Timeline {}
        Console {}
        Settings {}
    }
}
