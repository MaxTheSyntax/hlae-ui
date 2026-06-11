import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui
import "../controls"

Item {
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
                    hlaeRunner.run(
                        settings.hlaeExecutablePath,
                        settings.cs2ExecutablePath,
                        ["C:\Program Files (x86)\HLAE\x64\AfxHookSource2.dll"],
                        settings.launchArguments,
                        ["SteamPath=C:\Program Files (x86)\Steam", "SteamClientLaunch=1", "SteamGameId=730", "SteamAppId=730", "SteamOverlayGameId=730"]
                    )
                }
            }

            AppButton {
                Layout.fillWidth: true
                text: "Kill"
                color: "#8c150a"
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
