local Targeting = {}
local workspace = cloneref(game:GetService("Workspace"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer

function Targeting.Spectate(State)
    -- Ensure State table exists and contains the variable sub-table
    if not State or not State.Variables then return end
    
    local NameIdentifier = State.Variables.TargetIdentifier
    if not NameIdentifier or NameIdentifier == "" then 
        -- Fallback default reset if search input is completely empty
        local Camera = workspace.CurrentCamera
        local Hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Hum then
            Camera.CameraSubject = Hum
        end
        return 
    end

    local Camera = workspace.CurrentCamera
    local LocalHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

    if not LocalHum then return end

    local TargetPlayer = nil
    local SearchTerm = NameIdentifier:lower()
    
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            local NameMatch = Player.Name:lower():find(SearchTerm, 1, true)
            local DisplayMatch = Player.DisplayName:lower():find(SearchTerm, 1, true)
            
            if NameMatch or DisplayMatch then
                TargetPlayer = Player
                break
            end
        end
    end

    if TargetPlayer and TargetPlayer.Character then
        local TargetHum = TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if TargetHum then
            -- Toggle system: if already spectating target, switch back to yourself. Otherwise spectate target.
            Camera.CameraSubject = (Camera.CameraSubject == TargetHum) and LocalHum or TargetHum
            return
        end
    end
    
    -- If target selection wasn't found or fell out of world, snap subject back onto user character
    Camera.CameraSubject = LocalHum
end

return Targeting
