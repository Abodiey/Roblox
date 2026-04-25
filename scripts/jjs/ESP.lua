local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local ScreenGui = CoreGui:FindFirstChild("PlayerESP") or Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "PlayerESP"

local Cache = {}

-- Distance-based Color Config for Tracers
local function getTracerColor(dist)
    if dist < 50 then return Color3.fromRGB(255, 0, 0)      -- Red (Close)
    elseif dist < 150 then return Color3.fromRGB(255, 165, 0) -- Orange
    elseif dist < 300 then return Color3.fromRGB(255, 255, 0) -- Yellow
    else return Color3.fromRGB(0, 255, 0)                   -- Green (Far)
end

function ESP.Init(State)
    local conn = RunService.RenderStepped:Connect(function()
        if not State.Toggles.Esp then 
            for _, c in pairs(Cache) do c.Line.Visible = false c.Bill.Enabled = false end
            return 
        end

        local cam = workspace.CurrentCamera
        local myChar = Players.LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

        for _, p in pairs(Players:GetPlayers()) do
            if p == Players.LocalPlayer then continue end
            
            local char = p.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if root and hum and myRoot then
                if not Cache[p] then
                    -- Tracer Line
                    local l = Instance.new("Frame", ScreenGui)
                    l.BorderSizePixel = 0
                    l.AnchorPoint = Vector2.new(0.5, 0.5)
                    
                    -- Billboard (Above Head)
                    local b = Instance.new("BillboardGui", ScreenGui)
                    b.AlwaysOnTop = true
                    b.Size = UDim2.new(0, 200, 0, 50)
                    b.ExtentsOffset = Vector3.new(0, 4, 0) -- Higher position
                    
                    local t = Instance.new("TextLabel", b)
                    t.Size = UDim2.new(1, 0, 1, 0)
                    t.BackgroundTransparency = 1
                    t.TextColor3 = Color3.new(1, 1, 1)
                    t.TextStrokeTransparency = 0 -- Smallest black border
                    t.RichText = true -- Allows bold tags
                    t.Font = Enum.Font.RobotoMono -- Bolder look
                    t.TextSize = 16
                    
                    Cache[p] = {Line = l, Bill = b, Text = t}
                end

                local c = Cache[p]
                local p1, vis1 = cam:WorldToViewportPoint(myRoot.Position)
                local p2, vis2 = cam:WorldToViewportPoint(root.Position)
                local dist = (myRoot.Position - root.Position).Magnitude

                if p2.Z > 0 then
                    -- 1. Update Tracer (Accurate + Thin + Color Coded)
                    c.Line.Visible = true
                    local diff = Vector2.new(p2.X, p2.Y) - Vector2.new(p1.X, p1.Y)
                    c.Line.Size = UDim2.new(0, diff.Magnitude, 0, 1) -- Thinner
                    c.Line.Position = UDim2.new(0, (p1.X + p2.X)/2, 0, (p1.Y + p2.Y)/2)
                    c.Line.Rotation = math.deg(math.atan2(diff.Y, diff.X))
                    c.Line.BackgroundColor3 = getTracerColor(dist)

                    -- 2. Update Stats
                    c.Bill.Enabled = true
                    c.Bill.Adornee = root
                    
                    local kills = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Kills") and p.leaderstats.Kills.Value or 0
                    local hpPercent = math.floor((hum.Health / hum.MaxHealth) * 100)
                    local hpColor = hpPercent < 20 and "rgb(255,0,0)" or "rgb(255,255,255)"
                    
                    -- Conditional Display: Username only if far (e.g., > 60 studs)
                    if dist > 60 then
                        c.Text.Text = string.format("<b>%s</b>\n[%d] %dm <font color='%s'>%d%%</font>", p.Name, kills, math.floor(dist), hpColor, hpPercent)
                    else
                        c.Text.Text = string.format("[%d] %dm <font color='%s'>%d%%</font>", kills, math.floor(dist), hpColor, hpPercent)
                    end
                else
                    c.Line.Visible = false
                    c.Bill.Enabled = false
                end
            elseif Cache[p] then
                -- Cleanup if character is missing/respawning
                Cache[p].Line.Visible = false
                Cache[p].Bill.Enabled = false
            end
        end

        -- Final cleanup for players who left
        for p, assets in pairs(Cache) do
            if not p or not p.Parent then
                assets.Line:Destroy()
                assets.Bill:Destroy()
                Cache[p] = nil
            end
        end
    end)
    table.insert(State.Connections, conn)
end

return ESP
