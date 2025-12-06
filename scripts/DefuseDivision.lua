-- Centralized ESP system
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
    if plr:IsFriendsWith(LocalPlayer.UserId) then SpectateFriend = plr break end
end
Players.PlayerAdded:Connect(function(plr)
    if FRIEND_MODE and not SpectateFriend and plr:IsFriendsWith(LocalPlayer.UserId) then
        SpectateFriend = plr
    end
end)

-- Determine enemy
local function IsEnemy(player)
    local perspective = FRIEND_MODE and SpectateFriend or LocalPlayer
    if not perspective or not perspective.Character then perspective = LocalPlayer end
    if player == LocalPlayer then return false end
    if player:IsFriendsWith(LocalPlayer.UserId) then return false end
    if not player:FindFirstChild("PlayerStates") or not player.PlayerStates:FindFirstChild("Team") then return false end
    return player.PlayerStates.Team.Value ~= perspective.PlayerStates.Team.Value
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

-- Bounding box helper using only Head and HumanoidRootPart
local function getScreenBox(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not hrp or not head then
        print(char.Name.." missing HRP or Head!")
        return nil
    end

    local points = {hrp.Position, head.Position}
    local minX, maxX = huge, -huge
    local minY, maxY = huge, -huge
    local onScreen = false

    for _, pos in ipairs(points) do
        local screenPos, visible = cam:WorldToViewportPoint(pos)
        print("Debug:", char.Name, "screenPos:", screenPos, "visible:", visible)
        if screenPos.Z > 0 and visible then
            onScreen = true
            minX = min(minX, screenPos.X)
            maxX = max(maxX, screenPos.X)
            minY = min(minY, screenPos.Y)
            maxY = max(maxY, screenPos.Y)
        end
    end

    if not onScreen then
        print(char.Name.." is offscreen, hiding ESP")
        return nil
    end
    return Vector2.new(minX, minY), Vector2.new(maxX, maxY)
end

local function CreateESP(player)
    if ESPData[player] then return end
    if not IsEnemy(player) then
        print(player.Name.." is not enemy, skipping ESP")
        return
    end

    local char = player.Character
    if not char then
        print(player.Name.." has no character, skipping ESP")
        return
    end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then
        print(player.Name.." has no Humanoid, skipping ESP")
        return
    end

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
    print("ESP created for "..player.Name)
end

local function RemoveESP(player)
    local data = ESPData[player]
    if not data then return end
    if data.highlight and data.highlight.Parent then data.highlight:Destroy() end
    for _,d in ipairs(data.drawings) do if d.Remove then pcall(function() d:Remove() end) end end
    for _,s in ipairs(data.skeleton) do if s.line and s.line.Remove then pcall(function() s.line:Remove() end) end end
    ESPData[player] = nil
    print("ESP removed for "..player.Name)
end

-- CENTRAL RENDER LOOP
RunService.RenderStepped:Connect(function()
    for player,data in pairs(ESPData) do
        local char = data.char
        local hum = data.hum
        if not char or not hum or not char.Parent then
            RemoveESP(player)
            continue
        end

        -- Alive check
        local alive = true
        if player:FindFirstChild("PlayerStates") and player.PlayerStates:FindFirstChild("Alive") then
            alive = player.PlayerStates.Alive.Value
        end
        if char:FindFirstChild("Killer") then alive = false end

        if not alive then
            for _,d in ipairs(data.drawings) do d.Visible=false end
            for _,s in ipairs(data.skeleton) do s.line.Visible=false end
            if data.highlight and data.highlight.Parent then data.highlight.FillTransparency = 1 end
            continue
        else
            if data.highlight and data.highlight.Parent then data.highlight.FillTransparency = 0.3 end
        end

        -- Bounding box
        local minPos, maxPos = getScreenBox(char)
        if not minPos or not maxPos then
            for _,d in ipairs(data.drawings) do d.Visible=false end
            for _,s in ipairs(data.skeleton) do s.line.Visible=false end
            continue
        end

        local minX, minY = minPos.X, minPos.Y
        local maxX, maxY = maxPos.X, maxPos.Y
        local barHeight = maxY-minY
        local distance = (char.HumanoidRootPart.Position-cam.CFrame.Position).Magnitude
        local fontSize = clamp(MAX_FONT_SIZE/(distance/15), MIN_FONT_SIZE, MAX_FONT_SIZE)

        -- Box
        local playerBox = data.drawings[7]
        playerBox.Position = Vector2.new(minX,minY)
        playerBox.Size = Vector2.new(maxX-minX,maxY-minY)
        playerBox.Visible = true

        -- Health
        local healthBar = data.drawings[1]
        local healthX = minX-BAR_WIDTH-5
        local healthRatio = hum.Health>0 and clamp(hum.Health/hum.MaxHealth,0,1) or 0
        healthBar.Position = Vector2.new(healthX,minY)
        healthBar.Size = Vector2.new(BAR_WIDTH,barHeight)
        healthBar.Color = getHealthColor(healthRatio)
        healthBar.Visible = true

        local healthText = data.drawings[3]
        healthText.Text = tostring(ceil(hum.Health))
        healthText.Position = Vector2.new(healthX+BAR_WIDTH/2,minY-15)
        healthText.Size = fontSize
        healthText.Visible = true

        -- Armor
        local armorBar = data.drawings[2]
        local armorVal = char:FindFirstChild("Armor")
        local armorRatio = armorVal and clamp(armorVal.Value/100,0,1) or 0
        local armorX = maxX+5
        armorBar.Position = Vector2.new(armorX,minY+(1-armorRatio)*barHeight)
        armorBar.Size = Vector2.new(BAR_WIDTH,barHeight*armorRatio)
        armorBar.Color = lerpColor(ARMOR_COLOR_MIN,ARMOR_COLOR_MAX,armorRatio)
        armorBar.Visible = true

        local armorText = data.drawings[4]
        armorText.Text = armorVal and tostring(ceil(armorVal.Value)) or "0"
        armorText.Position = Vector2.new(armorX+BAR_WIDTH/2,minY-15)
        armorText.Size = fontSize
        armorText.Visible = true

        -- Name & Gun
        local nameText = data.drawings[5]
        nameText.Text = player.Name
        nameText.Position = Vector2.new((minX+maxX)/2,minY+NAME_OFFSET_Y)
        nameText.Size = fontSize
        nameText.Visible = true

        local gunText = data.drawings[6]
        local gunName = "None"
        local gun = char:FindFirstChild("Gun") or char:FindFirstChild("Gun1")
        if gun and gun:FindFirstChild("GunName") then gunName = gun.GunName.Value end
        gunText.Text = "Gun: "..gunName
        gunText.Position = Vector2.new(maxX+5,minY)
        gunText.Size = fontSize
        gunText.Visible = true

        -- Skeleton
        for _,sk in ipairs(data.skeleton) do
            local p1 = char:FindFirstChild(sk.parts[1])
            local p2 = char:FindFirstChild(sk.parts[2])
            if p1 and p2 then
                local s1 = cam:WorldToViewportPoint(p1.Position)
                local s2 = cam:WorldToViewportPoint(p2.Position)
                sk.line.From = Vector2.new(s1.X,s1.Y)
                sk.line.To = Vector2.new(s2.X,s2.Y)
                sk.line.Visible = true
            else
                sk.line.Visible = false
            end
        end
    end
end)

-- HOOK PLAYER
local function HookPlayer(player)
    local function tryCreate()
        if player.Character and player:FindFirstChild("PlayerStates") and player.PlayerStates:FindFirstChild("Alive") then
            if player.PlayerStates.Alive.Value and IsEnemy(player) then
                CreateESP(player)
            end
        end
    end
    tryCreate()

    -- Listen for Alive changes
    if player:FindFirstChild("PlayerStates") and player.PlayerStates:FindFirstChild("Alive") then
        player.PlayerStates.Alive.Changed:Connect(function(newVal)
            if newVal and IsEnemy(player) then
                CreateESP(player)
            else
                RemoveESP(player)
            end
        end)
    end

    -- Listen for character respawn
    player.CharacterAdded:Connect(function(newChar)
        task.wait(0.1)
        if newChar:FindFirstChild("Killer") then
            RemoveESP(player)
        elseif player:FindFirstChild("PlayerStates") and player.PlayerStates:FindFirstChild("Alive") and player.PlayerStates.Alive.Value and IsEnemy(player) then
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
