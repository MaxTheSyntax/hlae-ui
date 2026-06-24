pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui
import "../controls"

AppDialog {
    id: dialog

    required property var projectManagerBackend
    required property var pathValidatorBackend

    signal projectCreated()

    function reset() {
        projectCreateName.text = ""
        projectCreateDemoPath.text = ""
        projectCreateDemoPath.resetValidation()
        projectCreateError.text = ""
    }

    onOpened: projectCreateName.forceActiveFocus()

    contentItem: ColumnLayout {
        property int labelWidth: Sizes.textFieldModalLabelWidth
        property int fieldWidth: Sizes.textFieldModalFieldWidth

        spacing: Sizes.spacingLarge

        AppLabelTextField {
            id: projectCreateName

            labelWidth: parent.labelWidth
            fieldWidth: parent.fieldWidth
            labelText: qsTr("Project name")
            supportingText: text === "" ? qsTr("Enter your project name here") : qsTr("Project folder will be called '%1'").arg(dialog.projectManagerBackend.normalizeProjectName(text))
            useSupportingText: true
        }

        AppValidatedTextField {
            id: projectCreateDemoPath

            labelWidth: parent.labelWidth
            fieldWidth: parent.fieldWidth
            labelText: qsTr("Demo Path")
            placeholderText: qsTr("C:\\path\\to\\demo.dem")
            supportingTextElide: Text.ElideMiddle
            validateEmptyText: true
            validator: function(value) {
                return dialog.pathValidatorBackend.validateDemoFile(value)
            }

            onTextEdited: projectCreateError.text = ""
        }

        Label {
            id: projectCreateError

            color: Colors.error
        }

        Item {
            Layout.preferredHeight: Sizes.modalSpacerHeight
        }

        RowLayout {
            id: projectCreateButtons

            property int buttonHeight: Sizes.buttonHeightSmall
            property int pixelSizes: Sizes.textDelegate

            AppButton {
                Layout.fillWidth: true
                Layout.preferredWidth: 3
                Layout.preferredHeight: projectCreateButtons.buttonHeight
                pixelSize: projectCreateButtons.pixelSizes
                text: qsTr("Cancel")
                color: Colors.cancelAction

                onClicked: dialog.close()
            }

            AppButton {
                Layout.fillWidth: true
                Layout.preferredWidth: 2
                Layout.preferredHeight: projectCreateButtons.buttonHeight
                pixelSize: projectCreateButtons.pixelSizes
                text: qsTr("Create")
                color: Colors.successAction

                onClicked: {
                    projectCreateError.text = ""
                    if (!projectCreateDemoPath.validate()) {
                        return
                    }

                    const result = dialog.projectManagerBackend.create(projectCreateName.text, projectCreateDemoPath.text)

                    if (result.valid) {
                        dialog.close()
                        dialog.projectCreated()
                    } else {
                        projectCreateError.text = result.error
                    }
                }
            }
        }
    }
}
