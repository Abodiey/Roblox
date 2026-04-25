local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "PlayerESP"

local Cache = {}

-- Distance-based color coding
local function GetDistanceColor(dist)
    if dist < 50 then return Color3.fromRGB(255, 0, 0)      -- Red (Very Close)
    elseif dist < 150 then return Color3.fromRGB(255, 165, 0) -- Orange (Close)
    elseif dist < 300 then return Color3.fromRGB(255, 255, 0) -- Yellow (Medium)
    else return Color3.fromRGB(0, 255, 0)                  -- Green (Far)
    end
end

function ESP.Init(State)
    local conn = RunService.RenderStepped:Connect(function()
        if not State.Toggles.Esp then 
            ScreenGui.Enabled = false 
            return 
        end
        ScreenGui.Enabled = true

        local cam = workspace.CurrentCamera
        local lp = Players.LocalPlayer
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

        -- Cleanup players who left or died (fixes "stuck" lines)
        for player, folder in pairs(Cache) do
            if not player.Parent or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                folder.Line:Destroy()
                folder.Bill:Destroy()
                Cache[player] = nil
            end
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p == lp then continue end
            
            local char = p.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")

            if root and head and myRoot then
                if not Cache[p] then
                    local l = Instance.new("Frame", ScreenGui)
                    l.BorderSizePixel = 0
                    l.AnchorPoint = Vector2.new(0.5, 0.5)
                    
                    local b = Instance.new("BillboardGui", ScreenGui)
                    b.AlwaysOnTop = true
                    b.Size = UDim2.new(0, 200, 0, 50)
                    b.ExtentsOffset = Vector3.new(0, 4, 0) -- Higher position
                    
                    local t = Instance.new("TextLabel", b)
                    t.Size = UDim2.new(1, 0, 1, 0)
                    t.BackgroundTransparency = 1
                    t.TextColor3 = Color3.new(1, 1, 1)
                    t.TextStrokeTransparency = 0
                    t.Font = Enum.Font.RobotoMono -- Clean bold-ish font
                    t.RichText = true -- Allows for <b> tag
                    
                    Cache[p] = {Line = l, Bill = b, Text = t}
                end

                local c = Cache[p]
                local p1, vis1 = cam:WorldToViewportPoint(myRoot.Position)
                local p2, vis2 = cam:WorldToViewportPoint(root.Position)
                
                if p2.Z > 0 then
                    local dist = (myRoot.Position - root.Position).Magnitude
                    local color = GetDistanceColor(dist)
                    
                    -- 1. Accurate Thin Tracer
                    c.Line.Visible = true
                    local startPos = Vector2.new(p1.X, p1.Y)
                    local endPos = Vector2.new(p2.X, p2.Y)
                    local diff = endPos - startPos
                    
                    c.Line.BackgroundColor3 = color
                    c.Line.Size = UDim2.new(0, diff.Magnitude, 0, 1) -- Thinner (1px)
                    c.Line.Position = UDim2.new(0, (startPos.X + endPos.X)/2, 0, (startPos.Y + endPos.Y)/2)
                    c.Line.Rotation = math.deg(math.atan2(diff.Y, diff.X))

                    -- 2. Stats & Text Logic
                    c.Bill.Enabled = true
                    c.Bill.Adornee = head
                    
                    local stats = p:FindFirstChild("leaderstats")
                    local kills = stats and stats:FindFirstChild("Kills") and stats.Kills.Value or 0
                    
                    -- Username only if distance > 50 studs
                    local nameDisplay = (dist > 50) and p.Name or ""
                    local text = string.format("<b>%s [%d]</b>\n%dm", nameDisplay, kills, math.floor(dist))
                    
                    c.Text.Text = text
                    c.Text.TextColor3 = color
                else
                    c.Line.Visible = false
                    c.Bill.Enabled = false
                end
            end
        end
    end)
    table.insert(State.Connections, conn)
end

return ESP
