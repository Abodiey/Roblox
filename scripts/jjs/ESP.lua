local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "PlayerESP"

local Cache = {}

function ESP.Init(State)
    local conn = RunService.RenderStepped:Connect(function()
        if not State.Toggles.Esp then ScreenGui.Enabled = false return end
        ScreenGui.Enabled = true

        local cam = workspace.CurrentCamera
        local myRoot = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        for _, p in pairs(Players:GetPlayers()) do
            if p == Players.LocalPlayer then continue end
            
            local char = p.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")

            if root and head and myRoot then
                if not Cache[p] then
                    -- Create Line
                    local l = Instance.new("Frame", ScreenGui)
                    l.BorderSizePixel = 0
                    l.BackgroundColor3 = Color3.new(1, 1, 1)
                    l.AnchorPoint = Vector2.new(0.5, 0.5)
                    
                    -- Create Billboard (Above Head)
                    local b = Instance.new("BillboardGui", ScreenGui)
                    b.AlwaysOnTop = true
                    b.Size = UDim2.new(0, 100, 0, 30)
                    b.ExtentsOffset = Vector3.new(0, 3, 0)
                    
                    local t = Instance.new("TextLabel", b)
                    t.Size = UDim2.new(1, 0, 1, 0)
                    t.BackgroundTransparency = 1
                    t.TextColor3 = Color3.new(1, 1, 1)
                    t.TextStrokeTransparency = 0
                    
                    Cache[p] = {Line = l, Bill = b, Text = t}
                end

                local c = Cache[p]
                local p1, vis1 = cam:WorldToViewportPoint(myRoot.Position)
                local p2, vis2 = cam:WorldToViewportPoint(root.Position)
                
                if p2.Z > 0 then
                    c.Line.Visible = true
                    c.Bill.Enabled = true
                    c.Bill.Adornee = head
                    
                    -- Update Tracer
                    local startPos = Vector2.new(p1.X, p1.Y)
                    local endPos = Vector2.new(p2.X, p2.Y)
                    local diff = endPos - startPos
                    
                    c.Line.Size = UDim2.new(0, diff.Magnitude, 0, 2) -- Set Thickness here
                    c.Line.Position = UDim2.new(0, (startPos.X + endPos.X)/2, 0, (startPos.Y + endPos.Y)/2)
                    c.Line.Rotation = math.deg(math.atan2(diff.Y, diff.X))

                    -- Update Stats (Name + Kills)
                    local kills = p:FindFirstChild("leaderstats") and p.leaderstats:FindFirstChild("Kills") and p.leaderstats.Kills.Value or 0
                    c.Text.Text = string.format("%s | Kills: %d", p.DisplayName, kills)
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
