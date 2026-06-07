import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui

Item {
    ConsoleBridge {
        id: consoleBridge
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.background

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 10

            Label {
                text: qsTr("Source Console")
                color: Colors.text
                font.pixelSize: 20
                font.bold: true
            }

            TextField {
                id: commandInput

                Layout.fillWidth: true
                Layout.preferredHeight: 44
                placeholderText: qsTr("Type a console command")
                color: Colors.text
                placeholderTextColor: Colors.mutedText
                selectionColor: Colors.accent
                selectedTextColor: Colors.background
                font.pixelSize: 16

                background: Rectangle {
                    color: Colors.secondaryBackground
                    border.color: commandInput.activeFocus ? Colors.accent : Colors.hoverBackground
                    border.width: 1
                    radius: 6
                }

                onAccepted: {
                    const command = text
                    clear()
                    consoleBridge.sendCommand(command)
                }
            }

            Label {
                Layout.fillWidth: true
                text: consoleBridge.statusMessage
                color: Colors.mutedText
                font.pixelSize: 13
                elide: Text.ElideRight
                visible: text.length > 0
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
