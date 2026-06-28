local KillSound = {}

-- Game execution check
if not game:IsLoaded() then game.Loaded:Wait() end
if game.GameId ~= 3508322461 then return KillSound end

local Players = cloneref(game:GetService("Players"))
local SoundService = cloneref(game:GetService("SoundService"))
local Debris = cloneref(game:GetService("Debris"))
local plr = Players.LocalPlayer

-- Secure data folders
local stats = plr:WaitForChild("leaderstats", 99999)
local hiddenFolder = stats and stats:WaitForChild("Hidden", 99999)
if not stats or not hiddenFolder then return KillSound end

-- Pre-create sound template
local baseSound = Instance.new("Sound")
baseSound.SoundId = "rbxassetid://120891770644830"
baseSound.Volume = 10
baseSound.Parent = SoundService

-- State variables for connections
local valueConn = nil
local attributeConn = nil
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
                task.wait(math.random(50, 110) / 1000) 
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
    -- Spawn a persistent thread since Init is only called once at startup
    task.spawn(function()
        local wasActive = false

        while true do
            -- Target toggle state pointer
            local isActive = not not (State.Toggles and State.Toggles.KillSound)

            if isActive and not wasActive then
                -- Toggle just turned ON: Setup source tracking and attribute listeners
                wasActive = true
                updateKillSource()

                attributeConn = stats:GetAttributeChangedSignal("HiddenKills"):Connect(updateKillSource)

            elseif not isActive and wasActive then
                -- Toggle just turned OFF: Disconnect everything safely
                wasActive = false
                cleanupKillSound()
            end

            -- Sleep interval to check state pointer with zero overhead
            task.wait(0.1)
        end
    end)
end

return KillSound
