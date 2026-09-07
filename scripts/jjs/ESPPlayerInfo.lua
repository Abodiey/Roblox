local ESPPlayerInfo = {}

function ESPPlayerInfo.new(State, Assets, ActiveMarks, MOVESET_COLORS, DARK_MOVESETS)
    local enabled = State.Toggles.ESPPlayerInfo
    local colors = Assets.Colors
    local COLOR_WHITE = colors.White

    local renderRichText = Assets.RenderRichText
    local getGradientColor = Assets.GetGradientColor
    local formatVal = Assets.FormatValue
    local m_clamp = math.clamp
    local m_floor = math.floor
    local s_format = string.format

    local function Hide(assets)
        for _, textObject in ipairs(assets.TextPool) do
            textObject.Visible = false
        end
    end

    local function Render(c, frame)
        if not enabled.Value then
            Hide(c)
            return
        end

        local p = frame.player
        local char = frame.char
        local movesetName = frame.movesetName
        local isHaruta = frame.isHaruta
        local miraclesObj = frame.miraclesObj
        local info = frame.info
        local dist = frame.dist
        local hideNameAndHealth = frame.hideNameAndHealth
        local inUlt = frame.inUlt
        local shouldUpdateHeavy = frame.shouldUpdateHeavy
        local scaleFactor = frame.scaleFactor
        local root2D = frame.root2D
        local hasActiveMoveset = frame.hasActiveMoveset
        local slotY = frame.slotY
        local uY = frame.uY

        if shouldUpdateHeavy then
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
    end

    return {
        Render = Render,
        Hide = Hide,
    }
end

return ESPPlayerInfo

