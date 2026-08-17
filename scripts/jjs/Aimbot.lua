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

-- Static edge index map (reused across all 3D box computations)
local BOX_EDGES = {
    {1, 2}, {2, 3}, {3, 4}, {4, 1},
    {5, 6}, {6, 7}, {7, 8}, {8, 5},
    {1, 5}, {2, 6}, {3, 7}, {4, 8}
}

-- Reusable buffer for screen projection (prevents GC allocations every frame)
local ScreenCornersBuffer = table.create(8)

-- Pre-created static pool of 7 boxes (12 lines each)
local FixedBoxPool = table.create(#R6_PART_NAMES)

for i = 1, #R6_PART_NAMES do
    local lines = table.create(12)
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
    for i = 1, #FixedBoxPool do
        local lines = FixedBoxPool[i]
        for j = 1, 12 do
            local line = lines[j]
            if line.Visible then
                line.Visible = false
            end
        end
    end
end

local function HideBox(lines)
    for j = 1, 12 do
        local line = lines[j]
        if line.Visible then
            line.Visible = false
        end
    end
end

local function Draw3DPartBox(part, lines)
    if not part or not part:IsA("BasePart") then
        HideBox(lines)
        return
    end

    local cf = part.CFrame
    local size = part.Size * 0.5
    local sx, sy, sz = size.X, size.Y, size.Z

    -- Fast vector transformation via PointToWorldSpace without creating CFrame instances
    local corners = {
        cf:PointToWorldSpace(Vector3.new(-sx,  sy, -sz)),
        cf:PointToWorldSpace(Vector3.new( sx,  sy, -sz)),
        cf:PointToWorldSpace(Vector3.new( sx,  sy,  sz)),
        cf:PointToWorldSpace(Vector3.new(-sx,  sy,  sz)),
        cf:PointToWorldSpace(Vector3.new(-sx, -sy, -sz)),
        cf:PointToWorldSpace(Vector3.new( sx, -sy, -sz)),
        cf:PointToWorldSpace(Vector3.new( sx, -sy,  sz)),
        cf:PointToWorldSpace(Vector3.new(-sx, -sy,  sz))
    }

    -- Project corners to screen space
    for i = 1, 8 do
        local pos, onScreen = Camera:WorldToViewportPoint(corners[i])
        if not onScreen then
            HideBox(lines)
            return
        end
        ScreenCornersBuffer[i] = Vector2.new(pos.X, pos.Y)
    end

    -- Draw lines using static edges
    for i = 1, 12 do
        local edge = BOX_EDGES[i]
        local line = lines[i]
        line.From = ScreenCornersBuffer[edge[1]]
        line.To = ScreenCornersBuffer[edge[2]]
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

    local updateConn = RunService.RenderStepped:Connect(function()
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

        -- Optimized 3D Box Rendering loop
        for idx = 1, #R6_PART_NAMES do
            local child = target:FindFirstChild(R6_PART_NAMES[idx])
            if child and child:IsA("BasePart") then
                Draw3DPartBox(child, FixedBoxPool[idx])
            else
                HideBox(FixedBoxPool[idx])
            end
        end
    end)
    table.insert(State.Connections, updateConn)
end

return Aimbot
