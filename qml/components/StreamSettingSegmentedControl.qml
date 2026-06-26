import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui

RowLayout {
    id: control

    property string labelText: ""
    property string supportingText: ""
    property int labelWidth: 180
    property var options: []
    property string value: ""

    function optionLabelAt(index) {
        const option = options[index]
        if (option === undefined)
            return ""
        return typeof option === "string" ? option : option.label
    }

    function optionValueAt(index) {
        const option = options[index]
        if (option === undefined)
            return ""
        return typeof option === "string" ? option : option.value
    }

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

    RowLayout {
        spacing: Sizes.spacingNone

        Repeater {
            model: control.options.length

            Button {
                id: segment

                required property int index

                readonly property bool selected: control.optionValueAt(index) === control.value

                Layout.preferredHeight: Sizes.textFieldHeight
                Layout.minimumWidth: 88
                leftPadding: Sizes.spacingLarge
                rightPadding: Sizes.spacingLarge

                text: control.optionLabelAt(index)
                onClicked: control.value = control.optionValueAt(index)

                contentItem: Label {
                    text: segment.text
                    color: segment.selected ? Colors.background : Colors.text
                    font.pixelSize: Sizes.text
                    font.weight: segment.selected ? Font.DemiBold : Font.Normal
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    color: segment.selected ? Colors.selectedAccent : (segment.hovered ? Colors.hoverBackground : Colors.secondaryBackground)
                    border.color: segment.selected ? Colors.selectedAccent : Colors.border
                    border.width: Sizes.controlBorderWidth
                    topLeftRadius: segment.index === 0 ? Sizes.controlRadiusSmall : 0
                    bottomLeftRadius: segment.index === 0 ? Sizes.controlRadiusSmall : 0
                    topRightRadius: segment.index === control.options.length - 1 ? Sizes.controlRadiusSmall : 0
                    bottomRightRadius: segment.index === control.options.length - 1 ? Sizes.controlRadiusSmall : 0
                }
            }
        }
    }
}