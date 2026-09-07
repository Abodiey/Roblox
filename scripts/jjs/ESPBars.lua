local ESPBars = {}

function ESPBars.new(State, Assets, MOVESET_COLORS)
    local healthEnabled = State.Toggles.ESPHealthBar
    local evadeEnabled = State.Toggles.ESPEvadeBar
    local extraEnabled = State.Toggles.ESPExtraBar
    local ultimateEnabled = State.Toggles.ESPUltimateBar

    local colors = Assets.Colors
    local COLOR_RED = colors.Red
    local COLOR_YELLOW = colors.Yellow
    local COLOR_BRIGHT_GREEN = colors.BrightGreen
    local COLOR_CYAN = colors.Cyan
    local COLOR_DARK_BLUE = colors.DarkBlue
    local COLOR_WHITE = colors.White
    local COLOR_BLACK = colors.Black
    local COLOR_GOLD = colors.Gold
    local COLOR_PURPLE = colors.Purple

    local setBarGroupVisible = Assets.SetBarVisible
    local c3_fromHex = Color3.fromHex
    local c3_new = Color3.new
    local v2_new = Vector2.new
    local m_clamp = math.clamp
    local m_floor = math.floor

    local function Render(c, frame)
        local char = frame.char
        local hum = frame.hum
        local p = frame.player
        local scaleFactor = frame.scaleFactor
        local boxX = frame.boxX
        local boxY = frame.boxY
        local boxWidth = frame.boxWidth
        local boxHeight = frame.boxHeight
        local hideNameAndHealth = frame.hideNameAndHealth
        local isRyu = frame.isRyu
        local isHaruta = frame.isHaruta
        local overheatObj = frame.overheatObj
        local miraclesObj = frame.miraclesObj
        local globalRainbowColor = frame.globalRainbowColor
        local globalRainbowHex = frame.globalRainbowHex
        local isThrottledFrame = frame.isThrottledFrame
        local shouldUpdateHeavy = frame.shouldUpdateHeavy
        local movesetName = frame.movesetName
        local fullyCustom = frame.fullyCustom

        if healthEnabled.Value then
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
        else
            setBarGroupVisible(c.HealthBar, false)
        end

        if evadeEnabled.Value then
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
        else
            setBarGroupVisible(c.EvadeBar, false)
        end

        if extraEnabled.Value then
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
        else
            setBarGroupVisible(c.ExtraBar, false)
        end

                    -- 4. Ultimate Bar
                    local uHeight = m_floor(m_clamp(4 * scaleFactor, 2, 8))
                    local uGap = m_floor(m_clamp(3 * scaleFactor, 2, 6))
                    local uW = boxWidth
                    local uX = boxX
                    local uY = boxY - uHeight - uGap

        local rawUlt = p:GetAttribute("Ultimate")
        local ultValue = type(rawUlt) == "number" and rawUlt or 0
        local ultRatio = m_clamp(ultValue / 100, 0, 1)

        if ultimateEnabled.Value then
                    setBarGroupVisible(c.UltBar, true)
                    c.UltBar.Back.Position = v2_new(uX, uY)
                    c.UltBar.Back.Size = v2_new(uW, uHeight)
                    c.UltBar.Outline.Position = v2_new(uX, uY)
                    c.UltBar.Outline.Size = v2_new(uW, uHeight)

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
        else
            setBarGroupVisible(c.UltBar, false)
        end

                    -- 6. Heavy updates
                    if shouldUpdateHeavy then
                        local inUlt = char:GetAttribute("InUlt")
                    frame.inUlt = inUlt

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
                    end

        frame.uY = uY
        frame.ultValue = ultValue
    end

    return {
        Render = Render,
    }
end

return ESPBars

