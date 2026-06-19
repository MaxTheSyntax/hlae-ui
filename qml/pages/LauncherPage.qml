pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import hlae_ui
import "../controls"

Item {
    id: launcher

    required property var consoleBridge

    property string runnerError: ""
    property bool runnerHasError: false
    property string projectError: ""
    property string projectDeleteId: ""
    property string projectDeleteTitle: ""

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

        projectLoaded(result.id)
        consoleBridge.sendCommand("playdemo " + quoteConsoleArgument(result.demoPath) + "")
    }

    function confirmDeleteProject(projectId, projectTitle) {
        projectError = ""
        projectDeleteError.text = ""
        projectDeleteId = projectId
        projectDeleteTitle = projectTitle
        projectDeleteModal.open()
    }

    function deleteProject(projectId) {
        projectError = ""
        projectDeleteError.text = ""

        const result = projectManager.remove(projectId)
        if (result.valid) {
            projectDeleteModal.visible = false
            projectDeleteId = ""
            projectDeleteTitle = ""
            launcher.refreshProjects()
        } else {
            projectDeleteError.text = result.error
            projectError = result.error
        }
    }

    Component.onCompleted: refreshProjects()

    Popup {
        id: projectCreateModal

        visible: false
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

        contentItem: ColumnLayout {
            property int labelWidth: Sizes.textFieldModalLabelWidth
            property int fieldWidth: Sizes.textFieldModalFieldWidth

            spacing: Sizes.spacingLarge

            AppLabelTextField {
                id: projectCreateName

                labelWidth: labelWidth
                fieldWidth: fieldWidth
                labelText: qsTr("Project name")
                supportingText: text === "" ? qsTr("Enter your project name here") : qsTr("Project folder will be called '%1'").arg(projectManager.normalizeProjectName(text))
                useSupportingText: true
            }

            AppValidatedTextField {
                id: projectCreateDemoPath

                labelWidth: labelWidth
                fieldWidth: fieldWidth
                labelText: qsTr("Demo Path")
                placeholderText: qsTr("C:\\path\\to\\demo.dem")
                supportingTextElide: Text.ElideMiddle
                validateEmptyText: true
                validator: function(value) {
                    return pathValidator.validateDemoFile(value)
                }

                onTextEdited: projectCreateError.text = ""
            }

            Label {
                id: projectCreateError
                color: Colors.error
            }

            Item {
                height: Sizes.modalSpacerHeight
            }

            RowLayout {
                id: projectCreateButtons

                property int buttonHeight: Sizes.buttonHeightSmall
                property int pixelSizes: Sizes.textDelegate

                AppButton {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 3
                    Layout.preferredHeight: projectCreateButtons.buttonHeight
                    pixelSize: projectCreateButtons.pixelSizes
                    text: "Cancel"
                    color: Colors.cancelAction

                    onClicked: projectCreateModal.visible = false
                }

                AppButton {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 2
                    Layout.preferredHeight: projectCreateButtons.buttonHeight
                    pixelSize: projectCreateButtons.pixelSizes
                    text: "Create"
                    color: Colors.successAction

                    onClicked: {
                        projectCreateError.text = ""
                        if (!projectCreateDemoPath.validate()) {
                            return
                        }

                        const result = projectManager.create(projectCreateName.text, projectCreateDemoPath.text)

                        if (result.valid) {
                            projectCreateModal.visible = false
                            launcher.refreshProjects()
                        } else {
                            projectCreateError.text = result.error
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: projectDeleteModal

        visible: false
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

        contentItem: ColumnLayout {
            spacing: Sizes.spacingLarge
            width: Sizes.textFieldModalLabelWidth + Sizes.textFieldModalFieldWidth

            Label {
                Layout.fillWidth: true
                text: qsTr("Delete project?")
                color: Colors.text
                font.pixelSize: Sizes.textTitle
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("This will permanently delete '%1' and its project files.").arg(launcher.projectDeleteTitle)
                color: Colors.text
                font.pixelSize: Sizes.text
                wrapMode: Text.Wrap
            }

            Label {
                id: projectDeleteError

                Layout.fillWidth: true
                color: Colors.error
                font.pixelSize: Sizes.textSmall
                wrapMode: Text.Wrap
                visible: text.length > 0
            }

            Item {
                height: Sizes.modalSpacerHeight
            }

            RowLayout {
                id: projectDeleteButtons

                property int buttonHeight: Sizes.buttonHeightSmall
                property int pixelSizes: Sizes.textDelegate

                AppButton {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 3
                    Layout.preferredHeight: projectDeleteButtons.buttonHeight
                    pixelSize: projectDeleteButtons.pixelSizes
                    text: "Cancel"
                    color: Colors.cancelAction

                    onClicked: projectDeleteModal.visible = false
                }

                AppButton {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 2
                    Layout.preferredHeight: projectDeleteButtons.buttonHeight
                    pixelSize: projectDeleteButtons.pixelSizes
                    text: "Delete"
                    color: Colors.dangerAction

                    onClicked: launcher.deleteProject(launcher.projectDeleteId)
                }
            }
        }
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
                    projectCreateModal.open()
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
