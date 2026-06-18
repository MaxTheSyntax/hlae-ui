import QtCore
import QtQuick
import QtQuick.Layouts
import hlae_ui
import "../controls"

Item {
    id: settingsPage

    signal refreshProjectsRequested()

    Settings {
        property alias hlaeExecutablePath: hlaeExe.text
        property alias cs2ExecutablePath: cs2Exe.text
        property alias launchArguments: launchArgumentsField.text
    }

    PathValidator {
        id: pathValidator
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 10

        AppSettingTextField {
            id: hlaeExe

            Layout.fillWidth: true
            labelText: qsTr("HLAE.exe file location")
            placeholderText: qsTr("C:\\path\\to\\HLAE\\HLAE.exe")
            text: "C:\\Program Files (x86)\\HLAE\\HLAE.exe"
            validator: function(value) {
                return pathValidator.containsExecutable(value, "HLAE.exe")
            }
        }

        AppSettingTextField {
            id: cs2Exe

            Layout.fillWidth: true
            labelText: qsTr("cs2.exe file location")
            placeholderText: qsTr("C:\\path\\to\\cs2.exe")
            text: "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Counter-Strike Global Offensive\\game\\bin\\win64\\cs2.exe"

            validator: function(value) {
                return pathValidator.containsExecutable(value, "cs2.exe")
            }
        }

        AppSettingTextField {
            id: launchArgumentsField

            Layout.fillWidth: true
            labelText: qsTr("Game launch arguments")
            placeholderText: qsTr("-steam -insecure ...")
            text: "-steam -insecure +sv_lan 1 -window -console -novid -afxDisableSteamStorage"

            validator: function(value) {
                const args = value.split(" ")

                if (args.includes("-w") || args.includes("-h")) {
                    return {
                        valid: false,
                        error: qsTr("Set window dimensions in the launcher.")
                    }
                }

                if (!value.includes("-insecure")) {
                    return {
                        valid: false,
                        error: qsTr("Please set the -insecure flag.")
                    }
                }

                return {
                    valid: true,
                    error: ""
                }
            }
        }

        AppButton {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            text: qsTr("Refresh Projects")
            color: "#0c57ad"

            onClicked: settingsPage.refreshProjectsRequested()
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
