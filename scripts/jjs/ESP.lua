local ESP = {}

-- Localize Services & Core API
local cloneref = cloneref or function(o) return o end
local game = game
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local workspace = cloneref(game:GetService("Workspace"))

-- Localize Global Engine Functions
local task = task
local t_wait = task.wait
local type = type
local typeof = typeof
local tostring = tostring
local tonumber = tonumber
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
local m_abs = math.abs
local m_max = math.max
local string = string
local s_format = string.format
local os = os
local o_clock = os.clock

-- Localize Roblox Datatypes
local Vector2 = Vector2
local v2_new = Vector2.new
local Vector3 = Vector3
local v3_new = Vector3.new
local Color3 = Color3
local c3_fromHex = Color3.fromHex
local c3_new = Color3.new

local lp = Players.LocalPlayer
if not lp then
    task.spawn(function()
        lp = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    end)
end
local TARGET_GROUP = 16357742

local Cache = {}
local ActiveMarks = {}
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
local COLOR_LIGHT_BLUE = Color3.fromRGB(50, 180, 255)
local COLOR_SEAL_RED = c3_new(1, 0.2, 0.2)
local COLOR_SEAL_GREEN = c3_new(0.2, 1, 0.2)

local ultNamesModule = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UltNames"))

-- Dynamically generate MOVESET_COLORS and DARK_MOVESETS by looping over ultNamesModule
local MOVESET_COLORS = {
    ["Custom"] = "00FF80"
}
local DARK_MOVESETS = {}

for movesetName, dataTable in pairs(ultNamesModule) do
    local colorObj = dataTable[2]
    if typeof(colorObj) == "Color3" then
        MOVESET_COLORS[movesetName] = s_format("%02X%02X%02X", m_floor(colorObj.R * 255), m_floor(colorObj.G * 255), m_floor(colorObj.B * 255))
        
        -- Flag dark colors for stroke readability (perceived luminance check)
        local luminance = (0.299 * colorObj.R) + (0.587 * colorObj.G) + (0.114 * colorObj.B)
        if luminance < 0.2 then
            DARK_MOVESETS[movesetName] = true
        end
    end
end

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

-- Helper constructor for Drawing API primitives
local function createDrawing(class, properties)
    local obj = Drawing.new(class)
    if properties then
        for k, v in pairs(properties) do
            obj[k] = v
        end
    end
    return obj
end

-- Safe cleanup helper for Drawing objects
local function safeRemove(drawingObj)
    if drawingObj then
        pcall(function()
            drawingObj:Remove()
        end)
    end
end

-- Generates Drawing lines for interval ticks
local function applyBrawlhallaTicks(count)
    count = count or 9
    local lineCache = {}
    for idx = 1, count do
        lineCache[idx] = createDrawing("Line", {
            Color = COLOR_BLACK,
            Thickness = 1,
            Transparency = 0.5,
            Visible = false
        })
    end
    return lineCache
end

-- Helper to bundle bar components (Background, Outline, Fill, and Ticks)
local function createBarGroupWithTicks(tickCount)
    return {
        Back = createDrawing("Square", { Filled = true, Color = c3_new(0.05, 0.05, 0.05), Transparency = 0.5, Visible = false }),
        Outline = createDrawing("Square", { Filled = false, Color = COLOR_BLACK, Thickness = 1, Visible = false }),
        Fill = createDrawing("Square", { Filled = true, Transparency = 0.8, Visible = false }),
        Lines = applyBrawlhallaTicks(tickCount)
    }
end

local function createBarGroup()
    return createBarGroupWithTicks(9)
end

local function setBarGroupVisible(bar, visible)
    bar.Back.Visible = visible
    bar.Outline.Visible = visible
    bar.Fill.Visible = visible
    for i = 1, #bar.Lines do
        bar.Lines[i].Visible = visible
    end
end

local function removeBarGroup(bar)
    safeRemove(bar.Back)
    safeRemove(bar.Outline)
    safeRemove(bar.Fill)
    for i = 1, #bar.Lines do
        safeRemove(bar.Lines[i])
    end
end

-- ============================================================================
-- DRAWING.NEW RICHTEXT PARSER & LAYOUT ENGINE
-- ============================================================================

local function parseRichTextLine(lineStr, defaultColor)
    local segments = {}
    local colorStack = { defaultColor }
    local pos = 1
    local len = #lineStr

    while pos <= len do
        local tagStart, tagEnd, tagName, tagAttr = lineStr:find("<(%/?%a+)%s*([^>]*)>", pos)
        if not tagStart then
            local text = lineStr:sub(pos)
            if #text > 0 then
                table_insert(segments, {
                    Text = text,
                    Color = colorStack[#colorStack] or defaultColor
                })
            end
            break
        end

        if tagStart > pos then
            local text = lineStr:sub(pos, tagStart - 1)
            if #text > 0 then
                table_insert(segments, {
                    Text = text,
                    Color = colorStack[#colorStack] or defaultColor
                })
            end
        end

        local isClosing = tagName:sub(1, 1) == "/"
        local cleanTagName = isClosing and tagName:sub(2):lower() or tagName:lower()

        if cleanTagName == "font" then
            if isClosing then
                if #colorStack > 1 then
                    table.remove(colorStack)
                end
            else
                local hex = tagAttr:match("color%s*=%s*['\"]#?([%x%X]+)['\"]") or tagAttr:match("color%s*=%s*#?([%x%X]+)")
                if hex then
                    local success, col = pcall(c3_fromHex, "#" .. hex)
                    if success and col then
                        table_insert(colorStack, col)
                    else
                        table_insert(colorStack, colorStack[#colorStack])
                    end
                else
                    table_insert(colorStack, colorStack[#colorStack])
                end
            end
        end

        pos = tagEnd + 1
    end

    return segments
end

local function renderRichText(pool, rawText, centerX, topY, fontSize, defaultColor)
    local lines = {}
    for line in rawText:gmatch("[^\r\n]+") do
        table_insert(lines, line)
    end

    if #lines == 0 then
        for _, obj in ipairs(pool) do
            obj.Visible = false
        end
        return
    end

    local poolIdx = 0
    local currentY = m_floor(topY)
    local lineHeight = fontSize + 2

    for _, lineStr in ipairs(lines) do
        local segments = parseRichTextLine(lineStr, defaultColor)
        local totalLineWidth = 0
        local segWidths = {}

        for i, seg in ipairs(segments) do
            poolIdx = poolIdx + 1
            local textObj = pool[poolIdx]
            if not textObj then
                textObj = Drawing.new("Text")
                textObj.Center = false
                pool[poolIdx] = textObj
            end

            textObj.Size = fontSize
            textObj.Outline = true
            textObj.OutlineColor = COLOR_BLACK
            textObj.Text = seg.Text
            local w = textObj.TextBounds.X
            segWidths[i] = w
            totalLineWidth = totalLineWidth + w
        end

        local currentX = m_floor(centerX - (totalLineWidth / 2))
        local lineStartIdx = poolIdx - #segments + 1

        for i, seg in ipairs(segments) do
            local textObj = pool[lineStartIdx + i - 1]
            textObj.Position = v2_new(m_floor(currentX), currentY)
            textObj.Color = seg.Color
            textObj.Visible = true
            currentX = currentX + segWidths[i]
        end

        currentY = currentY + lineHeight
    end

    for i = poolIdx + 1, #pool do
        pool[i].Visible = false
    end
end

-- ============================================================================
-- ASSET CREATION & LIFECYCLE
-- ============================================================================

local function CreateAssets(p)
    local assets = {}

    -- Tracer Line
    assets.Line = createDrawing("Line", {
        Thickness = 1,
        Color = COLOR_GREEN,
        Transparency = 1,
        Visible = false
    })

    -- RichText Segment Pool
    assets.TextPool = {}

    -- Bars
    assets.UltBar = createBarGroup()
    assets.HealthBar = createBarGroup()
    assets.EvadeBar = createBarGroup()
    assets.OverheatBar = createBarGroup()
    assets.MiraclesBar = createBarGroupWithTicks(6)

    -- Moveset slots (5 slots: 4 regular + 1 extra for Reggie's NextReceipt)
    -- Slot 5 will be rendered separately to the right
    assets.MovesetItems = {}
    for i = 1, 5 do
        assets.MovesetItems[i] = {
            Back = createDrawing("Square", { Filled = true, Color = c3_new(0.1, 0.1, 0.1), Transparency = 0.6, Visible = false }),
            Fill = createDrawing("Square", { Filled = true, Color = COLOR_LIGHT_BLUE, Transparency = 0.5, Visible = false }),
            Outline = createDrawing("Square", { Filled = false, Color = COLOR_BLACK, Thickness = 1, Visible = false }),
            Label = createDrawing("Text", { Size = 10, Center = true, Outline = true, OutlineColor = COLOR_BLACK, Color = COLOR_WHITE, Visible = false }),
            SealCircle = createDrawing("Circle", { Filled = true, Radius = 4, Color = COLOR_SEAL_RED, Visible = false }),
            Data = { Visible = false, Key = tostring(i), Name = "", Tip = "", CooldownRatio = 0 },
            MoveRef = nil
        }
    end

    -- Connections
    assets.Connections = {}
    assets.CharacterConnections = {} 
    assets.KillValueConnections = {} 
    
    -- AFK
    assets.LastPosition = v3_new(0, 0, 0)
    assets.LastMoveTime = o_clock()
    assets.IsAFK = false
    
    -- Cached display strings
    assets.LastDist = 0
    assets.CachedKills = 0
    assets.CachedMoveset = ""
    assets.NameDisplay = ""
    assets.CashDisplay = ""
    assets.GroupRoleTag = ""
    assets.IsFriend = false
    assets.IsMutual = false
    assets.LineColor = COLOR_GREEN
    assets.HexKillColor = "ffffff"
    assets.HexDistColor = "ffffff"
    assets.IsHidingKills = false

    -- Extra info
    assets.AgeDisplay = ""
    assets.FriendDisplay = ""
    assets.GamepassDisplay = ""
    assets.MiracleDisplay = ""
    assets.ExtraInfo = ""
    
    return assets
end

local function HideAllAssets(assets)
    if assets.Line then assets.Line.Visible = false end
    if assets.TextPool then
        for _, textObj in ipairs(assets.TextPool) do
            textObj.Visible = false
        end
    end
    if assets.UltBar then setBarGroupVisible(assets.UltBar, false) end
    if assets.HealthBar then setBarGroupVisible(assets.HealthBar, false) end
    if assets.EvadeBar then setBarGroupVisible(assets.EvadeBar, false) end
    if assets.OverheatBar then setBarGroupVisible(assets.OverheatBar, false) end
    if assets.MiraclesBar then setBarGroupVisible(assets.MiraclesBar, false) end
    
    if assets.MovesetItems then
        for i = 1, 5 do
            local item = assets.MovesetItems[i]
            item.Back.Visible = false
            item.Fill.Visible = false
            item.Outline.Visible = false
            item.Label.Visible = false
            item.SealCircle.Visible = false
        end
    end
end

local function CleanupCacheEntry(p, assets)
    for _, conn in ipairs(assets.Connections) do conn:Disconnect() end
    for _, conn in ipairs(assets.CharacterConnections) do conn:Disconnect() end
    for _, conn in ipairs(assets.KillValueConnections) do conn:Disconnect() end
    
    safeRemove(assets.Line)
    
    if assets.TextPool then
        for _, textObj in ipairs(assets.TextPool) do
            safeRemove(textObj)
        end
    end
    
    if assets.UltBar then removeBarGroup(assets.UltBar) end
    if assets.HealthBar then removeBarGroup(assets.HealthBar) end
    if assets.EvadeBar then removeBarGroup(assets.EvadeBar) end
    if assets.OverheatBar then removeBarGroup(assets.OverheatBar) end
    if assets.MiraclesBar then removeBarGroup(assets.MiraclesBar) end

    if assets.MovesetItems then
        for i = 1, 5 do
            local item = assets.MovesetItems[i]
            safeRemove(item.Back)
            safeRemove(item.Fill)
            safeRemove(item.Outline)
            safeRemove(item.Label)
            safeRemove(item.SealCircle)
        end
    end
    
    Cache[p] = nil
end


local function CleanupAllESP()
    for p, assets in pairs(Cache) do
        CleanupCacheEntry(p, assets)
    end

    table_clear(ActiveMarks)
end

-- ============================================================================
-- PLAYER INFO UPDATER (Account Age, Friends, Gamepasses)
-- ============================================================================

local function UpdatePlayerInfo(p, assets)
    -- Account age (colored, no prefix)
    local age = p.AccountAge or 0
    local ageStr
    if age >= 1 then
        ageStr = s_format("%dd", m_floor(age))
    elseif age * 24 >= 1 then
        ageStr = s_format("%dh", m_floor(age * 24))
    else
        ageStr = s_format("%dm", m_floor(age * 24 * 60))
    end
    assets.AgeDisplay = s_format("<font color='#FFA500'>%s</font>", ageStr)

    -- Friend count (async) - show as number + "F"
    task.spawn(function()
        local success, friends = pcall(function()
            return p:GetFriendsAsync()
        end)
        if success and friends then
            local count = #friends
            if count > 0 then
                assets.FriendDisplay = s_format("<font color='#00BFFF'>%dF</font>", count)
            else
                assets.FriendDisplay = ""
            end
        else
            assets.FriendDisplay = ""
        end
    end)

    -- Gamepasses count (count of attributes in Gamepasses folder)
    task.spawn(function()
        local gamepassFolder = p:FindFirstChild("Gamepasses")
        if gamepassFolder then
            local attrs = gamepassFolder:GetAttributes()
            local count = 0
            for _ in pairs(attrs) do count = count + 1 end
            if count > 0 then
                assets.GamepassDisplay = s_format("<font color='#00FF00'>%dG</font>", count)
            else
                assets.GamepassDisplay = ""
            end
        else
            assets.GamepassDisplay = ""
        end
    end)
end

local function StartPeriodicInfoUpdates(p, assets)
    -- Initial update
    UpdatePlayerInfo(p, assets)
    -- Loop every 60 seconds
    task.spawn(function()
        while p and p.Parent do
            t_wait(60)
            UpdatePlayerInfo(p, assets)
        end
    end)
end

-- ============================================================================
-- PLAYER & CHARACTER SIGNALS
-- ============================================================================

local function SetupPlayerSignals(p, assets)
    task.spawn(function()
        local directSuccess, directRes = pcall(function() return lp:IsFriendsWith(p.UserId) end)
        if directSuccess and directRes then
            assets.IsFriend = true
            return
        end

        for _, other in ipairs(Players:GetPlayers()) do
            if other ~= lp and other ~= p then
                local s1, r1 = pcall(function() return lp:IsFriendsWith(other.UserId) end)
                local s2, r2 = pcall(function() return p:IsFriendsWith(other.UserId) end)
                if s1 and r1 and s2 and r2 then
                    assets.IsMutual = true
                    break
                end
            end
        end
    end)

    task.spawn(function()
        local success, rank = pcall(p.GetRankInGroup, p, TARGET_GROUP)
        if success and type(rank) == "number" and rank > 0 then
            local successRole, role = pcall(p.GetRoleInGroup, p, TARGET_GROUP)
            if successRole then
                role = tostring(role)
                assets.GroupRoleTag = s_format("<font color='#00AAFF'>[%s]</font> ", role)
                return
            end
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
            assets.IsHidingKills = not not isHidden

            task.spawn(function()
                if isHidden then
                    local hiddenFolder = leaderstats:FindFirstChild("Hidden")
                    while not hiddenFolder and p.Parent and leaderstats:GetAttribute("HiddenKills") == true do
                        t_wait()
                        hiddenFolder = leaderstats:FindFirstChild("Hidden")
                    end
                    if not hiddenFolder then return end
                    
                    local killsVal = hiddenFolder:FindFirstChild("Kills")
                    while not killsVal and p.Parent and leaderstats:GetAttribute("HiddenKills") == true do
                        t_wait()
                        killsVal = hiddenFolder:FindFirstChild("Kills")
                    end
                    if killsVal then trackValueInstance(killsVal) end
                else
                    local killsVal = leaderstats:FindFirstChild("Kills")
                    while not killsVal and p.Parent and not leaderstats:GetAttribute("HiddenKills") do
                        t_wait()
                        killsVal = leaderstats:FindFirstChild("Kills")
                    end
                    if killsVal then trackValueInstance(killsVal) end
                end
            end)
        end

        table_insert(assets.Connections, leaderstats:GetAttributeChangedSignal("HiddenKills"):Connect(evaluateSource))
        evaluateSource()
    end

    local function checkLeaderstats()
        local leaderstats = p:FindFirstChild("leaderstats")
        if leaderstats then
            watchKills(leaderstats)
        else
            task.spawn(function()
                local leaderstatsWait = p:FindFirstChild("leaderstats")
                while not leaderstatsWait and p.Parent do
                    t_wait()
                    leaderstatsWait = p:FindFirstChild("leaderstats")
                end
                if leaderstatsWait then watchKills(leaderstatsWait) end
            end)
        end
    end
    checkLeaderstats()

    -- Start periodic updates for account age, friends, and gamepasses
    StartPeriodicInfoUpdates(p, assets)
end

local function SetupCharacterSignals(assets, char, hum)
    for _, conn in ipairs(assets.CharacterConnections) do conn:Disconnect() end
    table_clear(assets.CharacterConnections)

    if not hum then return end

    local function updateBarsInline()
        if assets.LastDist < 10 then return end
        local hpPerc = m_clamp(hum.Health / hum.MaxHealth, 0, 1)
        
        if hpPerc <= 0.02 then
            setBarGroupVisible(assets.HealthBar, false)
        else
            if hpPerc >= 0.99 then
                assets.HealthBar.Fill.Color = COLOR_GOLD
                for i = 1, 9 do assets.HealthBar.Lines[i].Visible = false end
            else
                assets.HealthBar.Fill.Color = COLOR_BRIGHT_GREEN:Lerp(COLOR_RED, 1 - hpPerc)
            end
        end
    end
    
    table_insert(assets.CharacterConnections, hum:GetPropertyChangedSignal("Health"):Connect(updateBarsInline))
    table_insert(assets.CharacterConnections, hum:GetPropertyChangedSignal("MaxHealth"):Connect(updateBarsInline))
    updateBarsInline()
end

-- ============================================================================
-- ESP INIT
-- ============================================================================

function ESP.Init(State)
    local toggleObject = State.Toggles.ESP

    local function handleToggleChange()
        if not toggleObject.Value then 
            for _, assets in pairs(Cache) do
                HideAllAssets(assets)
            end
            return 
        end
    end

    -- Hook Charles Mark Replication Remote Stream
    local KnitFolder = ReplicatedStorage:FindFirstChild("Knit")
    local EffectsEvent = KnitFolder and KnitFolder:FindFirstChild("Knit") 
        and KnitFolder.Knit:FindFirstChild("Services")
        and KnitFolder.Knit.Services:FindFirstChild("CharlesService")
        and KnitFolder.Knit.Services.CharlesService:FindFirstChild("RE")
        and KnitFolder.Knit.Services.CharlesService.RE:FindFirstChild("Effects")

    if EffectsEvent then
        local markConn = EffectsEvent.OnClientEvent:Connect(function(action, charInstance, pos, markValueObject)
            if action == "Mark" and typeof(charInstance) == "Instance" and typeof(markValueObject) == "Instance" then
                ActiveMarks[charInstance] = markValueObject
            end
        end)
        table_insert(State.Connections, markConn)
    end

    local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
        if player == lp then
            CleanupAllESP()
        end
    end)

    table_insert(State.Connections, playerRemovingConn)

    local conn = RunService.RenderStepped:Connect(function()
        if not toggleObject.Value then return end

        local cam = workspace.CurrentCamera
        if not cam or not lp then return end
        local viewportSize = cam.ViewportSize
        local char_lp = lp.Character
        -- Use PrimaryPart if available, fallback to HumanoidRootPart
        local myRoot = char_lp and (char_lp.PrimaryPart or char_lp:FindFirstChild("HumanoidRootPart"))
        
        FrameTick = FrameTick + 1
        local shouldUpdateHeavy = (FrameTick % 2 == 0)
        local isThrottledFrame = (FrameTick % 3 == 0)
        local gameClock = o_clock()

        local globalRainbowColor = Color3.fromHSV((gameClock * 0.4) % 1, 1, 1)
        local globalRainbowHex = s_format("%02x%02x%02x", m_floor(globalRainbowColor.R * 255), m_floor(globalRainbowColor.G * 255), m_floor(globalRainbowColor.B * 255))

        for p, assets in pairs(Cache) do
            if not p or not p.Parent then CleanupCacheEntry(p, assets) end
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p == lp then continue end
            local char = p.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local root = char and (char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"))

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
                
                -- Project root, head, and feet
                local root2D, visRoot = cam:WorldToViewportPoint(root.Position)
                local head2D, visHead = cam:WorldToViewportPoint(root.Position + v3_new(0, 3.2, 0))
                local feet2D, visFeet = cam:WorldToViewportPoint(root.Position - v3_new(0, 3.6, 0))

                if visRoot and root2D.Z > 0 then
                    local currentRootPos = myRoot and myRoot.Position or cam.CFrame.Position
                    local dist = (currentRootPos - root.Position).Magnitude
                    c.LastDist = dist

                    local scaleFactor = m_clamp(50 / m_max(dist, 10), 0.55, 1.35)

                    local baseBoxHeight = m_abs(feet2D.Y - head2D.Y)
                    local boxHeight = m_floor(m_clamp(baseBoxHeight * scaleFactor, 18, 500))
                    local boxWidth = m_floor(m_clamp(boxHeight * 0.55, 18, 260))
                    local boxX = m_floor(root2D.X - (boxWidth / 2))
                    local boxY = m_floor(head2D.Y)

                    local sX, sY
                    if myRoot then
                        local p1, visP1 = cam:WorldToViewportPoint(myRoot.Position)
                        sX, sY = m_floor(p1.X), m_floor(p1.Y)
                    else
                        sX, sY = m_floor(viewportSize.X * 0.5), m_floor(viewportSize.Y)
                    end

                    local currentPos = root.Position
                    if (currentPos - c.LastPosition).Magnitude > 0.1 then
                        c.LastPosition = currentPos
                        c.LastMoveTime = gameClock
                        c.IsAFK = false
                    elseif (gameClock - c.LastMoveTime) >= 300 then
                        c.IsAFK = true
                    end
                    
                    local hideNameAndHealth = (dist < 10)

                    -- Compute moveset name once per frame
                    local movesetName = ""
                    local movesetFolder = char:FindFirstChild("Moveset")
                    local fullyCustom = isCustom(movesetFolder)
                    local cm = char:GetAttribute("Moveset")
                    local pm = p:GetAttribute("Moveset")
                    if cm == "Custom" or fullyCustom then
                        if fullyCustom then
                            local ultAttr = char:GetAttribute("CustomUlt")
                            local customChild = movesetFolder and movesetFolder:FindFirstChild("Custom")
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

                    local isRyu = (movesetName == "Ryu")
                    local isHaruta = (movesetName == "Haruta")
                    local isReggie = (movesetName == "Reggie")
                    local info = char:FindFirstChild("Info")
                    local overheatObj = info and info:FindFirstChild("Overheat")
                    local miraclesObj = info and info:FindFirstChild("Miracles")
                    local nextReceiptObj = info and info:FindFirstChild("NextReceipt") -- for Reggie

                    -- 1. Health Bar
                    local hWidth = m_floor(m_clamp(4 * scaleFactor, 2, 8))
                    local hGap = m_floor(m_clamp(4 * scaleFactor, 2, 8))
                    local hX = boxX - hWidth - hGap
                    local hY = boxY
                    local hH = boxHeight

                    if hideNameAndHealth or hum.Health / hum.MaxHealth <= 0.02 then
                        setBarGroupVisible(c.HealthBar, false)
                    else
                        local liveHpPerc = m_clamp(hum.Health / hum.MaxHealth, 0, 1)
                        setBarGroupVisible(c.HealthBar, true)

                        c.HealthBar.Back.Position = v2_new(hX, hY)
                        c.HealthBar.Back.Size = v2_new(hWidth, hH)
                        c.HealthBar.Outline.Position = v2_new(hX, hY)
                        c.HealthBar.Outline.Size = v2_new(hWidth, hH)

                        local fillH = m_floor(hH * liveHpPerc)
                        c.HealthBar.Fill.Position = v2_new(hX, hY + (hH - fillH))
                        c.HealthBar.Fill.Size = v2_new(hWidth, fillH)

                        if liveHpPerc >= 0.99 then
                            c.HealthBar.Fill.Color = COLOR_GOLD
                            for i = 1, 9 do c.HealthBar.Lines[i].Visible = false end
                        else
                            c.HealthBar.Fill.Color = COLOR_BRIGHT_GREEN:Lerp(COLOR_RED, 1 - liveHpPerc)
                            for i = 1, 9 do
                                local lineY = m_floor(hY + (hH * 0.1 * i))
                                c.HealthBar.Lines[i].From = v2_new(hX, lineY)
                                c.HealthBar.Lines[i].To = v2_new(hX + hWidth, lineY)
                                c.HealthBar.Lines[i].Visible = true
                            end
                        end
                    end

                    -- 2. Evade Bar
                    local eWidth = m_floor(m_clamp(4 * scaleFactor, 2, 8))
                    local eGap = m_floor(m_clamp(4 * scaleFactor, 2, 8))
                    local eX = boxX + boxWidth + eGap
                    local eY = boxY
                    local eH = boxHeight

                    local rawEvade = char:GetAttribute("Evade")
                    local evadeValue = type(rawEvade) == "number" and rawEvade or 0
                    local evadePerc = m_clamp(evadeValue / 50, 0, 1)

                    if evadePerc <= 0.02 then
                        setBarGroupVisible(c.EvadeBar, false)
                    else
                        setBarGroupVisible(c.EvadeBar, true)

                        c.EvadeBar.Back.Position = v2_new(eX, eY)
                        c.EvadeBar.Back.Size = v2_new(eWidth, eH)
                        c.EvadeBar.Outline.Position = v2_new(eX, eY)
                        c.EvadeBar.Outline.Size = v2_new(eWidth, eH)

                        local eFillH = m_floor(eH * evadePerc)
                        c.EvadeBar.Fill.Position = v2_new(eX, eY + (eH - eFillH))
                        c.EvadeBar.Fill.Size = v2_new(eWidth, eFillH)

                        if evadePerc >= 0.99 then
                            c.EvadeBar.Fill.Color = COLOR_PURPLE
                            for i = 1, 9 do c.EvadeBar.Lines[i].Visible = false end
                        else
                            c.EvadeBar.Fill.Color = COLOR_CYAN:Lerp(COLOR_DARK_BLUE, 1 - evadePerc)
                            for i = 1, 9 do
                                local lineY = m_floor(eY + (eH * 0.1 * i))
                                c.EvadeBar.Lines[i].From = v2_new(eX, lineY)
                                c.EvadeBar.Lines[i].To = v2_new(eX + eWidth, lineY)
                                c.EvadeBar.Lines[i].Visible = true
                            end
                        end
                    end

                    -- 3. Overheat or Miracles Bar
                    local ohGap = m_floor(m_clamp(3 * scaleFactor, 2, 6))
                    local ohX = eX + eWidth + ohGap

                    if isRyu and overheatObj then
                        local ohVal = overheatObj.Value
                        local ohRatio = m_clamp(ohVal / 50, 0, 1)
                        
                        if ohRatio <= 0.02 then
                            setBarGroupVisible(c.OverheatBar, false)
                        else
                            setBarGroupVisible(c.OverheatBar, true)

                            c.OverheatBar.Back.Position = v2_new(ohX, eY)
                            c.OverheatBar.Back.Size = v2_new(eWidth, eH)
                            c.OverheatBar.Outline.Position = v2_new(ohX, eY)
                            c.OverheatBar.Outline.Size = v2_new(eWidth, eH)

                            local ohFillH = m_floor(eH * ohRatio)
                            c.OverheatBar.Fill.Position = v2_new(ohX, eY + (eH - ohFillH))
                            c.OverheatBar.Fill.Size = v2_new(eWidth, ohFillH)

                            local ohColor
                            if ohVal >= 50 then
                                ohColor = COLOR_YELLOW
                                for i = 1, 9 do c.OverheatBar.Lines[i].Visible = false end
                            else
                                ohColor = c3_new(0, 0.66, 1):Lerp(c3_new(1, 0, 0.5), ohRatio)
                                for i = 1, 9 do
                                    local lineY = m_floor(eY + (eH * 0.1 * i))
                                    c.OverheatBar.Lines[i].From = v2_new(ohX, lineY)
                                    c.OverheatBar.Lines[i].To = v2_new(ohX + eWidth, lineY)
                                    c.OverheatBar.Lines[i].Visible = true
                                end
                            end
                            c.OverheatBar.Fill.Color = ohColor
                        end
                        setBarGroupVisible(c.MiraclesBar, false)

                    elseif isHaruta and miraclesObj then
                        local mirVal = miraclesObj.Value
                        local mirRatio = m_clamp(mirVal / 6, 0, 1)
                        
                        if mirRatio <= 0.02 then
                            setBarGroupVisible(c.MiraclesBar, false)
                        else
                            setBarGroupVisible(c.MiraclesBar, true)

                            local bar = c.MiraclesBar
                            local harutaColor = c3_fromHex("#" .. (MOVESET_COLORS["Haruta"] or "A77DCB"))

                            bar.Back.Position = v2_new(ohX, eY)
                            bar.Back.Size = v2_new(eWidth, eH)
                            bar.Outline.Position = v2_new(ohX, eY)
                            bar.Outline.Size = v2_new(eWidth, eH)

                            local mirFillH = m_floor(eH * mirRatio)
                            bar.Fill.Position = v2_new(ohX, eY + (eH - mirFillH))
                            bar.Fill.Size = v2_new(eWidth, mirFillH)
                            bar.Fill.Color = harutaColor

                            for i = 1, 6 do
                                local lineY = m_floor(eY + (eH * (i / 6)))
                                bar.Lines[i].From = v2_new(ohX, lineY)
                                bar.Lines[i].To = v2_new(ohX + eWidth, lineY)
                                bar.Lines[i].Visible = true
                            end
                        end
                        setBarGroupVisible(c.OverheatBar, false)

                    else
                        setBarGroupVisible(c.OverheatBar, false)
                        setBarGroupVisible(c.MiraclesBar, false)
                    end

                    -- 4. Ultimate Bar
                    local uHeight = m_floor(m_clamp(4 * scaleFactor, 2, 8))
                    local uGap = m_floor(m_clamp(3 * scaleFactor, 2, 6))
                    local uW = boxWidth
                    local uX = boxX
                    local uY = boxY - uHeight - uGap

                    setBarGroupVisible(c.UltBar, true)
                    c.UltBar.Back.Position = v2_new(uX, uY)
                    c.UltBar.Back.Size = v2_new(uW, uHeight)
                    c.UltBar.Outline.Position = v2_new(uX, uY)
                    c.UltBar.Outline.Size = v2_new(uW, uHeight)

                    local rawUlt = p:GetAttribute("Ultimate")
                    local ultValue = type(rawUlt) == "number" and rawUlt or 0
                    local ultRatio = m_clamp(ultValue / 100, 0, 1)

                    c.UltBar.Fill.Position = v2_new(uX, uY)
                    c.UltBar.Fill.Size = v2_new(m_floor(uW * ultRatio), uHeight)

                    if isThrottledFrame then
                        if ultValue >= 100 then
                            c.UltBar.Outline.Thickness = 1.5
                            c.UltBar.Outline.Color = globalRainbowColor
                            for i = 1, 9 do c.UltBar.Lines[i].Visible = false end
                        else
                            c.UltBar.Outline.Thickness = 1
                            c.UltBar.Outline.Color = COLOR_BLACK
                            for i = 1, 9 do
                                local lineX = m_floor(uX + (uW * 0.1 * i))
                                c.UltBar.Lines[i].From = v2_new(lineX, uY)
                                c.UltBar.Lines[i].To = v2_new(lineX, uY + uHeight)
                                c.UltBar.Lines[i].Visible = true
                            end
                        end
                    end

                    -- 5. Moveset Slots (slots 1-4) + Reggie's extra slot (5) separately
                    local slotHeight = m_floor(m_clamp(22 * scaleFactor, 14, 32))
                    local slotGap = m_floor(m_clamp(3 * scaleFactor, 2, 6))
                    local moveFontSize = m_floor(m_clamp(10 * scaleFactor, 8, 15))
                    local slotY = uY - slotHeight - m_floor(m_clamp(4 * scaleFactor, 2, 8))
                    local hasActiveMoveset = false

                    -- We'll render slots 1-4 normally, and slot 5 (Reggie) to the right
                    if c.MovesetItems then
                        -- Reset visibility for all 5 slots
                        for index = 1, 5 do
                            c.MovesetItems[index].Data.Visible = false
                            c.MovesetItems[index].MoveRef = nil
                        end

                        -- Populate slots 1-4 from moveset folder
                        if movesetFolder then
                            for _, move in ipairs(movesetFolder:GetChildren()) do
                                local slotKey = move:GetAttribute("Key")
                                if type(slotKey) == "number" and slotKey >= 1 and slotKey <= 4 then
                                    local item = c.MovesetItems[slotKey]
                                    if item then
                                        hasActiveMoveset = true
                                        item.Data.Visible = true
                                        item.Data.Key = tostring(slotKey)
                                        item.Data.Name = move.Name
                                        item.MoveRef = move

                                        local lastUsedStamp = move:GetAttribute("LastUse")
                                        local totalCdDuration = tonumber(move.Value)

                                        if type(lastUsedStamp) == "number" and type(totalCdDuration) == "number" and totalCdDuration > 0 then
                                            local serverNow = workspace:GetServerTimeNow()
                                            local remainingCd = (lastUsedStamp + totalCdDuration) - serverNow
                                            item.Data.CooldownRatio = m_clamp(remainingCd / totalCdDuration, 0, 1)
                                        else
                                            item.Data.CooldownRatio = 0
                                        end
                                    end
                                end
                            end
                        end

                        -- Slot 5: for Reggie if NextReceipt exists (rendered separately to the right)
                        if isReggie and nextReceiptObj then
                            local item = c.MovesetItems[5]
                            hasActiveMoveset = true
                            item.Data.Visible = true
                            item.Data.Key = "5"
                            -- Update name on value change
                            local function updateReceipt()
                                item.Data.Name = tostring(nextReceiptObj.Value)
                            end
                            updateReceipt()
                            -- connect to value change
                            if not c._receiptConn then
                                c._receiptConn = nextReceiptObj:GetPropertyChangedSignal("Value"):Connect(updateReceipt)
                                table_insert(c.Connections, c._receiptConn)
                            end
                            item.Data.CooldownRatio = 0  -- no cooldown
                            item.MoveRef = nil
                        end

                        -- Compute total width for slots 1-4 only (for centering)
                        local itemWidths = {}
                        local totalMovesetWidth = 0
                        local activeCount = 0
                        for i = 1, 4 do  -- only slots 1-4
                            local item = c.MovesetItems[i]
                            if item.Data.Visible then
                                activeCount = activeCount + 1
                                -- Make square: width = height
                                item.Label.Text = item.Data.Name
                                item.Label.Size = moveFontSize
                                local textW = item.Label.TextBounds.X
                                -- slot width = max(textW + padding, slotHeight)
                                local slotW = m_floor(m_max(slotHeight, textW + m_clamp(8 * scaleFactor, 4, 12)))
                                itemWidths[i] = slotW
                                totalMovesetWidth = totalMovesetWidth + slotW
                            else
                                itemWidths[i] = 0
                            end
                        end
                        if activeCount > 0 then
                            totalMovesetWidth = totalMovesetWidth + ((activeCount - 1) * slotGap)
                        end

                        -- Render slots 1-4 centered
                        local movesetStartX = m_floor(root2D.X - (totalMovesetWidth / 2))
                        local currentSlotX = movesetStartX
                        for i = 1, 4 do
                            local item = c.MovesetItems[i]
                            if item.Data.Visible then
                                local slotW = itemWidths[i]
                                -- Ensure square: width = height
                                slotW = m_floor(m_max(slotW, slotHeight))
                                item.Back.Visible = true
                                item.Back.Position = v2_new(currentSlotX, slotY)
                                item.Back.Size = v2_new(slotW, slotHeight)

                                item.Outline.Visible = true
                                item.Outline.Position = v2_new(currentSlotX, slotY)
                                item.Outline.Size = v2_new(slotW, slotHeight)

                                local cdRatio = item.Data.CooldownRatio
                                if cdRatio > 0 then
                                    local cdFillH = m_floor(slotHeight * cdRatio)
                                    item.Fill.Visible = true
                                    item.Fill.Color = COLOR_LIGHT_BLUE
                                    item.Fill.Transparency = 0.5
                                    item.Fill.Size = v2_new(slotW, cdFillH)
                                    item.Fill.Position = v2_new(currentSlotX, slotY + (slotHeight - cdFillH))
                                else
                                    item.Fill.Visible = false
                                end

                                item.Label.Visible = true
                                item.Label.Outline = true
                                item.Label.OutlineColor = COLOR_BLACK
                                item.Label.Text = item.Data.Name
                                item.Label.Size = moveFontSize
                                item.Label.Position = v2_new(currentSlotX + m_floor(slotW / 2), slotY + m_floor((slotHeight - item.Label.TextBounds.Y) / 2))

                                -- Seal Circle (lower position)
                                local seal = item.MoveRef and item.MoveRef:GetAttribute("Seal")
                                if seal and (seal == 1 or seal == 2) then
                                    local radius = m_floor(m_clamp(4 * scaleFactor, 3, 8))
                                    local padding = m_floor(m_clamp(2 * scaleFactor, 1, 4))
                                    item.SealCircle.Visible = true
                                    item.SealCircle.Radius = radius
                                    if seal == 1 then
                                        item.SealCircle.Color = COLOR_SEAL_RED
                                    else
                                        item.SealCircle.Color = COLOR_SEAL_GREEN
                                    end
                                    -- Position: top-right corner, lower Y (padding + radius offset)
                                    item.SealCircle.Position = v2_new(currentSlotX + slotW - radius - padding, slotY + padding + radius * 0.5)
                                else
                                    item.SealCircle.Visible = false
                                end

                                currentSlotX = currentSlotX + slotW + slotGap
                            else
                                item.Back.Visible = false
                                item.Fill.Visible = false
                                item.Outline.Visible = false
                                item.Label.Visible = false
                                item.SealCircle.Visible = false
                            end
                        end

                        -- Render Reggie's slot 5 separately to the right of slots 1-4
                        local reggieItem = c.MovesetItems[5]
                        if isReggie and nextReceiptObj and reggieItem.Data.Visible then
                            -- Position it to the right of the last rendered slot
                            local lastSlotEnd = currentSlotX - slotGap  -- since we added gap after last
                            local reggieWidth = m_floor(m_clamp(slotHeight * 1.2, 30, 60))  -- slightly wider
                            local reggieX = lastSlotEnd + slotGap
                            reggieItem.Back.Visible = true
                            reggieItem.Back.Position = v2_new(reggieX, slotY)
                            reggieItem.Back.Size = v2_new(reggieWidth, slotHeight)
                            reggieItem.Outline.Visible = true
                            reggieItem.Outline.Position = v2_new(reggieX, slotY)
                            reggieItem.Outline.Size = v2_new(reggieWidth, slotHeight)
                            reggieItem.Fill.Visible = false  -- no cooldown

                            reggieItem.Label.Visible = true
                            reggieItem.Label.Outline = true
                            reggieItem.Label.OutlineColor = COLOR_BLACK
                            reggieItem.Label.Text = reggieItem.Data.Name
                            reggieItem.Label.Size = moveFontSize
                            reggieItem.Label.Position = v2_new(reggieX + m_floor(reggieWidth / 2), slotY + m_floor((slotHeight - reggieItem.Label.TextBounds.Y) / 2))
                            reggieItem.SealCircle.Visible = false  -- no seal
                            hasActiveMoveset = true  -- ensure it's counted
                        else
                            reggieItem.Back.Visible = false
                            reggieItem.Fill.Visible = false
                            reggieItem.Outline.Visible = false
                            reggieItem.Label.Visible = false
                            reggieItem.SealCircle.Visible = false
                        end
                    end

                    -- 6. Heavy updates (only every 2 frames)
                    if shouldUpdateHeavy then
                        local isDead = char:GetAttribute("Dead")
                        local inUlt = char:GetAttribute("InUlt")

                        local hexColor = MOVESET_COLORS[movesetName] or "FFFFFF"
                        local usesCustomLook = false
                        
                        if movesetName == "Custom" or fullyCustom then
                            usesCustomLook = true
                            hexColor = globalRainbowHex
                            c.UltBar.Fill.Color = globalRainbowColor
                        else
                            c.UltBar.Fill.Color = c3_fromHex("#" .. hexColor)
                        end
                        
                        if hexColor == "000000" and not usesCustomLook then
                            c.UltBar.Back.Color = c3_new(0.18, 0.18, 0.18)
                            if ultValue < 100 then c.UltBar.Outline.Color = COLOR_WHITE end
                        else
                            c.UltBar.Back.Color = c3_new(0.05, 0.05, 0.05)
                        end

                        -- Cash
                        local rawCash = p:GetAttribute("Cash")
                        local cashValue = type(rawCash) == "number" and rawCash or 0
                        if cashValue > 0 then
                            local cashStr = hideNameAndHealth and tostring(cashValue) or formatVal(cashValue)
                            c.CashDisplay = s_format("<font color='#00FF00'>$%s</font> | ", cashStr)
                        else
                            c.CashDisplay = ""
                        end

                        -- Perm badges (no emojis)
                        local permBadges = ""
                        if p:GetAttribute("PS_Owner") == true then
                            permBadges = permBadges .. "<font color='#FFDF00'>[Owner]</font> "
                        elseif p:GetAttribute("PS_Perms") == true then
                            permBadges = permBadges .. "<font color='#FFAA00'>[Admin]</font> "
                        end
                        if p:GetAttribute("Workshop") == true then
                            permBadges = permBadges .. "<font color='#AE00FF'>[Workshop]</font> "
                        end

                        -- Jackpot
                        local rawJackpot = char:GetAttribute("JackpotInRow")
                        local jackpotCount = type(rawJackpot) == "number" and rawJackpot or 0
                        local jackpotTag = (jackpotCount > 0) and s_format("<font color='#00FF00'>[%sx JP]</font> ", jackpotCount) or ""

                        -- Left tag (ULT)
                        local leftTag = inUlt and "<font color='#FF007F'>[ULT]</font> " or ""
                        local afkTag = c.IsAFK and "<font color='#A0A0A0'>[AFK]</font> " or ""
                        
                        -- Mark
                        local markTag = ""
                        local currentMarkObj = ActiveMarks[char]
                        if currentMarkObj then
                            if currentMarkObj.Parent and char.Parent then
                                markTag = "<font color='#9D8D6D'><b>[MARK]</b></font> "
                            else
                                ActiveMarks[char] = nil
                            end
                        end

                        -- ITFG
                        local itfgTag = ""
                        local itfgVal = char:GetAttribute("ITFG")
                        if type(itfgVal) == "number" and itfgVal >= 1 and itfgVal <= 2 then
                            itfgTag = s_format("<font color='#DF00FF'><b>[IT %d/2]</b></font> ", itfgVal)
                        end

                        -- EXEC (max 3)
                        local execTag = ""
                        local execVal = char:GetAttribute("EXEC")
                        if type(execVal) == "number" and execVal > 0 then
                            execTag = s_format("<font color='#FFFF00'><b>[EXEC %d/3]</b></font> ", execVal)
                        end

                        -- Burst
                        local burstTag = ""
                        if char:GetAttribute("Burst") ~= nil then
                            burstTag = "<font color='#FFFFFF'><b>[BURST]</b></font> "
                        end

                        local trailingBrackets = ""
                        if markTag ~= "" then trailingBrackets = trailingBrackets .. markTag end
                        if itfgTag ~= "" then trailingBrackets = trailingBrackets .. itfgTag end
                        if execTag ~= "" then trailingBrackets = trailingBrackets .. execTag end
                        if burstTag ~= "" then trailingBrackets = trailingBrackets .. burstTag end

                        -- Name line (without miracle)
                        if hideNameAndHealth then
                            -- Show mutual info if applicable
                            local mutualStr = ""
                            if c.IsMutual then
                                mutualStr = "[MF] "
                            end
                            c.NameDisplay = mutualStr .. trailingBrackets
                        elseif isDead then
                            c.NameDisplay = s_format("%s%s%s%s<font color='#FF0000'>[DEAD] %s</font> %s", afkTag, leftTag, jackpotTag, c.GroupRoleTag, p.Name, trailingBrackets)
                        else
                            local nameColorHex = "FFFFFF"
                            if c.IsFriend then
                                nameColorHex = "00FF00"
                            elseif c.IsMutual then
                                nameColorHex = "00FFFF"
                            end

                            local nameStr = (dist < 50) and p.Name or "<b>" .. p.Name .. "</b>"
                            c.NameDisplay = s_format("%s%s%s%s%s<font color='#%s'>%s</font> %s", afkTag, leftTag, jackpotTag, permBadges, c.GroupRoleTag, nameColorHex, nameStr, trailingBrackets)
                        end
                        
                        -- Distance color
                        local distCol = getGradientColor(dist / 800)
                        c.HexDistColor = s_format("%02x%02x%02x", m_floor(distCol.R * 255), m_floor(distCol.G * 255), m_floor(distCol.B * 255))
                        c.LineColor = getGradientColor(dist / 600)
                        
                        -- Moveset label
                        if movesetName and movesetName ~= "" then
                            if DARK_MOVESETS[movesetName] and not usesCustomLook then
                                c.CachedMoveset = s_format("<stroke color='#FFFFFF' thickness='1'><font color='#%s'>%s</font></stroke> | ", hexColor, tostring(movesetName))
                            else
                                c.CachedMoveset = s_format("<font color='#%s'>%s</font> | ", hexColor, tostring(movesetName))
                            end
                        else
                            c.CachedMoveset = ""
                        end

                        -- Build extra info (Miracles, Age, Friends, Gamepasses)
                        local extra = ""
                        if isHaruta and miraclesObj then
                            -- Show plain number with color
                            local harutaHex = MOVESET_COLORS["Haruta"] or "A77DCB"
                            extra = extra .. s_format(" • <font color='#%s'>%s</font>", harutaHex, tostring(miraclesObj.Value))
                        end
                        if c.AgeDisplay and c.AgeDisplay ~= "" then
                            extra = extra .. " • " .. c.AgeDisplay
                        end
                        if c.FriendDisplay and c.FriendDisplay ~= "" then
                            extra = extra .. " • " .. c.FriendDisplay
                        end
                        if c.GamepassDisplay and c.GamepassDisplay ~= "" then
                            extra = extra .. " • " .. c.GamepassDisplay
                        end
                        c.ExtraInfo = extra
                    end
                    
                    -- Tracer
                    c.Line.Visible = true
                    c.Line.Color = c.LineColor
                    c.Line.From = v2_new(sX, sY)
                    c.Line.To = v2_new(m_floor(root2D.X), m_floor(feet2D.Y))

                    -- 7. Main Overhead Text
                    local killString = hideNameAndHealth and tostring(c.CachedKills) or formatVal(c.CachedKills)
                    if c.IsHidingKills then
                        killString = s_format("%s <font color='#FF3333'><b>[HIDDEN]</b></font>", killString)
                    end

                    local rawText = s_format("%s\n%s%s<font color='#%s'>%s</font> • <font color='#%s'>%sm</font>%s", 
                        c.NameDisplay, 
                        c.CachedMoveset,
                        c.CashDisplay,
                        c.HexKillColor, 
                        killString, 
                        c.HexDistColor, 
                        tostring(m_floor(c.LastDist)),
                        c.ExtraInfo
                    )

                    local mainFontSize = m_floor(m_clamp(13 * scaleFactor, 9, 18))
                    local textY = hasActiveMoveset and (slotY - mainFontSize - m_floor(m_clamp(10 * scaleFactor, 6, 14))) or (uY - mainFontSize - m_floor(m_clamp(10 * scaleFactor, 6, 14)))
                    renderRichText(c.TextPool, rawText, m_floor(root2D.X), textY, mainFontSize, COLOR_WHITE)
                else
                    HideAllAssets(c)
                end
            elseif Cache[p] then
                HideAllAssets(Cache[p])
            end
        end
    end)
    table_insert(State.Connections, conn)

    local toggleConn = toggleObject:GetPropertyChangedSignal("Value"):Connect(handleToggleChange)
    table_insert(State.Connections, toggleConn)

    handleToggleChange()
end

return ESP
