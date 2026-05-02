local Noclip = {}
local Players = game:GetService("Players")

function Noclip.Init(State)
    local charFolder = workspace:WaitForChild("Characters")
    local lp = Players.LocalPlayer

    task.spawn(function()
        task.wait(0.1)
        while State.Toggles.Noclip do
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
            task.wait(0.1)
        end
    end)
end

return Noclip
