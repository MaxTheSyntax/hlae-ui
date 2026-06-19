import QtQuick
import QtQuick.Controls
import hlae_ui

Button {
    id: control

    property color color: Colors.accent
    property int pixelSize: Sizes.text

    function blendColor(baseColor, tintColor, amount) {
        const baseAmount = 1 - amount
        return Qt.rgba(
            baseColor.r * baseAmount + tintColor.r * amount,
            baseColor.g * baseAmount + tintColor.g * amount,
            baseColor.b * baseAmount + tintColor.b * amount,
            baseColor.a)
    }

    function colorWithAlpha(sourceColor, alpha) {
        return Qt.rgba(sourceColor.r, sourceColor.g, sourceColor.b,
                       sourceColor.a * alpha)
    }

    // implicitWidth: Math.max(132, implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Sizes.buttonHeight
    leftPadding: Sizes.buttonHorizontalPadding
    rightPadding: Sizes.buttonHorizontalPadding

    scale: down ? 0.985 : 1

    Behavior on scale {
        NumberAnimation {
            duration: 90
            easing.type: Easing.OutCubic
        }
    }

    contentItem: Text {
        text: control.text
        color: control.enabled ? Colors.text : Colors.disabledText
        font.pixelSize: control.pixelSize
        font.weight: Font.DemiBold
        font.letterSpacing: 0.25
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight

        Behavior on color {
            ColorAnimation {
                duration: 140
            }
        }
    }

    background: Rectangle {
        id: background

        radius: Sizes.controlRadiusXLarge
        clip: true
        border.width: control.activeFocus ? Sizes.controlFocusBorderWidth : Sizes.controlBorderWidth
        border.color: control.activeFocus
                      ? control.color
                      : control.colorWithAlpha(
                            control.color, control.hovered ? 0.42 : 0.22)

        gradient: Gradient {
            orientation: Gradient.Vertical

            GradientStop {
                position: 0
                color: control.blendColor(
                           Qt.lighter(Colors.secondaryBackground,
                                      control.down ? 0.94 : 1.02),
                           control.color,
                           control.down ? 0.025
                                        : (control.hovered ? 0.075 : 0.035))
            }
            GradientStop {
                position: 1
                color: control.blendColor(
                           Qt.darker(Colors.secondaryBackground,
                                     control.down ? 1.20 : 1.15),
                           control.color,
                           control.down ? 0.015
                                        : (control.hovered ? 0.045 : 0.02))
            }
        }

        Canvas {
            id: sheen

            property color sheenColor: control.color

            anchors.fill: parent
            opacity: control.enabled && control.hovered ? 1 : 0

            onSheenColorChanged: requestPaint()

            onPaint: {
                const context = getContext("2d")
                const inset = background.border.width
                const left = inset
                const top = inset
                const right = width - inset
                const bottom = height - inset
                const radius = Math.max(0, background.radius - inset)

                context.reset()
                context.beginPath()
                context.moveTo(left + radius, top)
                context.lineTo(right - radius, top)
                context.quadraticCurveTo(right, top, right, top + radius)
                context.lineTo(right, bottom - radius)
                context.quadraticCurveTo(right, bottom, right - radius, bottom)
                context.lineTo(left + radius, bottom)
                context.quadraticCurveTo(left, bottom, left, bottom - radius)
                context.lineTo(left, top + radius)
                context.quadraticCurveTo(left, top, left + radius, top)
                context.closePath()
                context.clip()

                const gradient = context.createLinearGradient(
                    width * 0.42, height * 0.08, width, height)
                gradient.addColorStop(0, "transparent")
                gradient.addColorStop(
                    0.58, control.colorWithAlpha(sheenColor, 0.015))
                gradient.addColorStop(
                    0.82, control.colorWithAlpha(sheenColor, 0.10))
                gradient.addColorStop(
                    1, control.colorWithAlpha(sheenColor, 0.24))
                context.fillStyle = gradient
                context.fillRect(0, 0, width, height)
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: control.hovered ? 180 : 240
                    easing.type: Easing.InOutCubic
                }
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }
    }
}
