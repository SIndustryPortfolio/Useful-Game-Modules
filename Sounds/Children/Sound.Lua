local SoundsSoundModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated"):WaitForChild("Assets")["InfoModules"]
local DumpFolder = workspace["Dump"]

-- Info Modules
local SoundsInfoModule = require(InfoModulesFolder["Sounds"])

-- Modules
local DebrisModule = require(ModulesFolder["Debris"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
--
local SoundsModule = nil

-- CORE
local Index = 0
local CustomConnection = nil

local SoundEffectsCacheFolder = nil

local DefaultSoundVolume = 0.5

-- Services
local SoundService = game:GetService("SoundService")

-- Functions
-- MECHANICS
local function CreateTempPart()
	-- Functions
	-- INIT
	local TempPart = Instance.new("Part")
	
	UtilitiesModule:ApplyProperties(TempPart, 
	{
		[{"CanCollide", "CanQuery", "CanTouch", "CastShadow", "EnableFluidForces"}] = false,
		[{"Anchored", "Massless"}] = true,
		["Transparency"] = 1,
		["Material"] = Enum.Material.SmoothPlastic,
		["Size"] = Vector3.one,
		["Name"] = "TempSoundPart",
		["Parent"] = DumpFolder["Sound"]
	})
	
	return TempPart
end

local function Play(_SoundInfo, ParentOrLocation, Properties)
	-- Functions
	-- INIT
	local SoundInfo = nil 
	
	if _SoundInfo["Id"] ~= nil then
		SoundInfo = _SoundInfo
	else
		SoundInfo = SoundsInfoModule:GetSounds("Effects")[_SoundInfo["Type"]][_SoundInfo["Name"]]
	end
	
	local Parent = SoundEffectsCacheFolder

	if ParentOrLocation then
		if typeof(ParentOrLocation) == "Instance" then
			Parent = ParentOrLocation
		else
			Parent = CreateTempPart()
			
			if typeof(ParentOrLocation) == "CFrame" then
				Parent.CFrame = ParentOrLocation
			else
				Parent.Position = ParentOrLocation
			end
		end
	end

	local Sound = Instance.new("Sound")
	
	if SoundInfo["Name"] then
		Sound.Name = SoundInfo["Name"]
	else
		Sound.Name = tostring(SoundInfo["Id"])
	end
	
	Sound.SoundId = SoundInfo["Id"]
	Sound.Volume = DefaultSoundVolume
	Sound.Parent = Parent
	
	if Properties then
		UtilitiesModule:ApplyProperties(Sound, Properties)
	end
	
	Sound:Play()
	
	if not Sound["Looped"] and not Sound:GetAttributes()["DontDestroyWhenFinished"] then
		local Connection1 = nil
		
		Connection1 = Sound.Ended:Connect(function()
			UtilitiesModule:DisconnectConnections({Connection1})
			
			UtilitiesModule:TryFor(1, function()
				Sound:Stop()
				Sound.Volume = 0
			end)
			
			DebrisModule:AddItem(Sound, (Sound.TimeLength / 4))
		end)
	end
	
	
	return Sound
end

local function Mute()
	-- Functions
	-- INIT
end

local function Unmute()
	-- Functions
	-- INIT
end


local function Initialise(_SoundsModule)
	-- Functions
	-- INIT
	SoundsModule = _SoundsModule
	
	-- Instancing
	SoundEffectsCacheFolder = SoundService:FindFirstChild("SoundEffects")

	if not SoundEffectsCacheFolder then
		SoundEffectsCacheFolder = Instance.new("Folder", SoundService)
		SoundEffectsCacheFolder.Name = "SoundEffects"
	end
end

local function End()
	-- Functions
	-- INIT
	
end

-- DIRECT
function SoundsSoundModule.Mute()
	return Mute()
end

function SoundsSoundModule.Unmute()
	return Unmute()
end

function SoundsSoundModule.Play(NilParam, ...)
	return Play(...)
end

function SoundsSoundModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function SoundsSoundModule.End(NilParam, ...)
	return End(...)
end

return SoundsSoundModule
