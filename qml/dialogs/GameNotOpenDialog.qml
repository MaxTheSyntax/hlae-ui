pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui
import "../controls"

AppDialog {
    id: dialog

    required property var consoleBridge

    Connections {
        target: dialog.consoleBridge

        function onGameNotOpenDialogRequested() {
            dialog.open()
        }
    }

    contentItem: ColumnLayout {
        spacing: Sizes.spacingLarge
        width: Sizes.textFieldModalLabelWidth + Sizes.textFieldModalFieldWidth

        Label {
            Layout.fillWidth: true
            text: qsTr("Game not launched")
            color: Colors.text
            font.pixelSize: Sizes.textTitle
        }

        Label {
            Layout.fillWidth: true
            text: qsTr("It looks like CS2 isn't running with a reachable VConsole. Please launch it using the \"Launch\" button and try again.")
            color: Colors.text
            font.pixelSize: Sizes.text
            wrapMode: Text.Wrap
        }

        Item {
            Layout.preferredHeight: Sizes.modalSpacerHeight
        }

        RowLayout {
            id: gameNotOpenButtons

            property int buttonHeight: Sizes.buttonHeightSmall
            property int pixelSizes: Sizes.textDelegate

            AppButton {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.preferredHeight: gameNotOpenButtons.buttonHeight
                pixelSize: gameNotOpenButtons.pixelSizes
                text: qsTr("OK")
                color: Colors.primaryAction

                onClicked: dialog.close()
            }
        }
    }
}
