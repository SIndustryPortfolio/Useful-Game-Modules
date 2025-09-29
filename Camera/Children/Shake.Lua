local ShakeModule = {}

-- Client
local Player = game.Players.LocalPlayer

-- Dirs
local Camera = workspace.CurrentCamera
local DumpFolder = workspace["Dump"]

-- EXT
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])
--
local CameraModule = nil

-- CORE
local Connections = {}
local TweenDict = {}

local EffectInfo = 
	{
		["Duration"] = .3,
		["Style"] = Enum.EasingStyle.Cubic,
		["Direction"] = Enum.EasingDirection.Out		
	}

local Started = false
local LastEffectTick = nil

-- Services
local TweenService = game:GetService("TweenService")

-- Functions
-- MECHANICS
local function Initialise(_CameraModule)
	-- Functions
	-- INIT
	CameraModule = _CameraModule
end

local function Effect(Duration, Intensity, Options)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player, true)
	local StartTime = UtilitiesModule:GetTick()
	LastEffectTick = StartTime
	
	local AccumulatedTime = 0
	local Damp = 10
	
	-- Functions
	-- INIT
	if not Character then
		return nil
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local HumanoidRootPart = Character.PrimaryPart
	
	if not Humanoid then
		return nil
	end
	
	local Connection1 = nil
	
	Connection1 = UtilitiesModule:RenderSteppedFPSLock(30, function(DeltaTime)
		AccumulatedTime += DeltaTime
		
		if not Humanoid or not HumanoidRootPart then
			return UtilitiesModule:DisconnectConnections({Connection1})
		end
		
		local TimeNow = UtilitiesModule:GetTick()
		local TimeSpan = TimeNow - StartTime
		local MaxMultiplier = Intensity / 100
		
		local Multiplier = MaxMultiplier
		
		
		if Options ~= nil and Options["Position"] ~= nil and Options["MaxDistance"] ~= nil then
			local Distance = (Options["Position"] - HumanoidRootPart.Position).Magnitude
			
			if Distance > Options["MaxDistance"] then
				Intensity = 0
				Multiplier = 0
			else
				Intensity = math.clamp(Options["MaxIntensity"] * (1 - (Distance / Options["MaxDistance"])), 0, Options["MaxIntensity"])
				Multiplier = math.clamp(MaxMultiplier * (1 - (Distance / Options["MaxDistance"])), 0, MaxMultiplier)
			end
		end
		
		if TimeSpan > Duration then
			if StartTime == LastEffectTick then
				Humanoid.CameraOffset = Vector3.new()
			end	
			
			return UtilitiesModule:DisconnectConnections({Connection1})
		end
		
		local BobbleX = math.cos(AccumulatedTime * Intensity) * Multiplier
		local BobbleY = math.abs(math.sin(AccumulatedTime * Intensity)) * Multiplier
		local Bobble = Vector3.new(BobbleX, BobbleY, 0)
		
		if Options ~= nil and Options["CameraInterfaces"] ~= nil then
			for i, UIName in pairs(Options["CameraInterfaces"]) do
				local FoundUIHolderPart = DumpFolder["UI"]:FindFirstChild(UIName)
				
				if not FoundUIHolderPart then
					continue
				end
				
				FoundUIHolderPart:SetAttribute("Offset", (FoundUIHolderPart:GetAttributes()["Offset"] or Vector3.zero):Lerp(-Bobble, Damp * DeltaTime))
			end
			
		end
		
		Humanoid.CameraOffset = Humanoid.CameraOffset:lerp(Bobble, Damp * DeltaTime)
	end)
	
	-- Connections
	table.insert(CameraModule:GetCameraConnections(), Connection1)
	
	return Connection1
end

local function End()
	-- Functions
	-- INIT
	
end

-- DIRECT
function ShakeModule.Effect(NilParam, ...)
	return Effect(...)
end

function ShakeModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function ShakeModule.End(NilParam, ...)
	return End(...)
end

return ShakeModule
