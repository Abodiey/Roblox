local Aimbot = {}

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local GuiService = cloneref(game:GetService("GuiService"))

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

while not Player or not Player.Parent or not CoreGui or not Camera do
    task.wait()
end

while CoreGui:FindFirstChild("AimbotHighlight") do 
    CoreGui.AimbotHighlight:Destroy() 
    task.wait() 
end

local Highlight = Instance.new("Highlight")
Highlight.Name = "AimbotHighlight"
Highlight.Parent = CoreGui

function Aimbot.Toggle(State)
    if State.Toggles.Aim.Value then 
        State.Toggles.Aim.Value = false
        State.Variables.LockedTarget.Value = nil
        Highlight.Adornee = nil
        return 
    end

    local nearest, dist = nil, math.huge
    local inset = GuiService:GetGuiInset()
    local mousePos = UserInputService:GetMouseLocation() - inset
    local myTeam = Player.Team
    local characterFolder = workspace:FindFirstChild("Characters") or workspace
    Camera = workspace.CurrentCamera

    for _, obj in ipairs(characterFolder:GetChildren()) do
        if obj == Player.Character then continue end
        if obj:GetAttribute("Dead") then continue end
        
        local hrp = obj:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        local targetPlayer = Players:GetPlayerFromCharacter(obj)
        if State.Toggles.TeamCheck.Value and myTeam and targetPlayer and targetPlayer.Team == myTeam then 
            continue 
        end

        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then continue end

        local mDist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
        if mDist >= dist then continue end

        dist = mDist
        nearest = obj 
    end

    if not nearest then return end
    
    State.Variables.LockedTarget.Value = nearest
    State.Toggles.Aim.Value = true
end

function Aimbot.Init(State)
    Camera = workspace.CurrentCamera
    State.Connections = State.Connections or {}
    
    if State.Toggles.TeamCheck.Value == nil then
        State.Toggles.TeamCheck.Value = true
    end

    local removeConn = Players.PlayerRemoving:Connect(function(p)
        local currentTarget = State.Variables.LockedTarget.Value
        if not currentTarget then return end
        if currentTarget.Name ~= p.Name then return end
        
        State.Variables.LockedTarget.Value = nil
        Highlight.Adornee = nil
    end)
    table.insert(State.Connections, removeConn)

    local updateConn = RunService.Heartbeat:Connect(function()
        if not State.Toggles.Aim.Value then Highlight.Adornee = nil return end
        
        local target = State.Variables.LockedTarget.Value
        if not target or not target.Parent then Highlight.Adornee = nil return end
        
        if target:GetAttribute("Dead") then
            State.Variables.LockedTarget.Value = nil
            State.Toggles.Aim.Value = false
            Highlight.Adornee = nil
            return
        end

        local targetPart = target:FindFirstChild("HumanoidRootPart")
        if not targetPart then
            State.Variables.LockedTarget.Value = nil
            State.Toggles.Aim.Value = false
            Highlight.Adornee = nil
            return
        end

        Highlight.Adornee = target
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
    end)
    table.insert(State.Connections, updateConn)
end

return Aimbot
