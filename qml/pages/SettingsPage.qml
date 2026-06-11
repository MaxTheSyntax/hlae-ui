import QtCore
import QtQuick
import QtQuick.Layouts
import hlae_ui
import "../controls"

Item {
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

            onVerifiedEdit: {
                if (text === "") {
                    return
                }

                const result = pathValidator.containsExecutable(text, "HLAE.exe")
                hasError = !result.valid
                validationError = result.error
            }
        }

        AppSettingTextField {
            id: cs2Exe

            Layout.fillWidth: true
            labelText: qsTr("cs2.exe file location")
            placeholderText: qsTr("C:\\path\\to\\cs2.exe")
            text: "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Counter-Strike Global Offensive\\game\\bin\\win64\\cs2.exe"

            onVerifiedEdit: {
                if (text === "") {
                    return
                }

                const result = pathValidator.containsExecutable(text, "cs2.exe")
                hasError = !result.valid
                validationError = result.error
            }
        }

        AppSettingTextField {
            id: launchArgumentsField

            Layout.fillWidth: true
            labelText: qsTr("Game launch arguments")
            placeholderText: qsTr("-steam -insecure ...")
            text: "-steam -insecure +sv_lan 1 -window -console -novid -afxDisableSteamStorage"

            onVerifiedEdit: {
                if (text === "") {
                    return
                }

                if (text.includes("-w") || text.includes("-h")) {
                    hasError = true
                    validationError = "Set window dimensions in the launcher."
                } else if (!text.includes("-insecure")) {
                    hasError = true
                    validationError = "Please set the -insecure flag."
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
