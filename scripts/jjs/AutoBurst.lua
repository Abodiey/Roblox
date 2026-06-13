local AutoBurst = {}

-- Constants
local DASH_DIRECTION = "Left"
local ATTRIBUTE_NAME = "Burst"

-- Services & Player
local Knit = require(game.ReplicatedStorage.Knit.Knit)
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))

local LocalPlayer = Players.LocalPlayer
local MovementService
pcall(function()
    MovementService = Knit.GetService("MovementService")
end)

task.spawn(function()
    while not MovementService do
        pcall(function()
            MovementService = Knit.GetService("MovementService")
        end)
        task.wait(1)
    end
end)

-- Optimizations
local getAttribute = game.GetAttribute

function AutoBurst.Init(State)
    local wasBurstActive = false

    local HeartbeatConnection = RunService.Heartbeat:Connect(function()
        -- Directly check the toggle state
        if not State.Toggles.AutoBurst then return end
        if not MovementService then return end
            
        local character = LocalPlayer.Character
        if not character then return end

        local isBurstActive = getAttribute(character, ATTRIBUTE_NAME)

        -- Check for a rising edge trigger (the exact moment "Burst" becomes true)
        if isBurstActive and not wasBurstActive then
            MovementService.Dash:Fire(DASH_DIRECTION, true)
        end

        -- Update historical state for the next frame's comparison
        wasBurstActive = isBurstActive
    end)

    table.insert(State.Connections, HeartbeatConnection)
end

return AutoBurst
