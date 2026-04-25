local Noclip = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

function Noclip.Process(model, toggle)
    if model == Players.LocalPlayer.Character then return end
    
    -- Force collision off on all parts
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not toggle
        end
    end

    -- The "Secret Sauce": Disable the Humanoid collision state
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid then
        -- SetStateEnabled is client-side compatible
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, not toggle)
    end
end

function Noclip.Init(State)
    local charFolder = Workspace:WaitForChild("Characters")

    local conn = RunService.Stepped:Connect(function()
        if not State.Toggles.NoclipPlayers then return end

        for _, child in pairs(charFolder:GetChildren()) do
            if child:IsA("Model") then
                -- In a loop to fight the engine's auto-reset
                for _, part in pairs(child:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)

    -- Handle the State Change (Humanoid States only need to be toggled once per change)
    -- This handles the "toggle off" logic to restore everything
    task.spawn(function()
        local lastState = false
        while task.wait(0.5) do
            local current = State.Toggles.NoclipPlayers
            if current ~= lastState then
                lastState = current
                for _, child in pairs(charFolder:GetChildren()) do
                    Noclip.Process(child, current)
                end
            end
        end
    end)

    table.insert(State.Connections, conn)
    return Noclip
end

return Noclip
