import QtQuick
import QtQuick.Controls
import hlae_ui

Popup {
    id: control

    modal: true
    focus: true
    anchors.centerIn: Overlay.overlay
    padding: Sizes.modalPadding

    Overlay.modal: Rectangle {
        color: Colors.dimBackground
    }

    background: Rectangle {
        color: Colors.panelBackground
        border.color: Colors.border
        border.width: Sizes.controlBorderWidth
        radius: Sizes.controlRadiusXLarge
    }
}
