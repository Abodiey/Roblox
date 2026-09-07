local ESPAssets = {}

local Color3 = Color3
local Vector2 = Vector2
local Vector3 = Vector3

local COLOR_RED = Color3.new(1, 0.1, 0.1)
local COLOR_YELLOW = Color3.new(1, 1, 0)
local COLOR_GREEN = Color3.new(0, 1, 0)
local COLOR_BRIGHT_GREEN = Color3.new(0, 1, 0.2)
local COLOR_CYAN = Color3.new(0, 0.8, 1)
local COLOR_DARK_BLUE = Color3.new(0, 0.1, 0.5)
local COLOR_WHITE = Color3.new(1, 1, 1)
local COLOR_BLACK = Color3.new(0, 0, 0)
local COLOR_GOLD = Color3.new(1, 0.85, 0)
local COLOR_PURPLE = Color3.new(0.68, 0.1, 1)
local COLOR_LIGHT_BLUE = Color3.fromRGB(50, 180, 255)
local COLOR_SEAL_RED = Color3.new(1, 0.2, 0.2)
local COLOR_SEAL_GREEN = Color3.new(0.2, 1, 0.2)

local c3_new = Color3.new
local c3_fromHex = Color3.fromHex
local v2_new = Vector2.new
local v3_new = Vector3.new
local m_clamp = math.clamp
local m_floor = math.floor
local m_max = math.max
local s_format = string.format
local o_clock = os.clock
local table_insert = table.insert

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
    assets.ExtraBar = createBarGroupWithTicks(9)

    -- Moveset slots: 0 = special, 1-4 = regular, 5 = extra (Reggie)
    assets.MovesetItems = {}
    for i = 0, 5 do
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

    -- Single special cooldown end timestamp
    assets.SpecialCooldownEnd = 0

    -- Dead state
    assets.IsDead = false
    assets.CurrentCharacter = nil

    -- Moveset tracking for resetting special on change
    assets.CurrentMoveset = ""

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
    if assets.ExtraBar then setBarGroupVisible(assets.ExtraBar, false) end
    
    if assets.MovesetItems then
        for i = 0, 5 do
            local item = assets.MovesetItems[i]
            item.Back.Visible = false
            item.Fill.Visible = false
            item.Outline.Visible = false
            item.Label.Visible = false
            item.SealCircle.Visible = false
        end
    end
end

local function DestroyAssets(assets)
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
    if assets.ExtraBar then removeBarGroup(assets.ExtraBar) end

    if assets.MovesetItems then
        for i = 0, 5 do
            local item = assets.MovesetItems[i]
            safeRemove(item.Back)
            safeRemove(item.Fill)
            safeRemove(item.Outline)
            safeRemove(item.Label)
            safeRemove(item.SealCircle)
        end
    end
end

ESPAssets.Colors = {
    Red = COLOR_RED,
    Yellow = COLOR_YELLOW,
    Green = COLOR_GREEN,
    BrightGreen = COLOR_BRIGHT_GREEN,
    Cyan = COLOR_CYAN,
    DarkBlue = COLOR_DARK_BLUE,
    White = COLOR_WHITE,
    Black = COLOR_BLACK,
    Gold = COLOR_GOLD,
    Purple = COLOR_PURPLE,
    LightBlue = COLOR_LIGHT_BLUE,
    SealRed = COLOR_SEAL_RED,
    SealGreen = COLOR_SEAL_GREEN,
}

ESPAssets.GetGradientColor = getGradientColor
ESPAssets.FormatValue = formatVal
ESPAssets.IsCustom = isCustom
ESPAssets.Create = CreateAssets
ESPAssets.Hide = HideAllAssets
ESPAssets.Destroy = DestroyAssets
ESPAssets.SetBarVisible = setBarGroupVisible
ESPAssets.RenderRichText = renderRichText

return ESPAssets

