import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui
import "../controls"

ItemDelegate {
    id: control

    property string streamName: ""
    property string streamType: "unknown"
    property bool recordEnabled: false
    property string outputSettings: ""

    signal editRequested()
    signal removeRequested()

    function streamTypeLabel(type) {
        if (type === "normal")
            return qsTr("Normal")
        if (type === "depth")
            return qsTr("Depth")
        if (type === "hudBlack")
            return qsTr("HUD (black)")
        if (type === "hudWhite")
            return qsTr("HUD (white)")
        return qsTr("Unknown")
    }

    function streamTypeTextColor(type) {
        if (type === "normal")
            return Colors.normalStreamType
        if (type === "depth")
            return Colors.depthStreamType
        if (type === "hudBlack" || type === "hudWhite")
            return Colors.hudStreamType
        return Colors.disabledText
    }

    function streamTypeBackgroundColor(type) {
        if (type === "normal")
            return Colors.normalBackgroundStreamType
        if (type === "depth")
            return Qt.rgba(Colors.depthStreamType.r, Colors.depthStreamType.g, Colors.depthStreamType.b, 0.18)
        if (type === "hudBlack" || type === "hudWhite")
            return Qt.rgba(Colors.hudStreamType.r, Colors.hudStreamType.g, Colors.hudStreamType.b, 0.16)
        return Colors.secondaryBackground
    }

    implicitHeight: 82
    padding: 0

    contentItem: RowLayout {
        anchors.fill: parent
        anchors.margins: Sizes.spacingLarge
        spacing: Sizes.spacingLarge

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Sizes.spacingSmall

            RowLayout {
                spacing: Sizes.spacingSmall

                Label {
                    text: control.streamName
                    color: Colors.text
                    font.pixelSize: Sizes.textTitle
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                AppBadge {
                    text: control.streamTypeLabel(control.streamType)
                    textColor: control.streamTypeTextColor(control.streamType)
                    backgroundColor: control.streamTypeBackgroundColor(control.streamType)
                }
            }

            RowLayout {
                spacing: Sizes.spacingLarge

                Label {
                    text: qsTr("Record: %1").arg(control.recordEnabled ? qsTr("On") : qsTr("Off"))
                    color: Colors.mutedText
                    font.pixelSize: Sizes.textStatus
                }

                Label {
                    text: qsTr("Preset: %1").arg(control.outputSettings.length > 0 ? control.outputSettings : qsTr("Unknown"))
                    color: Colors.mutedText
                    font.pixelSize: Sizes.textStatus
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }

        AppButton {
            Layout.preferredWidth: 92
            Layout.preferredHeight: Sizes.buttonHeightSmall
            pixelSize: Sizes.textDelegate
            text: qsTr("Edit")
            color: Colors.primaryAction
            onClicked: control.editRequested()
        }

        AppButton {
            Layout.preferredWidth: 104
            Layout.preferredHeight: Sizes.buttonHeightSmall
            pixelSize: Sizes.textDelegate
            text: qsTr("Remove")
            color: Colors.dangerAction
            onClicked: control.removeRequested()
        }
    }

    background: Rectangle {
        color: control.hovered ? Colors.hoverBackground : Colors.panelBackground
        border.color: Colors.border
        border.width: Sizes.controlBorderWidth
        radius: Sizes.panelRadius
    }
}