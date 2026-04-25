local Aimbot = {}
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

function Aimbot.Toggle(State)
    if State.Toggles.Aim then 
        State.Toggles.Aim = false
        State.LockedTarget = nil 
        return 
    end
    local nearest, dist = nil, math.huge
    local mousePos = Vector2.new(Player:GetMouse().X, Player:GetMouse().Y)
    local myTeam = Player.Team
    for _, obj in ipairs(workspace.Characters:GetChildren()) do
        local hrp = obj:FindFirstChild("HumanoidRootPart")
        if obj == Player.Character or not hrp then continue end
        local targetPlayer = Players:GetPlayerFromCharacter(obj)
        if myTeam and targetPlayer and targetPlayer.Team == myTeam then continue end
        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if onScreen then
            local mDist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
            if mDist < dist then 
                dist = mDist
                nearest = obj 
            end
        end
    end
    if nearest then 
        State.LockedTarget = nearest
        State.Toggles.Aim = true 
    end
end
function Aimbot.Init(State)
    local conn = game:GetService("RunService").Heartbeat:Connect(function()
        if State.Toggles.Aim and State.LockedTarget and State.LockedTarget:FindFirstChild("HumanoidRootPart") then
            local targetPart = State.LockedTarget.HumanoidRootPart
            local offset = targetPart.CFrame.LookVector * 2 -- Change 2 to how many studs behind you want

            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position - offset)
        end
    end)
    table.insert(State.Connections, conn)
end

return Aimbot
