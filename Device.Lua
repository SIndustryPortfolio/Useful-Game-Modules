local DeviceGameModule = {}

-- Client
local Player = game.Players.LocalPlayer

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated"):WaitForChild("Assets")["InfoModules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated"):WaitForChild("Remotes")["ClientServer"]

-- Info Modules
local DeviceInfoModule = require(InfoModulesFolder["Device"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Elements
-- FOLDERS
local ClientServerEventsFolder = ClientServerRemotesFolder["Events"]

-- REMOTES
local GameProcessEvent = ClientServerEventsFolder["GameProcess"]

-- CORE
local Connections = {}

-- Services
local UserInputService = game:GetService("UserInputService")

-- Functions
-- MECHANICS
local function DeviceChangedToMobile()
	-- Functions
	-- INIT
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["Mobile"] = DeviceChangedToMobile		
}

-- MECHANICS
local function HandleDeviceChangeClient()
	-- CORE
	local DeviceName = Player:GetAttributes()["Device"]
	
	-- Functions
	-- INIT
	if DeviceName == nil then
		return nil
	end
	
	local Function = ClientRequests[DeviceName]
	
	if Function == nil then
		return nil
	end
	
	return Function()
end

local function UpdateNewDevice(DeviceName)
	-- Functions
	-- INIT
	Player:SetAttribute("Device", DeviceName)
end

local function UpdateNewDeviceFromLastInput(LastUserInputType)
	-- CORE
	local Device = ""
	
	-- Functions
	-- INIT
	for DeviceName, DeviceInfo in pairs(DeviceInfoModule:GetAllDeviceInfo()) do
		for i, InputType in pairs(DeviceInfo["Inputs"]) do
			if LastUserInputType == InputType then
				Device = DeviceName
				break
			end
		end
		
		if Device ~= "" then
			break
		end
	end
	
	return UpdateNewDevice(Device)
end

local function UpdateDeviceFromCurrent()
	-- Functions
	-- INIT
	if UtilitiesModule:IsGamepadConnected() then
		UpdateNewDevice("Console")
	end
end

local function Initialise()
	-- Functions
	-- DIRECT
	local Connection1 = UserInputService.LastInputTypeChanged:Connect(function(...)
		return UpdateNewDeviceFromLastInput(...)
	end)
	
	local Connection2 = UserInputService.InputBegan:Connect(function(InputObject)
		return UpdateNewDeviceFromLastInput(InputObject.UserInputType)
	end)
	
	local Connection3 = Player:GetAttributeChangedSignal("Device"):Connect(function()
		return HandleDeviceChangeClient()
	end)
	
	local Connection4 = UserInputService.GamepadConnected:Connect(function(Gamepad)
		return UpdateDeviceFromCurrent()
	end)
	
	-- Connections 
	UtilitiesModule:AddToTable(Connections, Connection1, Connection2, Connection3, Connection4)
	
	-- INIT
	UpdateDeviceFromCurrent()
	
	return HandleDeviceChangeClient()
end

local function End()
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Connections)
end

-- DIRECT
function DeviceGameModule.Initialise()
	return Initialise()
end

function DeviceGameModule.End()
	return End()
end

return DeviceGameModule
