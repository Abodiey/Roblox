local Noclip = {}

local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local lp = Players.LocalPlayer
local charFolder = workspace:WaitForChild("Characters")

-- Passive memory management using Weak Keys
local storedParts = {}
setmetatable(storedParts, {__mode = "k"}) 

local lastToggle = false

function Noclip.Init(State)
    local connection = RunService.Stepped:Connect(function()
        local enabled = State.Toggles.Noclip
        local myChar = lp.Character

        -- 1. RESTORE ON TOGGLE OFF
        if lastToggle and not enabled then
            for part in pairs(storedParts) do
                -- No need to check if part exists; weak table cleans up nil parts
                part.CanCollide = true
            end
            table.clear(storedParts)
        end
        lastToggle = enabled

        -- 2. FORCE NOCLIP WHILE ACTIVE
        if enabled then
            for _, char in pairs(charFolder:GetChildren()) do
                if char ~= myChar then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") then
                            if v.CanCollide then
                                storedParts[v] = true
                                v.CanCollide = false
                            end
                        end
                    end
                end
            end
        end
    end)

    table.insert(State.Connections, connection)
end

return Noclip
