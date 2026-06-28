local ESP = {}

-- Localize Services & Core API
local cloneref = cloneref
local game = game
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local workspace = cloneref(game:GetService("Workspace"))

-- Localize Global Engine Functions
local task = task
local t_wait = task.wait
local Instance = Instance
local inst_new = Instance.new
local type = type
local tostring = tostring
local ipairs = ipairs
local pairs = pairs
local table = table
local table_insert = table.insert
local table_clear = table.clear

-- Localize Math & String Libraries
local math = math
local m_clamp = math.clamp
local m_floor = math.floor
local m_deg = math.deg
local m_atan2 = math.atan2
local string = string
local s_format = string.format
local os = os
local o_clock = os.clock

-- Localize Roblox Datatypes
local Vector2 = Vector2
local v2_new = Vector2.new
local Vector3 = Vector3
local v3_new = Vector3.new
local UDim2 = UDim2
local ud2_new = UDim2.new
local Color3 = Color3
local c3_fromHex = Color3.fromHex
local c3_new = Color3.new
local Enum = Enum

local lp = Players.LocalPlayer
if not lp then
    task.spawn(function()
        lp = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    end)
end
local TARGET_GROUP = 16357742

-- Clean previous asset hierarchy
while CoreGui:FindFirstChild("PlayerESP") do
    CoreGui.PlayerESP:Destroy()
    t_wait()
end

local ScreenGui = inst_new("ScreenGui")
ScreenGui.Name = "PlayerESP"
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local Cache = {}
local FrameTick = 0 

-- Design Palette Constants
local COLOR_RED = c3_new(1, 0.1, 0.1)
local COLOR_YELLOW = c3_new(1, 1, 0)
local COLOR_GREEN = c3_new(0, 1, 0)
local COLOR_BRIGHT_GREEN = c3_new(0, 1, 0.2)
local COLOR_CYAN = c3_new(0, 0.8, 1)
local COLOR_DARK_BLUE = c3_new(0, 0.1, 0.5)
local COLOR_WHITE = c3_new(1, 1, 1)
local COLOR_BLACK = c3_new(0, 0, 0)
local COLOR_GOLD = c3_new(1, 0.85, 0)
local COLOR_PURPLE = c3_new(0.68, 0.1, 1)

-- JJK Character Moveset Color Map
local MOVESET_COLORS = {
    ["Gojo"]       = "55FFFF",
    ["Itadori"]    = "FF0000",
    ["Hakari"]     = "55FF7F",
    ["Megumi"]     = "2D2D2D",
    ["Mahito"]     = "AAAAFF",
    ["Choso"]      = "820000",
    ["Todo"]       = "86D7FF",
    ["Hiromi"]     = "B3823D",
    ["Yuta"]       = "FFAAFF",
    ["Mechamaru"]  = "E10A4B",
    ["Naoya"]      = "BCBCFF",
    ["Nanami"]     = "83CBC7",
    ["Hanami"]     = "ACCBA3",
    ["Ryu"]        = "AAFFFF",
    ["Locust"]     = "55AA00",
    ["Yuki"]       = "000000",
    ["Charles"]    = "9D8D6D",
    ["Haruta"]     = "A77DCB",
    ["MeiMei"]     = "232850",
    ["Kurourushi"] = "65232C",
    ["Custom"]     = "00FF80"
}

-- Dark Moveset Identification Table
local DARK_MOVESETS = {
    ["Megumi"]     = true,
    ["Choso"]      = true,
    ["Yuki"]       = true,
    ["MeiMei"]     = true,
    ["Kurourushi"] = true
}

local function getGradientColor(percent)
    percent = m_clamp(percent, 0, 1)
    if percent > 0.5 then
        return COLOR_YELLOW:Lerp(COLOR_GREEN, (percent - 0.5) * 2)
    end
    return COLOR_RED:Lerp(COLOR_YELLOW, percent * 2)
end

local function formatVal(val)
    return val >= 1000 and s_format("%.1fk", val / 1000) or tostring(val)
end

local function isCustom(movesetFolder)
    if not movesetFolder then return false end
    local children = movesetFolder:GetChildren()
    if #children == 0 then return false end
    
    for _, move in ipairs(children) do
        if move.Name ~= "Custom" then 
            return false 
        end
    end
    return true
end

-- Draws Brawlhalla style interval ticks and populates reference arrays
local function applyBrawlhallaTicks(parentFrame, isVertical)
    local lineCache = {}
    for idx = 1, 9 do
        local tick = inst_new("Frame")
        tick.BorderSizePixel = 0
        tick.BackgroundColor3 = COLOR_BLACK
        tick.BackgroundTransparency = 0.5
        tick.ZIndex = 3
        if isVertical then
            tick.Size = ud2_new(1, 0, 0, 1)
            tick.Position = ud2_new(0, 0, 0.1 * idx, 0)
        else
            tick.Size = ud2_new(0, 1, 1, 0)
            tick.Position = ud2_new(0.1 * idx, 0, 0, 0)
        end
        tick.Parent = parentFrame
        lineCache[idx] = tick
    end
    return lineCache
end

local function CreateAssets(p)
    local assets = {}
    
    -- Tracer Line Frame
    local line = inst_new("Frame")
    line.BorderSizePixel = 0
    line.AnchorPoint = v2_new(0.5, 0.5)
    line.ZIndex = 1
    line.Parent = ScreenGui
    assets.Line = line
    
    -- 1. OVERHEAD BILLBOARD (Text & Ultimate Bar Only)
    local bill = inst_new("BillboardGui")
    bill.AlwaysOnTop = true
    bill.Size = ud2_new(0, 200, 0, 42)
    bill.ExtentsOffset = v3_new(0, 3.3, 0)
    bill.Parent = ScreenGui
    assets.Bill = bill
    
    local mainFrame = inst_new("Frame")
    mainFrame.Size = ud2_new(1, 0, 1, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = bill
    
    local blockLayout = inst_new("UIListLayout")
    blockLayout.SortOrder = Enum.SortOrder.LayoutOrder
    blockLayout.Padding = UDim.new(0, 2)
    blockLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    blockLayout.Parent = mainFrame

    local txt = inst_new("TextLabel")
    txt.Size = ud2_new(1, 0, 1, -8)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = COLOR_WHITE
    txt.RichText = true
    txt.Font = Enum.Font.RobotoMono
    txt.TextSize = 11
    txt.LayoutOrder = 1
    txt.Parent = mainFrame
    assets.Text = txt
    
    local stroke = inst_new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = COLOR_BLACK
    stroke.Parent = txt
    assets.Stroke = stroke
    
    local ultBack = inst_new("Frame")
    ultBack.Size = ud2_new(1, 0, 0, 5)
    ultBack.BackgroundColor3 = c3_new(0.05, 0.05, 0.05)
    ultBack.BackgroundTransparency = 0.5
    ultBack.BorderSizePixel = 0
    ultBack.ZIndex = 1
    ultBack.LayoutOrder = 2
    ultBack.Parent = mainFrame
    assets.UltBack = ultBack
    
    local ultStroke = inst_new("UIStroke")
    ultStroke.Thickness = 1
    ultStroke.Color = COLOR_BLACK
    ultStroke.Parent = ultBack
    assets.UltStroke = ultStroke
    
    local ultFill = inst_new("Frame")
    ultFill.Size = ud2_new(0, 0, 1, 0)
    ultFill.BorderSizePixel = 0
    ultFill.BackgroundTransparency = 0.2
    ultFill.ZIndex = 2
    ultFill.Parent = ultBack
    assets.UltFill = ultFill
    assets.UltLines = applyBrawlhallaTicks(ultBack, false)

    -- 2. PHYSICAL CHARACTER SIDEBARS (Widened to 5.4 studs to clear animations)
    local bodyBill = inst_new("BillboardGui")
    bodyBill.AlwaysOnTop = true
    bodyBill.Size = ud2_new(5.4, 0, 4.8, 0)
    bodyBill.ExtentsOffset = v3_new(0, -0.3, 0)
    bodyBill.Parent = ScreenGui
    assets.BodyBill = bodyBill

    -- Left Sidebar: Health
    local hBack = inst_new("Frame")
    hBack.Size = ud2_new(0, 5, 1, 0)
    hBack.Position = ud2_new(0, 0, 0, 0)
    hBack.BackgroundColor3 = c3_new(0.05, 0.05, 0.05)
    hBack.BackgroundTransparency = 0.5
    hBack.BorderSizePixel = 0
    hBack.ZIndex = 1
    hBack.Parent = bodyBill
    assets.HealthBack = hBack
    
    local hBackStroke = inst_new("UIStroke")
    hBackStroke.Thickness = 1
    hBackStroke.Color = COLOR_BLACK
    hBackStroke.Parent = hBack
    assets.HealthBackStroke = hBackStroke
    
    local hFill = inst_new("Frame")
    hFill.Size = ud2_new(1, 0, 1, 0)
    hFill.AnchorPoint = v2_new(0, 1)
    hFill.Position = ud2_new(0, 0, 1, 0)
    hFill.BorderSizePixel = 0
    hFill.BackgroundTransparency = 0.2
    hFill.ZIndex = 2
    hFill.BackgroundColor3 = COLOR_BRIGHT_GREEN
    hFill.Parent = hBack
    assets.HealthFill = hFill
    assets.HealthLines = applyBrawlhallaTicks(hBack, true)

    -- Right Sidebar: Evade
    local eBack = inst_new("Frame")
    eBack.Size = ud2_new(0, 5, 1, 0)
    eBack.Position = ud2_new(1, -5, 0, 0)
    eBack.BackgroundColor3 = c3_new(0.05, 0.05, 0.05)
    eBack.BackgroundTransparency = 0.5
    eBack.BorderSizePixel = 0
    eBack.ZIndex = 1
    eBack.Parent = bodyBill
    assets.EvadeBack = eBack
    
    local eBackStroke = inst_new("UIStroke")
    eBackStroke.Thickness = 1
    eBackStroke.Color = COLOR_BLACK
    eBackStroke.Parent = eBack
    assets.EvadeBackStroke = eBackStroke
    
    local eFill = inst_new("Frame")
    eFill.Size = ud2_new(1, 0, 0, 0)
    eFill.AnchorPoint = v2_new(0, 1)
    eFill.Position = ud2_new(0, 0, 1, 0)
    eFill.BorderSizePixel = 0
    eFill.BackgroundTransparency = 0.2
    eFill.ZIndex = 2
    eFill.BackgroundColor3 = COLOR_CYAN
    eFill.Parent = eBack
    assets.EvadeFill = eFill
    assets.EvadeLines = applyBrawlhallaTicks(eBack, true)
    
    -- Connections and runtime storage
    assets.Connections = {}
    assets.CharacterConnections = {} 
    assets.KillValueConnections = {} 
    
    -- AFK Detection Coordinates
    assets.LastPosition = v3_new(0, 0, 0)
    assets.LastMoveTime = o_clock()
    assets.IsAFK = false
    
    assets.LastDist = 0
    assets.CachedKills = 0
    assets.CachedMoveset = ""
    assets.NameDisplay = ""
    assets.CashDisplay = ""
    assets.GroupRoleTag = ""
    assets.LineColor = COLOR_GREEN
    assets.HexKillColor = "ffffff"
    assets.HexDistColor = "ffffff"
    assets.IsHidingKills = false
    
    return assets
end

local function CleanupCacheEntry(p, assets)
    for _, conn in ipairs(assets.Connections) do conn:Disconnect() end
    for _, conn in ipairs(assets.CharacterConnections) do conn:Disconnect() end
    for _, conn in ipairs(assets.KillValueConnections) do conn:Disconnect() end
    if assets.Line then assets.Line:Destroy() end
    if assets.Bill then assets.Bill:Destroy() end
    if assets.BodyBill then assets.BodyBill:Destroy() end
    Cache[p] = nil
end

local function SetupPlayerSignals(p, assets)
    task.spawn(function()
        local success, role = pcall(function() return p:GetRoleInGroup(TARGET_GROUP) end)
        if success and role and role ~= "Guest" and role ~= "Member" then
            assets.GroupRoleTag = s_format("<font color='#00AAFF'>[%s]</font> ", role)
        end
    end)

    local function trackValueInstance(killsVal)
        for _, conn in ipairs(assets.KillValueConnections) do conn:Disconnect() end
        table_clear(assets.KillValueConnections)

        if not killsVal then return end

        local function updateKills()
            assets.CachedKills = tonumber(killsVal.Value) or 0
            local killCol = getGradientColor(1 - (assets.CachedKills / 1000))
            assets.HexKillColor = s_format("%02x%02x%02x", m_floor(killCol.R * 255), m_floor(killCol.G * 255), m_floor(killCol.B * 255))
        end
        table_insert(assets.KillValueConnections, killsVal:GetPropertyChangedSignal("Value"):Connect(updateKills))
        updateKills()
    end

    local function watchKills(leaderstats)
        local function evaluateSource()
            local isHidden = leaderstats:GetAttribute("HiddenKills")
            assets.IsHidingKills = not (not isHidden)

            if isHidden then
                local hiddenFolder = leaderstats:FindFirstChild("Hidden")
                if hiddenFolder then
                    local killsVal = hiddenFolder:FindFirstChild("Kills")
                    if killsVal then trackValueInstance(killsVal) end
                end
            else
                local killsVal = leaderstats:FindFirstChild("Kills")
                if killsVal then trackValueInstance(killsVal) end
            end
        end

        table_insert(assets.Connections, leaderstats:GetAttributeChangedSignal("HiddenKills"):Connect(evaluateSource))
        evaluateSource()
    end

    local leaderstats = p:FindFirstChild("leaderstats")
    if leaderstats then watchKills(leaderstats) end
end

local function SetupCharacterSignals(assets, char, hum)
    for _, conn in ipairs(assets.CharacterConnections) do conn:Disconnect() end
    table_clear(assets.CharacterConnections)

    if not hum then return end

    local function updateBarsInline()
        if not assets.HealthFill then return end
        local hpPerc = m_clamp(hum.Health / hum.MaxHealth, 0, 1)
        
        if hpPerc <= 0.02 then
            assets.HealthBack.Visible = false
        else
            assets.HealthBack.Visible = true
            assets.HealthFill.Size = ud2_new(1, 0, hpPerc, 0)
            if hpPerc >= 0.99 then
                assets.HealthFill.BackgroundColor3 = COLOR_GOLD
                for i = 1, 9 do assets.HealthLines[i].Visible = false end
            else
                assets.HealthFill.BackgroundColor3 = COLOR_BRIGHT_GREEN:Lerp(COLOR_RED, 1 - hpPerc)
                for i = 1, 9 do assets.HealthLines[i].Visible = true end
            end
        end
    end
    
    table_insert(assets.CharacterConnections, hum:GetPropertyChangedSignal("Health"):Connect(updateBarsInline))
    table_insert(assets.CharacterConnections, hum:GetPropertyChangedSignal("MaxHealth"):Connect(updateBarsInline))
    updateBarsInline()
end

function ESP.Init(State)
    local conn = RunService.RenderStepped:Connect(function()
        if not State.Toggles.Esp then 
            ScreenGui.Enabled = false 
            for _, assets in pairs(Cache) do
                if assets.Line then assets.Line.Visible = false end
                if assets.Bill then assets.Bill.Enabled = false end
                if assets.BodyBill then assets.BodyBill.Enabled = false end
            end
            return 
        end
        ScreenGui.Enabled = true

        local cam = workspace.CurrentCamera
        local viewportSize = cam.ViewportSize
        if not lp then return end
        local char_lp = lp.Character
        local myRoot = char_lp and char_lp:FindFirstChild("HumanoidRootPart")
        
        FrameTick = FrameTick + 1
        local shouldUpdateHeavy = (FrameTick % 2 == 0)
        local isThrottledFrame = (FrameTick % 3 == 0)
        local gameClock = o_clock()

        -- Optimize performance footprint: single calculation per engine cycle
        local globalRainbowColor = Color3.fromHSV((gameClock * 0.4) % 1, 1, 1)
        local globalRainbowHex = s_format("%02x%02x%02x", m_floor(globalRainbowColor.R * 255), m_floor(globalRainbowColor.G * 255), m_floor(globalRainbowColor.B * 255))

        for p, assets in pairs(Cache) do
            if not p or not p.Parent then CleanupCacheEntry(p, assets) end
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p == lp then continue end
            local char = p.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if root and hum then
                local c = Cache[p]
                if not c then 
                    c = CreateAssets(p)
                    Cache[p] = c 
                    c.LastPosition = root.Position
                    c.LastMoveTime = gameClock
                    SetupPlayerSignals(p, c)
                    SetupCharacterSignals(c, char, hum)
                end
                
                local p2, vis2 = cam:WorldToViewportPoint(root.Position)

                if vis2 and p2.Z > 0 then
                    c.Line.Visible = true
                    c.Bill.Enabled = true
                    c.BodyBill.Enabled = true
                    c.Text.Visible = true
                    
                    c.Bill.Adornee = root
                    c.BodyBill.Adornee = root

                    local sX, sY
                    if myRoot then
                        local p1, _ = cam:WorldToViewportPoint(myRoot.Position)
                        sX, sY = p1.X, p1.Y
                    else
                        sX, sY = viewportSize.X * 0.5, viewportSize.Y * 0.5
                    end

                    -- Inline Real-Time Position Vector Delta Validation (AFK Tracking)
                    local currentPos = root.Position
                    if (currentPos - c.LastPosition).Magnitude > 0.1 then
                        c.LastPosition = currentPos
                        c.LastMoveTime = gameClock
                        c.IsAFK = false
                    elseif (gameClock - c.LastMoveTime) >= 300 then
                        c.IsAFK = true
                    end

                    -- Frame-by-Frame Health Monitoring Loop
                    local liveHpPerc = m_clamp(hum.Health / hum.MaxHealth, 0, 1)
                    if liveHpPerc <= 0.02 then
                        c.HealthBack.Visible = false
                    else
                        c.HealthBack.Visible = true
                        c.HealthFill.Size = ud2_new(1, 0, liveHpPerc, 0)
                        if liveHpPerc >= 0.99 then
                            c.HealthFill.BackgroundColor3 = COLOR_GOLD
                            for i = 1, 9 do c.HealthLines[i].Visible = false end
                        else
                            c.HealthFill.BackgroundColor3 = COLOR_BRIGHT_GREEN:Lerp(COLOR_RED, 1 - liveHpPerc)
                            for i = 1, 9 do c.HealthLines[i].Visible = true end
                        end
                    end

                    -- Frame-by-Frame Evade Monitoring Loop
                    local rawEvade = char:GetAttribute("Evade")
                    local evadeValue = type(rawEvade) == "number" and rawEvade or 0
                    local evadePerc = m_clamp(evadeValue / 50, 0, 1)
                    if evadePerc <= 0.02 then
                        c.EvadeBack.Visible = false
                    else
                        c.EvadeBack.Visible = true
                        c.EvadeFill.Size = ud2_new(1, 0, evadePerc, 0)
                        if evadePerc >= 0.99 then
                            c.EvadeFill.BackgroundColor3 = COLOR_PURPLE
                            for i = 1, 9 do c.EvadeLines[i].Visible = false end
                        else
                            c.EvadeFill.BackgroundColor3 = COLOR_CYAN:Lerp(COLOR_DARK_BLUE, 1 - evadePerc)
                            for i = 1, 9 do c.EvadeLines[i].Visible = true end
                        end
                    end

                    -- Ultimate Tracking Updates
                    local rawUlt = p:GetAttribute("Ultimate")
                    local ultValue = type(rawUlt) == "number" and rawUlt or 0
                    c.UltFill.Size = ud2_new(m_clamp(ultValue / 100, 0, 1), 0, 1, 0)

                    -- Throttled UI Rendering Layer Property Application
                    if isThrottledFrame then
                        if ultValue >= 100 then
                            c.UltStroke.Thickness = 1.5
                            c.UltStroke.Color = globalRainbowColor
                            for i = 1, 9 do c.UltLines[i].Visible = false end
                        else
                            c.UltStroke.Thickness = 1
                            c.UltStroke.Color = COLOR_BLACK
                            for i = 1, 9 do c.UltLines[i].Visible = true end
                        end
                    end

                    if shouldUpdateHeavy then
                        local currentRootPos = myRoot and myRoot.Position or cam.CFrame.Position
                        local dist = (currentRootPos - root.Position).Magnitude
                        c.LastDist = dist
                        
                        local isDead = char:GetAttribute("Dead")
                        local inUlt = char:GetAttribute("InUlt")
                        
                        -- Moveset Architecture Evaluator
                        local movesetName = "Custom"
                        local cm = char:GetAttribute("Moveset")
                        local pm = p:GetAttribute("Moveset")
                        local movesetFolder = char:FindFirstChild("Moveset")
                        local fullyCustom = isCustom(movesetFolder)
                        local usesCustomLook = false
                        
                        if cm == "Custom" or fullyCustom then
                            usesCustomLook = true
                            if fullyCustom then
                                local ultAttr = char:GetAttribute("CustomUlt")
                                local customChild = movesetFolder:FindFirstChild("Custom")
                                local tagAttr = customChild and customChild:GetAttribute("Tag")
                                
                                if type(ultAttr) == "string" and ultAttr:find("%a") then
                                    movesetName = ultAttr
                                elseif tagAttr then
                                    movesetName = tagAttr
                                else
                                    movesetName = "Custom"
                                end
                            else
                                movesetName = pm or "Custom"
                            end
                        else
                            movesetName = cm or pm or ""
                        end
                        
                        if cm == pm and not (movesetFolder and movesetFolder:FindFirstChild("Custom")) then
                            movesetName = pm or ""
                        end

                        -- Custom Lookalike Safeguard Framework (Dynamic Multi-Color Swapping)
                        local hexColor = MOVESET_COLORS[movesetName] or "FFFFFF"
                        if usesCustomLook then
                            hexColor = globalRainbowHex
                        end
                        c.UltFill.BackgroundColor3 = c3_fromHex("#" .. hexColor)
                        
                        if hexColor == "000000" and not usesCustomLook then
                            c.UltBack.BackgroundColor3 = c3_new(0.18, 0.18, 0.18)
                            if ultValue < 100 then c.UltStroke.Color = COLOR_WHITE end
                        else
                            c.UltBack.BackgroundColor3 = c3_new(0.05, 0.05, 0.05)
                        end

                        -- Cash Interface Processing
                        local rawCash = p:GetAttribute("Cash")
                        local cashValue = type(rawCash) == "number" and rawCash or 0
                        c.CashDisplay = (cashValue > 0) and s_format("<font color='#00FF00'>$%s</font> | ", formatVal(cashValue)) or ""

                        -- Player-Based Badges Compilation
                        local permBadges = ""
                        if p:GetAttribute("PS_Owner") == true then
                            permBadges = permBadges .. "<font color='#FFDF00'>[👑 Owner]</font> "
                        elseif p:GetAttribute("PS_Perms") == true then
                            permBadges = permBadges .. "<font color='#FFAA00'>[⚙️ Admin]</font> "
                        end
                        if p:GetAttribute("Workshop") == true then
                            permBadges = permBadges .. "<font color='#AE00FF'>[🛠️ Workshop]</font> "
                        end

                        local rawJackpot = char:GetAttribute("JackpotInRow")
                        local jackpotCount = type(rawJackpot) == "number" and rawJackpot or 0
                        local jackpotTag = (jackpotCount > 0) and s_format("<font color='#00FF00'>[%sx JP]</font> ", jackpotCount) or ""
                        
                        local leftTag = inUlt and "<font color='#FF007F'>[ULT]</font> " or ""
                        local afkTag = c.IsAFK and "<font color='#A0A0A0'>[AFK]</font> " or ""
                        
                        if isDead then
                            c.NameDisplay = s_format("%s%s%s%s%s<font color='#FF0000'>[DEAD] %s</font>", afkTag, leftTag, jackpotTag, c.GroupRoleTag, permBadges, p.Name)
                        else
                            c.NameDisplay = s_format("%s%s%s%s%s%s", afkTag, leftTag, jackpotTag, c.GroupRoleTag, permBadges, (dist < 50) and p.Name or "<b>" .. p.Name .. "</b>")
                        end
                        
                        local distCol = getGradientColor(dist / 800)
                        c.HexDistColor = s_format("%02x%02x%02x", m_floor(distCol.R * 255), m_floor(distCol.G * 255), m_floor(distCol.B * 255))
                        c.LineColor = getGradientColor(dist / 600)
                        
                        if movesetName and movesetName ~= "" then
                            if DARK_MOVESETS[movesetName] and not usesCustomLook then
                                c.CachedMoveset = s_format("<stroke color='#FFFFFF' thickness='1'><font color='#%s'>%s</font></stroke> | ", hexColor, tostring(movesetName))
                            else
                                c.CachedMoveset = s_format("<font color='#%s'>%s</font> | ", hexColor, tostring(movesetName))
                            end
                        else
                            c.CachedMoveset = ""
                        end
                    end
                    
                    local currentDist = c.LastDist

                    -- Tracer Vectors
                    local eX, eY = p2.X, p2.Y
                    local diffX, diffY = eX - sX, eY - sY
                    local mag = (diffX * diffX + diffY * diffY) ^ 0.5
                    
                    c.Line.BackgroundColor3 = c.LineColor
                    c.Line.Size = ud2_new(0, mag, 0, 1)
                    c.Line.Position = ud2_new(0, (sX + eX) * 0.5, 0, (sY + eY) * 0.5)
                    c.Line.Rotation = m_deg(m_atan2(diffY, diffX))

                    -- Explicit High-Visibility Flag Configuration
                    local killString = formatVal(c.CachedKills)
                    if c.IsHidingKills then
                        killString = s_format("%s <font color='#FF3333'><b>[HIDDEN]</b></font>", killString)
                    end

                    c.Text.Text = s_format("%s\n%s%s<font color='#%s'>%s</font> • <font color='#%s'>%sm</font>", 
                        c.NameDisplay, 
                        c.CachedMoveset,
                        c.CashDisplay,
                        c.HexKillColor, 
                        killString, 
                        c.HexDistColor, 
                        tostring(m_floor(currentDist))
                    )
                else
                    c.Line.Visible = false
                    c.Bill.Enabled = false
                    c.BodyBill.Enabled = false
                    c.Text.Visible = false
                end
            elseif Cache[p] then
                Cache[p].Line.Visible = false
                Cache[p].Bill.Enabled = false
                Cache[p].BodyBill.Enabled = false
            end
        end
    end)
    table_insert(State.Connections, conn)
end

return ESP
