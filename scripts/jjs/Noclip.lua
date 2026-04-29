local Noclip = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

function Noclip.Init(State)
    local charFolder = Workspace:WaitForChild("Characters")
    local lp = Players.LocalPlayer

    task.spawn(function()
        while true do
            task.wait(0.1) -- Runs 10 times a second (No lag, still effective)
            
            if not State.Toggles.NoclipPlayers then continue end

            local myChar = lp.Character
            for _, char in pairs(charFolder:GetChildren()) do
                if char == myChar then continue end

                -- Force CanCollide false on all parts
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide then
                        v.CanCollide = false
                    end
                end
            end
        end
    end)

    return Noclip
end

return Noclip
