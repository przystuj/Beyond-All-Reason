local widget = widget ---@type Widget

function widget:GetInfo()
	return {
		name = "Join Existing Builder Queue",
		desc = "Adds a command which allows to join building queue of another builder.",
		author = "SuperKitowiec",
		date = "August 26, 2025",
		license = "GNU GPL, v2 or later",
		version = 1,
		layer = 1,
		enabled = true,
		handler = true,
	}
end

if Spring.GetSpectatingState() then
	return
end

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------

local ALWAYS_ON_MODE = false
local DEFAULT_ONLY_SINGLE_CMD = false
local HIGHLIGHT_NEARBY_GHOSTS = true

--------------------------------------------------------------------------------
-- Spring API Imports
--------------------------------------------------------------------------------

local spGetMyTeamID = Spring.GetMyTeamID
local spGetUnitDefId = Spring.GetUnitDefID
local spGetGroundHeight = Spring.GetGroundHeight
local spGetSelectedUnits = Spring.GetSelectedUnits
local spTraceScreenRay = Spring.TraceScreenRay
local spGetMouseState = Spring.GetMouseState
local spGetActiveCommand = Spring.GetActiveCommand
local spSetActiveCommand = Spring.SetActiveCommand
local spGetSpectatingState = Spring.GetSpectatingState
local spPlaySoundFile = Spring.PlaySoundFile
local spIsGUIHidden = Spring.IsGUIHidden
local spGetModKeyState = Spring.GetModKeyState
local spGiveOrderToUnitArray = Spring.GiveOrderToUnitArray

local mathSqrt = math.sqrt
local mathAbs = math.abs
local mathFloor = math.floor
local mathSin = math.sin
local mathCos = math.cos
local mathPi = math.pi
local mathMax = math.max
local mathMin = math.min
local tableWipe = function(t) for k in pairs(t) do t[k] = nil end end

--------------------------------------------------------------------------------
-- Command Definition & Constants
--------------------------------------------------------------------------------

local CMD_JOIN_BUILD_QUEUE = 455650
local CMD_JOIN_BUILD_QUEUE_DEFINITION = {
	id = CMD_JOIN_BUILD_QUEUE,
	type = CMDTYPE.ICON_MAP,
	name = 'Join Queue',
	cursor = 'join_build_queue',
	action = 'join_build_queue',
	tooltip = 'Join existing building queue from selected spot',
}

-- Highlighting constants
local CIRCLE_PIECES = 3
local CIRCLE_PIECE_DETAIL = 14
local CIRCLE_SPACE_USAGE = 0.8
local CIRCLE_INNER_OFFSET = 0
local ROTATION_SPEED = 8

local INNER_SIZE = 1.95
local OUTER_SIZE = 2.02

local ALPHA_FALLOFF_DISTANCE = 250
local ALPHA_FALLOFF_DISTANCE_SQ = ALPHA_FALLOFF_DISTANCE * ALPHA_FALLOFF_DISTANCE
local GHOST_HIGHLIGHT_MAX_ALPHA = 0.4
local TARGETED_QUEUE_BASE_ALPHA = 0.5
local WAVE_LENGTH = 20 -- queue items
local WAVE_FADE_OUT_DISTANCE = 30

local SUB_QUEUE_CACHE_THROTTLE_TIME = 1

local COLORS = {
	green = { 0.2, 1.0, 0.2 },
	yellow = { 1.0, 1.0, 0.2 },
	red = { 1.0, 0.2, 0.2 },
}

--------------------------------------------------------------------------------
-- Widget State
--------------------------------------------------------------------------------

-- API references
local builderQueueApi --- @type BuilderQueueApi

-- Caches
local ghostsToDraw = {}
local queueGhostsToDraw = {}
local queueGhostIndices = {}
local buildableSet = {}
local colorCache = {}
local selectedBuilders = {}
local selectionDirty = true
local groundHeightCache = {}
local subQueueCache = {}
local myTeamID

local cursorGround = { 0, 0, 0 }
local targetedGhost
local activeSubQueue

-- Animation
local circleList, chobbyInterface
local previousOsClock = os.clock()
local currentRotationAngle = 0
local currentRotationAngleOpposite = 0
local pulseTime = 0
local PULSE_DURATION = 3
local lastQueueAlphaUpdateTime = 0
local cachedQueueAlphas = {}
local subQueueCacheThrottleCounter = 0

-- Sine Lookup Table
local SIN_TABLE_SIZE = 512
local SIN_TABLE_MULTIPLIER = SIN_TABLE_SIZE / (2 * mathPi)
local sin_lookup_table = {}

--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------

local function reverseTable(tbl)
	local n = #tbl
	for i = 1, math.floor(n / 2) do
		local oppositeIndex = n - i + 1
		tbl[i], tbl[oppositeIndex] = tbl[oppositeIndex], tbl[i]
	end
end

local function fastSin(rad)
	local index = mathFloor(rad * SIN_TABLE_MULTIPLIER) % SIN_TABLE_SIZE
	return sin_lookup_table[index]
end

local function drawCircleLine(inner, outer)
	gl.BeginEnd(GL.QUADS, function()
		local detailPartWidth, a1, a2, a3, a4
		local width = CIRCLE_SPACE_USAGE
		local detail = CIRCLE_PIECE_DETAIL

		local radstep = (2.0 * mathPi) / CIRCLE_PIECES
		for i = 1, CIRCLE_PIECES do
			for d = 1, detail do
				detailPartWidth = ((width / detail) * d)
				a1 = ((i + detailPartWidth - (width / detail)) * radstep)
				a2 = ((i + detailPartWidth) * radstep)
				a3 = ((i + CIRCLE_INNER_OFFSET + detailPartWidth - (width / detail)) * radstep)
				a4 = ((i + CIRCLE_INNER_OFFSET + detailPartWidth) * radstep)

				gl.Vertex(mathSin(a4) * inner, 0, mathCos(a4) * inner)
				gl.Vertex(mathSin(a3) * inner, 0, mathCos(a3) * inner)
				gl.Vertex(mathSin(a1) * outer, 0, mathCos(a1) * outer)
				gl.Vertex(mathSin(a2) * outer, 0, mathCos(a2) * outer)
			end
		end
	end)
end

local function drawHighlightCircle(x, y, z, size, rotation, r, g, b, a)
	gl.Color(r, g, b, a)
	gl.PushMatrix()
	gl.Translate(x, y, z)
	gl.Scale(size, 1.0, size)
	gl.Rotate(rotation, 0, 1, 0)
	gl.CallList(circleList)
	gl.PopMatrix()
end

local function updateSelectedBuilders()
	tableWipe(selectedBuilders)
	local selectedUnits = spGetSelectedUnits()
	for i = 1, #selectedUnits do
		local unitId = selectedUnits[i]
		local unitDefId = spGetUnitDefId(unitId)
		if builderQueueApi.isBuilder(unitDefId) then
			selectedBuilders[unitId] = unitDefId
		end
	end
end

local function findTargetedGhostAtPos(groundPos)
	if not groundPos then return nil end
	local gx, gz = groundPos[1], groundPos[3]

	local closestGhost = nil
	local closestDistanceSq = math.huge

	for commandId, ghostData in pairs(ghostsToDraw) do
		local px, pz = ghostData.positionX, ghostData.positionZ
		local udef = UnitDefs[ghostData.unitDefId]
		local footprintX, footprintZ = udef.xsize * 4, udef.zsize * 4

		if (gx >= px - footprintX and gx <= px + footprintX and
			gz >= pz - footprintZ and gz <= pz + footprintZ) then
			local dx = gx - px
			local dz = gz - pz
			local distanceSq = dx * dx + dz * dz
			if distanceSq < closestDistanceSq then
				closestDistanceSq = distanceSq
				closestGhost = commandId
			end
		end
	end

	return closestGhost
end

local function resetCommandState()
	tableWipe(ghostsToDraw)
	tableWipe(queueGhostsToDraw)
	targetedGhost = nil
	activeSubQueue = nil
end

local function canAnySelectedBuilderBuild(targetUnitDefId)
	if not next(selectedBuilders) then
		return false
	end
	for _, builderDefId in pairs(selectedBuilders) do
		if builderQueueApi.canBuilderBuild(builderDefId, targetUnitDefId) then
			return true
		end
	end
	return false
end

local function getColorForGhost(commandId)
	local ghostData = queueGhostsToDraw[commandId] or ghostsToDraw[commandId]
	if not ghostData then
		return "red"
	end

	-- If no builders are selected, all ghosts are unbuildable (red).
	if not next(selectedBuilders) then
		return "red"
	end

	local targetUnitDefId = ghostData.unitDefId
	local canBuildCount, cannotBuildCount = 0, 0

	for _, builderDefId in pairs(selectedBuilders) do
		if builderQueueApi.canBuilderBuild(builderDefId, targetUnitDefId) then
			canBuildCount = canBuildCount + 1
		else
			cannotBuildCount = cannotBuildCount + 1
		end
	end

	if canBuildCount > 0 and cannotBuildCount == 0 then
		return "green"
	elseif canBuildCount > 0 and cannotBuildCount > 0 then
		return "yellow"
	else
		return "red"
	end
end

local function calculateSubQueue(targetCommandId, alt, ctrl)
	local result
	if DEFAULT_ONLY_SINGLE_CMD then
		alt = not alt
	end
	if ctrl then
		result = builderQueueApi.getQueueToLocation(targetCommandId)
		if result then
			reverseTable(result)
		end
	elseif alt then
		local command = builderQueueApi.getBuildCommandAtLocation(targetCommandId)
		if command then
			result = { command }
		end
	else
		result = builderQueueApi.getQueueFromLocation(targetCommandId)
	end
	return result or {}
end

local function getQueueFromLocation(targetCommandId)
	local alt, ctrl = spGetModKeyState()
	local modState = "none"
	if alt then modState = "alt" elseif ctrl then modState = "ctrl" end
	local cacheKey = targetCommandId .. "_" .. modState

	if subQueueCache[cacheKey] then
		return subQueueCache[cacheKey]
	end

	local result = calculateSubQueue(targetCommandId, alt, ctrl)
	subQueueCache[cacheKey] = result
	return result
end

local function handleFailedCommand()
	spPlaySoundFile("FailedCommand", 7, 'ui')
	if not ALWAYS_ON_MODE then
		spSetActiveCommand("join_build_queue")
	end
end

local function executeJoinQueue(options)
	if not targetedGhost then
		handleFailedCommand()
		return false
	end

	updateSelectedBuilders()

	if not ghostsToDraw[targetedGhost] then
		handleFailedCommand()
		return false
	end
	local targetUnitDefId = ghostsToDraw[targetedGhost].unitDefId

	if not canAnySelectedBuilderBuild(targetUnitDefId) then
		handleFailedCommand()
		return false
	end

	activeSubQueue = getQueueFromLocation(targetedGhost)
	if not activeSubQueue or #activeSubQueue == 0 then
		handleFailedCommand()
		return false
	end

	local commandsGiven = 0
	local insertIndex = 0

	for _, commandData in ipairs(activeSubQueue) do
		local commandUnitDefId = commandData.unitDefId
		local command = commandData.rawCommand
		local capableBuilders = {}

		for builderUnitId, builderDefId in pairs(selectedBuilders) do
			if builderQueueApi.canBuilderBuild(builderDefId, commandUnitDefId) then
				table.insert(capableBuilders, builderUnitId)
			end
		end

		if #capableBuilders > 0 then
			if options.meta then
				local insertParams = { insertIndex, command.id, 0, unpack(command.params) }
				spGiveOrderToUnitArray(capableBuilders, CMD.INSERT, insertParams, { "alt" })
				insertIndex = insertIndex + 1
			else
				local modifiers = {}
				if options.shift or commandsGiven > 0 then
					table.insert(modifiers, "shift")
				end
				spGiveOrderToUnitArray(capableBuilders, command.id, command.params, modifiers)
			end
			commandsGiven = commandsGiven + 1
		end
	end

	if commandsGiven == 0 then
		handleFailedCommand()
		return false
	else
		spPlaySoundFile("cmd-repair", 1, 'ui')
	end

	return true
end

local function updateGhostsList()
	local _, cmdID, _ = spGetActiveCommand()
	local inCommandMode = not ALWAYS_ON_MODE and (cmdID == CMD_JOIN_BUILD_QUEUE)
	local inAlwaysOnMode = ALWAYS_ON_MODE and next(selectedBuilders)

	if not inCommandMode and not inAlwaysOnMode then
		resetCommandState()
		return
	end

	if not next(selectedBuilders) then
		selectionDirty = true -- Reset dirty flag for when a unit is next selected.
	end

	if selectionDirty then
		tableWipe(buildableSet)
		for _, builderDefId in pairs(selectedBuilders) do
			local udef = UnitDefs[builderDefId]
			if udef and udef.buildOptions then
				for i = 1, #udef.buildOptions do
					buildableSet[udef.buildOptions[i]] = true
				end
			end
		end
		selectionDirty = false
	end

	tableWipe(ghostsToDraw)
	builderQueueApi.forEachActiveBuildCommand(function(commandId, commandData)
		ghostsToDraw[commandId] = commandData
	end, myTeamID)

	tableWipe(queueGhostsToDraw)
	tableWipe(queueGhostIndices)

	local ghostData = ghostsToDraw[targetedGhost]
	if targetedGhost and ghostData and canAnySelectedBuilderBuild(ghostData.unitDefId) then
		activeSubQueue = getQueueFromLocation(targetedGhost)
		for i, commandData in ipairs(activeSubQueue) do
			local commandId = string.format('%s_%s_%s', commandData.unitDefId, commandData.positionX, commandData.positionZ)
			queueGhostsToDraw[commandId] = commandData
			queueGhostIndices[commandId] = i
		end
	else
		activeSubQueue = nil
	end
end

--------------------------------------------------------------------------------
-- Widget Callins
--------------------------------------------------------------------------------

function widget:Initialize()
	if Spring.GetSpectatingState() then
		return
	end
	if not WG.BuilderQueueApi then
		error("API Builder Queue is disabled")
		widget:Shutdown()
		return
	end
	Spring.AssignMouseCursor("join_build_queue", "cursorrepair", false)

	myTeamID = spGetMyTeamID()
	builderQueueApi = WG.BuilderQueueApi
	circleList = gl.CreateList(drawCircleLine, INNER_SIZE, OUTER_SIZE)
	selectionDirty = true

	for i = 0, SIN_TABLE_SIZE - 1 do
		sin_lookup_table[i] = mathSin((i / SIN_TABLE_SIZE) * 2 * mathPi)
	end
end

function widget:Shutdown()
	if circleList then
		gl.DeleteList(circleList)
		circleList = nil
	end
end

function widget:PlayerChanged()
	myTeamID = spGetMyTeamID()
end

function widget:CommandsChanged()
	if spGetSpectatingState() then return end
	selectionDirty = true

	updateSelectedBuilders()

	if not ALWAYS_ON_MODE and next(selectedBuilders) then
		widgetHandler.customCommands[#widgetHandler.customCommands + 1] = CMD_JOIN_BUILD_QUEUE_DEFINITION
	end
end

function widget:CommandNotify(cmdId, cmdParams, options)
	if ALWAYS_ON_MODE or cmdId ~= CMD_JOIN_BUILD_QUEUE then return false end

	local mx, my = spGetMouseState()
	local _, groundPos = spTraceScreenRay(mx, my, true)
	targetedGhost = findTargetedGhostAtPos(groundPos)
	executeJoinQueue(options)
	return true
end

function widget:MousePress(x, y, button)
	if not ALWAYS_ON_MODE then return false end
	if button ~= 3 then return false end

	local _, groundPos = spTraceScreenRay(x, y, true)
	local currentTarget = findTargetedGhostAtPos(groundPos)
	if not currentTarget then return false end

	if not next(selectedBuilders) then return false end

	local _, cmdID, _ = spGetActiveCommand()
	if cmdID then return false end

	targetedGhost = currentTarget

	local _, ctrl, meta, shift = spGetModKeyState()

	return executeJoinQueue({ shift = shift, ctrl = ctrl, meta = meta })
end


function widget:Update(dt)
	if not WG.BuilderQueueApi then
		error("API Builder Queue is disabled")
		widget:Shutdown()
		return
	end

	subQueueCacheThrottleCounter = subQueueCacheThrottleCounter + dt
	if subQueueCacheThrottleCounter > SUB_QUEUE_CACHE_THROTTLE_TIME then
		subQueueCacheThrottleCounter = 0
		tableWipe(subQueueCache)
	end

	updateSelectedBuilders()
	updateGhostsList()

	-- Only check mouse position if there are ghosts to interact with.
	if not next(ghostsToDraw) and not next(queueGhostsToDraw) then return end

	local mx, my = spGetMouseState()
	local _, coords = spTraceScreenRay(mx, my, true)

	if type(coords) == "table" then
		cursorGround = coords
		local newTargetedGhost = findTargetedGhostAtPos(coords)
		if newTargetedGhost ~= targetedGhost then
			targetedGhost = newTargetedGhost
			pulseTime = -0.3
			tableWipe(subQueueCache)
			if targetedGhost then
				tableWipe(groundHeightCache)
			end
		end
	end
end

function widget:RecvLuaMsg(msg)
	if msg:sub(1, 18) == "LobbyOverlayActive" then
		chobbyInterface = (msg:sub(1, 19) == "LobbyOverlayActive1")
	end
end

function widget:DrawWorldPreUnit()
	if chobbyInterface or spIsGUIHidden() then return end

	tableWipe(colorCache)

	if not next(ghostsToDraw) and not next(queueGhostsToDraw) then return end

	local currentTime = os.clock()
	local clockDifference = currentTime - previousOsClock
	previousOsClock = currentTime

	pulseTime = pulseTime + clockDifference
	if pulseTime > PULSE_DURATION then
		pulseTime = pulseTime - PULSE_DURATION
	end

	if ROTATION_SPEED > 0 then
		local angleDifference = ROTATION_SPEED * (clockDifference * 5)
		currentRotationAngle = (currentRotationAngle + (angleDifference * 0.66)) % 360
		currentRotationAngleOpposite = (currentRotationAngleOpposite - angleDifference) % 360
	end

	local ghostsToRender = next(queueGhostsToDraw) and queueGhostsToDraw or ghostsToDraw
	local isQueueMode = next(queueGhostsToDraw) ~= nil

	if isQueueMode and (currentTime - lastQueueAlphaUpdateTime > 0.05) then
		lastQueueAlphaUpdateTime = currentTime
		tableWipe(cachedQueueAlphas)

		if activeSubQueue and #activeSubQueue >= 8 then
			local baseAlpha = TARGETED_QUEUE_BASE_ALPHA
			local wavePhase = (pulseTime / PULSE_DURATION) * WAVE_LENGTH * 4

			local fadeFactor = mathMax(0, 1 - (wavePhase / WAVE_FADE_OUT_DISTANCE))

			for commandId, _ in pairs(ghostsToRender) do
				local queueIndex = queueGhostIndices[commandId] or 1
				local itemPosition = queueIndex - 1
				local waveDistance = mathAbs(wavePhase - itemPosition)

				local waveInfluence = mathMax(0, 1 - (waveDistance / (WAVE_LENGTH * 0.25)))
				local waveValue = fastSin(waveInfluence * mathPi)

				local waveIntensity = 1 * fadeFactor
				local alphaMult = 1.0 + (waveValue * waveIntensity)
				cachedQueueAlphas[commandId] = baseAlpha * alphaMult
			end
		end
	end

	for commandId, ghostData in pairs(ghostsToRender) do
		local px, pz = ghostData.positionX, ghostData.positionZ
		local alpha
		if isQueueMode then
			alpha = cachedQueueAlphas[commandId] or TARGETED_QUEUE_BASE_ALPHA
		elseif HIGHLIGHT_NEARBY_GHOSTS then
			local xDiff = cursorGround[1] - px
			local zDiff = cursorGround[3] - pz
			local distSq = xDiff * xDiff + zDiff * zDiff
			if distSq < ALPHA_FALLOFF_DISTANCE_SQ then
				local dist = mathSqrt(distSq)
				alpha = (1 - dist / ALPHA_FALLOFF_DISTANCE) * 0.7
				alpha = mathMin(alpha, GHOST_HIGHLIGHT_MAX_ALPHA)
			else
				alpha = 0
			end
		else
			alpha = 0
		end

		if alpha > 0.005 then
			local colorName = colorCache[commandId]
			if not colorName then
				colorName = getColorForGhost(commandId)
				colorCache[commandId] = colorName
			end
			local r, g, b = unpack(COLORS[colorName])

			local udef = UnitDefs[ghostData.unitDefId]
			local size = udef.xsize + udef.zsize

			if commandId == targetedGhost then
				alpha = 1
				if isQueueMode then
					r, g, b = r * 1.2, g, b * 1.2
				end
			end

			local py = groundHeightCache[commandId]
			if not py then
				py = spGetGroundHeight(px, pz)
				groundHeightCache[commandId] = py
			end

			drawHighlightCircle(px, py, pz, size, currentRotationAngle, r, g, b, alpha * TARGETED_QUEUE_BASE_ALPHA)
			drawHighlightCircle(px, py, pz, size * 1.18, -currentRotationAngle, r, g, b, alpha)
		end
	end

	gl.Color(1, 1, 1, 1)
end
