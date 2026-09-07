local ESPTracking = {}

local cloneReference = cloneref or function(object) return object end
local Players = cloneReference(game:GetService("Players"))
local TARGET_GROUP = 16357742

function ESPTracking.new(Assets)
    local localPlayer = Players.LocalPlayer
    local getGradientColor = Assets.GetGradientColor
    local setBarGroupVisible = Assets.SetBarVisible
    local colors = Assets.Colors

    local COLOR_RED = colors.Red
    local COLOR_BRIGHT_GREEN = colors.BrightGreen
    local COLOR_GOLD = colors.Gold

    local t_wait = task.wait
    local m_clamp = math.clamp
    local m_floor = math.floor
    local s_format = string.format
    local table_insert = table.insert
    local table_clear = table.clear

    local function UpdatePlayerInfo(p, assets)
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
        UpdatePlayerInfo(p, assets)
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
            local directSuccess, directRes = pcall(function() return localPlayer:IsFriendsWith(p.UserId) end)
            if directSuccess and directRes then
                assets.IsFriend = true
                return
            end
    
            for _, other in ipairs(Players:GetPlayers()) do
                if other ~= localPlayer and other ~= p then
                    local s1, r1 = pcall(function() return localPlayer:IsFriendsWith(other.UserId) end)
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
    
        StartPeriodicInfoUpdates(p, assets)
    
        -- Listen to player's Moveset attribute changes to reset special
        local function onPlayerMovesetChanged()
            assets.SpecialCooldownEnd = 0
        end
        assets.Connections[#assets.Connections+1] = p:GetAttributeChangedSignal("Moveset"):Connect(onPlayerMovesetChanged)
    end
    
    local function SetupCharacterSignals(assets, char, hum)
        for _, conn in ipairs(assets.CharacterConnections) do conn:Disconnect() end
        table_clear(assets.CharacterConnections)
    
        if not hum then return end
    
        assets.IsDead = false
    
        -- Dead attribute
        local function onDeadChanged()
            assets.IsDead = char:GetAttribute("Dead") or false
        end
        assets.CharacterConnections[#assets.CharacterConnections+1] = char:GetAttributeChangedSignal("Dead"):Connect(onDeadChanged)
        onDeadChanged()
    
        -- Moveset attribute on character - reset special
        local function onCharMovesetChanged()
            assets.SpecialCooldownEnd = 0
        end
        assets.CharacterConnections[#assets.CharacterConnections+1] = char:GetAttributeChangedSignal("Moveset"):Connect(onCharMovesetChanged)
    
        -- Health bar updates
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

    return {
        SetupPlayer = SetupPlayerSignals,
        SetupCharacter = SetupCharacterSignals,
    }
end

return ESPTracking

