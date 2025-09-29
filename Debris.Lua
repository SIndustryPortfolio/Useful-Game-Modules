local DebrisModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local MaxTries = 2

-- Services
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

-- Functions
-- MECHANICS
local function CheckPropertiesAgainstItem(_Instance, PropertiesToMatch)
	-- Functions
	-- INIT
	for PropertyName, PropertyValue in pairs(PropertiesToMatch) do
		if _Instance[PropertyName] ~= PropertyValue then
			return false
		end
	end
	
	return true
end

local function RemoveCollections(_Instance)
	-- Functions
	-- INIT
	for i, CollectionName in pairs(CollectionService:GetTags(_Instance)) do
		CollectionService:RemoveTag(_Instance, CollectionName)
	end
end

local function Destroy(_Instance, PropertiesToMatch, Connections, CallBackFunction)
	-- Functions
	-- INIT
	if _Instance == nil or _Instance.Parent == nil or typeof(_Instance) ~= "Instance" then
		return nil
	end
	
	if CallBackFunction ~= nil then
		CallBackFunction()
	end
	
	if PropertiesToMatch == nil then
		if Connections ~= nil then
			UtilitiesModule:DisconnectConnections(Connections)
		end

		RemoveCollections(_Instance)
		return _Instance:Destroy()
	else
		if CheckPropertiesAgainstItem(_Instance, PropertiesToMatch) then
			if Connections ~= nil then
				UtilitiesModule:DisconnectConnections(Connections)
			end

			RemoveCollections(_Instance)
			return _Instance:Destroy()
		end
	end
	
	UtilitiesModule:TryFor(1, function()
		_Instance.Parent = nil
		collectgarbage("collect")
	end)
end

local function AddItem(_Instance, TimeToLive, ...)
	-- Functions
	-- INIT
	if not _Instance then
		return nil
	end
	
	if typeof(_Instance) == "table" then
		for i, _TableInstance in pairs(_Instance) do
			AddItem(_TableInstance)
		end
		return
	end
	
	local AccumulatedTime = 0
	local DestroyArgs = {...}
	
	if TimeToLive ~= nil then
		local Connection1 = nil

		Connection1 = UtilitiesModule:RenderSteppedFPSLock(30, function(DeltaTime) --RunService.Heartbeat:Connect(function()
			-- CORE
			AccumulatedTime += DeltaTime

			if not _Instance then
				return UtilitiesModule:DisconnectConnections({Connection1})
			end

			if AccumulatedTime < TimeToLive then
				return nil
			end
			
			UtilitiesModule:DisconnectConnections({Connection1})

			UtilitiesModule:TryFor(MaxTries, function()
				return Destroy(_Instance, unpack(DestroyArgs))
			end)
		end)
	else
		UtilitiesModule:TryFor(MaxTries, function()
			return Destroy(_Instance, unpack(DestroyArgs))
		end)
	end
end

-- DIRECT
function DebrisModule.AddItem(NilParam, ...)
	return AddItem(...)
end

return DebrisModule
