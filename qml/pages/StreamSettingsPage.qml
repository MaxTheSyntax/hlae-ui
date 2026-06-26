import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import hlae_ui
import "../components"
import "../controls"
import "../themes"

Item {
    id: settingsPage

    required property bool editLoading
    required property var selectedStream
    required property var draft
    required property var presetOptions
    required property var captureOptions
    required property var captureTypeOptions
    required property var depthChannelOptions
    required property var depthModeOptions

    signal backRequested()
    signal applyRequested()
    signal draftValueChanged(string key, var value)

    function friendlyStreamType(type) {
        if (type === "normal") return qsTr("Normal")
        if (type === "depth") return qsTr("Depth")
        if (type === "hudBlack") return qsTr("HUD (black)")
        if (type === "hudWhite") return qsTr("HUD (white)")
        return qsTr("Unknown")
    }

    function streamTypeTextColor(type) {
        if (type === "normal") return Colors.normalStreamType
        if (type === "depth") return Colors.depthStreamType
        if (type === "hudBlack" || type === "hudWhite") return Colors.hudStreamType
        return Colors.disabledText
    }

    function streamTypeBackgroundColor(type) {
        if (type === "normal") return Colors.normalBackgroundStreamType
        if (type === "depth") return Qt.rgba(Colors.depthStreamType.r, Colors.depthStreamType.g, Colors.depthStreamType.b, 0.18)
        if (type === "hudBlack" || type === "hudWhite") return Qt.rgba(Colors.hudStreamType.r, Colors.hudStreamType.g, Colors.hudStreamType.b, 0.16)
        return Colors.secondaryBackground
    }

    function hasTypeSpecificSettings() {
        return selectedStream.type === "depth" || selectedStream.type === "hudBlack" || selectedStream.type === "hudWhite"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Sizes.pageMargin
        spacing: Sizes.spacingLarge

        RowLayout {
            Layout.fillWidth: true
            spacing: Sizes.spacingLarge

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Sizes.spacingSmall

                RowLayout {
                    spacing: Sizes.spacingSmall

                    Label {
                        text: settingsPage.selectedStream.name || ""
                        color: Colors.text
                        font.pixelSize: Sizes.textTitle
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    AppBadge {
                        text: settingsPage.friendlyStreamType(settingsPage.selectedStream.type)
                        textColor: settingsPage.streamTypeTextColor(settingsPage.selectedStream.type)
                        backgroundColor: settingsPage.streamTypeBackgroundColor(settingsPage.selectedStream.type)
                    }
                }

                Label {
                    text: settingsPage.editLoading ? qsTr("Loading current stream settings...") : qsTr("Changes are sent when you apply.")
                    color: Colors.mutedText
                    font.pixelSize: Sizes.textStatus
                }
            }

            AppButton {
                Layout.preferredWidth: 96
                Layout.preferredHeight: Sizes.buttonHeightSmall
                pixelSize: Sizes.textDelegate
                text: qsTr("Back")
                color: Colors.cancelAction
                onClicked: settingsPage.backRequested()
            }

            AppButton {
                Layout.preferredWidth: 104
                Layout.preferredHeight: Sizes.buttonHeightSmall
                pixelSize: Sizes.textDelegate
                text: qsTr("Apply")
                color: Colors.successAction
                enabled: !settingsPage.editLoading
                onClicked: settingsPage.applyRequested()
            }
        }

        ScrollView {
            id: editScroll

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth

            ColumnLayout {
                width: editScroll.availableWidth
                spacing: Sizes.spacingLarge

                Pane {
                    Layout.fillWidth: true
                    padding: Sizes.spacingLarge

                    background: Rectangle {
                        color: Colors.panelBackground
                        border.color: Colors.border
                        border.width: Sizes.controlBorderWidth
                        radius: Sizes.panelRadius
                    }

                    ColumnLayout {
                        width: parent.width
                        spacing: Sizes.spacingLarge
                        enabled: !settingsPage.editLoading

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Generic")
                            color: Colors.text
                            font.pixelSize: Sizes.textTitle
                            font.bold: true
                        }

                        StreamSettingToggle {
                            labelText: qsTr("Record")
                            supportingText: qsTr("Include this stream in recording output.")
                            checked: settingsPage.draft.record === true
                            onCheckedChanged: settingsPage.draftValueChanged("record", checked)
                        }

                        StreamSettingSegmentedControl {
                            labelText: qsTr("Capture")
                            supportingText: qsTr("Choose when this stream captures the frame.")
                            options: settingsPage.captureOptions
                            value: settingsPage.draft.capture || "beforePresent"
                            onValueChanged: settingsPage.draftValueChanged("capture", value)
                        }

                        StreamSettingComboBox {
                            labelText: qsTr("Output settings")
                            supportingText: qsTr("Recording preset from mirv_streams settings.")
                            options: settingsPage.presetOptions
                            value: settingsPage.draft.settings || "afxDefault"
                            onValueChanged: settingsPage.draftValueChanged("settings", value)
                        }
                    }
                }

                Pane {
                    Layout.fillWidth: true
                    padding: Sizes.spacingLarge
                    visible: settingsPage.hasTypeSpecificSettings()

                    background: Rectangle {
                        color: Colors.panelBackground
                        border.color: Colors.border
                        border.width: Sizes.controlBorderWidth
                        radius: Sizes.panelRadius
                    }

                    ColumnLayout {
                        width: parent.width
                        spacing: Sizes.spacingLarge
                        enabled: !settingsPage.editLoading

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("%1 settings").arg(settingsPage.friendlyStreamType(settingsPage.selectedStream.type))
                            color: Colors.text
                            font.pixelSize: Sizes.textTitle
                            font.bold: true
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Sizes.spacingLarge
                            visible: settingsPage.selectedStream.type === "depth"

                            StreamSettingComboBox {
                                labelText: qsTr("Capture type")
                                supportingText: qsTr("How stream data is saved.")
                                options: settingsPage.captureTypeOptions
                                value: settingsPage.draft.captureType || "rgb"
                                onValueChanged: settingsPage.draftValueChanged("captureType", value)
                            }

                            StreamSettingToggle {
                                labelText: qsTr("Smoke composite")
                                supportingText: qsTr("Composite smoke depth into depth capture.")
                                checked: settingsPage.draft.depthCompositeSmoke === true
                                onCheckedChanged: settingsPage.draftValueChanged("depthCompositeSmoke", checked)
                            }

                            StreamSettingNumberField {
                                labelText: qsTr("Depth min")
                                supportingText: qsTr("Minimum depth value.")
                                value: settingsPage.draft.depthVal || ""
                                onValueEdited: function(value) { settingsPage.draftValueChanged("depthVal", value) }
                            }

                            StreamSettingNumberField {
                                labelText: qsTr("Depth max")
                                supportingText: qsTr("Maximum depth value.")
                                value: settingsPage.draft.depthValMax || ""
                                onValueEdited: function(value) { settingsPage.draftValueChanged("depthValMax", value) }
                            }

                            StreamSettingComboBox {
                                labelText: qsTr("Depth channels")
                                supportingText: qsTr("How depth is encoded into pixels.")
                                options: settingsPage.depthChannelOptions
                                value: settingsPage.draft.depthChannels || "gray"
                                onValueChanged: settingsPage.draftValueChanged("depthChannels", value)
                            }

                            StreamSettingComboBox {
                                labelText: qsTr("Depth transformation")
                                supportingText: qsTr("How depth values are transformed.")
                                options: settingsPage.depthModeOptions
                                value: settingsPage.draft.depthMode || "inverse"
                                onValueChanged: settingsPage.draftValueChanged("depthMode", value)
                            }

                            StreamSettingToggle {
                                labelText: qsTr("High quality smoke")
                                supportingText: qsTr("Force full resolution smoke passes for depth capture.")
                                checked: settingsPage.draft.autoForceFullResSmoke === true
                                onCheckedChanged: settingsPage.draftValueChanged("autoForceFullResSmoke", checked)
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: Sizes.spacingLarge
                            visible: settingsPage.selectedStream.type === "hudBlack" || settingsPage.selectedStream.type === "hudWhite"

                            StreamSettingColor {
                                labelText: qsTr("UI background")
                                supportingText: qsTr("Color cleared behind Panorama UI elements.")
                                value: settingsPage.draft.clearBeforeUI || "none"
                                onValueChanged: settingsPage.draftValueChanged("clearBeforeUI", value)
                            }
                        }
                    }
                }
            }
        }
    }
}