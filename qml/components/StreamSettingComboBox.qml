import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui

RowLayout {
    id: control

    property string labelText: ""
    property string supportingText: ""
    property int labelWidth: 180
    property int fieldWidth: 260
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

    function valueIndex() {
        for (let optionIndex = 0; optionIndex < options.length; ++optionIndex) {
            if (optionValueAt(optionIndex) === value)
                return optionIndex
        }
        return -1
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

    ComboBox {
        id: comboBox

        model: control.options.length
        currentIndex: control.valueIndex()
        Layout.preferredWidth: control.fieldWidth
        Layout.preferredHeight: Sizes.textFieldHeight
        leftPadding: Sizes.comboBoxLeftPadding
        rightPadding: Sizes.comboBoxRightPadding

        onActivated: function(index) {
            control.value = control.optionValueAt(index)
        }

        contentItem: Label {
            text: comboBox.currentIndex >= 0 ? control.optionLabelAt(comboBox.currentIndex) : ""
            color: Colors.text
            font.pixelSize: Sizes.text
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        indicator: Image {
            width: Sizes.comboBoxIndicatorSize
            height: Sizes.comboBoxIndicatorSize
            x: comboBox.width - width - Sizes.comboBoxIndicatorRightMargin
            y: comboBox.topPadding + (comboBox.availableHeight - height) / 2
            source: "qrc:/qt/qml/hlae_ui/assets/images/icons/dropdown.svg"
            sourceSize.width: width * Screen.devicePixelRatio
            sourceSize.height: height * Screen.devicePixelRatio
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        delegate: ItemDelegate {
            id: optionDelegate

            required property int index

            width: comboBox.width
            height: Sizes.comboBoxDelegateHeight
            highlighted: comboBox.highlightedIndex === index

            contentItem: Label {
                text: control.optionLabelAt(optionDelegate.index)
                color: Colors.text
                font.pixelSize: Sizes.textDelegate
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                color: optionDelegate.highlighted ? Colors.hoverBackground : Colors.panelBackground
                radius: Sizes.controlRadiusMedium
            }
        }

        background: Rectangle {
            border.color: comboBox.activeFocus ? Colors.accent : Colors.hoverBackground
            color: Colors.secondaryBackground
            radius: Sizes.controlRadiusSmall
            border.width: Sizes.controlBorderWidth
        }
    }
}