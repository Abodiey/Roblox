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
    
    -- Tracer Frame
    local line = inst_new("Frame")
    line.BorderSizePixel = 0
    line.AnchorPoint = v2_new(0.5, 0.5)
    line.Parent = ScreenGui
    assets.Line = line
    
    -- Main Text Element Layout
    local bill = inst_new("BillboardGui")
    bill.AlwaysOnTop = true
    bill.Size = ud2_new(0, 250, 0, 65)
    bill.ExtentsOffset = v3_new(0, 3.5, 0)
    bill.Parent = ScreenGui
    assets.Bill = bill
    
    local txt = inst_new("TextLabel")
    txt.Size = ud2_new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = COLOR_WHITE
    txt.RichText = true
    txt.Font = Enum.Font.RobotoMono
    txt.TextSize = 15
    txt.Parent = bill
    assets.Text = txt
    
    local stroke = inst_new("UIStroke")
    stroke.Thickness = 0.5
    stroke.Color = COLOR_BLACK
    stroke.Parent = txt
    assets.Stroke = stroke
    
    -- Health Bar Element Layout
    local hBill = inst_new("BillboardGui")
    hBill.AlwaysOnTop = true
    hBill.Size = ud2_new(0, 4, 0, 40)
    hBill.ExtentsOffset = v3_new(-2.5, 0, 0)
    hBill.Parent = ScreenGui
    assets.HealthBill = hBill
    
    local hBack = inst_new("Frame")
    hBack.Size = ud2_new(1, 0, 1, 0)
    hBack.BackgroundColor3 = COLOR_BLACK
    hBack.BorderSizePixel = 0
    hBack.Parent = hBill
    
    local hFill = inst_new("Frame")
    hFill.Size = ud2_new(1, 0, 1, 0)
    hFill.AnchorPoint = v2_new(0, 1)
    hFill.Position = ud2_new(0, 0, 1, 0)
    hFill.BorderSizePixel = 0
    hFill.Parent = hBack
    assets.HealthFill = hFill
    
    -- Connection trackers
    assets.Connections = {}
    assets.CharacterConnections = {} 
    
    -- Dynamic variable caching
    assets.LastDist = 0
    assets.CachedKills = 0
    assets.CachedMoveset = ""
    assets.NameDisplay = ""
    assets.UltDisplay = ""
    assets.LineColor = COLOR_GREEN
    assets.HexKillColor = "ffffff"
    assets.HexDistColor = "ffffff"
    
    return assets
end

local function CleanupCacheEntry(p, assets)
    for _, conn in ipairs(assets.Connections) do conn:Disconnect() end
    for _, conn in ipairs(assets.CharacterConnections) do conn:Disconnect() end
    if assets.Line then assets.Line:Destroy() end
    if assets.Bill then assets.Bill:Destroy() end
    if assets.HealthBill then assets.HealthBill:Destroy() end
    Cache[p] = nil
end

local function SetupPlayerSignals(p, assets)
    local function watchKills(leaderstats)
        local killsVal = leaderstats:FindFirstChild("Kills")
        if killsVal then
            local function updateKills()
                assets.CachedKills = killsVal.Value
                local killCol = getGradientColor(1 - (assets.CachedKills / 1000))
                assets.HexKillColor = s_format("%02x%02x%02x", m_floor(killCol.R * 255), m_floor(killCol.G * 255), m_floor(killCol.B * 255))
            end
            table_insert(assets.Connections, killsVal:GetPropertyChangedSignal("Value"):Connect(updateKills))
            updateKills()
        end
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
                    c.HealthBill.Enabled = true
                    c.Text.Visible = true
                    c.HealthFill.Visible = true
                    c.Bill.Adornee = root
                    c.HealthBill.Adornee = root

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
                        
                        -- Attribute Checks: InUlt, Dead, Evade
                        local isDead = char:GetAttribute("Dead")
                        local inUlt = char:GetAttribute("InUlt")
                        local evadeValue = char:GetAttribute("Evade")
                        
                        -- Ult Text Handler
                        c.UltDisplay = inUlt and "<b><font color='#FF007F'>[Ult]</font></b>\n" or ""
                        
                        -- Name Formatting with Dead color fallback
                        if isDead then
                            c.NameDisplay = "<b><font color='#FF0000'>" .. p.Name .. "</font></b> "
                        else
                            c.NameDisplay = (dist < 50) and "" or "<b>" .. p.Name .. "</b> "
                        end
                        
                        local distCol = getGradientColor(dist / 800)
                        c.HexDistColor = s_format("%02x%02x%02x", m_floor(distCol.R * 255), m_floor(distCol.G * 255), m_floor(distCol.B * 255))
                        c.LineColor = getGradientColor(dist / 600)
                        
                        -- Evade tag configuration ([EV] in hot magenta side-by-side with moveset name)
                        local evadeTag = (evadeValue == 50) and " <font color='#FF00FF'>[EV]</font>" or ""
                        
                        -- Moveset attribute verification
                        local movesetAttr = char:GetAttribute("Moveset")
                        if movesetAttr and movesetAttr ~= "" then
                            local movesetInstance = char:FindFirstChild("Moveset")
                            if movesetInstance and movesetInstance:FindFirstChild("Custom") then 
                                movesetAttr = "Custom" 
                            end
                            
                            local hexColor = MOVESET_COLORS[movesetAttr] or "FFFFFF"
                            
                            -- Isolated stroke tagging based on background brightness requirements
                            if DARK_MOVESETS[movesetAttr] then
                                c.CachedMoveset = s_format("<b><stroke color='#FFFFFF' thickness='1'><font color='#%s'>%s</font></stroke>%s</b>\n", hexColor, tostring(movesetAttr), evadeTag)
                            else
                                c.CachedMoveset = s_format("<b><font color='#%s'>%s</font>%s</b>\n", hexColor, tostring(movesetAttr), evadeTag)
                            end
                        else
                            -- Show standalone [EV] next to a blank space if character has no current moveset
                            c.CachedMoveset = (evadeTag ~= "") and "<b>" .. evadeTag .. "</b>\n" or ""
                        end
                    end
                    
                    local currentDist = c.LastDist

                    -- 2D Line Line Calculations
                    local eX, eY = p2.X, p2.Y
                    local diffX, diffY = eX - sX, eY - sY
                    local mag = (diffX * diffX + diffY * diffY) ^ 0.5
                    
                    c.Line.BackgroundColor3 = c.LineColor
                    c.Line.Size = ud2_new(0, mag, 0, 1)
                    c.Line.Position = ud2_new(0, (sX + eX) * 0.5, 0, (sY + eY) * 0.5)
                    c.Line.Rotation = m_deg(m_atan2(diffY, diffX))

                    -- Output structured data block string formatting
                    c.Text.Text = s_format("%s%s%s<font color='#%s'>[%s]</font> <font color='#%s'>%sm</font>", 
                        c.UltDisplay, 
                        c.CachedMoveset, 
                        c.NameDisplay, 
                        c.HexKillColor, 
                        formatVal(c.CachedKills), 
                        c.HexDistColor, 
                        tostring(m_floor(currentDist))
                    )
                else
                    c.Line.Visible = false
                    c.Bill.Enabled = false
                    c.HealthBill.Enabled = false
                    c.Text.Visible = false
                    c.HealthFill.Visible = false
                end
            elseif Cache[p] then
                local c = Cache[p]
                c.Line.Visible = false
                c.Bill.Enabled = false
                c.HealthBill.Enabled = false
                c.HealthFill.Visible = false
                c.Text.Visible = true
            end
        end
    end)
    table_insert(State.Connections, conn)
end

return ESP
