local DebugModule = {}

-- Dirs
--local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated"):WaitForChild("Assets")["Modules"]
--local ClientSignalsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated"):WaitForChild("Remotes")["Client"]["Signals"]
--local ClientRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated"):WaitForChild("Remotes")["Client"]["Remotes"]

-- Client
local Player = game.Players.LocalPlayer

-- Elements
-- REMOTES
--local ClientProcessRemote = ClientRemotesFolder["ClientProcess"]

-- SIGNALS
--local ClientRequestSignal = ClientSignalsFolder["ClientRequest"]

-- CORE
local BackLog = {}
local BackLogLimit = 200
local DebugMode = false

-- Services
local RunService = game:GetService("RunService")

-- Functions
-- MECAHNICS
local function ReEnabled()
	-- Functions
	-- INIT
	for i = 1, #BackLog do
		local Success, Error = pcall(function()
			return DebugModule:Print("BACKLOGGED | ".. BackLog[i]["String"].. " | Time: ".. tostring(BackLog[i]["Time"])--[[.. " | Tick: ".. tostring(BackLog[i]["Tick"])]], BackLog[i]["Type"])
		end)
		
		table.remove(BackLog, #BackLog)
	end
end

local function LogInstance(String, Type, Time)
	-- Functions
	-- INIT
	if not Player or not string.find(String, "Error") then
		return nil
	end
	
	--[[local PlayerClientFolder = Player:WaitForChild("Client")["Debug"]
	
	local Value = Instance.new("StringValue")
	Value.Name = tostring(Type)
	Value.Value = tostring(String)
	Value:SetAttribute("Tick", Time)
	Value.Parent = PlayerClientFolder]]
end

local function Print(String, Type)
	-- Functions
	-- INIT		
	local Time = time()
	
	table.insert(BackLog, {["Type"] = Type, ["String"] = String, ["Tick"] = Time, ["Time"] = os.date("*t")["hour"].. ":".. os.date("*t")["min"].. ":".. os.date("*t")["sec"]})
	LogInstance(String, Type, Time)
	
	
	if #BackLog > 200 then
		table.remove(BackLog, #BackLog)
	end
	
	if not Type or Type == "Normal" then
		local FoundErrorInString = string.find(String, "Error")

		if FoundErrorInString ~= nil then
			return warn(tostring(String))
		end

		if script:GetAttribute("Enabled") and not FoundErrorInString then
			return print(tostring(String))			
		end
	elseif Type == "Error" then
		return error(tostring(String))
	end
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["Print"] = function(String, Type)
		return Print(String, Type)
	end,	
}

-- DIRECT
function DebugModule.Request(NilParam, FunctionName, ...)
	return ClientRequests[FunctionName](...)
end

function DebugModule.Print(NilParam, String, Type)
	return Print(String, Type)
end

-- CONNECTIONS
local Connection1 = script:GetAttributeChangedSignal("Enabled"):Connect(function()
	if script:GetAttribute("Enabled") then
		return ReEnabled()
	end
end)

return DebugModule
