getgenv().cloneref = cloneref or function(o) return o end
local Aimbot = {}

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local GuiService = cloneref(game:GetService("GuiService"))

local Player = Players.LocalPlayer
local workspace = cloneref(game:GetService("Workspace"))
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
    -- Early Return: If already aiming, turn it off and exit
    if State.Toggles.Aim then 
        State.Toggles.Aim = false
        State.LockedTarget = nil
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
        -- Early Continues: Filter out invalid targets instantly
        if obj == Player.Character then continue end
        if obj:GetAttribute("Dead") then continue end
        
        local hrp = obj:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        -- Team Check Guard
        local targetPlayer = Players:GetPlayerFromCharacter(obj)
        if State.Toggles.TeamCheck and myTeam and targetPlayer and targetPlayer.Team == myTeam then 
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
    
    State.LockedTarget = nearest
    State.Toggles.Aim = true
end

function Aimbot.Init(State)
    Camera = workspace.CurrentCamera
    State.Connections = State.Connections or {}
    
    if State.Toggles.TeamCheck == nil then
        State.Toggles.TeamCheck = true
    end

    local removeConn = Players.PlayerRemoving:Connect(function(p)
        if not State.LockedTarget then return end
        if State.LockedTarget.Name ~= p.Name then return end
        
        State.LockedTarget = nil
        Highlight.Adornee = nil
    end)
    table.insert(State.Connections, removeConn)

    local updateConn = RunService.Heartbeat:Connect(function()
        -- Early Return: System is idle or has no target
        if not State.Toggles.Aim then Highlight.Adornee = nil return end
        
        local target = State.LockedTarget
        if not target or not target.Parent then Highlight.Adornee = nil return end
        
        -- Early Return: Reset target if they are flagged dead
        if target:GetAttribute("Dead") then
            State.LockedTarget = nil
            Highlight.Adornee = nil
            return
        end

        -- Early Return: Reset target if tracking part is missing
        local targetPart = target:FindFirstChild("HumanoidRootPart")
        if not targetPart then
            State.LockedTarget = nil
            Highlight.Adornee = nil
            return
        end

        -- Main execution path (fully flattened, no nesting)
        Highlight.Adornee = target
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
    end)
    table.insert(State.Connections, updateConn)
end

return Aimbot
