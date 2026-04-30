local cloneref = cloneref or function(o) return o end
local Aimbot = {}

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local CoreGui = cloneref(game:GetService("CoreGui"))

local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer

while not Player or not Player.Parent or not CoreGui do
    task.wait()
end

local Highlight = CoreGui:FindFirstChildOfClass("Highlight") or Instance.new("Highlight")
Highlight.Name = "AimbotHighlight"
Highlight.Parent = CoreGui

function Aimbot.Toggle(State)
    -- If already aiming, turn it off
    if State.Toggles.Aim then 
        State.Toggles.Aim = false
        State.LockedTarget = nil
        Highlight.Adornee = nil
        return 
    end

    local nearest, dist = nil, math.huge
    local mousePos = Vector2.new(Player:GetMouse().X, Player:GetMouse().Y)
    local myTeam = Player.Team
    local characterFolder = workspace:FindFirstChild("Characters") or workspace

    for _, obj in ipairs(characterFolder:GetChildren()) do
        local hrp = obj:FindFirstChild("HumanoidRootPart")
        local hum = obj:FindFirstChildOfClass("Humanoid")
        
        -- Basic validity checks
        if obj == Player.Character or not hrp or (hum and hum.Health <= 0) then continue end
        
        -- Team Check Logic
        local targetPlayer = Players:GetPlayerFromCharacter(obj)
        if State.Toggles.TeamCheck and myTeam and targetPlayer and targetPlayer.Team == myTeam then 
            continue 
        end

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
    State.Connections = State.Connections or {}
    -- Ensure TeamCheck exists in state if not defined
    if State.Toggles.TeamCheck == nil then
        State.Toggles.TeamCheck = true
    end

    local removeConn = Players.PlayerRemoving:Connect(function(p)
        if State.LockedTarget and State.LockedTarget.Name == p.Name then
            State.LockedTarget = nil
            Highlight.Adornee = nil
        end
    end)
    table.insert(State.Connections, removeConn)

    local updateConn = RunService.Heartbeat:Connect(function()
        if State.Toggles.Aim and State.LockedTarget and State.LockedTarget.Parent then
            local targetPart = State.LockedTarget:FindFirstChild("HumanoidRootPart")
            local humanoid = State.LockedTarget:FindFirstChildOfClass("Humanoid")

            if targetPart and (not humanoid or humanoid.Health > 0) then
                Highlight.Adornee = State.LockedTarget
                local offset = targetPart.CFrame.LookVector * 0.5 
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position - offset)
            else
                State.LockedTarget = nil
                Highlight.Adornee = nil
            end
        else
            Highlight.Adornee = nil
        end
    end)
    table.insert(State.Connections, updateConn)
end

return Aimbot
