local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local ScreenGui = CoreGui:FindFirstChild("PlayerESP") 
if ScreenGui then ScreenGui:Destroy() end
ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "PlayerESP"

local Cache = {}

-- Smooth Gradient Helper (Green -> Yellow -> Red)
local function getGradientColor(percent)
    percent = math.clamp(percent, 0, 1)
    if percent > 0.5 then
        return Color3.new(1, 1, 0):Lerp(Color3.new(0, 1, 0), (percent - 0.5) * 2)
    end
    return Color3.new(1, 0, 0):Lerp(Color3.new(1, 1, 0), percent * 2)
end

-- Format numbers (e.g., 2200 -> 2.2k)
local function formatVal(val)
    return val >= 1000 and string.format("%.1fk", val / 1000) or tostring(val)
end

function ESP.Init(State)
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not ScreenGui or not ScreenGui.Parent then conn:Disconnect() return end
        if not State.Toggles.Esp then ScreenGui.Enabled = false return end
        ScreenGui.Enabled = true

        local cam = workspace.CurrentCamera
        local lp = Players.LocalPlayer
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

        -- Cleanup stuck tracers for players who left
        for p, assets in pairs(Cache) do
            if not p or not p.Parent then
                assets.Line:Destroy()
                assets.Bill:Destroy()
                Cache[p] = nil
            end
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p == lp then continue end
            local char = p.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if root and hum and myRoot then
                if not Cache[p] then
                    local l = Instance.new("Frame", ScreenGui)
                    l.BorderSizePixel = 0
                    
                    local b = Instance.new("BillboardGui", ScreenGui)
                    b.AlwaysOnTop = true
                    b.Size = UDim2.new(0, 250, 0, 50)
                    b.ExtentsOffset = Vector3.new(0, 4, 0) -- Moved text higher up
                    
                    local t = Instance.new("TextLabel", b)
                    t.Size = UDim2.new(1, 0, 1, 0)
                    t.BackgroundTransparency = 1
                    t.TextColor3 = Color3.new(1, 1, 1)
                    t.RichText = true -- Essential for color coding parts of text
                    t.Font = Enum.Font.RobotoMono -- Clean mono font
                    t.TextSize = 16
                    
                    local stroke = Instance.new("UIStroke", t)
                    stroke.Thickness = 0.5 -- Smallest black border
                    stroke.Color = Color3.new(0, 0, 0)

                    Cache[p] = {Line = l, Bill = b, Text = t}
                end

                local c = Cache[p]
                local p1, _ = cam:WorldToViewportPoint(myRoot.Position)
                local p2, vis2 = cam:WorldToViewportPoint(root.Position)
                local dist = (myRoot.Position - root.Position).Magnitude

                -- Visibility Logic
                if vis2 and p2.Z > 0 then
                    c.Line.Visible = true
                    -- Hide text if closer than 10 studs
                    c.Bill.Enabled = dist > 10 
                    c.Bill.Adornee = root

                    -- 1. Accurate Tracer Logic
                    local startPos = Vector2.new(p1.X, p1.Y)
                    local endPos = Vector2.new(p2.X, p2.Y)
                    local diff = endPos - startPos
                    
                    -- Color tracer based on distance (Red = Near, Green = Far)
                    local lineCol = getGradientColor(dist / 500)
                    c.Line.BackgroundColor3 = lineCol
                    c.Line.Size = UDim2.new(0, diff.Magnitude, 0, 1) -- Thinner line
                    c.Line.Position = UDim2.new(0, (startPos.X + endPos.X)/2, 0, (startPos.Y + endPos.Y)/2)
                    c.Line.Rotation = math.deg(math.atan2(diff.Y, diff.X))

                    -- 2. Format Stats
                    local kills = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Kills") and p.leaderstats.Kills.Value or 0
                    local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    
                    -- Color Codes
                    local killHex = getGradientColor(kills / 50).ToHex()
                    local distHex = getGradientColor(dist / 1000).ToHex()
                    local hpHex   = getGradientColor(hpPercent).ToHex()

                    -- Format: USERNAME [224] 130m 50%
                    c.Text.Text = string.format(
                        "<b>%s</b> <font color='#%s'>[%s]</font> <font color='#%s'>%sm</font> <font color='#%s'>%d%%</font>",
                        p.Name, -- Username
                        killHex, formatVal(kills),
                        distHex, formatVal(math.floor(dist)),
                        hpHex, math.floor(hpPercent * 100)
                    )
                else
                    c.Line.Visible = false
                    c.Bill.Enabled = false
                end
            elseif Cache[p] then
                -- Hide assets if character is missing/respawning
                Cache[p].Line.Visible = false
                Cache[p].Bill.Enabled = false
            end
        end
    end)
    table.insert(State.Connections, conn)
end

return ESP
