import QtQuick

AppLabelTextField {
    id: control

    property var validator: null
    property bool validateEmptyText: false
    property string validationError: ""
    property string fallbackValidationError: qsTr("Invalid value.")

    signal verifiedEdit()

    supportingText: control.hasError ? control.validationError : ""
    supportingTextColor: "#ef4444"

    function resetValidation() {
        control.hasError = false
        control.validationError = ""
    }

    function validate() {
        if (!control.validateEmptyText && control.text === "") {
            control.resetValidation()
            return true
        }

        if (control.validator !== null && control.validator !== undefined) {
            const result = control.validator(control.text)
            const valid = result !== null && result !== undefined && result.valid === true

            control.hasError = !valid
            control.validationError = valid ? "" : (result && result.error ? result.error : control.fallbackValidationError)
            control.verifiedEdit()
            return valid
        }

        control.verifiedEdit()
        return !control.hasError
    }

    onTextEdited: {
        control.resetValidation()
        validationTimer.restart()
    }

    onFieldActiveFocusChanged: function(activeFocus) {
        if (!activeFocus) {
            validationTimer.stop()
            control.validate()
        }
    }

    Timer {
        id: validationTimer
        interval: 1000
        onTriggered: control.validate()
    }
}
