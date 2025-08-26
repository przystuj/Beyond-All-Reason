local widget = widget ---@type Widget

function widget:GetInfo()
	return {
		name = "API Builder Queue",
		desc = "Provides builder queue data tracking and management for other widgets",
		author = "SuperKitowiec (extracted from 'Show Builder Queue' by WarXperiment, Decay, Floris)",
		date = "August 26, 2025",
		license = "GNU GPL, v2 or later",
		version = 1,
		layer = 0,
		enabled = true
	}
end

--------------------------------------------------------------------------------
-- Spring API Imports
--------------------------------------------------------------------------------

local spGetUnitCommands = Spring.GetUnitCommands
local spGetUnitCommandCount = Spring.GetUnitCommandCount
local spGetUnitDefID = Spring.GetUnitDefID
local spGetUnitTeam = Spring.GetUnitTeam
local spGetUnitPosition = Spring.GetUnitPosition
local spGetAllUnits = Spring.GetAllUnits
local spEcho = Spring.Echo

local floor = math.floor

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

local MAX_QUEUE_DEPTH = 2000

--------------------------------------------------------------------------------
-- State Management
--------------------------------------------------------------------------------

--- Table for all unique build commands.
--- @type table<string, BuildCommandEntry>
local buildCommands = {}

--- An ordered index of command IDs for each builder's queue.
--- @type table<number, string[]>
local builderCommandQueues = {}

local commandIdToCreatedUnitIdMap = {}
local createdUnitIdToCommandIdMap = {}
local unitsAwaitingCommandProcessing = {}
local buildersList = {}
local builderBuildOptions = {}

-- Event system for notifying consumers
local Event = {
	onBuildCommandAdded = 'onBuildCommandAdded',
	onBuildCommandRemoved = 'onBuildCommandRemoved',
	onUnitCreated = 'onUnitCreated',
	onUnitFinished = 'onUnitFinished',
	onBuilderDestroyed = 'onBuilderDestroyed',

}

local eventCallbacks = {
	[Event.onBuildCommandAdded] = {},
	[Event.onBuildCommandRemoved] = {},
	[Event.onUnitCreated] = {},
	[Event.onUnitFinished] = {},
	[Event.onBuilderDestroyed] = {}
}

local elapsedSeconds = 0
local lastUpdateTime = 0
local periodicCheckCounter = 1

--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

for unitDefId, unitDefinition in ipairs(UnitDefs) do
	if unitDefinition.isBuilder and not unitDefinition.isFactory and unitDefinition.buildOptions[1] then
		buildersList[unitDefId] = true
	end
end

--------------------------------------------------------------------------------
-- Event System Functions
--------------------------------------------------------------------------------

local function notifyEvent(eventName, ...)
	for _, callback in pairs(eventCallbacks[eventName] or {}) do
		callback(...)
	end
end

---@param eventName string
---@param callback function()
local function registerCallback(eventName, callback)
	if eventCallbacks[eventName] then
		table.insert(eventCallbacks[eventName], callback)
	else
		spEcho("Warn: Unknown event name " .. eventName)
	end
	---@class BuilderQueueEventCallback
	local callbackEntry = {}
	callbackEntry.eventName = eventName
	callbackEntry.callback = callback
	return callbackEntry
end

local function unregisterCallback(eventName, callback)
	if eventCallbacks[eventName] then
		for i, registeredCallback in ipairs(eventCallbacks[eventName]) do
			if registeredCallback == callback then
				table.remove(eventCallbacks[eventName], i)
				break
			end
		end
	else
		spEcho("Warn: Unknown event name " .. eventName)
	end
end

--------------------------------------------------------------------------------
-- Core Functions
--------------------------------------------------------------------------------

local function generateId(unitDefId, positionX, positionZ)
	return string.format('%s_%s_%s', unitDefId, positionX, positionZ)
end

local function generateIdFromUnitCommand(cmd)
	local unitDefId = math.abs(cmd.id)
	local positionX = floor(cmd.params[1])
	local positionZ = floor(cmd.params[3])
	return generateId(unitDefId, positionX, positionZ), unitDefId, positionX, positionZ
end

local function removeBuilderFromCommand(commandId, unitId)
	local command = buildCommands[commandId]
	if command and command.builderIds[unitId] then
		command.builderIds[unitId] = nil
		command.builderCount = command.builderCount - 1
		if command.builderCount == 0 then
			local commandData = command
			buildCommands[commandId] = nil
			notifyEvent(Event.onBuildCommandRemoved, commandId, commandData)
		end
	end
end

local function clearBuilderCommands(unitId)
	if not builderCommandQueues[unitId] then
		return
	end

	for _, commandId in ipairs(builderCommandQueues[unitId]) do
		removeBuilderFromCommand(commandId, unitId)
	end
	builderCommandQueues[unitId] = nil
end

local function checkBuilder(unitId)
	local queueDepth = spGetUnitCommandCount(unitId)
	if not queueDepth or queueDepth <= 0 then
		clearBuilderCommands(unitId)
		return
	end

	local queue = spGetUnitCommands(unitId, math.min(queueDepth, MAX_QUEUE_DEPTH))
	local newCommandQueue = {}
	local newCommandMap = {}

	-- Step 1: Process the current queue
	for i = 1, #queue do
		local queueCommand = queue[i]
		if queueCommand.id < 0 then
			local commandId, unitDefId, positionX, positionZ = generateIdFromUnitCommand(queueCommand)

			table.insert(newCommandQueue, commandId)
			newCommandMap[commandId] = true

			if commandIdToCreatedUnitIdMap[commandId] == nil then
				local isNewCommand = false
				if buildCommands[commandId] == nil then
					local buildCommand = {} --- @class BuildCommandEntry
					buildCommand.builderCount = 0
					buildCommand.unitDefId = unitDefId
					buildCommand.teamId = spGetUnitTeam(unitId)
					buildCommand.positionX = positionX
					buildCommand.positionY = floor(queueCommand.params[2])
					buildCommand.positionZ = positionZ
					buildCommand.rotation = floor(queueCommand.params[4])
					buildCommand.builderIds = {}
					buildCommand.rawCommand = queueCommand
					buildCommands[commandId] = buildCommand
					isNewCommand = true
				end

				if not buildCommands[commandId].builderIds[unitId] then
					buildCommands[commandId].builderIds[unitId] = true
					buildCommands[commandId].builderCount = buildCommands[commandId].builderCount + 1
				end

				if isNewCommand then
					notifyEvent(Event.onBuildCommandAdded, commandId, buildCommands[commandId])
				end
			end
		end
	end

	-- Step 2: Compare old queue with new queue to find what was removed
	local oldCommandQueue = builderCommandQueues[unitId]
	if oldCommandQueue then
		for _, oldCommandId in ipairs(oldCommandQueue) do
			if not newCommandMap[oldCommandId] then
				removeBuilderFromCommand(oldCommandId, unitId)
			end
		end
	end

	builderCommandQueues[unitId] = newCommandQueue
end

local function clearUnit(unitId)
	if not createdUnitIdToCommandIdMap[unitId] then
		return
	end
	local commandId = createdUnitIdToCommandIdMap[unitId]
	local commandData = buildCommands[commandId]
	buildCommands[commandId] = nil
	commandIdToCreatedUnitIdMap[commandId] = nil
	createdUnitIdToCommandIdMap[unitId] = nil
	notifyEvent(Event.onUnitFinished, unitId, commandId, commandData)
end

local function processNewBuildCommands()
	local currentTime = os.clock()
	for unitId, commandClockTime in pairs(unitsAwaitingCommandProcessing) do
		if currentTime > commandClockTime then
			checkBuilder(unitId)
			unitsAwaitingCommandProcessing[unitId] = nil
		end
	end
end

local function periodicBuilderCheck()
	periodicCheckCounter = periodicCheckCounter + 1
	for unitId, _ in pairs(builderCommandQueues) do
		--- Load balancer which ensures that at most 30 units are checked per frame
		if (unitId + periodicCheckCounter) % 30 == 1 and not unitsAwaitingCommandProcessing[unitId] then
			checkBuilder(unitId)
		end
	end
end

local function cacheBuildOptions()
	for udefId, udef in ipairs(UnitDefs) do
		if udef.isBuilder and not udef.isFactory and udef.buildOptions and udef.buildOptions[1] then
			local buildSet = {}
			for i = 1, #udef.buildOptions do
				buildSet[udef.buildOptions[i]] = true
			end
			builderBuildOptions[udefId] = buildSet
		end
	end
end

local function resetStateAndReinitialize()
	buildCommands = {}
	builderCommandQueues = {}
	commandIdToCreatedUnitIdMap = {}
	createdUnitIdToCommandIdMap = {}
	unitsAwaitingCommandProcessing = {}
	cacheBuildOptions()

	-- Re-scan all units
	local allUnits = spGetAllUnits()
	for i = 1, #allUnits do
		local unitId = allUnits[i]
		if buildersList[spGetUnitDefID(unitId)] then
			checkBuilder(unitId)
		end
	end
end

--------------------------------------------------------------------------------
-- API Definition
--------------------------------------------------------------------------------

--- @class BuilderQueueApi
local BuilderQueueApi = {}

---@param callback fun(commandId: string, data: BuildCommandEntry)
function BuilderQueueApi.forEachActiveBuildCommand(callback, teamId)
	for commandId, commandEntry in pairs(buildCommands) do
		if commandEntry.builderCount > 0 and (teamId == nil or commandEntry.teamId == teamId) then
			callback(commandId, commandEntry)
		end
	end
end

BuilderQueueApi.onBuildCommandAdded = function(callback) return registerCallback(Event.onBuildCommandAdded, callback) end
BuilderQueueApi.onBuildCommandRemoved = function(callback) return registerCallback(Event.onBuildCommandRemoved, callback) end
BuilderQueueApi.onUnitCreated = function(callback) return registerCallback(Event.onUnitCreated, callback) end
BuilderQueueApi.onUnitFinished = function(callback) return registerCallback(Event.onUnitFinished, callback) end
BuilderQueueApi.onBuilderDestroyed = function(callback) return registerCallback(Event.onBuilderDestroyed, callback) end
BuilderQueueApi.unregisterCallback = unregisterCallback

---@param unitDefId number
---@return boolean
function BuilderQueueApi.isBuilder(unitDefId)
	return buildersList[unitDefId] ~= nil
end

---@param builderDefId number
---@param targetUnitDefId number
---@return boolean
function BuilderQueueApi.canBuilderBuild(builderDefId, targetUnitDefId)
	return builderBuildOptions[builderDefId] and builderBuildOptions[builderDefId][targetUnitDefId]
end

---@param commandId string
---@return BuildCommandEntry|nil
function BuilderQueueApi.getBuildCommandAtLocation(commandId)
	return buildCommands[commandId]
end

---@param targetCommandId string
---@return table|nil commandsToQueue
function BuilderQueueApi.getQueueFromLocation(targetCommandId)
	local targetCommand = buildCommands[targetCommandId]
	if not targetCommand then
		return nil
	end

	-- Find a builder that has this command in their queue
	local sourceBuilderUnitId
	for builderUnitId, _ in pairs(targetCommand.builderIds) do
		sourceBuilderUnitId = builderUnitId
		break
	end

	if not sourceBuilderUnitId then
		return nil
	end

	local builderQueue = builderCommandQueues[sourceBuilderUnitId]
	if not builderQueue then
		return nil
	end

	local startIndex = -1

	for i = 1, #builderQueue do
		if builderQueue[i] == targetCommandId then
			startIndex = i
			break
		end
	end

	local subQueueData = {}
	if startIndex > 0 then
		for i = startIndex, #builderQueue do
			local commandId = builderQueue[i]
			local commandData = buildCommands[commandId]
			if commandData then
				table.insert(subQueueData, commandData)
			end
		end
	end

	return #subQueueData > 0 and subQueueData or nil
end

---@param targetCommandId string
---@return table|nil commandsToQueue
function BuilderQueueApi.getQueueToLocation(targetCommandId)
	local targetCommand = buildCommands[targetCommandId]
	if not targetCommand then
		return nil
	end

	-- Find a builder that has this command in their queue
	local sourceBuilderUnitId
	for builderUnitId, _ in pairs(targetCommand.builderIds) do
		sourceBuilderUnitId = builderUnitId
		break
	end

	if not sourceBuilderUnitId then
		return nil
	end

	local builderQueue = builderCommandQueues[sourceBuilderUnitId]
	if not builderQueue then
		return nil
	end

	local endIndex = -1

	for i = 1, #builderQueue do
		if builderQueue[i] == targetCommandId then
			endIndex = i
			break
		end
	end

	local subQueueData = {}
	if endIndex > 0 then
		for i = 1, endIndex do
			local commandId = builderQueue[i]
			local commandData = buildCommands[commandId]
			if commandData then
				table.insert(subQueueData, commandData)
			end
		end
	end

	return #subQueueData > 0 and subQueueData or nil
end

--------------------------------------------------------------------------------
-- Widget Callins
--------------------------------------------------------------------------------

function widget:Initialize()
	resetStateAndReinitialize()
	WG.BuilderQueueApi = BuilderQueueApi
end

function widget:Update(dt)
	elapsedSeconds = elapsedSeconds + dt
	if elapsedSeconds > lastUpdateTime + 0.12 then
		lastUpdateTime = elapsedSeconds
		processNewBuildCommands()
		periodicBuilderCheck()
	end
end

function widget:PlayerChanged(playerId)
	-- Clear all data when player changes (spectating state changes)
	local myPlayerId = Spring.GetMyPlayerID()
	if playerId == myPlayerId then
		resetStateAndReinitialize()
	end
end

function widget:UnitCommand(unitId, unitDefId)
	if buildersList[unitDefId] then
		unitsAwaitingCommandProcessing[unitId] = os.clock() + 0.13
	end
end

function widget:UnitCreated(unitId, unitDefId)
	local x, _, z = spGetUnitPosition(unitId)
	if x then
		local commandId = generateId(unitDefId, floor(x), floor(z))
		local commandData = buildCommands[commandId]
		if commandData then
			buildCommands[commandId] = nil
			commandIdToCreatedUnitIdMap[commandId] = unitId
			createdUnitIdToCommandIdMap[unitId] = commandId
			notifyEvent(Event.onUnitCreated, unitId, unitDefId, commandId, commandData)
		end
	end
end

function widget:UnitFinished(unitId)
	clearUnit(unitId)
end

function widget:UnitDestroyed(unitId, unitDefId)
	if buildersList[unitDefId] then
		unitsAwaitingCommandProcessing[unitId] = nil
		clearBuilderCommands(unitId)
		notifyEvent(Event.onBuilderDestroyed, unitId, unitDefId)
	end
	clearUnit(unitId)
end

function widget:Shutdown()
	WG.BuilderQueueApi = nil
end
