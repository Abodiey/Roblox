local Noclip = {}

local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local lp = Players.LocalPlayer
local charFolder = workspace:WaitForChild("Characters")

function Noclip.Init(State)
    local connection = RunService.Stepped:Connect(function()
        if not State.Toggles.Noclip then return end

        local myChar = lp.Character
        for _, char in pairs(charFolder:GetChildren()) do
            if char ~= myChar then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end
    end)

    table.insert(State.Connections, connection)
end

return Noclip
