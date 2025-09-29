local SoundsModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local RequiredModules = UtilitiesModule:RunSubModules(script, nil, SoundsModule)

-- Functions
-- MECHANICS
local function Play(Type, ...)
	-- CORE
	local Args = {...}
	
	-- Functions
	-- INIT
	local Success, Error = pcall(function()
		return RequiredModules[Type]:Play(unpack(Args))
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | PlaySound | Type: ".. tostring(Type).. " | Args: ".. tostring(Args).. " | Error: ".. tostring(Error))
	else
		return Error -- SOUND INSTANCE
	end
end

local function Mute(Type)
	-- Functions
	-- INIT
	if Type ~= nil then
		RequiredModules[Type]:Mute()
	else
		for ModuleName, Module in pairs(RequiredModules) do
			Module:Mute()
		end
	end
end

local function Unmute(Type)
	-- Functions
	-- INIT
	if Type ~= nil then
		RequiredModules[Type]:Unmute()
	else
		for ModuleName, Module in pairs(RequiredModules) do
			Module:Unmute()
		end
	end
end

-- DIRECT
function SoundsModule.Unmute(NilParam, ...)
	return Unmute(...)
end

function SoundsModule.Mute(NilParam, ...)
	return Mute(...)
end

function SoundsModule.Play(NilParam, ...)
	return Play(...)
end

return SoundsModule
