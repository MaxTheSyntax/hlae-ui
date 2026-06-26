import QtQuick
import QtQuick.Layouts
import hlae_ui
import "../dialogs"

Item {
    id: streamsPage

    required property var consoleBridge
    property string activeProjectId: ""
    property string errorText: ""
    property string statusText: ""
    property bool loadingStreams: false
    property bool editMode: false
    property bool editLoading: false
    property var selectedStream: ({})
    property var draft: ({})
    property var originalDraft: ({})
    property var knownStreamTypes: ({})
    property var outputQueue: []
    property bool outputRequestActive: false
    property var activeOutputRequest: ({})
    property int requestSerial: 0
    property var pendingAdd: ({})
    property string pendingRemoveName: ""
    property int editPendingSettings: 0
    property var presetOptions: fallbackPresetOptions()

    readonly property bool hasActiveProject: activeProjectId.length > 0
    readonly property var captureOptions: [
        { "label": qsTr("After UI"), "value": "beforePresent" },
        { "label": qsTr("Before UI"), "value": "beforeUi" }
    ]
    readonly property var captureTypeOptions: [
        { "label": "RGB", "value": "rgb" },
        { "label": "RGBA", "value": "rgba" },
        { "label": "Depth RGB", "value": "depthRgb" },
        { "label": "Depth 24", "value": "depth24" },
        { "label": "Depth 24 ZIP", "value": "depth24ZIP" },
        { "label": "Depth F", "value": "depthF" },
        { "label": "Depth F ZIP", "value": "depthFZIP" }
    ]
    readonly property var depthChannelOptions: [
        { "label": "Gray", "value": "gray" },
        { "label": "Split RGB", "value": "splitRgb" },
        { "label": "Dithered", "value": "dithered" }
    ]
    readonly property var depthModeOptions: [
        { "label": "Inverse", "value": "inverse" },
        { "label": "Linear", "value": "linear" },
        { "label": "Log E", "value": "logE" },
        { "label": "Pyramidal linear", "value": "pyramidalLinear" },
        { "label": "Pyramidal log E", "value": "pyramidalLogE" }
    ]

    ProjectManager { id: projectManager }
    ListModel { id: streamModel }

    StreamAddDialog {
        id: streamAddDialog
        onAddRequested: function(streamName, streamType) { streamsPage.addStream(streamName, streamType) }
    }

    StreamRemoveDialog {
        id: streamRemoveDialog
        onRemoveRequested: streamsPage.removeStream(streamRemoveDialog.streamName)
    }

    Connections {
        target: streamsPage.consoleBridge
        function onCommandOutputReady(requestId, lines) { streamsPage.handleCommandOutput(requestId, lines) }
    }

    Component.onCompleted: refreshPage()
    onActiveProjectIdChanged: refreshPage()

    function fallbackPresetOptions() {
        return [
            { "label": "afxClassic", "value": "afxClassic" },
            { "label": "afxDefault", "value": "afxDefault" },
            { "label": "afxFfmpeg", "value": "afxFfmpeg" },
            { "label": "afxFfmpegHuffyuv", "value": "afxFfmpegHuffyuv" },
            { "label": "afxFfmpegLosslessBest", "value": "afxFfmpegLosslessBest" },
            { "label": "afxFfmpegLosslessFast", "value": "afxFfmpegLosslessFast" },
            { "label": "afxFfmpegRaw", "value": "afxFfmpegRaw" },
            { "label": "afxFfmpegYuv420p", "value": "afxFfmpegYuv420p" },
            { "label": "afxSampler30", "value": "afxSampler30" }
        ]
    }

    function quoteConsoleArgument(value) { return "\"" + String(value).replace(/"/g, "\\\"") + "\"" }

    function cloneObject(source) {
        const target = {}
        for (const key in source) target[key] = source[key]
        return target
    }

    function setDraftValue(key, value) {
        if (draft[key] === value) return
        const nextDraft = cloneObject(draft)
        nextDraft[key] = value
        draft = nextDraft
    }

    function comparableValue(value) {
        if (value === undefined || value === null) return ""
        if (typeof value === "boolean") return value ? "1" : "0"
        return String(value)
    }

    function isDraftValueChanged(key) { return comparableValue(draft[key]) !== comparableValue(originalDraft[key]) }

    function streamNameExists(streamName) {
        for (let streamIndex = 0; streamIndex < streamModel.count; ++streamIndex) {
            if (streamModel.get(streamIndex).name === streamName) return true
        }
        return false
    }

    function setStreamTypeInModel(streamName, streamType) {
        for (let streamIndex = 0; streamIndex < streamModel.count; ++streamIndex) {
            if (streamModel.get(streamIndex).name === streamName) {
                streamModel.setProperty(streamIndex, "type", streamType)
                return
            }
        }
    }

    function loadStreamMetadata() {
        knownStreamTypes = ({})
        if (!hasActiveProject) return false

        const result = projectManager.streamMetadata(activeProjectId)
        if (!result.valid) {
            errorText = result.error
            return false
        }

        const streamTypes = {}
        const metadata = result.streams || {}
        for (const streamName in metadata) {
            const streamMetadata = metadata[streamName] || {}
            if (streamMetadata.type !== undefined && streamMetadata.type !== "") streamTypes[streamName] = streamMetadata.type
        }
        knownStreamTypes = streamTypes
        return true
    }

    function refreshPage() {
        errorText = ""
        statusText = ""
        editMode = false
        editLoading = false
        selectedStream = ({})
        draft = ({})
        originalDraft = ({})
        outputQueue = []
        outputRequestActive = false
        activeOutputRequest = ({})
        streamModel.clear()

        if (!hasActiveProject) {
            statusText = qsTr("Load a project from the Launcher page to manage streams.")
            return
        }
        if (!loadStreamMetadata()) return
        refreshPresets()
        refreshStreams()
    }

    function refreshPresets() { enqueueOutput("presets", "mirv_streams settings print", ({}), 700) }

    function refreshStreams() {
        if (!hasActiveProject) return
        loadingStreams = true
        enqueueOutput("streams", "mirv_streams print", ({}), 700)
    }

    function enqueueOutput(kind, command, payload, timeoutMs) {
        outputQueue.push({
            "id": kind + ":" + (++requestSerial),
            "kind": kind,
            "command": command,
            "payload": payload || ({}),
            "timeoutMs": timeoutMs || 700
        })
        pumpOutputQueue()
    }

    function pumpOutputQueue() {
        if (outputRequestActive || outputQueue.length === 0) return
        activeOutputRequest = outputQueue.shift()
        outputRequestActive = true
        if (!consoleBridge.requestCommandOutput(activeOutputRequest.id, activeOutputRequest.command, activeOutputRequest.timeoutMs)) {
            handleOutputRequestFailed(activeOutputRequest)
            outputRequestActive = false
            activeOutputRequest = ({})
            pumpOutputQueue()
        }
    }

    function handleCommandOutput(requestId, lines) {
        if (!outputRequestActive || activeOutputRequest.id !== requestId) return
        const request = activeOutputRequest
        outputRequestActive = false
        activeOutputRequest = ({})
        handleOutputResult(request, lines)
        pumpOutputQueue()
    }

    function handleOutputRequestFailed(request) {
        if (request.kind === "streams") {
            loadingStreams = false
            errorText = qsTr("Source console is not available.")
        } else if (request.kind === "editSetting") {
            finishEditSettingRequest()
        } else if (request.kind === "presets") {
            presetOptions = fallbackPresetOptions()
        }
    }

    function handleOutputResult(request, lines) {
        if (request.kind === "streams") handleStreamsOutput(lines)
        else if (request.kind === "presets") handlePresetOutput(lines)
        else if (request.kind === "editSetting") handleEditSettingOutput(request.payload, lines)
    }

    function parseStreamsOutput(lines) {
        const parsedStreams = []
        let sawStreamsShape = false
        let pendingRecord = false
        for (let lineIndex = 0; lineIndex < lines.length; ++lineIndex) {
            const line = String(lines[lineIndex]).trim()
            if (line.length === 0 || line.startsWith(">")) continue
            if (/^=+$/.test(line) || line === "name (recording preset)") {
                sawStreamsShape = true
                continue
            }
            if (line.startsWith("[R]")) {
                pendingRecord = line.indexOf("RECORD ON") !== -1
                sawStreamsShape = true
                continue
            }
            if (line.startsWith("==== Total streams:")) {
                sawStreamsShape = true
                continue
            }
            const match = line.match(/^(.+)\s+\(([^()]*)\)$/)
            if (match !== null) {
                parsedStreams.push({ "name": match[1].trim(), "settings": match[2].trim(), "record": pendingRecord })
                pendingRecord = false
            }
        }
        return { "valid": sawStreamsShape, "streams": parsedStreams }
    }

    function handleStreamsOutput(lines) {
        loadingStreams = false
        const parsed = parseStreamsOutput(lines)
        if (!parsed.valid) {
            streamModel.clear()
            errorText = qsTr("Unable to read streams from VConsole.")
            return
        }

        streamModel.clear()
        for (let streamIndex = 0; streamIndex < parsed.streams.length; ++streamIndex) {
            const stream = parsed.streams[streamIndex]
            streamModel.append({
                "name": stream.name,
                "type": knownStreamTypes[stream.name] || "unknown",
                "record": stream.record,
                "settings": stream.settings
            })
        }

        errorText = ""
        statusText = parsed.streams.length === 1 ? qsTr("1 stream loaded.") : qsTr("%1 streams loaded.").arg(parsed.streams.length)
        finishPendingAddOrRemove()
    }
    function parsePresetOutput(lines) {
        const options = []
        for (let lineIndex = 0; lineIndex < lines.length; ++lineIndex) {
            const line = String(lines[lineIndex]).trim()
            if (line.length === 0 || line.startsWith(">")) continue
            const match = line.match(/^([^\s(]+)(?:\s+\(protected\))?$/)
            if (match !== null) options.push({ "label": match[1], "value": match[1] })
        }
        return options
    }

    function handlePresetOutput(lines) {
        const parsedPresets = parsePresetOutput(lines)
        presetOptions = parsedPresets.length > 0 ? parsedPresets : fallbackPresetOptions()
    }

    function finishPendingAddOrRemove() {
        if (pendingAdd.name !== undefined && pendingAdd.name !== "") {
            const addedName = pendingAdd.name
            const addedType = pendingAdd.type
            pendingAdd = ({})

            if (!streamNameExists(addedName)) {
                streamAddDialog.errorText = qsTr("The stream was not found after adding. Check the console for details.")
                errorText = streamAddDialog.errorText
                return
            }

            const metadataResult = projectManager.setStreamMetadata(activeProjectId, addedName, { "type": addedType })
            if (!metadataResult.valid) {
                streamAddDialog.errorText = metadataResult.error
                errorText = metadataResult.error
                return
            }

            loadStreamMetadata()
            setStreamTypeInModel(addedName, addedType)
            streamAddDialog.close()
            statusText = qsTr("Added %1.").arg(addedName)
        }

        if (pendingRemoveName.length > 0) {
            const removedName = pendingRemoveName
            pendingRemoveName = ""

            if (streamNameExists(removedName)) {
                streamRemoveDialog.errorText = qsTr("The stream still exists after removing. Check the console for details.")
                errorText = streamRemoveDialog.errorText
                return
            }

            const metadataResult = projectManager.removeStreamMetadata(activeProjectId, removedName)
            if (!metadataResult.valid) {
                streamRemoveDialog.errorText = metadataResult.error
                errorText = metadataResult.error
                return
            }

            loadStreamMetadata()
            streamRemoveDialog.close()
            statusText = qsTr("Removed %1.").arg(removedName)
        }
    }

    function addStream(streamName, streamType) {
        errorText = ""
        streamAddDialog.errorText = ""
        if (!hasActiveProject) {
            streamAddDialog.errorText = qsTr("Load a project before adding streams.")
            return
        }
        if (streamNameExists(streamName)) {
            streamAddDialog.errorText = qsTr("A stream named '%1' already exists.").arg(streamName)
            return
        }

        pendingAdd = { "name": streamName, "type": streamType }
        const command = "mirv_streams add " + streamType + " " + quoteConsoleArgument(streamName)
        if (!consoleBridge.sendCommand(command)) {
            pendingAdd = ({})
            streamAddDialog.errorText = qsTr("Source console is not available.")
            return
        }
        refreshStreams()
    }

    function confirmRemoveStream(streamName) {
        streamRemoveDialog.resetError()
        streamRemoveDialog.streamName = streamName
        streamRemoveDialog.open()
    }

    function removeStream(streamName) {
        errorText = ""
        streamRemoveDialog.errorText = ""
        if (!hasActiveProject) {
            streamRemoveDialog.errorText = qsTr("Load a project before removing streams.")
            return
        }

        pendingRemoveName = streamName
        const command = "mirv_streams remove " + quoteConsoleArgument(streamName)
        if (!consoleBridge.sendCommand(command)) {
            pendingRemoveName = ""
            streamRemoveDialog.errorText = qsTr("Source console is not available.")
            return
        }
        refreshStreams()
    }

    function defaultDraftForStream(stream) {
        return {
            "record": stream.record,
            "capture": "beforePresent",
            "settings": stream.settings || "afxDefault",
            "captureType": "rgb",
            "depthCompositeSmoke": true,
            "depthVal": "7",
            "depthValMax": "2100",
            "depthChannels": "gray",
            "depthMode": "inverse",
            "autoForceFullResSmoke": true,
            "clearBeforeUI": "none"
        }
    }

    function settingQueriesForStream(stream) {
        const queries = [
            { "key": "record", "suffix": "record" },
            { "key": "capture", "suffix": "capture" },
            { "key": "settings", "suffix": "settings" }
        ]
        if (stream.type === "depth") {
            queries.push({ "key": "captureType", "suffix": "captureType" })
            queries.push({ "key": "depthCompositeSmoke", "suffix": "depthCompositeSmoke" })
            queries.push({ "key": "depthVal", "suffix": "depthVal" })
            queries.push({ "key": "depthValMax", "suffix": "depthValMax" })
            queries.push({ "key": "depthChannels", "suffix": "depthChannels" })
            queries.push({ "key": "depthMode", "suffix": "depthMode" })
            queries.push({ "key": "autoForceFullResSmoke", "suffix": "autoForceFullResSmoke" })
        } else if (stream.type === "hudBlack" || stream.type === "hudWhite") {
            queries.push({ "key": "clearBeforeUI", "suffix": "clearBeforeUI" })
        }
        return queries
    }

    function startEdit(streamIndex) {
        if (streamIndex < 0 || streamIndex >= streamModel.count) return
        const stream = streamModel.get(streamIndex)
        selectedStream = { "name": stream.name, "type": stream.type, "record": stream.record, "settings": stream.settings }
        draft = defaultDraftForStream(selectedStream)
        originalDraft = cloneObject(draft)
        editMode = true
        editLoading = true
        editPendingSettings = 0
        statusText = ""
        errorText = ""

        const queries = settingQueriesForStream(selectedStream)
        editPendingSettings = queries.length
        if (editPendingSettings === 0) {
            finishEditLoading()
            return
        }
        for (let queryIndex = 0; queryIndex < queries.length; ++queryIndex) {
            const query = queries[queryIndex]
            enqueueOutput("editSetting", "mirv_streams edit " + quoteConsoleArgument(selectedStream.name) + " " + query.suffix, query, 450)
        }
    }

    function parseCurrentValue(lines) {
        for (let lineIndex = 0; lineIndex < lines.length; ++lineIndex) {
            const match = String(lines[lineIndex]).trim().match(/^Current value:\s*(.*)$/)
            if (match !== null) return match[1].trim()
        }
        return ""
    }

    function compactNumberText(value) {
        const numberValue = Number(value)
        return isNaN(numberValue) ? value : String(numberValue)
    }

    function normalizeColorValue(value) {
        let cleanValue = String(value).trim()
        if (cleanValue === "none") return "none"
        cleanValue = cleanValue.replace(/^\(/, "").replace(/\)$/, "")
        const parts = cleanValue.split(/\s+/)
        if (parts.length !== 4) return "none"
        return parts.map(compactNumberText).join(" ")
    }

    function convertedSettingValue(key, value) {
        if (key === "record" || key === "depthCompositeSmoke" || key === "autoForceFullResSmoke") return value === "1"
        if (key === "clearBeforeUI") return normalizeColorValue(value)
        return value
    }

    function handleEditSettingOutput(query, lines) {
        const currentValue = parseCurrentValue(lines)
        if (currentValue.length > 0) setDraftValue(query.key, convertedSettingValue(query.key, currentValue))
        finishEditSettingRequest()
    }

    function finishEditSettingRequest() {
        editPendingSettings -= 1
        if (editPendingSettings <= 0) finishEditLoading()
    }

    function finishEditLoading() {
        originalDraft = cloneObject(draft)
        editLoading = false
    }

    function closeEdit() {
        editMode = false
        editLoading = false
        selectedStream = ({})
        draft = ({})
        originalDraft = ({})
        editPendingSettings = 0
    }

    function hasTypeSpecificSettings() {
        return selectedStream.type === "depth" || selectedStream.type === "hudBlack" || selectedStream.type === "hudWhite"
    }

    function isNumberText(value) {
        const cleanValue = String(value).trim()
        if (cleanValue.length === 0) return false
        return !isNaN(Number(cleanValue))
    }

    function isColorSettingValid(value) {
        if (value === "none") return true
        const parts = String(value).trim().split(/\s+/)
        if (parts.length !== 4) return false
        for (let partIndex = 0; partIndex < parts.length; ++partIndex) {
            const numberValue = Number(parts[partIndex])
            if (isNaN(numberValue) || numberValue < 0 || numberValue > 1) return false
        }
        return true
    }

    function appendChangedCommand(commands, key, suffix, value) {
        if (isDraftValueChanged(key)) commands.push(suffix + " " + value)
    }

    function applySettings() {
        errorText = ""
        statusText = ""
        if (!editMode || selectedStream.name === undefined) return

        if (selectedStream.type === "depth" && (!isNumberText(draft.depthVal) || !isNumberText(draft.depthValMax))) {
            errorText = qsTr("Depth min and max must be numbers.")
            return
        }
        if ((selectedStream.type === "hudBlack" || selectedStream.type === "hudWhite") && !isColorSettingValid(draft.clearBeforeUI)) {
            errorText = qsTr("HUD background color values must be between 0.0 and 1.0.")
            return
        }

        const commands = []
        appendChangedCommand(commands, "record", "record", draft.record ? "1" : "0")
        appendChangedCommand(commands, "capture", "capture", draft.capture)
        appendChangedCommand(commands, "settings", "settings", draft.settings)
        if (selectedStream.type === "depth") {
            appendChangedCommand(commands, "captureType", "captureType", draft.captureType)
            appendChangedCommand(commands, "depthCompositeSmoke", "depthCompositeSmoke", draft.depthCompositeSmoke ? "1" : "0")
            appendChangedCommand(commands, "depthVal", "depthVal", draft.depthVal)
            appendChangedCommand(commands, "depthValMax", "depthValMax", draft.depthValMax)
            appendChangedCommand(commands, "depthChannels", "depthChannels", draft.depthChannels)
            appendChangedCommand(commands, "depthMode", "depthMode", draft.depthMode)
            appendChangedCommand(commands, "autoForceFullResSmoke", "autoForceFullResSmoke", draft.autoForceFullResSmoke ? "1" : "0")
        } else if (selectedStream.type === "hudBlack" || selectedStream.type === "hudWhite") {
            appendChangedCommand(commands, "clearBeforeUI", "clearBeforeUI", draft.clearBeforeUI)
        }

        if (commands.length === 0) {
            statusText = qsTr("No stream settings changed.")
            return
        }

        for (let commandIndex = 0; commandIndex < commands.length; ++commandIndex) {
            const command = "mirv_streams edit " + quoteConsoleArgument(selectedStream.name) + " " + commands[commandIndex]
            if (!consoleBridge.sendCommand(command)) {
                errorText = qsTr("Source console is not available.")
                return
            }
        }

        if (selectedStream.type !== "unknown") {
            const metadataResult = projectManager.setStreamMetadata(activeProjectId, selectedStream.name, { "type": selectedStream.type })
            if (!metadataResult.valid) {
                errorText = metadataResult.error
                return
            }
            loadStreamMetadata()
        }

        statusText = qsTr("Applied settings for %1.").arg(selectedStream.name)
        originalDraft = cloneObject(draft)
        refreshStreams()
    }
    StackLayout {
        anchors.fill: parent
        currentIndex: streamsPage.editMode ? 1 : 0

        StreamsListPage {
            hasActiveProject: streamsPage.hasActiveProject
            loadingStreams: streamsPage.loadingStreams
            outputRequestActive: streamsPage.outputRequestActive
            errorText: streamsPage.errorText
            statusText: streamsPage.statusText
            streamModel: streamModel

            onRefreshRequested: {
                streamsPage.errorText = ""
                streamsPage.loadStreamMetadata()
                streamsPage.refreshPresets()
                streamsPage.refreshStreams()
            }

            onAddRequested: {
                streamAddDialog.reset()
                streamAddDialog.open()
            }

            onEditRequested: function(streamIndex) {
                streamsPage.startEdit(streamIndex)
            }

            onRemoveRequested: function(streamName) {
                streamsPage.confirmRemoveStream(streamName)
            }
        }

        StreamSettingsPage {
            editLoading: streamsPage.editLoading
            selectedStream: streamsPage.selectedStream
            draft: streamsPage.draft
            presetOptions: streamsPage.presetOptions
            captureOptions: streamsPage.captureOptions
            captureTypeOptions: streamsPage.captureTypeOptions
            depthChannelOptions: streamsPage.depthChannelOptions
            depthModeOptions: streamsPage.depthModeOptions

            onBackRequested: streamsPage.closeEdit()
            onApplyRequested: streamsPage.applySettings()
            onDraftValueChanged: function(key, value) {
                streamsPage.setDraftValue(key, value)
            }
        }
    }
}