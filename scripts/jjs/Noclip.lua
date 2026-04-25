local Noclip = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Simple function to flip collision on a model
function Noclip.SetCollision(model, boolean)
    if model == Players.LocalPlayer.Character then return end
    
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = boolean
        end
    end
end

function Noclip.Init(State)
    local charFolder = Workspace:WaitForChild("Characters")

    -- 1. Watch for new additions while toggle is ON
    local conn = charFolder.ChildAdded:Connect(function(child)
        if State.Toggles.NoclipPlayers then
            Noclip.SetCollision(child, false)
        end
    end)

    -- 2. Handle the "Toggle Off" logic
    -- We watch the State table for changes
    task.spawn(function()
        local lastState = State.Toggles.NoclipPlayers
        while task.wait(0.5) do -- Low frequency check to save CPU
            local currentState = State.Toggles.NoclipPlayers
            if currentState ~= lastState then
                lastState = currentState
                
                -- When toggle flips, update everyone currently in the folder
                for _, child in pairs(charFolder:GetChildren()) do
                    Noclip.SetCollision(child, not currentState) 
                    -- if currentState is true, collision is false
                    -- if currentState is false, collision is true
                end
            end
        end
    end)

    table.insert(State.Connections, conn)
    return Noclip
end

return Noclip
