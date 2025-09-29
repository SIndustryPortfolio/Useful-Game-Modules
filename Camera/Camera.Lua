local CameraModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated"):WaitForChild("Assets")["Modules"]

-- Client
local Player = game.Players.LocalPlayer

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])
local DebrisModule = require(ModulesFolder["Debris"])

-- CORE
local CameraAttributes = 
{
	["Offset"] = Vector3.new()	
}

local RequiredModules = UtilitiesModule:RunSubModules(script, nil, CameraModule)

local CameraConnections = {}
local TweenDict = {}

local FOVOffsetValueNames = {"UIFOVOffset"}

-- Functions
-- MECHANICS

local function GetCamera()
	-- Functions
	-- INIT
	return workspace.CurrentCamera
end

local function UpdateFOV()
	-- CORE
	local FOVToAdd = 0
	local Camera = GetCamera()

	-- Functions
	-- INIT
	for i, AttributeName in pairs(FOVOffsetValueNames) do
		FOVToAdd += Camera:FindFirstChild(AttributeName).Value or 0
	end

	Camera.FieldOfView = Camera:GetAttributes()["BaseFOV"] + FOVToAdd
end


local function SetupCamera()
	-- CORE
	local Camera = GetCamera()
	
	-- Functions
	-- MECHANICS
	local function Render()
		-- Functions
		-- INIT
		UpdateFOV()
	end

	-- INIT
	for AttributeName, AttributeValue in pairs(CameraAttributes) do
		Camera:SetAttribute(AttributeName, AttributeValue)
	end
	
	-- Functions
	-- DIRECT
	local Connection1 = UtilitiesModule:RenderSteppedFPSLock(60, Render)

	-- Connections
	UtilitiesModule:AddToTable(CameraConnections, Connection1)
	
	-- INIT
	Camera:SetAttribute("BaseFOV", 70)

	for i, AttributeName in pairs(FOVOffsetValueNames) do
		local NumberValue = Instance.new("NumberValue")

		UtilitiesModule:ApplyProperties(NumberValue, 
		{
			["Name"] = AttributeName,
			["Value"] = 0		
		})

		NumberValue.Parent = Camera
	end
end

--[[local function GetCharacter()
	--return Player.Character or Player.CharacterAdded:Wait()
end]]

local function ResetCamera(FullReset)
	-- CORE
	local Camera = GetCamera()
	local Character = UtilitiesModule:GetCharacter(Player, true) --GetCharacter()

	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(CameraConnections)
	UtilitiesModule:CancelTween(Camera, TweenDict)
	
	task.wait()
		
	for i, Blur in pairs(Camera:GetChildren()) do
		if not Blur:IsA("BlurEffect") then
			continue
		end
		
		DebrisModule:AddItem(Blur)
	end
		
	for ModuleName, RequiredModule in pairs(RequiredModules) do
		if RequiredModule and RequiredModule.Reset ~= nil then
			RequiredModule:Reset()
		end
	end
	
	if Camera:GetAttributes()["Offset"] ~= nil then
		Camera:SetAttribute("Offset", Vector3.new())
	end
	
	
	if FullReset then
		Character = Character or UtilitiesModule:GetCharacter(Player)

		--UtilitiesModule--:WaitUntilLoaded(Character)
		
		if not Character then
			return nil
		end
		
		DebugModule:Print(script.Name.. " | ResetCamera | Full reset!")
		
		Camera.CFrame = Character:WaitForChild("HumanoidRootPart").CFrame
		Camera.CameraType = Enum.CameraType.Custom
		Camera.CameraSubject = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	end
	
	SetupCamera()
end	

local function CameraProcess(FunctionName, Toggle, ...)
	-- Functions
	-- INIT
	local Args = {...}
	
	local Success, Error = pcall(function()
		local RequiredModule = RequiredModules[FunctionName] --require(UtilitiesModule:WaitForChildTimed(script, FunctionName))
		
		if Toggle then
			if RequiredModule.Effect ~= nil then
				return RequiredModule:Effect(unpack(Args))
			end
		else
			if RequiredModule.End ~= nil then
				return RequiredModule:End(unpack(Args))
			end
		end
	end)
	
	if Success then
		return Error
	else
		DebugModule:Print(script.Name.. " | CameraProcess | FunctionName: ".. tostring(FunctionName).. " | Toggle: ".. tostring(Toggle).. " | Args: ".. tostring(Args).. " | Error: ".. tostring(Error))
		--DebugModule:PrintError, "Error")
	end
end

local function CreateBlurEffect()
	-- Instancing
	local Blur = GetCamera():FindFirstChildOfClass("BlurEffect") or Instance.new("BlurEffect")
	Blur.Size = 0
	Blur.Parent = GetCamera()
	
	return Blur
end

-- DIRECT
function CameraModule.CreateBlurEffect()
	return CreateBlurEffect()
end

function CameraModule.GetCameraConnections()
	return CameraConnections
end

function CameraModule.GetTweenDict()
	return TweenDict
end

function CameraModule.GetCamera()
	return GetCamera()
end

function CameraModule.CameraProcess(NilParam, FunctionName, Toggle, ...)
	return CameraProcess(FunctionName, Toggle, ...)
end

function CameraModule.SetupCamera()
	return SetupCamera()
end

function CameraModule.ResetCamera(NilParam, ...)
	return ResetCamera(...)
end

-- INIT
SetupCamera()
--RunSubModules()

return CameraModule
