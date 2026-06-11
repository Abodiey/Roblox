local Targeting = {}
local workspace = cloneref(game:GetService("Workspace"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer

function Targeting.Spectate(name)
    local Camera = workspace.CurrentCamera
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")

    if not hum then return end

    local target = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (p.Name:lower():find(name:lower()) or p.DisplayName:lower():find(name:lower())) then
            target = p
            break
        end
    end

    if target and target.Character and target.Character:FindFirstChild("Humanoid") then
        local TargetHum = target.Character.Humanoid
        Camera.CameraSubject = (Camera.CameraSubject == TargetHum) and hum or TargetHum
    else
        Camera.CameraSubject = hum
    end
end

return Targeting
