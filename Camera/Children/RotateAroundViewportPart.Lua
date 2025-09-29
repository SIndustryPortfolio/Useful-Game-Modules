local RotateAroundViewportPartModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated"):WaitForChild("Assets")["Modules"]

-- Modules
local DebrisModule = require(ModulesFolder["Debris"])
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
--
local CameraModule = nil

-- Services
local RunService = game:GetService("RunService")

-- Functions
-- MECHANICS
local function Initialise(_CameraModule)
	-- Functions
	-- INIT
	CameraModule = _CameraModule
end

local function SetupViewportCamera()
	-- Functions
	-- INIT
	local Camera = Instance.new("Camera")
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CameraSubject = nil
	
	return Camera
end

local function Effect(Viewport, CustomConnection, Increment, ZOffset)
	if not CameraModule or not Viewport or not CustomConnection then
		return nil
	end
	
	-- CORE
	
	local PartToRotateAround = nil
	local ConfigurableOptionsValue = Instance.new("BoolValue")
	
	local FoundWorldModel = Viewport:FindFirstChildOfClass("WorldModel")
	
	if FoundWorldModel then
		PartToRotateAround = FoundWorldModel:FindFirstChildWhichIsA("BasePart") or FoundWorldModel:FindFirstChildOfClass("Model")
	else
		PartToRotateAround = Viewport:FindFirstChildWhichIsA("BasePart") or Viewport:FindFirstChildOfClass("Model") 
	end
	
	--local Angle = 0
	--local Offset = UtilitiesModule:GetLongestLengthOfCube(PartToRotateAround) -- Studs
	
	ConfigurableOptionsValue:SetAttribute("Angle", 0)
	ConfigurableOptionsValue:SetAttribute("Offset", UtilitiesModule:GetLongestLengthOfCube(PartToRotateAround))
	
	if ZOffset then
		--Offset += ZOffset
		ConfigurableOptionsValue:SetAttribute("Offset", ConfigurableOptionsValue:GetAttribute("Offset") + ZOffset)
	end
	
	-- Functions
	-- INIT
	if not Viewport.CurrentCamera then
		local Camera = SetupViewportCamera()
		Camera.CameraSubject = PartToRotateAround --PartToShift
		Camera.Parent = Viewport
		Viewport.CurrentCamera = Camera
	end
	
	if not Viewport.CurrentCamera.CameraSubject then
		Viewport.CurrentCamera.CameraSubject = PartToRotateAround
	end
	
	if Increment == nil then
		--Increment = 45
		ConfigurableOptionsValue:SetAttribute("Increment", 45)
	end
	
	local Connection = nil

	local Success, Error = pcall(function()

		local ViewportCamera = Viewport.CurrentCamera

		Connection = UtilitiesModule:RenderSteppedFPSLock(30, function(DeltaTime)
			-- CORE
			local _Increment = ConfigurableOptionsValue:GetAttribute("Increment")
			local _Angle = ConfigurableOptionsValue:GetAttribute("Angle")
			local _Offset = ConfigurableOptionsValue:GetAttribute("Offset")
			
			
			local Subject = UtilitiesModule:GetRootModel(ViewportCamera.CameraSubject)

			local StartPosition = nil

			if Subject:IsA("Model") then
				local _StartCFrame = Subject:GetPivot()

				StartPosition = Vector3.new(_StartCFrame.X, _StartCFrame.Y, _StartCFrame.Z)
			else
				if not Subject:IsA("BasePart") then
					--DebugModule:Print(script.Name.. " | Initialise | Subject: ".. tostring(Subject).. " | Error: Subject isn't a base part!")
					return UtilitiesModule:DisconnectConnections({Connection})
				end

				StartPosition = Subject.Position
			end

			ViewportCamera.CFrame = CFrame.new(StartPosition) * CFrame.Angles(0, math.rad(ConfigurableOptionsValue:GetAttributes()["FixedAngle"] or _Angle), 0) * CFrame.new(0, 0, _Offset)
			ViewportCamera.Focus = CFrame.new(StartPosition)

			ConfigurableOptionsValue:SetAttribute("Angle", _Angle + (_Increment * DeltaTime))

			if not Viewport or not ViewportCamera then
				UtilitiesModule:DisconnectCustomConnections({CustomConnection})
			end

			if not CustomConnection or not CustomConnection.Value then
				DebrisModule:AddItem(ConfigurableOptionsValue)
				return UtilitiesModule:DisconnectConnections({Connection})
			end

		end)
	end)
		
	if not Success then			
		DebugModule:Print("RotateAroundViewportPart | Error: ".. tostring(Error))
	end
	
	-- Connections
	table.insert(CameraModule:GetCameraConnections(), Connection)
	
	return ConfigurableOptionsValue
end

local function End(Type)
	
end

-- DIRECT
function RotateAroundViewportPartModule.Effect(NilParam, ...)
	return Effect(...)
end

function RotateAroundViewportPartModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function RotateAroundViewportPartModule.End(NilParam, CameraModule, Type)
	return End(CameraModule, Type)
end

return RotateAroundViewportPartModule
