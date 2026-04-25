local Noclip = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

Noclip.PartsCache = {} -- Stores lists of parts for each model

-- Adds a part to the cache if it's a BasePart
function Noclip.TrackPart(model, part)
    if part:IsA("BasePart") then
        table.insert(Noclip.PartsCache[model], part)
    end
end

-- Sets up a character's parts list and listens for new items (tools, etc.)
function Noclip.SetupCharacter(model)
    if model == Players.LocalPlayer.Character then return end
    Noclip.PartsCache[model] = {}

    -- Initial parts
    for _, descendant in pairs(model:GetDescendants()) do
        Noclip.TrackPart(model, descendant)
    end

    -- Handle new descendants (Tools, new limbs, etc.)
    local descConn = model.DescendantAdded:Connect(function(desc)
        Noclip.TrackPart(model, desc)
    end)
    
    -- Store connection on the model so we can clean up if needed
    -- (Omitted for simplicity, but handled by ChildRemoved below)
end

function Noclip.Init(State)
    local charFolder = Workspace:WaitForChild("Characters")

    -- 1. Watch for Character additions/removals
    local addConn = charFolder.ChildAdded:Connect(function(child)
        Noclip.SetupCharacter(child)
    end)

    local remConn = charFolder.ChildRemoved:Connect(function(child)
        Noclip.PartsCache[child] = nil
    end)

    -- 2. The Core Loop: Only iterates through flat tables (Very Fast)
    local loopConn = RunService.Stepped:Connect(function()
        if not State.Toggles.NoclipPlayers then return end

        for model, parts in pairs(Noclip.PartsCache) do
            for i = 1, #parts do
                local p = parts[i]
                if p.CanCollide then
                    p.CanCollide = false
                end
            end
        end
    end)

    -- Initialize existing characters
    for _, child in pairs(charFolder:GetChildren()) do
        Noclip.SetupCharacter(child)
    end

    table.insert(State.Connections, addConn)
    table.insert(State.Connections, remConn)
    table.insert(State.Connections, loopConn)

    return Noclip
end

return Noclip
