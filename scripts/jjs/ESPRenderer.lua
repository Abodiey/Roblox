local ESPRenderer = {}

local cloneReference = cloneref or function(object) return object end
local Players = cloneReference(game:GetService("Players"))
local ReplicatedStorage = cloneReference(game:GetService("ReplicatedStorage"))
local workspace = cloneReference(game:GetService("Workspace"))

local Color3 = Color3
local Vector2 = Vector2
local Vector3 = Vector3
local c3_fromHex = Color3.fromHex
local c3_new = Color3.new
local v2_new = Vector2.new
local v3_new = Vector3.new
local m_clamp = math.clamp
local m_floor = math.floor
local m_abs = math.abs
local m_max = math.max
local s_format = string.format
local o_clock = os.clock
local table_insert = table.insert
local table_clear = table.clear

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
        
        local luminance = (0.299 * colorObj.R) + (0.587 * colorObj.G) + (0.114 * colorObj.B)
        if luminance < 0.2 then
            DARK_MOVESETS[movesetName] = true
        end
    end
end

function ESPRenderer.new(context)
    local Assets = context.Assets
    local Tracking = context.Tracking
    local Cache = context.Cache
    local ActiveMarks = context.ActiveMarks
    local SPECIAL_COOLDOWNS = context.SpecialCooldowns
    local toggleObject = context.Toggle
    local CleanupCacheEntry = context.CleanupCacheEntry
    local lp = Players.LocalPlayer
    local FrameTick = 0

    local colors = Assets.Colors
    local COLOR_RED = colors.Red
    local COLOR_YELLOW = colors.Yellow
    local COLOR_GREEN = colors.Green
    local COLOR_BRIGHT_GREEN = colors.BrightGreen
    local COLOR_CYAN = colors.Cyan
    local COLOR_DARK_BLUE = colors.DarkBlue
    local COLOR_WHITE = colors.White
    local COLOR_BLACK = colors.Black
    local COLOR_GOLD = colors.Gold
    local COLOR_PURPLE = colors.Purple
    local COLOR_LIGHT_BLUE = colors.LightBlue
    local COLOR_SEAL_RED = colors.SealRed
    local COLOR_SEAL_GREEN = colors.SealGreen

    local CreateAssets = Assets.Create
    local HideAllAssets = Assets.Hide
    local setBarGroupVisible = Assets.SetBarVisible
    local renderRichText = Assets.RenderRichText
    local getGradientColor = Assets.GetGradientColor
    local formatVal = Assets.FormatValue
    local isCustom = Assets.IsCustom
    local SetupPlayerSignals = Tracking.SetupPlayer
    local SetupCharacterSignals = Tracking.SetupCharacter

    return function()
        if not toggleObject.Value then return end

        local cam = workspace.CurrentCamera
        if not cam or not lp then return end
        local viewportSize = cam.ViewportSize
        local char_lp = lp.Character
        local myRoot = char_lp and char_lp.PrimaryPart
        
        FrameTick = FrameTick + 1
        local shouldUpdateHeavy = (FrameTick % 2 == 0)
        local isThrottledFrame = (FrameTick % 3 == 0)
        local gameClock = o_clock()

        local globalRainbowColor = Color3.fromHSV((gameClock * 0.4) % 1, 1, 1)
        local globalRainbowHex = s_format("%02x%02x%02x", m_floor(globalRainbowColor.R * 255), m_floor(globalRainbowColor.G * 255), m_floor(globalRainbowColor.B * 255))

        -- Clean dead cache entries
        for p, assets in pairs(Cache) do
            if not p or not p.Parent then CleanupCacheEntry(p, assets) end
        end

        -- Remove expired marks (>25s)
        for char, data in pairs(ActiveMarks) do
            if gameClock - data.timestamp > 25 then
                ActiveMarks[char] = nil
            end
        end

        -- Loop through all players including local
        for _, p in pairs(Players:GetPlayers()) do
            local char = p.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local root = char and char.PrimaryPart

            local c = Cache[p]
            if not c then 
                c = CreateAssets(p)
                Cache[p] = c 
                c.LastPosition = root and root.Position or v3_new(0,0,0)
                c.LastMoveTime = gameClock
                SetupPlayerSignals(p, c)
                -- SetupCharacterSignals called below when char exists
            end

            -- Check if character changed (respawn or first load)
            if c.CurrentCharacter ~= char then
                -- Reset special on respawn
                c.SpecialCooldownEnd = 0
                c.CurrentCharacter = char
                if char and hum then
                    SetupCharacterSignals(c, char, hum)
                else
                    for _, conn in ipairs(c.CharacterConnections) do conn:Disconnect() end
                    table_clear(c.CharacterConnections)
                    c.IsDead = false
                end
            end

            if root and hum then
                -- AFK detection
                if c.LastPosition and (c.LastPosition - root.Position).Magnitude > 0.1 then
                    c.LastPosition = root.Position
                    c.LastMoveTime = gameClock
                    c.IsAFK = false
                elseif (gameClock - c.LastMoveTime) >= 300 then
                    c.IsAFK = true
                end
                
                -- Project positions
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

                    local hideNameAndHealth = (dist < 10)

                    -- Moveset name
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

                    -- Update current moveset tracking
                    c.CurrentMoveset = movesetName

                    local isRyu = (movesetName == "Ryu")
                    local isHaruta = (movesetName == "Haruta")
                    local isReggie = (movesetName == "Reggie")
                    local info = char:FindFirstChild("Info")
                    local overheatObj = info and info:FindFirstChild("Overheat")
                    local miraclesObj = info and info:FindFirstChild("Miracles")
                    local nextReceiptObj = info and info:FindFirstChild("NextReceipt")

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

                    -- 3. Extra Bar (Overheat / Miracles)
                    local ohGap = m_floor(m_clamp(3 * scaleFactor, 2, 6))
                    local ohX = eX + eWidth + ohGap

                    if isRyu and overheatObj then
                        local ohVal = overheatObj.Value
                        local ohRatio = m_clamp(ohVal / 50, 0, 1)
                        for i = 1, #c.ExtraBar.Lines do
                            c.ExtraBar.Lines[i].Visible = (i <= 9 and ohRatio > 0.02)
                        end
                        if ohRatio <= 0.02 then
                            setBarGroupVisible(c.ExtraBar, false)
                        else
                            setBarGroupVisible(c.ExtraBar, true)
                            c.ExtraBar.Back.Position = v2_new(ohX, eY)
                            c.ExtraBar.Back.Size = v2_new(eWidth, eH)
                            c.ExtraBar.Outline.Position = v2_new(ohX, eY)
                            c.ExtraBar.Outline.Size = v2_new(eWidth, eH)
                            local ohFillH = m_floor(eH * ohRatio)
                            c.ExtraBar.Fill.Position = v2_new(ohX, eY + (eH - ohFillH))
                            c.ExtraBar.Fill.Size = v2_new(eWidth, ohFillH)
                            if ohVal >= 50 then
                                c.ExtraBar.Fill.Color = COLOR_YELLOW
                                for i = 1, 9 do c.ExtraBar.Lines[i].Visible = false end
                            else
                                c.ExtraBar.Fill.Color = c3_new(0, 0.66, 1):Lerp(c3_new(1, 0, 0.5), ohRatio)
                                for i = 1, 9 do
                                    local lineY = m_floor(eY + (eH * 0.1 * i))
                                    c.ExtraBar.Lines[i].From = v2_new(ohX, lineY)
                                    c.ExtraBar.Lines[i].To = v2_new(ohX + eWidth, lineY)
                                    c.ExtraBar.Lines[i].Visible = true
                                end
                            end
                        end
                    elseif isHaruta and miraclesObj then
                        local mirVal = miraclesObj.Value
                        local mirRatio = m_clamp(mirVal / 6, 0, 1)
                        for i = 1, #c.ExtraBar.Lines do
                            c.ExtraBar.Lines[i].Visible = (i <= 6 and mirRatio > 0.02)
                        end
                        if mirRatio <= 0.02 then
                            setBarGroupVisible(c.ExtraBar, false)
                        else
                            setBarGroupVisible(c.ExtraBar, true)
                            local harutaColor = c3_fromHex("#" .. (MOVESET_COLORS["Haruta"] or "A77DCB"))
                            c.ExtraBar.Back.Position = v2_new(ohX, eY)
                            c.ExtraBar.Back.Size = v2_new(eWidth, eH)
                            c.ExtraBar.Outline.Position = v2_new(ohX, eY)
                            c.ExtraBar.Outline.Size = v2_new(eWidth, eH)
                            local mirFillH = m_floor(eH * mirRatio)
                            c.ExtraBar.Fill.Position = v2_new(ohX, eY + (eH - mirFillH))
                            c.ExtraBar.Fill.Size = v2_new(eWidth, mirFillH)
                            c.ExtraBar.Fill.Color = harutaColor
                            for i = 1, 6 do
                                local lineY = m_floor(eY + (eH * (i / 6)))
                                c.ExtraBar.Lines[i].From = v2_new(ohX, lineY)
                                c.ExtraBar.Lines[i].To = v2_new(ohX + eWidth, lineY)
                                c.ExtraBar.Lines[i].Visible = true
                            end
                        end
                    else
                        setBarGroupVisible(c.ExtraBar, false)
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

                    -- 5. Moveset Slots
                    local slotHeight = m_floor(m_clamp(22 * scaleFactor, 14, 32))
                    local slotGap = m_floor(m_clamp(3 * scaleFactor, 2, 6))
                    local moveFontSize = m_floor(m_clamp(10 * scaleFactor, 8, 15))
                    local slotY = uY - slotHeight - m_floor(m_clamp(4 * scaleFactor, 2, 8))
                    local hasActiveMoveset = false

                    if c.MovesetItems then
                        -- Reset visibility
                        for i = 0, 5 do
                            c.MovesetItems[i].Data.Visible = false
                            c.MovesetItems[i].MoveRef = nil
                        end

                        -- Slot 0: Special
                        local specialItem = c.MovesetItems[0]
                        specialItem.Data.Visible = true
                        specialItem.Data.Key = "0"
                        -- Determine name based on current moveset
                        local specData = SPECIAL_COOLDOWNS[movesetName]
                        if specData then
                            specialItem.Data.Name = specData.Name
                            local remaining = m_max(0, c.SpecialCooldownEnd - o_clock())
                            local cdRatio = m_clamp(remaining / specData.Duration, 0, 1)
                            specialItem.Data.CooldownRatio = cdRatio
                        else
                            specialItem.Data.Name = "Special"
                            specialItem.Data.CooldownRatio = 0
                        end
                        specialItem.MoveRef = nil
                        hasActiveMoveset = true

                        -- Slots 1-4: regular moves
                        if movesetFolder then
                            for _, move in ipairs(movesetFolder:GetChildren()) do
                                local slotKey = move:GetAttribute("Key")
                                if type(slotKey) == "number" and slotKey >= 1 and slotKey <= 4 then
                                    local item = c.MovesetItems[slotKey]
                                    if item then
                                        hasActiveMoveset = true
                                        item.Data.Visible = true
                                        item.Data.Key = tostring(slotKey)
                                        local tag = move:GetAttribute("Tag")
                                        if tag and move.Name ~= "-" then
                                            item.Data.Name = tostring(tag)
                                            if not item._tagConn then
                                                item._tagConn = move:GetAttributeChangedSignal("Tag"):Connect(function()
                                                    local newTag = move:GetAttribute("Tag")
                                                    if newTag and move.Name ~= "-" then
                                                        item.Data.Name = tostring(newTag)
                                                    else
                                                        item.Data.Name = move.Name
                                                    end
                                                end)
                                                table_insert(c.Connections, item._tagConn)
                                            end
                                        else
                                            item.Data.Name = move.Name
                                        end
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

                        -- Slot 5: extra for Reggie
                        local reggieItem = c.MovesetItems[5]
                        if isReggie and nextReceiptObj then
                            reggieItem.Data.Visible = true
                            reggieItem.Data.Key = "5"
                            local function updateReceipt()
                                reggieItem.Data.Name = tostring(nextReceiptObj.Value)
                            end
                            updateReceipt()
                            if not c._receiptConn then
                                c._receiptConn = nextReceiptObj:GetPropertyChangedSignal("Value"):Connect(updateReceipt)
                                table_insert(c.Connections, c._receiptConn)
                            end
                            reggieItem.Data.CooldownRatio = 0
                            reggieItem.MoveRef = nil
                            hasActiveMoveset = true
                        else
                            reggieItem.Data.Visible = false
                        end

                        -- Compute widths for slots 0-4
                        local itemWidths = {}
                        local totalMovesetWidth = 0
                        local activeCount = 0
                        for i = 0, 4 do
                            local item = c.MovesetItems[i]
                            if item.Data.Visible then
                                activeCount = activeCount + 1
                                item.Label.Text = item.Data.Name
                                item.Label.Size = moveFontSize
                                local textW = item.Label.TextBounds.X
                                local slotW = m_floor(m_max(slotHeight, textW + m_clamp(8 * scaleFactor, 4, 12)))
                                slotW = m_floor(m_max(slotW, slotHeight))
                                itemWidths[i] = slotW
                                totalMovesetWidth = totalMovesetWidth + slotW
                            else
                                itemWidths[i] = 0
                            end
                        end
                        if activeCount > 0 then
                            totalMovesetWidth = totalMovesetWidth + ((activeCount - 1) * slotGap)
                        end

                        -- Render slots 0-4 centered
                        local movesetStartX = m_floor(root2D.X - (totalMovesetWidth / 2))
                        local currentSlotX = movesetStartX
                        for i = 0, 4 do
                            local item = c.MovesetItems[i]
                            if item.Data.Visible then
                                local slotW = itemWidths[i]
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

                                local seal = item.MoveRef and item.MoveRef:GetAttribute("Seal")
                                if seal then
                                    local radius = m_floor(m_clamp(4 * scaleFactor, 3, 8))
                                    local padding = m_floor(m_clamp(2 * scaleFactor, 1, 4))
                                    item.SealCircle.Visible = true
                                    item.SealCircle.Radius = radius
                                    if seal == 1 then
                                        item.SealCircle.Color = COLOR_SEAL_RED
                                    else -- seal > 1
                                        item.SealCircle.Color = COLOR_SEAL_GREEN
                                    end
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

                        -- Render Reggie slot 5 to the right
                        if reggieItem and reggieItem.Data.Visible then
                            local lastSlotEnd = currentSlotX - slotGap
                            reggieItem.Label.Text = reggieItem.Data.Name
                            reggieItem.Label.Size = moveFontSize
                            local textW = reggieItem.Label.TextBounds.X
                            local reggieWidth = m_floor(m_max(slotHeight, textW + m_clamp(8 * scaleFactor, 4, 12)))
                            reggieWidth = m_floor(m_clamp(reggieWidth, slotHeight, 80))
                            local reggieX = lastSlotEnd + slotGap
                            reggieItem.Back.Visible = true
                            reggieItem.Back.Position = v2_new(reggieX, slotY)
                            reggieItem.Back.Size = v2_new(reggieWidth, slotHeight)
                            reggieItem.Outline.Visible = true
                            reggieItem.Outline.Position = v2_new(reggieX, slotY)
                            reggieItem.Outline.Size = v2_new(reggieWidth, slotHeight)
                            reggieItem.Fill.Visible = false
                            reggieItem.Label.Visible = true
                            reggieItem.Label.Outline = true
                            reggieItem.Label.OutlineColor = COLOR_BLACK
                            reggieItem.Label.Text = reggieItem.Data.Name
                            reggieItem.Label.Size = moveFontSize
                            reggieItem.Label.Position = v2_new(reggieX + m_floor(reggieWidth / 2), slotY + m_floor((slotHeight - reggieItem.Label.TextBounds.Y) / 2))
                            reggieItem.SealCircle.Visible = false
                        else
                            reggieItem.Back.Visible = false
                            reggieItem.Fill.Visible = false
                            reggieItem.Outline.Visible = false
                            reggieItem.Label.Visible = false
                            reggieItem.SealCircle.Visible = false
                        end
                    end

                    -- 6. Heavy updates
                    if shouldUpdateHeavy then
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

                        -- Perm badges
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

                        local leftTag = inUlt and "<font color='#FF007F'>[ULT]</font> " or ""
                        local afkTag = c.IsAFK and "<font color='#A0A0A0'>[AFK]</font> " or ""
                        
                        -- Mark
                        local markTag = ""
                        local markData = ActiveMarks[char]
                        if markData and markData.mark and markData.mark.Parent and char.Parent then
                            markTag = "<font color='#9D8D6D'><b>[MARK]</b></font> "
                        else
                            ActiveMarks[char] = nil
                        end

                        -- ITFG
                        local itfgTag = ""
                        local itfgVal = char:GetAttribute("ITFG")
                        if type(itfgVal) == "number" and itfgVal >= 1 and itfgVal <= 2 then
                            itfgTag = s_format("<font color='#DF00FF'><b>[IT %d/2]</b></font> ", itfgVal)
                        end

                        -- EXEC
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

                        -- Emote
                        local emoteTag = ""
                        if info and info:FindFirstChild("Emote") then
                            emoteTag = "<font color='#FF69B4'><b>[EMOTE]</b></font> "
                        end

                        -- VC
                        local vcTag = ""
                        local audioDevice = p:FindFirstChild("AudioDeviceInput")
                        if audioDevice then
                            local muted = audioDevice.Muted
                            if muted == true then
                                vcTag = "<font color='#FF0000'><b>[VC]</b></font> "
                            else
                                vcTag = "<font color='#00FF00'><b>[VC]</b></font> "
                            end
                        end

                        local trailingBrackets = ""
                        if markTag ~= "" then trailingBrackets = trailingBrackets .. markTag end
                        if itfgTag ~= "" then trailingBrackets = trailingBrackets .. itfgTag end
                        if execTag ~= "" then trailingBrackets = trailingBrackets .. execTag end
                        if burstTag ~= "" then trailingBrackets = trailingBrackets .. burstTag end
                        if emoteTag ~= "" then trailingBrackets = trailingBrackets .. emoteTag end

                        -- Name line
                        if hideNameAndHealth then
                            c.NameDisplay = vcTag .. trailingBrackets
                        elseif c.IsDead then
                            c.NameDisplay = s_format("%s%s%s%s%s%s<font color='#FF0000'>[DEAD] %s</font> %s", afkTag, leftTag, jackpotTag, vcTag, c.GroupRoleTag, emoteTag, p.Name, trailingBrackets)
                        else
                            local nameColorHex = "FFFFFF"
                            if c.IsFriend then
                                nameColorHex = "00FF00"
                            elseif c.IsMutual then
                                nameColorHex = "00FFFF"
                            end

                            local nameStr = (dist < 50) and p.Name or "<b>" .. p.Name .. "</b>"
                            c.NameDisplay = s_format("%s%s%s%s%s%s<font color='#%s'>%s</font> %s", afkTag, leftTag, jackpotTag, vcTag, permBadges, c.GroupRoleTag, nameColorHex, nameStr, trailingBrackets)
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

                        -- Extra info
                        local extra = ""
                        if isHaruta and miraclesObj then
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
            else
                -- No character
                if c then
                    HideAllAssets(c)
                    if c.CurrentCharacter then
                        for _, conn in ipairs(c.CharacterConnections) do conn:Disconnect() end
                        table_clear(c.CharacterConnections)
                        c.CurrentCharacter = nil
                        c.IsDead = false
                        c.SpecialCooldownEnd = 0
                    end
                end
            end
        end
    end
end

return ESPRenderer

