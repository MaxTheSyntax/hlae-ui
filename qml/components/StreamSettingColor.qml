import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui
import "../controls"

ColumnLayout {
    id: control

    property string labelText: ""
    property string supportingText: ""
    property int labelWidth: 180
    property string value: "none"
    property string selectedMode: "none"
    property string redValue: "0"
    property string greenValue: "0"
    property string blueValue: "0"
    property string alphaValue: "1"
    property bool syncing: false
    readonly property var colorModeOptions: [
        { "label": qsTr("None"), "value": "none" },
        { "label": qsTr("Black"), "value": "0 0 0 1" },
        { "label": qsTr("White"), "value": "1 1 1 1" },
        { "label": qsTr("Transparent"), "value": "0 0 0 0" },
        { "label": qsTr("Green"), "value": "0 1 0 1" },
        { "label": qsTr("Custom"), "value": "custom" }
    ]

    function splitColor(value) {
        return String(value).trim().split(/\s+/)
    }

    function isColorValue(value) {
        const parts = splitColor(value)
        if (parts.length !== 4)
            return false

        for (let partIndex = 0; partIndex < parts.length; ++partIndex) {
            const numberValue = Number(parts[partIndex])
            if (Number.isNaN(numberValue) || numberValue < 0 || numberValue > 1)
                return false
        }

        return true
    }

    function modeForValue(value) {
        if (value === "none")
            return "none"

        for (let optionIndex = 1; optionIndex < colorModeOptions.length - 1; ++optionIndex) {
            if (colorModeOptions[optionIndex].value === value)
                return value
        }

        return "custom"
    }

    function syncFromValue() {
        syncing = true
        selectedMode = modeForValue(value)

        if (isColorValue(value)) {
            const parts = splitColor(value)
            redValue = parts[0]
            greenValue = parts[1]
            blueValue = parts[2]
            alphaValue = parts[3]
        }

        syncing = false
    }

    function composeCustomValue() {
        if (syncing)
            return

        value = redValue + " " + greenValue + " " + blueValue + " " + alphaValue
    }

    spacing: Sizes.spacingSmall

    Component.onCompleted: syncFromValue()
    onValueChanged: syncFromValue()

    StreamSettingComboBox {
        labelText: control.labelText
        supportingText: control.supportingText
        labelWidth: control.labelWidth
        fieldWidth: 260
        options: control.colorModeOptions
        value: control.selectedMode

        onValueChanged: {
            control.selectedMode = value
            if (value === "custom") {
                if (!control.isColorValue(control.value)) {
                    control.redValue = "0"
                    control.greenValue = "0"
                    control.blueValue = "0"
                    control.alphaValue = "1"
                    control.composeCustomValue()
                }
            } else {
                control.value = value
            }
        }
    }

    GridLayout {
        Layout.leftMargin: control.labelWidth + Sizes.spacingLarge
        columns: 4
        columnSpacing: Sizes.spacingSmall
        rowSpacing: Sizes.spacingXSmall
        visible: control.selectedMode === "custom"

        Label { text: qsTr("R"); color: Colors.mutedText; font.pixelSize: Sizes.textSubtitle }
        Label { text: qsTr("G"); color: Colors.mutedText; font.pixelSize: Sizes.textSubtitle }
        Label { text: qsTr("B"); color: Colors.mutedText; font.pixelSize: Sizes.textSubtitle }
        Label { text: qsTr("A"); color: Colors.mutedText; font.pixelSize: Sizes.textSubtitle }

        Repeater {
            model: ["redValue", "greenValue", "blueValue", "alphaValue"]

            AppTextField {
                required property string modelData

                Layout.preferredWidth: 58
                text: control[modelData]
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                validator: DoubleValidator {
                    bottom: 0
                    top: 1
                    decimals: 3
                    notation: DoubleValidator.StandardNotation
                    locale: "C"
                }

                onTextEdited: {
                    control[modelData] = text
                    control.composeCustomValue()
                }
            }
        }
    }
}