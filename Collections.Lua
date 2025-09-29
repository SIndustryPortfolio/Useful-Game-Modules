local CollectionsClientModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated")["Assets"]["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
--
local ClientRuntimeInitModule = nil

-- CORE
local Connections = {}
local RequiredModules = UtilitiesModule:RunSubModules(script, false, CollectionsClientModule)

-- Services
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS


local function Initialise(_ClientRuntimeInitModule)
	-- Functions
	-- INIT
	ClientRuntimeInitModule = _ClientRuntimeInitModule
	
	for ModuleName, Module in pairs(RequiredModules) do
		local Connection1 = CollectionService:GetInstanceAddedSignal(ModuleName):Connect(function(_Instance)
			return Module:TagAdded(_Instance)
		end)
		
		local Connection2 = CollectionService:GetInstanceRemovedSignal(ModuleName):Connect(function(_Instance)
			return Module:TagRemoved(_Instance)
		end)
		
		-- Connections
		UtilitiesModule:AddToTable(Connections, Connection1, Connection2)
		
		-- INIT
		for i, _Instance in pairs(CollectionService:GetTagged(ModuleName)) do
			task.spawn(function()
				return Module:TagAdded(_Instance)
			end)
		end
	end
end

-- DIRECT
function CollectionsClientModule.Initialise(NilParam, ...)
	return Initialise(...)
end

return CollectionsClientModule
