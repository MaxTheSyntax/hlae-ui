import QtQuick
import QtQuick.Controls
import "qml"
import "qml/themes"

ApplicationWindow {
    width: Sizes.windowWidth
    height: Sizes.windowHeight
    visible: true
    title: "Sidebar example"
    color: Colors.background

    palette.window: Colors.background
    palette.windowText: Colors.text
    palette.base: Colors.background
    palette.alternateBase: Colors.secondaryBackground
    palette.text: Colors.text
    palette.button: Colors.secondaryBackground
    palette.buttonText: Colors.text
    palette.brightText: Colors.text
    palette.mid: Colors.hoverBackground
    palette.highlight: Colors.accent
    palette.highlightedText: Colors.background
    palette.placeholderText: Colors.mutedText

    App {
        anchors.fill: parent
    }
}
