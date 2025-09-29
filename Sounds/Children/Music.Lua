local SoundsMusicModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated"):WaitForChild("Assets")["InfoModules"]
local ClientRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Replicated"):WaitForChild("Remotes")["Client"]

-- Info Modules
local SoundsInfoModule = require(InfoModulesFolder["Sounds"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
--
local SoundsModule = nil

-- Elements
-- REMOTES

-- CORE
local Playlist = ""

local CustomConnection = nil

local BackingTrackFolder = nil
local MainMusicSound = nil

local DefaultMusicVolume = 0.125

-- Services
local SoundService = game:GetService("SoundService")

-- Functions
-- MECHANICS
local function StartPlaylist(PlaylistName)
	-- CORE
	local PlaylistInfo = SoundsInfoModule:GetSounds("Music")[PlaylistName]
	--local MaxTracks = UtilitiesModule:GetSizeOfDict(PlaylistInfo)
	local AllTracks = UtilitiesModule:GetDictKeys(PlaylistInfo)
	
	local _CustomConnection = UtilitiesModule:CreateCustomConnection()
	
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectCustomConnections({CustomConnection})
	
	CustomConnection = _CustomConnection
	Playlist = PlaylistName
		
	coroutine.wrap(function()
		while _CustomConnection and _CustomConnection.Value and task.wait() do
			if #AllTracks <= 0 then
				AllTracks = UtilitiesModule:GetDictKeys(PlaylistInfo)
			end
			
			local RandomIndex = math.random(1, #AllTracks)
			local TrackInfo = PlaylistInfo[RandomIndex]
			
			table.remove(AllTracks, RandomIndex)
			
			local Success, Error = pcall(function()
				MainMusicSound.SoundId = TrackInfo["Id"]
			end)
			
			if not Success then
				continue
			end
						
			MainMusicSound:Play()
			MainMusicSound.Ended:Wait()
		end
	end)()
end

local function Play(PlaylistName)
	-- Functions
	-- INIT
	if PlaylistName == Playlist then
		return nil
	end
	
	StartPlaylist(PlaylistName)
end

local function Mute()
	-- Functions
	-- INIT
	MainMusicSound.Volume = 0
end

local function Unmute()
	-- Functions
	-- INIT
	MainMusicSound.Volume = DefaultMusicVolume
end

local function Initialise(_SoundsModule)
	-- Functions
	-- INIT
	SoundsModule = _SoundsModule
	
	-- Instancing
	BackingTrackFolder = SoundService:FindFirstChild("BackingTrack") 

	if not BackingTrackFolder then
		BackingTrackFolder = Instance.new("Folder", SoundService)
		BackingTrackFolder.Name = "BackingTrack"
	end

	MainMusicSound = BackingTrackFolder:FindFirstChildOfClass("Sound")

	if not MainMusicSound then
		MainMusicSound = Instance.new("Sound", BackingTrackFolder)
		MainMusicSound.Name = "Music"
		Unmute()
	end

	--[[local SoundEffectsCacheFolder = SoundService:FindFirstChild("SoundEffects")

	if not SoundEffectsCacheFolder then
		SoundEffectsCacheFolder = Instance.new("Folder", SoundService)
		SoundEffectsCacheFolder.Name = "SoundEffects"
	end]]
end

local function End()
	-- Functions
	-- INIT
	
end

-- DIRECT
function SoundsMusicModule.Mute()
	return Mute()
end

function SoundsMusicModule.Unmute()
	return Unmute()
end

function SoundsMusicModule.Play(NilParam, ...)
	return Play(...)
end

function SoundsMusicModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function SoundsMusicModule.End(NilParam, ...)
	return End(...)
end

return SoundsMusicModule
