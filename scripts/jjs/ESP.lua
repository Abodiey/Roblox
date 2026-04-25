local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local ScreenGui = CoreGui:FindFirstChild("PlayerESP") or Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "PlayerESP"

local Cache = {}

-- Smooth Gradient Helper (Red -> Yellow -> Green)
local function getGradientColor(percent)
    percent = math.clamp(percent, 0, 1)
    local color = (percent > 0.5) 
        and Color3.new(1, 1, 0):Lerp(Color3.new(0, 1, 0), (percent - 0.5) * 2)
        or Color3.new(1, 0, 0):Lerp(Color3.new(1, 1, 0), percent * 2)
    return color:ToHex() -- Convert to Hex string immediately
end

local function formatVal(val)
    return val >= 1000 and string.format("%.1fk", val / 1000) or tostring(math.floor(val))
end

function ESP.Init(State)
    local conn = RunService.RenderStepped:Connect(function()
        if not State.Toggles.Esp then ScreenGui.Enabled = false return end
        ScreenGui.Enabled = true

        local cam = workspace.CurrentCamera
        local lp = Players.LocalPlayer
        local myChar = lp.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

        -- 1. STUCK TRACER FIX: Clear cache for gone/dead players
        for p, assets in pairs(Cache) do
            if not p or not p.Parent or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then
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
                    l.ZIndex = 1
                    
                    local b = Instance.new("BillboardGui", ScreenGui)
                    b.AlwaysOnTop = true
                    b.Size = UDim2.new(0, 300, 0, 50)
                    b.ExtentsOffset = Vector3.new(0, 4.5, 0)
                    
                    local t = Instance.new("TextLabel", b)
                    t.Size = UDim2.new(1, 0, 1, 0)
                    t.BackgroundTransparency = 1
                    t.TextColor3 = Color3.new(1, 1, 1)
                    t.RichText = true
                    t.Font = Enum.Font.RobotoMono
                    t.TextSize = 15
                    
                    local stroke = Instance.new("UIStroke", t)
                    stroke.Thickness = 0.6
                    stroke.Color = Color3.new(0, 0, 0)

                    Cache[p] = {Line = l, Bill = b, Text = t}
                end

                local c = Cache[p]
                local p1, _ = cam:WorldToViewportPoint(myRoot.Position)
                local p2, vis2 = cam:WorldToViewportPoint(root.Position)
                local dist = (myRoot.Position - root.Position).Magnitude

                if vis2 and p2.Z > 0 then
                    c.Line.Visible = true
                    -- USERNAME HIDDEN logic: Disable billboard if too close
                    c.Bill.Enabled = dist > 12 
                    c.Bill.Adornee = root

                    -- Tracer Logic (Thinner & Accurate)
                    local startPos = Vector2.new(p1.X, p1.Y)
                    local endPos = Vector2.new(p2.X, p2.Y)
                    local diff = endPos - startPos
                    
                    c.Line.BackgroundColor3 = Color3.fromHex(getGradientColor(dist / 600))
                    c.Line.Size = UDim2.new(0, diff.Magnitude, 0, 1) -- 1px Thinner
                    c.Line.Position = UDim2.new(0, (startPos.X + endPos.X)/2, 0, (startPos.Y + endPos.Y)/2)
                    c.Line.Rotation = math.deg(math.atan2(diff.Y, diff.X))

                    -- Stats Calculation
                    local kills = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Kills") and p.leaderstats.Kills.Value or 0
                    local hpPerc = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    
                    -- Formatted Text
                    local kCol = getGradientColor(kills / 40)
                    local dCol = getGradientColor(dist / 800)
                    local hCol = getGradientColor(hpPerc)

                    c.Text.Text = string.format(
                        "<b>%s</b> <font color='#%s'>[%s]</font> <font color='#%s'>%sm</font> <font color='#%s'>%d%%</font>",
                        p.Name, kCol, formatVal(kills), dCol, formatVal(dist), hCol, math.floor(hpPerc * 100)
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
