pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui

RowLayout {
    id: control

    property string labelText: ""
    property bool useSupportingText: true
    property string supportingText: ""
    property color supportingTextColor: Colors.mutedText
    property int labelWidth: 200
    property int fieldWidth: 300
    property bool fieldFillWidth: false
    property int supportingTextElide: Text.ElideLeft
    property alias text: textField.text
    property alias placeholderText: textField.placeholderText
    property alias hasError: textField.hasError

    signal textEdited()
    signal accepted()
    signal fieldActiveFocusChanged(bool activeFocus)

    spacing: 5

    Column {
        Layout.preferredWidth: control.labelWidth
        Layout.minimumWidth: control.labelWidth
        Layout.maximumWidth: control.labelWidth

        Label {
            font.pixelSize: Sizes.text
            text: control.labelText
        }

        Loader {
            active: control.useSupportingText
            width: parent.width

            sourceComponent: Label {
                font.pixelSize: Sizes.textSubtitle
                color: control.supportingTextColor
                elide: control.supportingTextElide
                verticalAlignment: Text.AlignVCenter
                text: control.supportingText
            }
        }
    }

    AppTextField {
        id: textField

        Layout.fillWidth: control.fieldFillWidth
        Layout.preferredWidth: control.fieldWidth

        onTextEdited: control.textEdited()
        onAccepted: control.accepted()
        onActiveFocusChanged: control.fieldActiveFocusChanged(activeFocus)
    }
}
