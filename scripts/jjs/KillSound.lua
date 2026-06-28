local KillSound = {}

-- Localize Services & Core API
local cloneref = cloneref
local game = game
local Players = cloneref(game:GetService("Players"))
local SoundService = cloneref(game:GetService("SoundService"))
local Debris = cloneref(game:GetService("Debris"))

-- Localize Global Engine Functions
local task = task
local Instance = Instance
local inst_new = Instance.new
local tonumber = tonumber
local table = table
local table_insert = table.insert
local math = math
local m_random = math.random

local plr = Players.LocalPlayer
if not plr then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    plr = Players.LocalPlayer
end

-- Secure data folders
local stats = plr:WaitForChild("leaderstats", 99999)
local hiddenFolder = stats and stats:WaitForChild("Hidden", 99999)
if not stats or not hiddenFolder then return KillSound end

-- Pre-create sound template
local baseSound = inst_new("Sound")
baseSound.SoundId = "rbxassetid://120891770644830"
baseSound.Volume = 10
baseSound.Parent = SoundService

-- State variables for connections
local valueConn = nil
local attributeConn = nil
local toggleConn = nil
local lastVal = 0

-- Core function to handle tracking logic when the active kill source updates
local function trackKillsObject(killsObj)
    if valueConn then valueConn:Disconnect() valueConn = nil end
    if not killsObj then return end
    
    lastVal = tonumber(killsObj.Value) or 0
    
    valueConn = killsObj:GetPropertyChangedSignal("Value"):Connect(function()
        local current = tonumber(killsObj.Value) or 0
        local diff = current - lastVal
        lastVal = current
        
        if diff <= 0 or diff > 50 then return end
        
        task.spawn(function()
            for _ = 1, diff do 
                local snd = baseSound:Clone()
                snd.Parent = SoundService
                snd:Play()
                Debris:AddItem(snd, 2)
                task.wait(m_random(50, 110) / 1000) 
            end
        end)
    end)
end

-- Function to evaluate where kills are located based on the current attribute state
local function updateKillSource()
    local kills
    if stats:GetAttribute("HiddenKills") then
        kills = hiddenFolder:WaitForChild("Kills", 5)
    else
        kills = stats:WaitForChild("Kills", 5)
    end
    trackKillsObject(kills)
end

-- Completely clears connections when toggle is off
local function cleanupKillSound()
    if valueConn then valueConn:Disconnect() valueConn = nil end
    if attributeConn then attributeConn:Disconnect() attributeConn = nil end
end

function KillSound.Init(State)
    local toggleObject = State.Toggles.KillSound

    local function handleToggleChange()
        local isEnabled = toggleObject.Value

        if isEnabled then
            -- Set up execution logic directly on toggle activation instead of polling
            updateKillSource()
            if not attributeConn then
                attributeConn = stats:GetAttributeChangedSignal("HiddenKills"):Connect(updateKillSource)
            end
        else
            cleanupKillSound()
        end
    end

    toggleConn = toggleObject:GetPropertyChangedSignal("Value"):Connect(handleToggleChange)
    table_insert(State.Connections, toggleConn)

    handleToggleChange()
end

return KillSound
