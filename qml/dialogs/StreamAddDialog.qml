pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui
import "../components"
import "../controls"

AppDialog {
    id: dialog

    property string errorText: ""

    signal addRequested(string streamName, string streamType)

    function reset() {
        streamNameField.text = ""
        streamTypeField.value = "normal"
        errorText = ""
    }

    onOpened: streamNameField.forceActiveFocus()

    contentItem: ColumnLayout {
        spacing: Sizes.spacingLarge
        width: 470

        Label {
            Layout.fillWidth: true
            text: qsTr("Add stream")
            color: Colors.text
            font.pixelSize: Sizes.textTitle
        }

        AppLabelTextField {
            id: streamNameField

            labelWidth: 120
            fieldFillWidth: true
            labelText: qsTr("Name")
            supportingText: qsTr("Unique stream name")
            placeholderText: qsTr("main")
            onTextEdited: dialog.errorText = ""
        }

        StreamSettingComboBox {
            id: streamTypeField

            labelWidth: 120
            fieldWidth: 220
            labelText: qsTr("Type")
            value: "normal"
            options: [
                { "label": qsTr("Normal"), "value": "normal" },
                { "label": qsTr("Depth"), "value": "depth" },
                { "label": qsTr("HUD (black)"), "value": "hudBlack" },
                { "label": qsTr("HUD (white)"), "value": "hudWhite" }
            ]
        }

        Label {
            Layout.fillWidth: true
            text: dialog.errorText
            color: Colors.error
            font.pixelSize: Sizes.text
            wrapMode: Text.Wrap
            visible: text.length > 0
        }

        Item {
            Layout.preferredHeight: Sizes.modalSpacerHeight
        }

        RowLayout {
            id: addButtons

            property int buttonHeight: Sizes.buttonHeightSmall
            property int pixelSizes: Sizes.textDelegate

            AppButton {
                Layout.fillWidth: true
                Layout.preferredWidth: 3
                Layout.preferredHeight: addButtons.buttonHeight
                pixelSize: addButtons.pixelSizes
                text: qsTr("Cancel")
                color: Colors.cancelAction
                onClicked: dialog.close()
            }

            AppButton {
                Layout.fillWidth: true
                Layout.preferredWidth: 2
                Layout.preferredHeight: addButtons.buttonHeight
                pixelSize: addButtons.pixelSizes
                text: qsTr("Add")
                color: Colors.successAction

                onClicked: {
                    const trimmedName = streamNameField.text.trim()
                    if (trimmedName.length === 0) {
                        dialog.errorText = qsTr("Enter a stream name.")
                        return
                    }

                    dialog.addRequested(trimmedName, streamTypeField.value)
                }
            }
        }
    }
}