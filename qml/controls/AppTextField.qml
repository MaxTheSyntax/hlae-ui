import QtQuick
import QtQuick.Controls
import hlae_ui

TextField {
    id: control

    property bool hasError: false
    readonly property real textViewportWidth: width - leftPadding - rightPadding
    property bool fadeLeft: false
    property bool fadeRight: false

    function updateFades() {
        fadeLeft = text.length > 0 && positionToRectangle(0).x < 0
        fadeRight = text.length > 0
                    && positionToRectangle(text.length).x > textViewportWidth
    }

    function scheduleFadeUpdate() {
        Qt.callLater(updateFades)
    }

    implicitHeight: Sizes.textFieldHeight
    clip: true
    color: Colors.text
    placeholderTextColor: Colors.mutedText
    selectionColor: Colors.accent
    selectedTextColor: Colors.background
    font.pixelSize: Sizes.textSmall

    background: Rectangle {
        color: Colors.secondaryBackground
        border.color: control.hasError
                      ? Colors.error
                      : (control.activeFocus ? Colors.accent : Colors.hoverBackground)
        border.width: Sizes.controlBorderWidth
        radius: Sizes.controlRadiusSmall
    }

    Component.onCompleted: scheduleFadeUpdate()
    onTextChanged: scheduleFadeUpdate()
    onCursorPositionChanged: scheduleFadeUpdate()
    onWidthChanged: scheduleFadeUpdate()
    onLeftPaddingChanged: scheduleFadeUpdate()
    onRightPaddingChanged: scheduleFadeUpdate()

    Rectangle {
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: Sizes.textFieldFadeInset
        }
        width: Sizes.textFieldFadeWidth
        visible: control.fadeLeft
        z: 10

        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                position: 0
                color: Colors.secondaryBackground
            }
            GradientStop {
                position: 1
                color: "transparent"
            }
        }
    }

    Rectangle {
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            margins: Sizes.textFieldFadeInset
        }
        width: Sizes.textFieldFadeWidth
        visible: control.fadeRight
        z: 10

        gradient: Gradient {
            orientation: Gradient.Horizontal

            GradientStop {
                position: 0
                color: "transparent"
            }
            GradientStop {
                position: 1
                color: Colors.secondaryBackground
            }
        }
    }
}
