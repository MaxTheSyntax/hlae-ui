pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui
import "../controls"
import "../dialogs"

Item {
    id: launcher

    required property var consoleBridge

    property string runnerError: ""
    property bool runnerHasError: false
    property string projectError: ""
    property string projectDeleteId: ""

    signal projectLoaded(string projectId)

    Settings {
        id: settings

        property string hlaeExecutablePath
        property string cs2ExecutablePath
        property string launchArguments
    }

    HlaeRunner {
        id: hlaeRunner
    }

    ProjectManager {
        id: projectManager
    }

    PathValidator {
        id: pathValidator
    }

    function projectIconSource(mapName) {
        if (mapName === undefined || mapName === "") {
            return "qrc:/qt/qml/hlae_ui/assets/images/maps/icons/unknown.png"
        }

        return "qrc:/qt/qml/hlae_ui/assets/images/maps/icons/" + mapName + ".svg"
    }

    function appendCreateProjectAction() {
        projectModel.append({
            title: qsTr("New Project"),
            iconSource: "qrc:/qt/qml/hlae_ui/assets/images/icons/new.svg",
            iconSize: Sizes.iconSmall,
            projectAction: "create",
            projectId: "",
            demoPath: "",
            map: ""
        })
    }

    function refreshProjects() {
        const selectedProjectId = projectSelect.currentIndex >= 0 && projectSelect.currentIndex < projectModel.count
                                ? projectModel.get(projectSelect.currentIndex).projectId
                                : ""

        projectModel.clear()
        appendCreateProjectAction()

        const projects = projectManager.list()
        for (let projectIndex = 0; projectIndex < projects.length; ++projectIndex) {
            const project = projects[projectIndex]
            projectModel.append({
                title: project.name,
                iconSource: projectIconSource(project.map),
                iconSize: Sizes.iconLarge,
                projectAction: "load",
                projectId: project.id,
                demoPath: project.demoPath,
                map: project.map
            })
        }

        projectSelect.currentIndex = -1
        if (selectedProjectId !== "") {
            for (let modelIndex = 1; modelIndex < projectModel.count; ++modelIndex) {
                if (projectModel.get(modelIndex).projectId === selectedProjectId) {
                    projectSelect.currentIndex = modelIndex
                    return
                }
            }
        }
    }

    function quoteConsoleArgument(value) {
        return "\"" + String(value).replace(/"/g, "\\\"") + "\""
    }

    function loadProject(projectId) {
        projectError = ""

        const result = projectManager.load(projectId)
        if (!result.valid) {
            projectError = result.error
            return
        }

        console.info("Loading project:")
        console.info("\tName: " + result.name)
        console.info("\tMap: " + result.map)
        console.info("\tDemo: " + result.demoPath.split("\\").pop())

        if (consoleBridge.sendCommand("playdemo " + quoteConsoleArgument(result.demoPath) + "")) {
            projectLoaded(result.id)
        }
    }

    function confirmDeleteProject(projectId, projectTitle) {
        projectError = ""
        projectDeleteDialog.resetError()
        projectDeleteId = projectId
        projectDeleteDialog.projectTitle = projectTitle
        projectDeleteDialog.open()
    }

    function deleteProject(projectId) {
        projectError = ""
        projectDeleteDialog.resetError()

        const result = projectManager.remove(projectId)
        if (result.valid) {
            projectDeleteDialog.close()
            projectDeleteId = ""
            launcher.refreshProjects()
        } else {
            projectDeleteDialog.errorText = result.error
            projectError = result.error
        }
    }

    Component.onCompleted: refreshProjects()

    ProjectCreateDialog {
        id: projectCreateDialog

        projectManagerBackend: projectManager
        pathValidatorBackend: pathValidator

        onProjectCreated: launcher.refreshProjects()
    }

    ProjectDeleteDialog {
        id: projectDeleteDialog

        onDeleteRequested: launcher.deleteProject(launcher.projectDeleteId)
    }

    GameNotOpenDialog {
        consoleBridge: launcher.consoleBridge
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Sizes.pageMargin
        spacing: Sizes.spacingSmall

        RowLayout {
            spacing: Sizes.spacingLarge

            AppButton {
                Layout.fillWidth: true
                text: "Launch"
                color: Colors.primaryAction

                onClicked: {
                    const result = hlaeRunner.run(
                        settings.hlaeExecutablePath,
                        settings.cs2ExecutablePath,
                        ["C:\\Program Files (x86)\\HLAE\\x64\\AfxHookSource2.dll"],
                        settings.launchArguments,
                        ["SteamPath=C:\\Program Files (x86)\\Steam", "SteamClientLaunch=1", "SteamGameId=730", "SteamAppId=730", "SteamOverlayGameId=730"]
                    )

                    runnerHasError = result.success
                    runnerError = result.error
                }
            }

            AppButton {
                Layout.fillWidth: true
                text: "Kill"
                color: Colors.dangerAction
            }
        }

        Label {
            text: runnerError
            color: Colors.error
            font.pixelSize: Sizes.textSmall
            visible: runnerHasError
        }

        ComboBox {
            id: projectSelect

            textRole: "title"
            valueRole: "projectAction"

            readonly property int iconColumnWidth: Sizes.comboBoxIconColumnWidth
            readonly property int selectedIconSize: currentIndex >= 0 && currentIndex < projectModel.count
                                                   ? projectModel.get(currentIndex).iconSize
                                                   : Sizes.iconMedium
            readonly property string selectedIconSource: currentIndex >= 0 && currentIndex < projectModel.count
                                                         ? projectModel.get(currentIndex).iconSource
                                                         : "qrc:/qt/qml/hlae_ui/assets/images/icons/mapIcon.svg"
            readonly property string selectedTitle: currentIndex >= 0 && currentIndex < projectModel.count
                                                    ? currentText
                                                    : qsTr("Select a project")

            model: ListModel {
                id: projectModel
            }

            Layout.fillWidth: true
            Layout.preferredHeight: Sizes.comboBoxHeight
            leftPadding: Sizes.comboBoxLeftPadding
            rightPadding: Sizes.comboBoxRightPadding

            contentItem: RowLayout {
                spacing: Sizes.spacingLarge

                Image {
                    source: projectSelect.selectedIconSource
                    Layout.preferredWidth: projectSelect.iconColumnWidth
                    Layout.preferredHeight: projectSelect.iconColumnWidth
                    sourceSize.width: projectSelect.selectedIconSize * Screen.devicePixelRatio
                    sourceSize.height: projectSelect.selectedIconSize * Screen.devicePixelRatio
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                Label {
                    text: projectSelect.selectedTitle
                    font.pixelSize: Sizes.text
                    color: Colors.text
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
            }

            indicator: Image {
                width: Sizes.comboBoxIndicatorSize
                height: Sizes.comboBoxIndicatorSize
                x: projectSelect.width - width - Sizes.comboBoxIndicatorRightMargin
                y: projectSelect.topPadding + (projectSelect.availableHeight - height) / 2

                source: "qrc:/qt/qml/hlae_ui/assets/images/icons/dropdown.svg"
                sourceSize.width: width * Screen.devicePixelRatio
                sourceSize.height: height * Screen.devicePixelRatio
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            background: Rectangle {
                border.color: Colors.secondaryBackground
                color: Colors.panelBackground
                radius: Sizes.controlRadiusLarge
                border.width: Sizes.controlBorderWidth
            }

            onActivated: function(index) {
                const project = projectModel.get(index)
                if (project.projectAction === "create") {
                    projectCreateDialog.reset()
                    projectCreateDialog.open()
                    projectSelect.currentIndex = -1
                } else {
                    launcher.loadProject(project.projectId)
                }
            }

            delegate: ItemDelegate {
                id: projectDelegate

                required property int index
                required property string title
                required property string iconSource
                required property int iconSize
                required property string projectAction
                required property string projectId

                width: projectSelect.width
                height: Sizes.comboBoxDelegateHeight
                highlighted: projectSelect.highlightedIndex === index
                padding: 0

                contentItem: RowLayout {
                    anchors.fill: parent
                    spacing: Sizes.spacingLarge

                    Image {
                        source: projectDelegate.iconSource
                        Layout.preferredWidth: projectSelect.iconColumnWidth
                        Layout.preferredHeight: projectSelect.iconColumnWidth
                        Layout.alignment: Qt.AlignVCenter
                        sourceSize.width: projectDelegate.iconSize * Screen.devicePixelRatio
                        sourceSize.height: projectDelegate.iconSize * Screen.devicePixelRatio
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    Label {
                        text: projectDelegate.title
                        color: Colors.text
                        font.pixelSize: Sizes.textDelegate
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    Button {
                        id: projectActionsButton

                        text: "..."
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: Sizes.spacingLarge
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        implicitWidth: 28 // have to set implicit sizing too or it gives warnings
                        implicitHeight: 28
                        visible: projectDelegate.projectAction === "load"
                        enabled: visible

                        contentItem: Image {
                            source: "qrc:/qt/qml/hlae_ui/assets/images/icons/ellipsis.svg"
                            sourceSize.width: width * Screen.devicePixelRatio
                            sourceSize.height: height * Screen.devicePixelRatio
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }

                        background: Rectangle {
                            radius: Sizes.controlRadiusMedium
                            color: projectActionsButton.hovered ? Colors.hoverBackground : Colors.secondaryBackground
                            border.color: projectActionsButton.hovered ? Colors.border : "transparent"
                            border.width: Sizes.controlBorderWidth
                        }

                        onClicked: menu.popup()

                        AppMenu {
                            id: menu

                            Action {
                                property color textColor: Colors.error

                                text: "Delete"
                                onTriggered: launcher.confirmDeleteProject(projectDelegate.projectId, projectDelegate.title)
                            }
                        }
                    }
                }

                background: Rectangle {
                    color: projectDelegate.highlighted ? Colors.hoverBackground : Colors.panelBackground
                    radius: Sizes.controlRadiusMedium
                }
            }
        }

        Label {
            Layout.fillWidth: true
            text: launcher.projectError
            color: Colors.error
            font.pixelSize: Sizes.textSmall
            wrapMode: Text.Wrap
            visible: text.length > 0
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
