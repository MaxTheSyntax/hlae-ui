import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import hlae_ui
import "../components"
import "../controls"
import "../themes"

Item {
    id: listPage

    required property bool hasActiveProject
    required property bool loadingStreams
    required property bool outputRequestActive
    required property string errorText
    required property string statusText
    required property var streamModel

    signal refreshRequested()
    signal addRequested()
    signal editRequested(int streamIndex)
    signal removeRequested(string streamName)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Sizes.pageMargin
        spacing: Sizes.spacingLarge

        RowLayout {
            Layout.fillWidth: true
            spacing: Sizes.spacingLarge

            Label {
                Layout.fillWidth: true
                text: qsTr("Streams")
                color: Colors.text
                font.pixelSize: Sizes.textTitle
                font.bold: true
            }

            AppButton {
                Layout.preferredWidth: 112
                Layout.preferredHeight: Sizes.buttonHeightSmall
                pixelSize: Sizes.textDelegate
                text: qsTr("Refresh")
                color: Colors.cancelAction
                enabled: listPage.hasActiveProject && !listPage.loadingStreams
                onClicked: listPage.refreshRequested()
            }

            AppButton {
                Layout.preferredWidth: 96
                Layout.preferredHeight: Sizes.buttonHeightSmall
                pixelSize: Sizes.textDelegate
                text: qsTr("Add")
                color: Colors.successAction
                enabled: listPage.hasActiveProject && !listPage.loadingStreams && !listPage.outputRequestActive
                onClicked: listPage.addRequested()
            }
        }

        Label {
            Layout.fillWidth: true
            text: listPage.errorText
            color: Colors.error
            font.pixelSize: Sizes.text
            wrapMode: Text.Wrap
            visible: text.length > 0
        }

        Label {
            Layout.fillWidth: true
            text: listPage.statusText
            color: Colors.mutedText
            font.pixelSize: Sizes.textStatus
            wrapMode: Text.Wrap
            visible: text.length > 0 && listPage.errorText.length === 0
        }

        Label {
            Layout.fillWidth: true
            text: listPage.hasActiveProject
                  ? (listPage.loadingStreams ? qsTr("Loading streams...") : qsTr("No streams found."))
                  : qsTr("No active project loaded.")
            color: Colors.mutedText
            font.pixelSize: Sizes.text
            horizontalAlignment: Text.AlignHCenter
            visible: !listPage.hasActiveProject || listPage.loadingStreams || listPage.streamModel.count === 0
        }

        ListView {
            id: streamList

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Sizes.spacingLarge
            visible: listPage.hasActiveProject && !listPage.loadingStreams && listPage.streamModel.count > 0
            model: listPage.streamModel

            delegate: StreamDelegate {
                width: streamList.width
                streamName: model.name
                streamType: model.type
                recordEnabled: model.record
                outputSettings: model.settings
                onEditRequested: listPage.editRequested(model.index)
                onRemoveRequested: listPage.removeRequested(model.name)
            }
        }
    }
}