local InterfaceFieldOfViewModule = {}

-- Dirs
local Camera = workspace.CurrentCamera

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

local FOVs = 
{
	[true] = -20, --50,
	[false] = 0, --70
}

local EffectInfo = 
{
	["Duration"] = .3,
	["Style"] = Enum.EasingStyle.Cubic,
	["Direction"] = Enum.EasingDirection.Out		
}

local Started = false
local Queue = 0


-- Services
local TweenService = game:GetService("TweenService")

-- Functions
-- MECHANICS
local function ChangeFOV(Value)
	-- Elements
	-- VALUES		
	local UIFOVOffsetValue = Camera:FindFirstChild("UIFOVOffset")
	
	if not UIFOVOffsetValue then
		DebugModule:Print(script.Name.. " | ChangeFOV | UIOffsetValue: ".. tostring(UIFOVOffsetValue).. " | Error: NO UI FOV OFFSET VALUE INSTANCE!")
		return nil
	end
	
	-- CORE
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	local tweeningInfo = {}
	tweeningInfo.Value = FOVs[Value]
	
	-- Functions
	-- INIT
	UtilitiesModule:CancelTween(UIFOVOffsetValue, TweenDict)
	TweenDict[UIFOVOffsetValue] = TweenService:Create(UIFOVOffsetValue, tweenInfo, tweeningInfo)
	TweenDict[UIFOVOffsetValue]:Play()
	UtilitiesModule:CompleteTween(UIFOVOffsetValue, TweenDict)
end

local function Update()
	-- Functions
	-- INIT
	
	if not Started then
		if Queue <= 0 then
			return nil
		end
		
		Started = true
		ChangeFOV(true)
		
	else
		if Queue > 0 then
			return nil
		end
		
		ChangeFOV(false)
		Started = false
	end
end

local function Effect(Value)
	-- Functions
	-- INIT
	
	if Value == nil then
		Queue = math.clamp(Queue + 1, 0, math.huge)		
	elseif Value == "Reset" then
		Queue = 0
	end
	Update()
end

local function Initialise(_CameraModule)
	-- Functions
	-- INIT
	CameraModule = _CameraModule
end

local function End()
	-- Functions
	-- INIT
	Queue = math.clamp(Queue - 1, 0, math.huge)
	
	Update()
end

-- DIRECT
function InterfaceFieldOfViewModule.Effect(NilParam, ...)
	return Effect(...)
end

function InterfaceFieldOfViewModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function InterfaceFieldOfViewModule.End(NilParam, ...)
	return End(...)
end

return InterfaceFieldOfViewModule
