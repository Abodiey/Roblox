local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Cleanup existing
local Existing = CoreGui:FindFirstChild("PlayerESP")
if Existing then Existing:Destroy() end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "PlayerESP"
ScreenGui.DisplayOrder = 10

local Cache = {}

local function CreatePlayerElements(player)
    local elements = {}
    
    -- Tracer Line
    local line = Instance.new("Frame")
    line.Thickness = 1 -- Internal reference for math
    line.BackgroundColor3 = Color3.new(1, 1, 1)
    line.BorderSizePixel = 0
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.Visible = false
    line.Parent = ScreenGui
    elements.Line = line
    
    -- Distance/Name Label
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.Size = UDim2.new(0, 100, 0, 20)
    label.Visible = false
    label.Parent = ScreenGui
    elements.Label = label
    
    return elements
end

function ESP.Init(State)
    local conn = RunService.RenderStepped:Connect(function()
        if not State.Toggles.Esp then 
            for _, entry in pairs(Cache) do
                entry.Line.Visible = false
                entry.Label.Visible = false
            end
            return 
        end

        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local id = player.UserId

            if root and myRoot then
                if not Cache[id] then
                    Cache[id] = CreatePlayerElements(player)
                end
                
                local elements = Cache[id]
                local p1, vis1 = Camera:WorldToViewportPoint(myRoot.Position)
                local p2, vis2 = Camera:WorldToViewportPoint(root.Position)

                -- Only show if target is in front of camera (Z > 0)
                if p2.Z > 0 then
                    elements.Line.Visible = true
                    elements.Label.Visible = true
                    
                    local startPos = Vector2.new(p1.X, p1.Y)
                    local endPos = Vector2.new(p2.X, p2.Y)
                    local diff = endPos - startPos
                    local dist = (myRoot.Position - root.Position).Magnitude

                    -- Update Line
                    elements.Line.Size = UDim2.new(0, diff.Magnitude, 0, 1) -- 1px thickness
                    elements.Line.Position = UDim2.new(0, (startPos.X + endPos.X) / 2, 0, (startPos.Y + endPos.Y) / 2)
                    elements.Line.Rotation = math.deg(math.atan2(diff.Y, diff.X))

                    -- Update Label
                    elements.Label.Text = string.format("%s\n[%.1f]", player.Name, dist)
                    elements.Label.Position = UDim2.new(0, p2.X, 0, p2.Y - 40)
                else
                    elements.Line.Visible = false
                    elements.Label.Visible = false
                end
            elseif Cache[id] then
                Cache[id].Line.Visible = false
                Cache[id].Label.Visible = false
            end
        end

        -- Clean up cache for players who left
        for id, elements in pairs(Cache) do
            if not Players:GetPlayerByUserId(id) then
                elements.Line:Destroy()
                elements.Label:Destroy()
                Cache[id] = nil
            end
        end
    end)

    table.insert(State.Connections, conn)
end

return ESP
