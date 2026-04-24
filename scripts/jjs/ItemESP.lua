local ESP = {}
local ExistingFolder = game.CoreGui:FindFirstChild("ItemESP")

if ExistingFolder then
    ExistingFolder:Destroy()
end

local Folder = Instance.new("Folder", game.CoreGui)
Folder.Name = "ItemESP"

local Cache = {}

local function CreateESP(item, part)
    local bg = Instance.new("BillboardGui")
    bg.Name = item:GetDebugId()
    bg.Adornee = part
    bg.Size = UDim2.new(0, 100, 0, 20)
    bg.AlwaysOnTop = true
    bg.Parent = Folder

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = item.Name
    l.TextColor3 = Color3.new(0, 1, 1)
    l.TextStrokeTransparency = 0
    l.TextStrokeColor3 = Color3.new(0, 0, 0)
    l.TextSize = 14
    l.Parent = bg

    return bg
end

function ESP.Init(State)
    local conn = game:GetService("RunService").Heartbeat:Connect(function()
        if not State.Toggles.ItemEsp then 
            Folder:ClearAllChildren()
            Cache = {}
            return 
        end
        
        local itemsFolder = workspace:FindFirstChild("Items")
        if not itemsFolder then return end

        local currentItems = itemsFolder:GetChildren()
        local activeIds = {}

        for _, item in pairs(currentItems) do
            local id = item:GetDebugId()
            activeIds[id] = true
            
            if not Cache[id] then
                local part = item:IsA("BasePart") and item or item:FindFirstChildOfClass("BasePart")
                if part then
                    Cache[id] = CreateESP(item, part)
                end
            end
        end

        for id, gui in pairs(Cache) do
            if not activeIds[id] then
                gui:Destroy()
                Cache[id] = nil
            end
        end
    end)
    
    table.insert(State.Connections, conn)
end

return ESP
