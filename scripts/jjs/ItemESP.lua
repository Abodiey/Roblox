local ItemESP = {}

-- Localize Services & Core API
local cloneref = cloneref
local game = game
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
local string = string
local s_format = string.format

-- Localize Roblox Datatypes
local Vector3 = Vector3
local v3_new = Vector3.new
local UDim2 = UDim2
local ud2_new = UDim2.new
local Color3 = Color3
local c3_new = Color3.new
local Enum = Enum

-- Clean previous asset hierarchy
while CoreGui:FindFirstChild("ItemESP") do
    CoreGui.ItemESP:Destroy()
    t_wait()
end

local ScreenGui = inst_new("ScreenGui")
ScreenGui.Name = "ItemESP"
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui

local Cache = {}
local itemsFolder = workspace:WaitForChild("Items")

-- Connection trackers
local loopConn = nil

-- Design Palette Constants matching PlayerESP
local COLOR_WHITE = c3_new(1, 1, 1)
local COLOR_BLACK = c3_new(0, 0, 0)
local COLOR_CYAN = c3_new(0, 0.8, 1)
local COLOR_YELLOW = c3_new(1, 1, 0)
local COLOR_RED = c3_new(1, 0.1, 0.1)

local function getGradientColor(percent)
    percent = m_clamp(percent, 0, 1)
    if percent > 0.5 then
        return COLOR_YELLOW:Lerp(COLOR_CYAN, (percent - 0.5) * 2)
    end
    return COLOR_RED:Lerp(COLOR_YELLOW, percent * 2)
end

local function CreateESP(item, part)
    local assets = {}

    local bill = inst_new("BillboardGui")
    bill.AlwaysOnTop = true
    bill.Size = ud2_new(0, 150, 0, 24)
    bill.ExtentsOffset = v3_new(0, 0.5, 0)
    bill.Adornee = part
    bill.Parent = ScreenGui
    assets.Bill = bill

    local txt = inst_new("TextLabel")
    txt.Size = ud2_new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = COLOR_CYAN
    txt.RichText = true
    txt.Font = Enum.Font.RobotoMono
    txt.TextSize = 11
    txt.Parent = bill
    assets.Text = txt

    local stroke = inst_new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = COLOR_BLACK
    stroke.Parent = txt
    assets.Stroke = stroke

    return assets
end

function ItemESP.Init(State)
    local toggleObject = State.Toggles.ItemESP

    local function handleToggleChange()
        local isEnabled = toggleObject.Value
        ScreenGui.Enabled = isEnabled

        if isEnabled then
            -- Connect the loop only when enabled
            if not loopConn then
                loopConn = RunService.Heartbeat:Connect(function()
                    if not itemsFolder then return end

                    local cam = workspace.CurrentCamera
                    local camPos = cam and cam.CFrame.Position
                    local currentItems = itemsFolder:GetChildren()
                    local activeIds = {}
                    
                    -- Stacking lookup tracker using simple string keys to prevent engine-level table reference bugs
                    local positionCounts = {}

                    for i = 1, #currentItems do
                        local item = currentItems[i]
                        local id = item:GetDebugId()
                        activeIds[id] = true

                        local c = Cache[id]
                        local part = item:IsA("BasePart") and item or item:FindFirstChildOfClass("BasePart")

                        if part then
                            if not c then
                                c = CreateESP(item, part)
                                Cache[id] = c
                            end

                            c.Bill.Enabled = true
                            
                            -- Generate a rounded string coordinate hash (snaps positions within a 2-stud boundary)
                            local pos = part.Position
                            local posKey = s_format("%d_%d_%d", m_floor(pos.X * 0.5), m_floor(pos.Y * 0.5), m_floor(pos.Z * 0.5))
                            
                            local stackIndex = positionCounts[posKey] or 0
                            positionCounts[posKey] = stackIndex + 1

                            -- Vertically stagger Billboard positions dynamically based on current overlaps
                            c.Bill.ExtentsOffset = v3_new(0, 0.5 + (stackIndex * 1.5), 0)
                            
                            local dist = camPos and (part.Position - camPos).Magnitude or 0
                            local distCol = getGradientColor(dist / 400)
                            local hexDistColor = s_format("%02x%02x%02x", m_floor(distCol.R * 255), m_floor(distCol.G * 255), m_floor(distCol.B * 255))

                            c.Text.Text = s_format("<b>%s</b>\n<font color='#%s'>%sm</font>", item.Name, hexDistColor, tostring(m_floor(dist)))
                        elseif c then
                            c.Bill.Enabled = false
                        end
                    end

                    for id, assets in pairs(Cache) do
                        if not activeIds[id] then
                            if assets.Bill then assets.Bill:Destroy() end
                            Cache[id] = nil
                        end
                    end
                end)
            end
        else
            -- Disconnect the loop completely when disabled
            if loopConn then
                loopConn:Disconnect()
                loopConn = nil
            end
            
            -- Clear assets from memory and UI
            for id, assets in pairs(Cache) do
                if assets.Bill then assets.Bill:Destroy() end
            end
            table_clear(Cache)
        end
    end

    local toggleConn = toggleObject:GetPropertyChangedSignal("Value"):Connect(handleToggleChange)
    table_insert(State.Connections, toggleConn)

    handleToggleChange()
end

return ItemESP
