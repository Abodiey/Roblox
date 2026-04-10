local Targeting = {}

function Targeting.Spectate(name)
    local found = nil
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Name:lower():find(name:lower()) or p.DisplayName:lower():find(name:lower()) then
            found = p; break
        end
    end
    if found and found.Character and found.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = found.Character.Humanoid
    end
end

return Targeting
