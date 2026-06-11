import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui
import "../controls"

Item {
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 6

        RowLayout {
            spacing: 10

            AppButton {
                Layout.fillWidth: true
                text: "Launch"
                color: "#0c57ad"
            }

            AppButton {
                Layout.fillWidth: true
                text: "Kill"
                color: "#8c150a"
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}