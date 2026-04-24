local Targeting = {}

function Targeting.Spectate(name)
    local Camera = workspace.CurrentCamera
    local LocalPlayer = game.Players.LocalPlayer
    local MyHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")

    if not MyHum then return end

    local target = nil
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= LocalPlayer and (p.Name:lower():find(name:lower()) or p.DisplayName:lower():find(name:lower())) then
            target = p
            break
        end
    end

    if target and target.Character and target.Character:FindFirstChild("Humanoid") then
        local TargetHum = target.Character.Humanoid
        Camera.CameraSubject = (Camera.CameraSubject == TargetHum) and MyHum or TargetHum
    else
        Camera.CameraSubject = MyHum
    end
end

return Targeting
