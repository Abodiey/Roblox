local AutoBurst = {}

-- Constants
local DASH_DIRECTION = "Left"
local ATTRIBUTE_NAME = "Burst"

-- Services & Player
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

local LocalPlayer = Players.LocalPlayer

-- Infinite wait chain for the remote instance in one line
local DashRemote
task.spawn(function()
    DashRemote = ReplicatedStorage:WaitForChild("Knit", 99999):WaitForChild("Knit", 99999):WaitForChild("Services", 99999):WaitForChild("MovementService", 99999):WaitForChild("RE", 99999):WaitForChild("Dash", 99999)
end)

-- Optimizations
local getAttribute = game.GetAttribute

function AutoBurst.Init(State)
    local wasBurstActive = false

    local HeartbeatConnection = RunService.Heartbeat:Connect(function()
        -- Directly check the toggle state
        if not State.Toggles.AutoBurst then return end
        if not DashRemote then return end
            
        local character = LocalPlayer.Character
        if not character then return end

        local isBurstActive = getAttribute(character, ATTRIBUTE_NAME)

        -- Check for a rising edge trigger (the exact moment "Burst" becomes true)
        if isBurstActive and not wasBurstActive then
            DashRemote:FireServer(DASH_DIRECTION, true)
        end

        -- Update historical state for the next frame's comparison
        wasBurstActive = isBurstActive
    end)

    table.insert(State.Connections, HeartbeatConnection)
end

return AutoBurst
