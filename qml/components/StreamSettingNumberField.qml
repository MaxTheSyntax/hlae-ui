import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui
import "../controls"

RowLayout {
    id: control

    property string labelText: ""
    property string supportingText: ""
    property int labelWidth: 180
    property int fieldWidth: 160
    property string value: ""

    signal valueEdited(string value)

    spacing: Sizes.spacingLarge

    ColumnLayout {
        Layout.preferredWidth: control.labelWidth
        Layout.minimumWidth: control.labelWidth
        Layout.maximumWidth: control.labelWidth
        spacing: Sizes.spacingXSmall

        Label {
            Layout.fillWidth: true
            text: control.labelText
            color: Colors.text
            font.pixelSize: Sizes.text
            wrapMode: Text.Wrap
        }

        Label {
            Layout.fillWidth: true
            text: control.supportingText
            color: Colors.mutedText
            font.pixelSize: Sizes.textSubtitle
            wrapMode: Text.Wrap
            visible: text.length > 0
        }
    }

    AppTextField {
        id: field

        Layout.preferredWidth: control.fieldWidth
        text: control.value
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        validator: DoubleValidator {
            notation: DoubleValidator.StandardNotation
            locale: "C"
        }

        onTextEdited: control.valueEdited(text)
    }
}