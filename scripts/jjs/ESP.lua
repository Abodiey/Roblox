local ESP = {}
local Folder = Instance.new("Folder", game.CoreGui)
Folder.Name = "RayfieldItemESP"

function ESP.Init(State)
    local conn = game:GetService("RunService").Heartbeat:Connect(function()
        if not State.Toggles.ItemEsp then Folder:ClearAllChildren(); return end
        if tick() % 2 > 0.1 then return end
        
        Folder:ClearAllChildren()
        local items = workspace:FindFirstChild("Items")
        if items then
            for _, item in pairs(items:GetChildren()) do
                local part = item:IsA("BasePart") and item or item:FindFirstChildOfClass("BasePart")
                if part then
                    local bg = Instance.new("BillboardGui", Folder)
                    bg.Adornee, bg.Size, bg.AlwaysOnTop = part, UDim2.new(0, 100, 0, 20), true
                    local l = Instance.new("TextLabel", bg)
                    l.Size, l.BackgroundTransparency, l.Text, l.TextColor3 = UDim2.new(1,0,1,0), 1, item.Name, Color3.new(0, 1, 1)
                end
            end
        end
    end)
    table.insert(State.Connections, conn)
end

return ESP
