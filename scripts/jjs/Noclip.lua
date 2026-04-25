local Noclip = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

function Noclip.Process(model)
    if model == Players.LocalPlayer.Character then return end
    
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

function Noclip.Init(State)
    local charFolder = Workspace:WaitForChild("Characters")

    -- Fix existing ones
    for _, child in pairs(charFolder:GetChildren()) do
        Noclip.Process(child)
    end

    -- Fix new ones as they join
    local conn = charFolder.ChildAdded:Connect(function(child)
        if #child:GetChildren() < 10 then task.wait(1) end
        if State.Toggles.NoclipPlayers then
            Noclip.Process(child)
        end
    end)

    table.insert(State.Connections, conn)
    return Noclip
end

return Noclip
