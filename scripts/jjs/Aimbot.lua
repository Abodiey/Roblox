local Aimbot = {}
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")

function Aimbot.Toggle(State)
    if State.Toggles.Aim then State.Toggles.Aim = false; State.LockedTarget = nil return end
    
    local nearest, dist = nil, math.huge
    for _, obj in pairs(workspace.Characters:GetChildren()) do
        if obj ~= Players.LocalPlayer.Character and obj:FindFirstChild("HumanoidRootPart") then
            local _, onScreen = Camera:WorldToViewportPoint(obj.HumanoidRootPart.Position)
            if onScreen then
                local mDist = (Vector2.new(Players.LocalPlayer:GetMouse().X, Players.LocalPlayer:GetMouse().Y) - Vector2.new(Camera:WorldToViewportPoint(obj.HumanoidRootPart.Position).X, Camera:WorldToViewportPoint(obj.HumanoidRootPart.Position).Y)).Magnitude
                if mDist < dist then dist = mDist; nearest = obj end
            end
        end
    end
    if nearest then State.LockedTarget = nearest; State.Toggles.Aim = true end
end

function Aimbot.Init(State)
    local conn = game:GetService("RunService").Heartbeat:Connect(function()
        if State.Toggles.Aim and State.LockedTarget and State.LockedTarget:FindFirstChild("HumanoidRootPart") then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, State.LockedTarget.HumanoidRootPart.Position)
        end
    end)
    table.insert(State.Connections, conn)
end

return Aimbot
