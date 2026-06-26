import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui

RowLayout {
    id: control

    property string labelText: ""
    property string supportingText: ""
    property int labelWidth: 180
    property alias checked: toggle.checked

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

    Switch {
        id: toggle

        Layout.alignment: Qt.AlignVCenter
    }
}