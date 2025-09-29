local HapticsModule = {}

-- Client
local Player = game.Players.LocalPlayer

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated"):WaitForChild("Assets")["InfoModules"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated"):WaitForChild("Assets")["Modules"]

-- Info Modules
local DeviceInfoModule = require(InfoModulesFolder["Device"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local MotorToLastTick = {}

-- Services
local HapticService = game:GetService("HapticService")
local UserInputService = game:GetService("UserInputService")

-- Functions
-- MECHANICS
local function VibrateNow(InputType, Motor, Intensity, Duration)
	-- CORE
	local TimeNow = UtilitiesModule:GetTick()

	-- Functions
	-- INIT
	if not table.find(DeviceInfoModule:GetDeviceInfo("Console")["Inputs"], InputType) then
		InputType = Enum.UserInputType.Gamepad1
	end
	
	MotorToLastTick[Motor] = TimeNow

	HapticService:SetMotor(InputType, Motor, Intensity) -- Full intensity
	
	task.delay(Duration, function()
		if MotorToLastTick[Motor] ~= TimeNow then
			return nil
		end
		
		UtilitiesModule:RemoveKeys(MotorToLastTick, Motor)

		HapticService:SetMotor(InputType, Motor, 0)
	end)
end

local function Vibrate(...)
	-- Functions
	-- INIT
	local InputType = UserInputService:GetLastInputType()	
	
	VibrateNow(InputType, ...)
end

-- DIRECT
function HapticsModule.Vibrate(NilParm, ...)
	return Vibrate(...)
end

return HapticsModule
