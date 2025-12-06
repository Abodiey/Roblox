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

local function debugPrint(...)
    print("[ESP DEBUG]", ...)
end

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
        debugPrint("SpectateFriend found:", plr.Name)
        break
    end
end
Players.PlayerAdded:Connect(function(plr)
    if FRIEND_MODE and not SpectateFriend and plr:IsFriendsWith(LocalPlayer.UserId) then
        SpectateFriend = plr
        debugPrint("SpectateFriend joined:", plr.Name)
    end
end)

-- Determine enemy with debug prints
local function IsEnemy(player)
    local perspective = FRIEND_MODE and SpectateFriend or LocalPlayer

    if not perspective then
        debugPrint("Perspective NIL")
        return false
    end

    if player == LocalPlayer then
        debugPrint(player.Name, "== LocalPlayer → not enemy")
        return false
    end

    if player:IsFriendsWith(LocalPlayer.UserId) then
        debugPrint(player.Name, "is a friend → not enemy")
        return false
    end

    if not player:FindFirstChild("PlayerStates") then
        debugPrint(player.Name, "missing PlayerStates")
        return false
    end

    local pTeam = player.PlayerStates:FindFirstChild("Team")
    local myTeam = perspective.PlayerStates and perspective.PlayerStates:FindFirstChild("Team")

    if not pTeam or not myTeam then
        debugPrint("Team missing for", player.Name)
        return false
    end

    local isEnemy = pTeam.Value ~= myTeam.Value
    debugPrint("IsEnemy(", player.Name, ") →", isEnemy, "(player team:", pTeam.Value, "perspective team:", myTeam.Value, ")")
    return isEnemy
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
    debugPrint("Attempt CreateESP for", player.Name)

    if ESPData[player] then
        debugPrint("ESP already exists →", player.Name)
        return
    end
    if not IsEnemy(player) then
        debugPrint("Create aborted, not enemy:", player.Name)
        return
    end

    local char = player.Character
    if not char then
        debugPrint("No character for", player.Name)
        return
    end

    local hum = char:FindFirstChild("Humanoid")
    if not hum then
        debugPrint("No humanoid for", player.Name)
        return
    end

    debugPrint("ESP CREATED for", player.Name)

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
    debugPrint("Removing ESP for", player.Name)
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
            debugPrint("ESP loop skipped for", player.Name, "→ char or hum missing")
            RemoveESP(player)
            continue
        end

        -------------------------------------------------------------------
        -- ★ DEATH CHECK #1 (PlayerStates.Alive)
        local alive = true
        if player:FindFirstChild("PlayerStates") and player.PlayerStates:FindFirstChild("Alive") then
            alive = player.PlayerStates.Alive.Value
        end

        -- ★ DEATH CHECK #2 (character.Killer exists)
        if char:FindFirstChild("Killer") then
            alive = false
        end

        debugPrint("Checking alive for", player.Name, "Alive:", alive)
        -------------------------------------------------------------------

        if not alive then
            for _,d in ipairs(data.drawings) do d.Visible=false end
            for _,s in ipairs(data.skeleton) do s.line.Visible=false end
            if data.highlight and data.highlight.Parent then
                data.highlight.FillTransparency = 1
            end
            continue
        else
            if data.highlight and data.highlight.Parent then
                data.highlight.FillTransparency = 0.3
            end
        end
    end
end)

-- HOOK PLAYER
local function HookPlayer(player)
    if player == LocalPlayer then return end
    local states = player:WaitForChild("PlayerStates",5)
    if not states then
        debugPrint("No PlayerStates for", player.Name)
        return
    end
    local aliveVal = states:WaitForChild("Alive",5)
    if not aliveVal then
        debugPrint("No Alive value for", player.Name)
        return
    end

    local function tryCreate()
        if aliveVal.Value and IsEnemy(player) then
            CreateESP(player)
        else
            debugPrint("Cannot create ESP for", player.Name, "alive:", aliveVal.Value)
        end
    end
    tryCreate()

    aliveVal.Changed:Connect(function(newVal)
        debugPrint("Alive changed for", player.Name, "→", newVal)
        if newVal and IsEnemy(player) then
            CreateESP(player)
        else
            RemoveESP(player)
        end
    end)

    player.CharacterAdded:Connect(function(newChar)
        task.wait(0.1)
        if newChar:FindFirstChild("Killer") then
            RemoveESP(player)
        elseif aliveVal.Value and IsEnemy(player) then
            CreateESP(player)
        end
    end)
end

-- TEAM CHANGE SYSTEM
local function updateESPsForTeamChange()
    debugPrint("Updating ESPs due to team change")
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
    if not perspective then
        debugPrint("No perspective for team watcher")
        return
    end
    if perspective:FindFirstChild("PlayerStates") and perspective.PlayerStates:FindFirstChild("Team") then
        perspective.PlayerStates.Team.Changed:Connect(updateESPsForTeamChange)
    end
end
setupTeamWatcher()

-- HOOK ALL PLAYERS
for _,plr in ipairs(Players:GetPlayers()) do HookPlayer(plr) end
Players.PlayerAdded:Connect(HookPlayer)
Players.PlayerRemoving:Connect(RemoveESP)
