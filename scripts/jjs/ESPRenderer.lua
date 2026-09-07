local ESPRenderer = {}

local cloneReference = cloneref or function(object) return object end
local Players = cloneReference(game:GetService("Players"))
local ReplicatedStorage = cloneReference(game:GetService("ReplicatedStorage"))
local workspace = cloneReference(game:GetService("Workspace"))

local Color3 = Color3
local v3_new = Vector3.new
local m_clamp = math.clamp
local m_floor = math.floor
local m_abs = math.abs
local m_max = math.max
local s_format = string.format
local o_clock = os.clock
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
    local State = context.State
    local Assets = context.Assets
    local Tracking = context.Tracking
    local Cache = context.Cache
    local ActiveMarks = context.ActiveMarks
    local toggleObject = context.Toggle
    local CleanupCacheEntry = context.CleanupCacheEntry
    local lp = Players.LocalPlayer
    local FrameTick = 0

    local Bars = context.BarsModule.new(State, Assets, MOVESET_COLORS)
    local Moveset = context.MovesetModule.new(State, Assets, context.SpecialCooldowns)
    local PlayerInfo = context.PlayerInfoModule.new(State, Assets, ActiveMarks, MOVESET_COLORS, DARK_MOVESETS)
    local Tracers = context.TracersModule.new(State, Assets)

    local CreateAssets = Assets.Create
    local HideAllAssets = Assets.Hide
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


                    local frame = c.FrameData
                    if not frame then
                        frame = {}
                        c.FrameData = frame
                    end

                    frame.player = p
                    frame.char = char
                    frame.hum = hum
                    frame.root2D = root2D
                    frame.feet2D = feet2D
                    frame.dist = dist
                    frame.scaleFactor = scaleFactor
                    frame.boxX = boxX
                    frame.boxY = boxY
                    frame.boxWidth = boxWidth
                    frame.boxHeight = boxHeight
                    frame.hideNameAndHealth = hideNameAndHealth
                    frame.movesetName = movesetName
                    frame.movesetFolder = movesetFolder
                    frame.fullyCustom = fullyCustom
                    frame.isRyu = isRyu
                    frame.isHaruta = isHaruta
                    frame.isReggie = isReggie
                    frame.info = info
                    frame.overheatObj = overheatObj
                    frame.miraclesObj = miraclesObj
                    frame.nextReceiptObj = nextReceiptObj
                    frame.globalRainbowColor = globalRainbowColor
                    frame.globalRainbowHex = globalRainbowHex
                    frame.shouldUpdateHeavy = shouldUpdateHeavy
                    frame.isThrottledFrame = isThrottledFrame
                    frame.tracerStartX = sX
                    frame.tracerStartY = sY

                    Bars.Render(c, frame)
                    Moveset.Render(c, frame)
                    PlayerInfo.Render(c, frame)
                    Tracers.Render(c, frame)
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


