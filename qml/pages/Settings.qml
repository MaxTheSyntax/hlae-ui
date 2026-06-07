import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui

Item {
    PathValidator {
        id: pathValidator
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 10

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 10
            rowSpacing: 4

            Column {
                Label {
                    text: qsTr("HLAE.exe file location")
                    font.pixelSize: 16
                }

                Label {
                    text: hlaeExe.validationError
                    color: "#ef4444"
                    font.pixelSize: 12
                    visible: hlaeExe.isInvalid
                }
            }

            TextField {
                id: hlaeExe

                Layout.fillWidth: true
                Layout.preferredHeight: 36
                placeholderText: qsTr("C:\\path\\to\\HLAE\\HLAE.exe")
                color: Colors.text
                placeholderTextColor: Colors.mutedText
                selectionColor: Colors.accent
                selectedTextColor: Colors.background
                font.pixelSize: 14
                property bool isInvalid: false
                property string validationError: ""

                function validatePath() {
                    validationTimer.stop()

                    if (text === "") {
                        return
                    }

                    const result = pathValidator.containsHlaeExecutable(text)
                    isInvalid = !result.valid
                    validationError = result.error

                    if (!isInvalid) {
                        // TODO: Handle a successfully validated HLAE executable path.
                        console.log("looks good")
                    }
                }

                background: Rectangle {
                    color: Colors.secondaryBackground
                    border.color: hlaeExe.isInvalid
                                  ? "#ef4444"
                                  : (hlaeExe.activeFocus ? Colors.accent : Colors.hoverBackground)
                    border.width: 1
                    radius: 4
                }

                onTextEdited: {
                    isInvalid = false
                    validationError = ""
                    validationTimer.restart()
                }
                onActiveFocusChanged: {
                    if (!activeFocus) {
                        validatePath()
                    }
                }

                Timer {
                    id: validationTimer
                    interval: 1000
                    onTriggered: hlaeExe.validatePath()
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
