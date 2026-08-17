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

-- Fixed R6 target parts
local R6_PART_NAMES = {
    "Head",
    "Torso",
    "HumanoidRootPart",
    "Left Arm",
    "Right Arm",
    "Left Leg",
    "Right Leg"
}

-- Static pool of 7 boxes (12 lines each) created once
local FixedBoxPool = {}

for i = 1, #R6_PART_NAMES do
    local lines = {}
    for j = 1, 12 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color3.fromRGB(255, 0, 0)
        line.Thickness = 1.5
        line.Transparency = 1
        lines[j] = line
    end
    FixedBoxPool[i] = lines
end

local function HideAllBoxes()
    for _, lines in ipairs(FixedBoxPool) do
        for _, line in ipairs(lines) do
            line.Visible = false
        end
    end
end

local function Draw3DPartBox(part, lines)
    if not part or not part:IsA("BasePart") then
        for _, line in ipairs(lines) do
            line.Visible = false
        end
        return
    end

    local cf = part.CFrame
    local size = part.Size / 2

    local corners = {
        cf * CFrame.new(-size.X,  size.Y, -size.Z),
        cf * CFrame.new( size.X,  size.Y, -size.Z),
        cf * CFrame.new( size.X,  size.Y,  size.Z),
        cf * CFrame.new(-size.X,  size.Y,  size.Z),
        cf * CFrame.new(-size.X, -size.Y, -size.Z),
        cf * CFrame.new( size.X, -size.Y, -size.Z),
        cf * CFrame.new( size.X, -size.Y,  size.Z),
        cf * CFrame.new(-size.X, -size.Y,  size.Z)
    }

    local screenCorners = {}
    for i = 1, 8 do
        local pos, onScreen = Camera:WorldToViewportPoint(corners[i].Position)
        if not onScreen then
            for _, line in ipairs(lines) do
                line.Visible = false
            end
            return
        end
        screenCorners[i] = Vector2.new(pos.X, pos.Y)
    end

    local edges = {
        {1, 2}, {2, 3}, {3, 4}, {4, 1},
        {5, 6}, {6, 7}, {7, 8}, {8, 5},
        {1, 5}, {2, 6}, {3, 7}, {4, 8}
    }

    for i, edge in ipairs(edges) do
        local line = lines[i]
        line.From = screenCorners[edge[1]]
        line.To = screenCorners[edge[2]]
        line.Visible = true
    end
end

function Aimbot.Toggle(State)
    if State.Toggles.Aim.Value then 
        State.Toggles.Aim.Value = false
        State.Variables.LockedTarget.Value = nil
        HideAllBoxes()
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
        HideAllBoxes()
    end)
    table.insert(State.Connections, removeConn)

    local updateConn = RunService.Heartbeat:Connect(function()
        if not State.Toggles.Aim.Value then 
            HideAllBoxes() 
            return 
        end
        
        local target = State.Variables.LockedTarget.Value
        if not target or not target.Parent then 
            HideAllBoxes() 
            return 
        end
        
        if target:GetAttribute("Dead") then
            State.Variables.LockedTarget.Value = nil
            State.Toggles.Aim.Value = false
            HideAllBoxes()
            return
        end

        local targetPart = target:FindFirstChild("HumanoidRootPart")
        if not targetPart then
            State.Variables.LockedTarget.Value = nil
            State.Toggles.Aim.Value = false
            HideAllBoxes()
            return
        end

        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)

        -- Reuse the pre-allocated 7 boxes directly
        for idx, partName in ipairs(R6_PART_NAMES) do
            local child = target:FindFirstChild(partName)
            if child and child:IsA("BasePart") then
                Draw3DPartBox(child, FixedBoxPool[idx])
            else
                for _, line in ipairs(FixedBoxPool[idx]) do
                    line.Visible = false
                end
            end
        end
    end)
    table.insert(State.Connections, updateConn)
end

return Aimbot
