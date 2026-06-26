import QtQuick
import QtQuick.Controls
import hlae_ui

Label {
    id: control

    property color textColor: Colors.text
    property color backgroundColor: Colors.secondaryBackground
    property color borderColor: textColor == Colors.text ? Colors.border : Qt.darker(textColor, 2)

    // text: "Normal"
    color: textColor
    font.pixelSize: Sizes.textSubtitle
    leftPadding: Sizes.badgeHPadding
    rightPadding: Sizes.badgeHPadding
    bottomPadding: Sizes.badgeVPadding
    topPadding: Sizes.badgeVPadding

    background: Rectangle {
        color: control.backgroundColor
        border.color: control.borderColor
        radius: Sizes.panelRadiusSmall
    }
}
