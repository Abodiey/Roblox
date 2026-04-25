local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local ScreenGui = CoreGui:FindFirstChild("PlayerESP") or Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "PlayerESP"

local Cache = {}

-- Fixed Hex Helper
local function toHex(color)
    return string.format("%02x%02x%02x", color.R * 255, color.G * 255, color.B * 255)
end

-- Smooth Gradient (Red -> Yellow -> Green)
local function getGradientColor(percent)
    percent = math.clamp(percent, 0, 1)
    if percent > 0.5 then
        return Color3.new(1, 1, 0):Lerp(Color3.new(0, 1, 0), (percent - 0.5) * 2)
    end
    return Color3.new(1, 0, 0):Lerp(Color3.new(1, 1, 0), percent * 2)
end

local function formatVal(val)
    return val >= 1000 and string.format("%.1fk", val / 1000) or tostring(math.floor(val))
end

function ESP.Init(State)
    local conn = RunService.RenderStepped:Connect(function()
        if not State.Toggles.Esp then ScreenGui.Enabled = false return end
        ScreenGui.Enabled = true

        local cam = workspace.CurrentCamera
        local viewportSize = cam.ViewportSize
        -- STATIC START POINT: Bottom Middle of Screen
        local startPos = Vector2.new(viewportSize.X / 2, viewportSize.Y)

        -- Cleanup 
        for p, assets in pairs(Cache) do
            if not p or not p.Parent then
                assets.Line:Destroy()
                assets.Bill:Destroy()
                Cache[p] = nil
            end
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p == Players.LocalPlayer then continue end
            local char = p.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if root and hum then
                if not Cache[p] then
                    local l = Instance.new("Frame", ScreenGui)
                    l.BorderSizePixel = 0
                    
                    local b = Instance.new("BillboardGui", ScreenGui)
                    b.AlwaysOnTop = true
                    b.Size = UDim2.new(0, 250, 0, 50)
                    b.ExtentsOffset = Vector3.new(0, 4, 0)
                    
                    local t = Instance.new("TextLabel", b)
                    t.Size = UDim2.new(1, 0, 1, 0)
                    t.BackgroundTransparency = 1
                    t.TextColor3 = Color3.new(1, 1, 1)
                    t.RichText = true
                    t.Font = Enum.Font.RobotoMono
                    t.TextSize = 15
                    
                    local stroke = Instance.new("UIStroke", t)
                    stroke.Thickness = 0.5
                    stroke.Color = Color3.new(0, 0, 0)

                    Cache[p] = {Line = l, Bill = b, Text = t}
                end

                local c = Cache[p]
                local p2, vis2 = cam:WorldToViewportPoint(root.Position)
                local dist = (cam.CFrame.Position - root.Position).Magnitude

                if vis2 and p2.Z > 0 then
                    c.Line.Visible = true
                    c.Bill.Enabled = dist > 5 -- Hidden when very close
                    c.Bill.Adornee = root

                    -- 1. Accurate Tracer Calculation
                    local endPos = Vector2.new(p2.X, p2.Y)
                    local diff = endPos - startPos
                    
                    c.Line.BackgroundColor3 = getGradientColor(dist / 600)
                    c.Line.Size = UDim2.new(0, diff.Magnitude, 0, 1)
                    c.Line.Position = UDim2.new(0, (startPos.X + endPos.X) / 2, 0, (startPos.Y + endPos.Y) / 2)
                    c.Line.Rotation = math.deg(math.atan2(diff.Y, diff.X))

                    -- 2. Stats & Formatting
                    local kills = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Kills") and p.leaderstats.Kills.Value or 0
                    local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    
                    local kHex = toHex(getGradientColor(kills / 50))
                    local dHex = toHex(getGradientColor(dist / 1000))
                    local hHex = toHex(getGradientColor(hpPercent))

                    c.Text.Text = string.format(
                        "<b>%s</b> <font color='#%s'>[%s]</font> <font color='#%s'>%sm</font> <font color='#%s'>%d%%</font>",
                        p.Name, kHex, formatVal(kills), dHex, formatVal(dist), hHex, math.floor(hpPercent * 100)
                    )
                else
                    c.Line.Visible = false
                    c.Bill.Enabled = false
                end
            elseif Cache[p] then
                Cache[p].Line.Visible = false
                Cache[p].Bill.Enabled = false
            end
        end
    end)
    table.insert(State.Connections, conn)
end

return ESP
