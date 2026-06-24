pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui
import "../controls"

AppDialog {
    id: dialog

    property string projectTitle: ""
    property string errorText: ""

    signal deleteRequested()

    function resetError() {
        errorText = ""
    }

    contentItem: ColumnLayout {
        spacing: Sizes.spacingLarge
        width: Sizes.textFieldModalLabelWidth + Sizes.textFieldModalFieldWidth

        Label {
            Layout.fillWidth: true
            text: qsTr("Delete project?")
            color: Colors.text
            font.pixelSize: Sizes.textTitle
        }

        Label {
            Layout.fillWidth: true
            text: qsTr("This will permanently delete '%1' and its project files.\nExternal files, such as the demo, will be kept.").arg(dialog.projectTitle)
            color: Colors.text
            font.pixelSize: Sizes.text
            wrapMode: Text.Wrap
        }

        Label {
            Layout.fillWidth: true
            color: Colors.error
            font.pixelSize: Sizes.textSmall
            text: dialog.errorText
            wrapMode: Text.Wrap
            visible: text.length > 0
        }

        Item {
            Layout.preferredHeight: Sizes.modalSpacerHeight
        }

        RowLayout {
            id: projectDeleteButtons

            property int buttonHeight: Sizes.buttonHeightSmall
            property int pixelSizes: Sizes.textDelegate

            AppButton {
                Layout.fillWidth: true
                Layout.preferredWidth: 3
                Layout.preferredHeight: projectDeleteButtons.buttonHeight
                pixelSize: projectDeleteButtons.pixelSizes
                text: qsTr("Cancel")
                color: Colors.cancelAction

                onClicked: dialog.close()
            }

            AppButton {
                Layout.fillWidth: true
                Layout.preferredWidth: 2
                Layout.preferredHeight: projectDeleteButtons.buttonHeight
                pixelSize: projectDeleteButtons.pixelSizes
                text: qsTr("Delete")
                color: Colors.dangerAction

                onClicked: dialog.deleteRequested()
            }
        }
    }
}
