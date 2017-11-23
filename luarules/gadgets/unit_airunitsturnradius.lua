function gadget:GetInfo()
  return {
    name      = "TurnRadius",
    desc      = "Fixes TurnRadius Dynamically for bombers",
    author    = "Doo",
    date      = "Sept 19th 2017",
    license   = "GNU GPL, v2 or later",
    layer     = 0,
    enabled   = true  --  loaded by default?
  }
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

if gadgetHandler:IsSyncedCode() then
isBomb = {}
isBomber = {}
Bombers = {}

for id, wDef in pairs(WeaponDefs) do
	if wDef.type == "AircraftBomb" then
		isBomb[id] = true
	end
end

for id, uDef in pairs(UnitDefs) do
	if (uDef["weapons"] and uDef["weapons"][1] and isBomb[uDef["weapons"][1].weaponDef] == true) or (uDef.name == "armlance" or uDef.name == "cortitan") then
		isBomber[id] = true
	end
end

function gadget:Initialize()
	for ct, unitID in pairs(Spring.GetAllUnits()) do
	gadget:UnitCreated(unitID, Spring.GetUnitDefID(unitID))
	end
end

function gadget:UnitCreated(unitID, unitDefID)
	if isBomber[Spring.GetUnitDefID(unitID)] then
		Bombers[unitID] = true
	end
end

function gadget:UnitDestroyed(unitID)
	if Bombers[unitID] then
		Bombers[unitID] = nil
	end
end

function gadget:GameFrame()
	for unitID, isbomber in pairs (Bombers) do
		local cQueue = Spring.GetCommandQueue(unitID,1)
			if (cQueue[1] and cQueue[1].id == CMD.ATTACK) or (not cQueue[1]) then
				Spring.MoveCtrl.SetAirMoveTypeData(unitID, "turnRadius", 500)
			else
				Spring.MoveCtrl.SetAirMoveTypeData(unitID, "turnRadius", UnitDefs[Spring.GetUnitDefID(unitID)].turnRadius)
			end
	end
end

function gadget:AllowCommand(unitID, _, _, _, cmdID)
	if Bombers[unitID] then
		if cmdID == CMD.ATTACK then
			Spring.MoveCtrl.SetAirMoveTypeData(unitID, "turnRadius", 500)
		else
			Spring.MoveCtrl.SetAirMoveTypeData(unitID, "turnRadius", UnitDefs[Spring.GetUnitDefID(unitID)].turnRadius)
		end
	end
	return true
end
end		