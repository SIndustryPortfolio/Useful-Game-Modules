local CacheCleanUpRuntimeModule = {}

-- Dirs
local ReplicatedFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated")

local SharedCachesFolder = ReplicatedFolder["Assets"]["Caches"]
local SharedModulesFolder = ReplicatedFolder["Assets"]["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local Connections = {}
local RequiredModules = {}

local CacheCleanUpTime = UtilitiesModule:MinutesToSeconds(25)
local LastCleanUpTime = UtilitiesModule:GetUTCTimeNow()

-- Services
local RunService = game:GetService("RunService")

-- Functions
-- MECHANICS
local function CleanGlobalCaches(TimeNow)
	-- Functions
	-- INIT
	for ModuleName, Module in pairs(RequiredModules["Global"]) do
		local AllCache = Module:GetAll()

		for Key, ValueInfo in pairs(AllCache) do
			local ValueTime = ValueInfo["Time"]
			local TimeSpan = TimeNow - ValueTime
			
			if TimeSpan < CacheCleanUpTime then
				continue
			end
			
			Module:Remove(Key)
		end
	end
end

local function Render()
	-- CORE
	local TimeNow = UtilitiesModule:GetUTCTimeNow()
	local TimeSpan = TimeNow - LastCleanUpTime
	
	-- Functions
	-- INIT
	if TimeSpan < CacheCleanUpTime then
		return nil
	end

	LastCleanUpTime = TimeNow

	CleanGlobalCaches(TimeNow)	
end

local function Initialise()
	-- Functions
	-- DIRECT
	local Connection1 = UtilitiesModule:RenderSteppedFPSLock(10, Render)
	
	-- Connections
	table.insert(Connections, Connection1)
	
	-- INIT
	for i, CategoryFolder in pairs(SharedCachesFolder:GetChildren()) do
		RequiredModules[CategoryFolder.Name] = UtilitiesModule:RunSubModules(CategoryFolder, true)
	end
end

local function End()
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Connections)
end

-- DIRECT
function CacheCleanUpRuntimeModule.Initialise()
	return Initialise()
end

function CacheCleanUpRuntimeModule.End()
	return End()
end

return CacheCleanUpRuntimeModule
