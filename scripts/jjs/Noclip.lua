local Noclip = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

Noclip.Cache = {} -- Stores lists of parts for each character

function Noclip.UpdateCache(model)
    if model == Players.LocalPlayer.Character then return end
    
    local parts = {}
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            table.insert(parts, part)
        end
    end
    Noclip.Cache[model] = parts
end

function Noclip.Init(State)
    local charFolder = Workspace:WaitForChild("Characters")

    -- 1. Listen for new characters and cache their parts
    local added = charFolder.ChildAdded:Connect(function(child)
        task.wait(0.1) -- Small wait for parts to load
        Noclip.UpdateCache(child)
    end)

    -- 2. Clean up cache when they leave
    local removed = charFolder.ChildRemoved:Connect(function(child)
        Noclip.Cache[child] = nil
    end)

    -- 3. The Loop: High frequency, but low CPU cost because it uses the cache
    local loop = RunService.Stepped:Connect(function()
        if not State.Toggles.NoclipPlayers then return end

        for model, parts in pairs(Noclip.Cache) do
            for i = 1, #parts do
                parts[i].CanCollide = false
            end
        end
    end)

    -- Initial cache for anyone already there
    for _, child in pairs(charFolder:GetChildren()) do
        Noclip.UpdateCache(child)
    end

    table.insert(State.Connections, added)
    table.insert(State.Connections, removed)
    table.insert(State.Connections, loop)

    return Noclip
end

return Noclip
