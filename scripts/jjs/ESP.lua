local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- 1. Destroy previous ScreenGui if it exists
local Existing = CoreGui:FindFirstChild("PlayerESP")
if Existing then Existing:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "PlayerESP"
ScreenGui.IgnoreGuiInset = true -- 3. Ignore Gui Inset for perfect alignment

local Cache = {}

local function toHex(color)
    return string.format("%02x%02x%02x", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
end

local function getGradientColor(percent)
    percent = math.clamp(percent, 0, 1)
    if percent > 0.5 then
        return Color3.new(1, 1, 0):Lerp(Color3.new(0, 1, 0), (percent - 0.5) * 2)
    end
    return Color3.new(1, 0, 0):Lerp(Color3.new(1, 1, 0), percent * 2)
end

local function formatVal(val)
    return val >= 1000 and string.format("%.1fk", val / 1000) or tostring(val)
end

local function CreateAssets(p)
    local assets = {}
    
    -- Tracer
    assets.Line = Instance.new("Frame", ScreenGui)
    assets.Line.BorderSizePixel = 0
    assets.Line.AnchorPoint = Vector2.new(0.5, 0.5)
    
    -- Main Info (Billboard)
    assets.Bill = Instance.new("BillboardGui", ScreenGui)
    assets.Bill.AlwaysOnTop = true
    assets.Bill.Size = UDim2.new(0, 250, 0, 50)
    assets.Bill.ExtentsOffset = Vector3.new(0, 3.5, 0)
    
    assets.Text = Instance.new("TextLabel", assets.Bill)
    assets.Text.Size = UDim2.new(1, 0, 1, 0)
    assets.Text.BackgroundTransparency = 1
    assets.Text.TextColor3 = Color3.new(1, 1, 1)
    assets.Text.RichText = true
    assets.Text.Font = Enum.Font.RobotoMono
    assets.Text.TextSize = 15
    Instance.new("UIStroke", assets.Text).Thickness = 0.5
    
    -- 4. Health Bar (Billboard)
    assets.HealthBill = Instance.new("BillboardGui", ScreenGui)
    assets.HealthBill.AlwaysOnTop = true
    assets.HealthBill.Size = UDim2.new(0, 4, 0, 40)
    assets.HealthBill.ExtentsOffset = Vector3.new(-2.5, 0, 0) -- Positioned to the side
    
    assets.HealthBack = Instance.new("Frame", assets.HealthBill)
    assets.HealthBack.Size = UDim2.new(1, 0, 1, 0)
    assets.HealthBack.BackgroundColor3 = Color3.new(0, 0, 0)
    assets.HealthBack.BorderSizePixel = 0
    
    assets.HealthFill = Instance.new("Frame", assets.HealthBack)
    assets.HealthFill.Size = UDim2.new(1, 0, 1, 0)
    assets.HealthFill.AnchorPoint = Vector2.new(0, 1)
    assets.HealthFill.Position = UDim2.new(0, 0, 1, 0)
    assets.HealthFill.BorderSizePixel = 0
    
    return assets
end

function ESP.Init(State)
    local conn = RunService.RenderStepped:Connect(function()
        if not State.Toggles.Esp then ScreenGui.Enabled = false return end
        ScreenGui.Enabled = true

        local cam = workspace.CurrentCamera
        local lp = Players.LocalPlayer
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

        for p, assets in pairs(Cache) do
            if not p or not p.Parent or not p.Character then
                assets.Line:Destroy()
                assets.Bill:Destroy()
                assets.HealthBill:Destroy()
                Cache[p] = nil
            end
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p == lp then continue end
            local char = p.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")

            if root and hum and myRoot then
                if not Cache[p] then Cache[p] = CreateAssets(p) end
                local c = Cache[p]
                
                local p1, _ = cam:WorldToViewportPoint(myRoot.Position)
                local p2, vis2 = cam:WorldToViewportPoint(root.Position)
                local dist = (myRoot.Position - root.Position).Magnitude

                if vis2 and p2.Z > 0 then
                    c.Line.Visible = true
                    c.Bill.Enabled = true
                    c.HealthBill.Enabled = true
                    c.Bill.Adornee = root
                    c.HealthBill.Adornee = root

                    -- Tracer
                    local startVec = Vector2.new(p1.X, p1.Y)
                    local endVec = Vector2.new(p2.X, p2.Y)
                    local diff = endVec - startVec
                    c.Line.BackgroundColor3 = getGradientColor(dist / 600)
                    c.Line.Size = UDim2.new(0, diff.Magnitude, 0, 1)
                    c.Line.Position = UDim2.new(0, (startVec.X + endVec.X) / 2, 0, (startVec.Y + endVec.Y) / 2)
                    c.Line.Rotation = math.deg(math.atan2(diff.Y, diff.X))

                    -- Stats & 2. Username Hide Logic
                    local kills = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Kills") and p.leaderstats.Kills.Value or 0
                    local hpPerc = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    
                    local nameDisplay = (dist < 50) and "" or "<b>" .. p.Name .. "</b> "
                    local killCol = getGradientColor(1 - (kills / 50))
                    local distCol = getGradientColor(dist / 800)

                    c.Text.Text = string.format(
                        "%s<font color='#%s'>[%s]</font> <font color='#%s'>%sm</font>",
                        nameDisplay,
                        toHex(killCol), formatVal(kills),
                        toHex(distCol), formatVal(math.floor(dist))
                    )

                    -- 4. Health Bar Update
                    c.HealthFill.Size = UDim2.new(1, 0, hpPerc, 0)
                    c.HealthFill.BackgroundColor3 = getGradientColor(hpPerc)
                else
                    c.Line.Visible = false
                    c.Bill.Enabled = false
                    c.HealthBill.Enabled = false
                end
            elseif Cache[p] then
                Cache[p].Line.Visible = false
                Cache[p].Bill.Enabled = false
                Cache[p].HealthBill.Enabled = false
            end
        end
    end)
    table.insert(State.Connections, conn)
end

return ESP
