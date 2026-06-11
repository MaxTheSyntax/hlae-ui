import QtQuick
import "../themes"

Item {
    Rectangle {
        anchors.fill: parent
        color: Colors.background
        Text {
            anchors.centerIn: parent

            text: qsTr("nuthin")
            color: Colors.text
        }
    }
}
