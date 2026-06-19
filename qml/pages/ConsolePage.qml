import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui
import "../controls"

Item {
    id: consolePage

    required property var consoleBridge

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Sizes.pageMargin
        spacing: Sizes.spacingLarge

        Label {
            text: qsTr("Source 2 Console")
            color: Colors.text
            font.pixelSize: Sizes.textTitle
            font.bold: true
        }

        AppTextField {
            id: commandInput

            Layout.fillWidth: true
            Layout.preferredHeight: Sizes.buttonHeightMedium
            placeholderText: qsTr("Type a console command")
            font.pixelSize: Sizes.text

            onAccepted: {
                const command = text
                clear()
                consolePage.consoleBridge.sendCommand(command)
            }
        }

        Label {
            Layout.fillWidth: true
            text: consolePage.consoleBridge.statusMessage
            color: Colors.mutedText
            font.pixelSize: Sizes.textStatus
            wrapMode: Text.Wrap
            visible: text.length > 0
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
