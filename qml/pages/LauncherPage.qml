import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui
import "../controls"

Item {
    id: launcher

    property string runnerError: ""
    property bool runnerHasError: false

    Settings {
        id: settings

        property string hlaeExecutablePath
        property string cs2ExecutablePath
        property string launchArguments
    }

    HlaeRunner {
        id: hlaeRunner
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 6

        RowLayout {
            spacing: 10

            AppButton {
                Layout.fillWidth: true
                text: "Launch"
                color: "#0c57ad"

                onClicked: {
                    const result = hlaeRunner.run(
                        settings.hlaeExecutablePath,
                        settings.cs2ExecutablePath,
                        ["C:\\Program Files (x86)\\HLAE\\x64\\AfxHookSource2.dll"],
                        settings.launchArguments,
                        ["SteamPath=C:\\Program Files (x86)\\Steam", "SteamClientLaunch=1", "SteamGameId=730", "SteamAppId=730", "SteamOverlayGameId=730"]
                    )

                    runnerHasError = result.success
                    runnerError = result.error
                }
            }

            AppButton {
                Layout.fillWidth: true
                text: "Kill"
                color: "#8c150a"
            }
        }

        Label {
            text: runnerError
            color: "#ef4444"
            font.pixelSize: 14
            visible: runnerHasError
        }

        ComboBox {
            id: projectSelect

            model: ["Epic edit", "Inferno Montage"]

            Layout.fillWidth: true;
            Layout.preferredHeight: 50

            contentItem: RowLayout {
                Image {
                    source: "qrc:/qt/qml/hlae_ui/assets/images/maps/icons/de_inferno.svg"
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 30
                    Layout.leftMargin: 10

                    sourceSize.width: 30 * Screen.devicePixelRatio
                    sourceSize.height: 30 * Screen.devicePixelRatio
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                Text {
                    text: projectSelect.currentText
                    font.pixelSize: 16
                    color: Colors.text
                    leftPadding: 5
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            indicator: Text {
                text: "⌄"
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 12
            }

            background: Rectangle {
                border.color: Colors.secondaryBackground
                color: Colors.panelBackground
                radius: 8
                border.width: 1

            }

            delegate: ItemDelegate {
                text: modelData
                width: parent.width
                height: 40
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
