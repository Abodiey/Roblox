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

-- Localize Roblox Datatypes
local Vector2 = Vector2
local v2_new = Vector2.new
local Vector3 = Vector3
local v3_new = Vector3.new
local UDim2 = UDim2
local ud2_new = UDim2.new
local Color3 = Color3
local c3_new = Color3.new
local Enum = Enum

local lp = Players.LocalPlayer

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

-- Cached static color bounds
local COLOR_RED = c3_new(1, 0, 0)
local COLOR_YELLOW = c3_new(1, 1, 0)
local COLOR_GREEN = c3_new(0, 1, 0)
local COLOR_WHITE = c3_new(1, 1, 1)
local COLOR_BLACK = c3_new(0, 0, 0)
local COLOR_CYAN = c3_new(0, 1, 1)
local COLOR_MAGENTA = c3_new(1, 0, 1)
local COLOR_ORANGE = c3_new(1, 0.4, 0)
local COLOR_GOLD = c3_new(1, 0.8, 0)

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

local function CreateAssets(p)
    local assets = {}
    
    -- Tracer Line Frame
    local line = inst_new("Frame")
    line.BorderSizePixel = 0
    line.AnchorPoint = v2_new(0.5, 0.5)
    line.Parent = ScreenGui
    assets.Line = line
    
    -- Main Text Element Layout
    local bill = inst_new("BillboardGui")
    bill.AlwaysOnTop = true
    bill.Size = ud2_new(0, 240, 0, 50)
    bill.ExtentsOffset = v3_new(0, 3.2, 0)
    bill.Parent = ScreenGui
    assets.Bill = bill
    
    local txt = inst_new("TextLabel")
    txt.Size = ud2_new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = COLOR_WHITE
    txt.RichText = true
    txt.Font = Enum.Font.RobotoMono
    txt.TextSize = 13
    txt.Parent = bill
    assets.Text = txt
    
    local stroke = inst_new("UIStroke")
    stroke.Thickness = 0.5
    stroke.Color = COLOR_BLACK
    stroke.Parent = txt
    assets.Stroke = stroke
    
    -- LEFT SIDEBAR FRAME (Health & Ultimate Stack)
    local leftBill = inst_new("BillboardGui")
    leftBill.AlwaysOnTop = true
    leftBill.Size = ud2_new(0, 3, 0, 36)
    leftBill.ExtentsOffset = v3_new(-2.2, -0.1, 0)
    leftBill.Parent = ScreenGui
    assets.LeftBill = leftBill
    
    local leftContainer = inst_new("Frame")
    leftContainer.Size = ud2_new(1, 0, 1, 0)
    leftContainer.BackgroundTransparency = 1
    leftContainer.Parent = leftBill
    
    -- Health (Top 50% of Left Sidebar)
    local hBack = inst_new("Frame")
    hBack.Size = ud2_new(1, 0, 0.48, 0)
    hBack.BackgroundColor3 = COLOR_BLACK
    hBack.BorderSizePixel = 0
    hBack.Parent = leftContainer
    
    local hFill = inst_new("Frame")
    hFill.Size = ud2_new(1, 0, 1, 0)
    hFill.AnchorPoint = v2_new(0, 1)
    hFill.Position = ud2_new(0, 0, 1, 0)
    hFill.BorderSizePixel = 0
    hFill.Parent = hBack
    assets.HealthFill = hFill

    -- Ultimate (Bottom 50% of Left Sidebar)
    local uBack = inst_new("Frame")
    uBack.Size = ud2_new(1, 0, 0.48, 0)
    uBack.Position = ud2_new(0, 0, 0.52, 0)
    uBack.BackgroundColor3 = COLOR_BLACK
    uBack.BorderSizePixel = 0
    uBack.Parent = leftContainer
    
    local uFill = inst_new("Frame")
    uFill.Size = ud2_new(1, 0, 1, 0)
    uFill.AnchorPoint = v2_new(0, 1)
    uFill.Position = ud2_new(0, 0, 1, 0)
    uFill.BorderSizePixel = 0
    uFill.Parent = uBack
    assets.UltFill = uFill

    -- RIGHT SIDEBAR FRAME (Evade & Jackpot Stack)
    local rightBill = inst_new("BillboardGui")
    rightBill.AlwaysOnTop = true
    rightBill.Size = ud2_new(0, 3, 0, 36)
    rightBill.ExtentsOffset = v3_new(2.2, -0.1, 0)
    rightBill.Parent = ScreenGui
    assets.RightBill = rightBill
    
    local rightContainer = inst_new("Frame")
    rightContainer.Size = ud2_new(1, 0, 1, 0)
    rightContainer.BackgroundTransparency = 1
    rightContainer.Parent = rightBill
    
    -- Evade (Top 50% of Right Sidebar)
    local eBack = inst_new("Frame")
    eBack.Size = ud2_new(1, 0, 0.48, 0)
    eBack.BackgroundColor3 = COLOR_BLACK
    eBack.BorderSizePixel = 0
    eBack.Parent = rightContainer
    
    local eFill = inst_new("Frame")
    eFill.Size = ud2_new(1, 0, 1, 0)
    eFill.AnchorPoint = v2_new(0, 1)
    eFill.Position = ud2_new(0, 0, 1, 0)
    eFill.BorderSizePixel = 0
    eFill.Parent = eBack
    assets.EvadeFill = eFill

    -- Jackpot (Bottom 50% of Right Sidebar)
    local jBack = inst_new("Frame")
    jBack.Size = ud2_new(1, 0, 0.48, 0)
    jBack.Position = ud2_new(0, 0, 0.52, 0)
    jBack.BackgroundColor3 = COLOR_BLACK
    jBack.BorderSizePixel = 0
    jBack.Parent = rightContainer
    assets.JackpotBack = jBack
    
    local jFill = inst_new("Frame")
    jFill.Size = ud2_new(1, 0, 1, 0)
    jFill.AnchorPoint = v2_new(0, 1)
    jFill.Position = ud2_new(0, 0, 1, 0)
    jFill.BorderSizePixel = 0
    jFill.Parent = jBack
    assets.JackpotFill = jFill
    
    -- Connection trackers
    assets.Connections = {}
    assets.CharacterConnections = {} 
    assets.KillValueConnections = {} 
    
    -- Dynamic variable caching
    assets.LastDist = 0
    assets.CachedKills = 0
    assets.CachedMoveset = ""
    assets.NameDisplay = ""
    assets.UltDisplay = ""
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
    if assets.LeftBill then assets.LeftBill:Destroy() end
    if assets.RightBill then assets.RightBill:Destroy() end
    Cache[p] = nil
end

local function SetupPlayerSignals(p, assets)
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
                    if killsVal then
                        trackValueInstance(killsVal)
                    else
                        local hConn
                        hConn = hiddenFolder.ChildAdded:Connect(function(child)
                            if child.Name == "Kills" and leaderstats:GetAttribute("HiddenKills") then
                                trackValueInstance(child)
                                hConn:Disconnect()
                            end
                        end)
                        table_insert(assets.KillValueConnections, hConn)
                    end
                else
                    local folderConn
                    folderConn = leaderstats.ChildAdded:Connect(function(child)
                        if child.Name == "Hidden" then
                            evaluateSource()
                            folderConn:Disconnect()
                        end
                    end)
                    table_insert(assets.KillValueConnections, folderConn)
                end
            else
                local killsVal = leaderstats:FindFirstChild("Kills")
                if killsVal then
                    trackValueInstance(killsVal)
                else
                    local kConn
                    kConn = leaderstats.ChildAdded:Connect(function(child)
                        if child.Name == "Kills" and not leaderstats:GetAttribute("HiddenKills") then
                            trackValueInstance(child)
                            kConn:Disconnect()
                        end
                    end)
                    table_insert(assets.KillValueConnections, kConn)
                end
            end
        end

        table_insert(assets.Connections, leaderstats:GetAttributeChangedSignal("HiddenKills"):Connect(evaluateSource))
        evaluateSource()
    end

    local leaderstats = p:FindFirstChild("leaderstats")
    if leaderstats then
        watchKills(leaderstats)
    else
        local lConn
        lConn = p.ChildAdded:Connect(function(child)
            if child.Name == "leaderstats" then
                watchKills(child)
                lConn:Disconnect()
            end
        end)
        table_insert(assets.Connections, lConn)
    end
end

local function SetupCharacterSignals(assets, char, hum)
    for _, conn in ipairs(assets.CharacterConnections) do conn:Disconnect() end
    table_clear(assets.CharacterConnections)

    if not hum then return end

    local function updateHealth()
        if not assets.HealthFill then return end
        local hpPerc = m_clamp(hum.Health / hum.MaxHealth, 0, 1)
        assets.HealthFill.Size = ud2_new(1, 0, hpPerc, 0)
        assets.HealthFill.BackgroundColor3 = getGradientColor(hpPerc)
    end
    
    table_insert(assets.CharacterConnections, hum:GetPropertyChangedSignal("Health"):Connect(updateHealth))
    table_insert(assets.CharacterConnections, hum:GetPropertyChangedSignal("MaxHealth"):Connect(updateHealth))
    updateHealth()
end

function ESP.Init(State)
    local conn = RunService.RenderStepped:Connect(function()
        if not State.Toggles.Esp then 
            ScreenGui.Enabled = false 
            return 
        end
        ScreenGui.Enabled = true

        local cam = workspace.CurrentCamera
        local viewportSize = cam.ViewportSize
        
        local char_lp = lp.Character
        local myRoot = char_lp and char_lp:FindFirstChild("HumanoidRootPart")
        
        FrameTick = FrameTick + 1
        local shouldUpdateHeavy = (FrameTick % 2 == 0)

        -- Clean stale player visual objects
        for p, assets in pairs(Cache) do
            if not p or not p.Parent then
                CleanupCacheEntry(p, assets)
            end
        end

        -- Main loop over game targets
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
                    SetupPlayerSignals(p, c)
                    SetupCharacterSignals(c, char, hum)
                    
                    local respawnConn
                    respawnConn = p.CharacterAdded:Connect(function(newChar)
                        if not Cache[p] then respawnConn:Disconnect() return end
                        local newHum = newChar:WaitForChild("Humanoid", 3)
                        SetupCharacterSignals(Cache[p], newChar, newHum)
                    end)
                    table_insert(c.Connections, respawnConn)
                end
                
                local p2, vis2 = cam:WorldToViewportPoint(root.Position)

                if vis2 and p2.Z > 0 then
                    c.Line.Visible = true
                    c.Bill.Enabled = true
                    c.LeftBill.Enabled = true
                    c.RightBill.Enabled = true
                    c.Text.Visible = true
                    
                    c.Bill.Adornee = root
                    c.LeftBill.Adornee = root
                    c.RightBill.Adornee = root

                    -- Define the starting viewport coordinates (Origin point)
                    local sX, sY
                    if myRoot then
                        local p1, _ = cam:WorldToViewportPoint(myRoot.Position)
                        sX, sY = p1.X, p1.Y
                    else
                        sX, sY = viewportSize.X * 0.5, viewportSize.Y * 0.5
                    end

                    -- Throttled calculations (Every 2 Frames)
                    if shouldUpdateHeavy then
                        local currentRootPos = myRoot and myRoot.Position or cam.CFrame.Position
                        local dist = (currentRootPos - root.Position).Magnitude
                        c.LastDist = dist
                        
                        -- Core Validation Attributes
                        local isDead = char:GetAttribute("Dead")
                        local inUlt = char:GetAttribute("InUlt")
                        
                        -- 1. Ultimate Capacity Calculations (0 - 100)
                        local rawUlt = char:GetAttribute("Ultimate")
                        local ultValue = type(rawUlt) == "number" and rawUlt or 0
                        local ultPerc = m_clamp(ultValue / 100, 0, 1)
                        c.UltFill.Size = ud2_new(1, 0, ultPerc, 0)
                        c.UltFill.BackgroundColor3 = (ultPerc >= 1) and COLOR_ORANGE or COLOR_YELLOW

                        -- 2. Evade Capacity Calculations (0 - 50 Max)
                        local rawEvade = char:GetAttribute("Evade")
                        local evadeValue = type(rawEvade) == "number" and rawEvade or 0
                        local evadePerc = m_clamp(rawEvade and (evadeValue / 50) or 0, 0, 1)
                        c.EvadeFill.Size = ud2_new(1, 0, evadePerc, 0)
                        c.EvadeFill.BackgroundColor3 = (evadePerc >= 1) and COLOR_MAGENTA or COLOR_CYAN:Lerp(COLOR_MAGENTA, evadePerc)

                        -- 3. Optional Attributes Parsing (Jackpots, Cash, Permissions)
                        local rawCash = char:GetAttribute("Cash")
                        local cashValue = type(rawCash) == "number" and rawCash or 0
                        
                        local rawJackpot = char:GetAttribute("JackpotInRow")
                        local jackpotCount = type(rawJackpot) == "number" and rawJackpot or 0
                        
                        -- Handle dynamic Jackpot sidebar tracking
                        if jackpotCount > 0 then
                            c.JackpotBack.Visible = true
                            local jPerc = m_clamp(jackpotCount / 7, 0, 1) -- Visual cap relative scale
                            c.JackpotFill.Size = ud2_new(1, 0, jPerc, 0)
                            c.JackpotFill.BackgroundColor3 = COLOR_GOLD
                        else
                            c.JackpotBack.Visible = false
                        end

                        -- Server Access Badge Compiling
                        local permBadges = ""
                        if char:GetAttribute("PS_Owner") == true then
                            permBadges = permBadges .. "<font color='#FFDF00'>[👑 Owner]</font> "
                        elseif char:GetAttribute("PS_Perms") == true then
                            permBadges = permBadges .. "<font color='#FFAA00'>[⚙️ Admin]</font> "
                        end
                        if char:GetAttribute("Workshop") == true then
                            permBadges = permBadges .. "<font color='#00FF80'>[🛠️ Workshop]</font> "
                        end

                        -- Top-Line Tag Assembly
                        local leftTag = inUlt and "<font color='#FF007F'>[ULT]</font> " or ""
                        local jackpotTag = (jackpotCount > 0) and s_format("<font color='#FFD700'>[%sx JP]</font> ", jackpotCount) or ""
                        
                        if isDead then
                            c.NameDisplay = s_format("%s%s%s<font color='#FF0000'>[DEAD] %s</font>", leftTag, jackpotTag, permBadges, p.Name)
                        else
                            c.NameDisplay = s_format("%s%s%s%s", leftTag, jackpotTag, permBadges, (dist < 50) and p.Name or "<b>" .. p.Name .. "</b>")
                        end
                        
                        local distCol = getGradientColor(dist / 800)
                        c.HexDistColor = s_format("%02x%02x%02x", m_floor(distCol.R * 255), m_floor(distCol.G * 255), m_floor(distCol.B * 255))
                        c.LineColor = getGradientColor(dist / 600)
                        
                        -- Moveset String Processing
                        local movesetAttr = char:GetAttribute("Moveset")
                        if movesetAttr and movesetAttr ~= "" then
                            local movesetInstance = char:FindFirstChild("Moveset")
                            if movesetAttr == "Custom" and movesetInstance and not movesetInstance:FindFirstChild("Custom") then
                                movesetAttr = movesetInstance:GetChildren()[1].Name
                            elseif movesetInstance and movesetInstance:FindFirstChild("Custom") then 
                                movesetAttr = "Custom!"
                            end
                            
                            local hexColor = MOVESET_COLORS[movesetAttr] or "FFFFFF"
                            if DARK_MOVESETS[movesetAttr] then
                                c.CachedMoveset = s_format("<stroke color='#FFFFFF' thickness='1'><font color='#%s'>%s</font></stroke> | ", hexColor, tostring(movesetAttr))
                            else
                                c.CachedMoveset = s_format("<font color='#%s'>%s</font> | ", hexColor, tostring(movesetAttr))
                            end
                        else
                            c.CachedMoveset = ""
                        end
                        
                        -- Cash Text Builder
                        c.UltDisplay = (cashValue > 0) and s_format("<font color='#85bb65'>$%s</font> | ", formatVal(cashValue)) or ""
                    end
                    
                    local currentDist = c.LastDist

                    -- 2D Line Calculations
                    local eX, eY = p2.X, p2.Y
                    local diffX, diffY = eX - sX, eY - sY
                    local mag = (diffX * diffX + diffY * diffY) ^ 0.5
                    
                    c.Line.BackgroundColor3 = c.LineColor
                    c.Line.Size = ud2_new(0, mag, 0, 1)
                    c.Line.Position = ud2_new(0, (sX + eX) * 0.5, 0, (sY + eY) * 0.5)
                    c.Line.Rotation = m_deg(m_atan2(diffY, diffX))

                    -- Build Kill Metadata String Bypasses
                    local killString = formatVal(c.CachedKills)
                    if c.IsHidingKills then
                        killString = s_format("%s<font color='#FFFF00'>*</font>", killString)
                    end

                    -- Final Structured Output Generation
                    c.Text.Text = s_format("%s\n%s%s<font color='#%s'>%s</font> • <font color='#%s'>%sm</font>", 
                        c.NameDisplay, 
                        c.CachedMoveset,
                        c.UltDisplay,
                        c.HexKillColor, 
                        killString, 
                        c.HexDistColor, 
                        tostring(m_floor(currentDist))
                    )
                else
                    c.Line.Visible = false
                    c.Bill.Enabled = false
                    c.LeftBill.Enabled = false
                    c.RightBill.Enabled = false
                    c.Text.Visible = false
                end
            elseif Cache[p] then
                local c = Cache[p]
                c.Line.Visible = false
                c.Bill.Enabled = false
                c.LeftBill.Enabled = false
                c.RightBill.Enabled = false
                c.Text.Visible = true
            end
        end
    end)
    table_insert(State.Connections, conn)
end

return ESP
