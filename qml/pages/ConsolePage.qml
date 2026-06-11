import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui
import "../controls"

Item {
    ConsoleBridge {
        id: consoleBridge
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 10

        Label {
            text: qsTr("Source 2 Console")
            color: Colors.text
            font.pixelSize: 20
            font.bold: true
        }

        AppTextField {
            id: commandInput

            Layout.fillWidth: true
            Layout.preferredHeight: 44
            placeholderText: qsTr("Type a console command")
            font.pixelSize: 16

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
            wrapMode: Text.Wrap
            visible: text.length > 0
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
