import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui

RowLayout {
    id: control

    required property string labelText
    property alias text: textField.text
    property alias placeholderText: textField.placeholderText
    property alias hasError: textField.hasError
    property string validationError: ""

    signal verifiedEdit()

    Column {

        Label {
            width: 200
            text: control.labelText
            font.pixelSize: 16
        }

        Label {
            text: control.validationError
            color: "#ef4444"
            font.pixelSize: 12
            visible: control.hasError
        }
    }

    AppTextField {
        id: textField

        Layout.fillWidth: true

        onTextEdited: {
            control.hasError = false
            control.validationError = ""
            validationTimer.restart()
        }

        onActiveFocusChanged: {
            if (!activeFocus) {
                validationTimer.stop()
                control.verifiedEdit()
            }
        }
    }

    Timer {
        id: validationTimer
        interval: 1000
        onTriggered: control.verifiedEdit()
    }
}
