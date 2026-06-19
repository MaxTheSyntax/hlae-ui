import QtQuick
import QtQuick.Controls
import hlae_ui

Menu {
    id: control

    property int menuWidth: 132
    property int itemHeight: 34

    width: menuWidth
    padding: Sizes.spacingXSmall
    margins: Sizes.spacingSmall
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    delegate: MenuItem {
        id: menuItem

        readonly property color actionTextColor: menuItem.action && menuItem.action.textColor
                                               ? menuItem.action.textColor
                                               : Colors.text

        implicitWidth: control.menuWidth - control.leftPadding - control.rightPadding
        implicitHeight: control.itemHeight
        leftPadding: Sizes.spacingLarge
        rightPadding: Sizes.spacingLarge

        contentItem: Text {
            text: menuItem.text
            color: !menuItem.enabled
                   ? Colors.disabledText
                   : menuItem.actionTextColor
            font.pixelSize: Sizes.textSmall
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            radius: Sizes.controlRadiusMedium
            color: menuItem.highlighted ? Colors.hoverBackground : "transparent"
        }
    }

    background: Rectangle {
        implicitWidth: control.menuWidth
        color: Colors.panelBackground
        radius: Sizes.controlRadiusLarge
        border.color: Colors.border
        border.width: Sizes.controlBorderWidth
    }
}
