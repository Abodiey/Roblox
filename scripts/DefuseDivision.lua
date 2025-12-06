-- Centralized ESP system with debug prints
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- SETTINGS
local FRIEND_MODE = true
local SpectateFriend = nil
local BAR_WIDTH = 3
local MAX_FONT_SIZE = 20
local MIN_FONT_SIZE = 12
local ARMOR_COLOR_MIN = Color3.fromRGB(0,0,128)
local ARMOR_COLOR_MAX = Color3.fromRGB(102,178,255)
local NAME_OFFSET_Y = -25
local BOX_THICKNESS = 1
local SKELETON_COLOR = Color3.new(1,1,1)

-- UTIL FUNCTIONS
local clamp, ceil, min, max, huge = math.clamp, math.ceil, math.min, math.max, math.huge

local function lerpColor(c1, c2, t)
    t = clamp(t or 0,0,1)
    return Color3.new(
        c1.R + (c2.R-c1.R)*t,
        c1.G + (c2.G-c1.G)*t,
        c1.B + (c2.B-c1.B)*t
    )
end

local function getHealthColor(ratio)
    ratio = clamp(ratio or 0,0,1)
    if ratio > 0.66 then
        return lerpColor(Color3.fromRGB(255,255,0), Color3.fromRGB(0,255,0),(ratio-0.66)/0.34)
    elseif ratio > 0.33 then
        return lerpColor(Color3.fromRGB(255,255,0), Color3.fromRGB(255,165,0),(ratio-0.33)/0.33)
    else
        return lerpColor(Color3.fromRGB(255,165,0), Color3.fromRGB(255,0,0),ratio/0.33)
    end
end

local SKELETON_JOINTS = {
    {"Head","HumanoidRootPart"},
    {"HumanoidRootPart","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"HumanoidRootPart","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"HumanoidRootPart","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"HumanoidRootPart","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}
}

-- FRIEND MODE: find first friend
for _,plr in ipairs(Players:GetPlayers()) do
    if plr:IsFriendsWith(LocalPlayer.UserId) then 
        SpectateFriend = plr 
        print("Friend found on script start:", plr.Name)
        break 
    end
end
Players.PlayerAdded:Connect(function(plr)
    if FRIEND_MODE and not SpectateFriend and plr:IsFriendsWith(LocalPlayer.UserId) then
        SpectateFriend = plr
        print("Friend found on PlayerAdded:", plr.Name)
    end
end)

-- Determine enemy
local function IsEnemy(player)
    local perspective = FRIEND_MODE and SpectateFriend or LocalPlayer
    if not perspective or not perspective.Character then perspective = LocalPlayer end

    if player == LocalPlayer then 
        print(player.Name,"is local player, not enemy")
        return false 
    end
    if player:IsFriendsWith(LocalPlayer.UserId) then 
        print(player.Name,"is friend, not enemy")
        return false 
    end
    if not player:FindFirstChild("PlayerStates") or not player.PlayerStates:FindFirstChild("Team") then 
        print(player.Name,"missing PlayerStates or Team")
        return false 
    end

    local enemy = player.PlayerStates.Team.Value ~= perspective.PlayerStates.Team.Value
    print(player.Name,"IsEnemy check:", enemy)
    return enemy
end

-- ESP STORAGE
local ESPData = {}

-- CREATE DRAWINGS
local function newText(center)
    local t = Drawing.new("Text")
    t.Center = center
    t.Outline = true
    t.OutlineColor = Color3.new(0,0,0)
    t.Visible = true
    return t
end

local function CreateESP(player)
    print("Attempting CreateESP for:", player.Name)

    if ESPData[player] then 
        print("ESP already exists for", player.Name)
        return 
    end
    if not IsEnemy(player) then 
        print(player.Name,"is not enemy, skipping ESP")
        return 
    end

    local char = player.Character
    if not char then 
        print(player.Name,"has no character yet")
        return 
    end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then 
        print(player.Name,"has no Humanoid")
        return 
    end

    print("Creating ESP for", player.Name)
    -- Highlight
    if char:FindFirstChild("ESPHighlight") then char.ESPHighlight:Destroy() end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.Adornee = char
    highlight.FillColor = Color3.fromRGB(0,255,0)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 1
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Parent = char

    if char:FindFirstChild("Shirt") then char.Shirt:Destroy() end

    -- Drawings
    local healthBar = Drawing.new("Square"); healthBar.Filled=true; healthBar.Visible=true
    local armorBar = Drawing.new("Square"); armorBar.Filled=true; armorBar.Visible=true
    local healthText = newText(true); healthText.Color=Color3.fromRGB(180,255,180)
    local armorText = newText(true); armorText.Color=Color3.fromRGB(180,180,255)
    local nameText = newText(true); nameText.Color=Color3.new(1,1,1)
    local gunText = newText(false); gunText.Color=Color3.new(1,1,1)
    local playerBox = Drawing.new("Square"); playerBox.Filled=false; playerBox.Thickness=1; playerBox.Color=Color3.new(1,1,1)

    local skeletonLines = {}
    for _,pair in ipairs(SKELETON_JOINTS) do
        local ln = Drawing.new("Line"); ln.Color=SKELETON_COLOR; ln.Visible=true; ln.Thickness=1
        table.insert(skeletonLines,{line=ln,parts=pair})
    end

    ESPData[player] = {
        char = char,
        hum = hum,
        highlight = highlight,
        drawings = {healthBar,armorBar,healthText,armorText,nameText,gunText,playerBox},
        skeleton = skeletonLines
    }
end

-- REMOVE ESP
local function RemoveESP(player)
    print("Removing ESP for", player.Name)
    local data = ESPData[player]
    if not data then return end
    if data.highlight and data.highlight.Parent then data.highlight:Destroy() end
    for _,d in ipairs(data.drawings) do if d.Remove then pcall(function() d:Remove() end) end end
    for _,s in ipairs(data.skeleton) do if s.line and s.line.Remove then pcall(function() s.line:Remove() end) end end
    ESPData[player] = nil
end

-- CENTRAL RENDER LOOP
RunService.RenderStepped:Connect(function()
    for player,data in pairs(ESPData) do
        local char = data.char
        local hum = data.hum
        if not char or not hum or not char.Parent then
            print("Skipping render for", player.Name,"(no char/hum/parent)")
            RemoveESP(player)
            continue
        end

        -- Alive check
        local alive = true
        if player:FindFirstChild("PlayerStates") and player.PlayerStates:FindFirstChild("Alive") then
            alive = player.PlayerStates.Alive.Value
        end
        if char:FindFirstChild("Killer") then alive=false end

        if not alive then
            for _,d in ipairs(data.drawings) do d.Visible=false end
            for _,s in ipairs(data.skeleton) do s.line.Visible=false end
            if data.highlight and data.highlight.Parent then data.highlight.FillTransparency=1 end
            print(player.Name,"is dead, hiding ESP")
            continue
        else
            if data.highlight and data.highlight.Parent then data.highlight.FillTransparency=0.3 end
        end

        -- Bounding box computation
        local modelCFrame = char:GetModelCFrame()
        local size = char:GetExtentsSize()
        local half = size*0.5
        local offsets = {
            Vector3.new(-half.X,-half.Y,-half.Z),Vector3.new(-half.X,-half.Y,half.Z),
            Vector3.new(-half.X,half.Y,-half.Z),Vector3.new(-half.X,half.Y,half.Z),
            Vector3.new(half.X,-half.Y,-half.Z),Vector3.new(half.X,-half.Y,half.Z),
            Vector3.new(half.X,half.Y,-half.Z),Vector3.new(half.X,half.Y,half.Z)
        }

        local minX,maxX = huge,-huge
        local minY,maxY = huge,-huge
        local onScreen=false

        for _,offset in ipairs(offsets) do
            local worldPos = modelCFrame.Position + modelCFrame:VectorToWorldSpace(offset)
            local screenPos, visible = cam:WorldToViewportPoint(worldPos)
            if visible then
                onScreen=true
                local sx,sy = screenPos.X, screenPos.Y
                minX = min(minX,sx); maxX = max(maxX,sx)
                minY = min(minY,sy); maxY = max(maxY,sy)
            end
        end

        if not onScreen then
            for _,d in ipairs(data.drawings) do d.Visible=false end
            for _,s in ipairs(data.skeleton) do s.line.Visible=false end
            print(player.Name,"is offscreen, hiding ESP")
            continue
        end
    end
end)

-- HOOK PLAYER
local function HookPlayer(player)
    if player == LocalPlayer then return end
    print("Hooking player:", player.Name)

    local states = player:WaitForChild("PlayerStates",5)
    if not states then print("No PlayerStates for", player.Name) return end
    local aliveVal = states:WaitForChild("Alive",5)
    if not aliveVal then print("No Alive value for", player.Name) return end

    local function tryCreate()
        print("Trying ESP for", player.Name, "Alive:", aliveVal.Value, "IsEnemy:", IsEnemy(player))
        if aliveVal.Value and IsEnemy(player) then
            CreateESP(player)
        end
    end
    tryCreate()

    aliveVal.Changed:Connect(function(newVal)
        print(player.Name,"Alive changed to",newVal)
        if newVal and IsEnemy(player) then
            CreateESP(player)
        else
            RemoveESP(player)
        end
    end)

    player.CharacterAdded:Connect(function(newChar)
        task.wait(0.1)
        print(player.Name,"CharacterAdded triggered")
        if newChar:FindFirstChild("Killer") then
            RemoveESP(player)
        elseif aliveVal.Value and IsEnemy(player) then
            CreateESP(player)
        end
    end)
end

-- TEAM CHANGE SYSTEM
local function updateESPsForTeamChange()
    for player,_ in pairs(ESPData) do
        if IsEnemy(player) then
            CreateESP(player)
        else
            RemoveESP(player)
        end
    end
end

local function setupTeamWatcher()
    local perspective = FRIEND_MODE and SpectateFriend or LocalPlayer
    if not perspective then return end
    if perspective:FindFirstChild("PlayerStates") and perspective.PlayerStates:FindFirstChild("Team") then
        perspective.PlayerStates.Team.Changed:Connect(updateESPsForTeamChange)
    end
end
setupTeamWatcher()

-- HOOK ALL PLAYERS
for _,plr in ipairs(Players:GetPlayers()) do HookPlayer(plr) end
Players.PlayerAdded:Connect(HookPlayer)
Players.PlayerRemoving:Connect(RemoveESP)
