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

-- Static lookup tables for 3D box calculations (prevents GC allocations every frame)
local CORNER_MULTIPLIERS = {
    Vector3.new(-1,  1, -1),
    Vector3.new( 1,  1, -1),
    Vector3.new( 1,  1,  1),
    Vector3.new(-1,  1,  1),
    Vector3.new(-1, -1, -1),
    Vector3.new( 1, -1, -1),
    Vector3.new( 1, -1,  1),
    Vector3.new(-1, -1,  1)
}

local EDGES = {
    {1, 2}, {2, 3}, {3, 4}, {4, 1},
    {5, 6}, {6, 7}, {7, 8}, {8, 5},
    {1, 5}, {2, 6}, {3, 7}, {4, 8}
}

-- Screen position cache to avoid array creation inside Draw3DPartBox
local screenCornersCache = table.create(8)

-- Static pool of 7 boxes (12 lines each) created once
local FixedBoxPool = {}

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

-- Part Caching variables
local CachedTarget = nil
local CachedParts = table.create(#R6_PART_NAMES)

local function ClearPartCache()
    CachedTarget = nil
    for i = 1, #R6_PART_NAMES do
        CachedParts[i] = nil
    end
end

local function HideAllBoxes()
    for i = 1, #FixedBoxPool do
        local lines = FixedBoxPool[i]
        for j = 1, 12 do
            lines[j].Visible = false
        end
    end
end

local function Draw3DPartBox(part, lines)
    if not part or not part:IsA("BasePart") or not part.Parent then
        for i = 1, 12 do
            lines[i].Visible = false
        end
        return
    end

    local cf = part.CFrame
    local halfSize = part.Size * 0.5

    -- Compute world-to-viewport points directly using CFrame:PointToWorldSpace
    for i = 1, 8 do
        local worldPos = cf:PointToWorldSpace(halfSize * CORNER_MULTIPLIERS[i])
        local pos, onScreen = Camera:WorldToViewportPoint(worldPos)

        if not onScreen then
            for j = 1, 12 do
                lines[j].Visible = false
            end
            return
        end

        screenCornersCache[i] = Vector2.new(pos.X, pos.Y)
    end

    -- Update 12 bounding lines using static EDGES lookup
    for i = 1, 12 do
        local edge = EDGES[i]
        local line = lines[i]
        line.From = screenCornersCache[edge[1]]
        line.To = screenCornersCache[edge[2]]
        line.Visible = true
    end
end

function Aimbot.Toggle(State)
    if State.Toggles.Aim.Value then 
        State.Toggles.Aim.Value = false
        State.Variables.LockedTarget.Value = nil
        ClearPartCache()
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
        ClearPartCache()
        HideAllBoxes()
    end)
    table.insert(State.Connections, removeConn)

    -- AIMBOT LOOP (Exact logic maintained)
    local updateConn = RunService.RenderStepped:Connect(function()
        if not State.Toggles.Aim.Value then 
            return 
        end
        
        local target = State.Variables.LockedTarget.Value
        if not target or not target.Parent then 
            return 
        end
        
        if target:GetAttribute("Dead") then
            State.Variables.LockedTarget.Value = nil
            State.Toggles.Aim.Value = false
            return
        end

        local targetPart = target:FindFirstChild("HumanoidRootPart")
        if not targetPart then
            State.Variables.LockedTarget.Value = nil
            State.Toggles.Aim.Value = false
            return
        end

        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
    end)
    table.insert(State.Connections, updateConn)

    -- OPTIMIZED 3D ESP LOOP WITH PART CACHING
    local espConn = RunService.RenderStepped:Connect(function()
        if not State.Toggles.Aim.Value then 
            if CachedTarget then ClearPartCache() end
            HideAllBoxes() 
            return 
        end
        
        local target = State.Variables.LockedTarget.Value
        if not target or not target.Parent or target:GetAttribute("Dead") then 
            if CachedTarget then ClearPartCache() end
            HideAllBoxes() 
            return 
        end

        -- Update cache if target changed
        if CachedTarget ~= target then
            CachedTarget = target
            for idx = 1, #R6_PART_NAMES do
                local child = target:FindFirstChild(R6_PART_NAMES[idx])
                CachedParts[idx] = (child and child:IsA("BasePart")) and child or false
            end
        end

        -- Render using cached part references directly
        for idx = 1, #R6_PART_NAMES do
            local cachedPart = CachedParts[idx]
            if cachedPart then
                Draw3DPartBox(cachedPart, FixedBoxPool[idx])
            else
                local lines = FixedBoxPool[idx]
                for j = 1, 12 do
                    lines[j].Visible = false
                end
            end
        end
    end)
    table.insert(State.Connections, espConn)
end

return Aimbot
