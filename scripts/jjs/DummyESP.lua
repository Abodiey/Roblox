local DummyESP = {}
local Characters = workspace:WaitForChild("Characters")
local CoreGui = cloneref(game:GetService("CoreGui"))

local BBQ = CoreGui:FindFirstChild("DummyHighlightESP")
if BBQ then
    BBQ:Destroy()
end

BBQ = Instance.new("BillboardGui", CoreGui)
BBQ.Name = "DummyHighlightESP"
BBQ.Size = UDim2.new(4, 0, 6, 0)
BBQ.AlwaysOnTop = true
BBQ.ResetOnSpawn = false

local strokeFrame = Instance.new("Frame", BBQ)
strokeFrame.Size = UDim2.new(1, 0, 1, 0)
strokeFrame.BackgroundTransparency = 1

local uiStroke = Instance.new("UIStroke", strokeFrame)
uiStroke.Color = Color3.fromRGB(255, 0, 0)
uiStroke.Thickness = 2

-- Persistent tracking references
local ChildAddedConn = nil
local ChildRemovedConn = nil
local DummyDestroyedConn = nil

-- Helper to safely disconnect and pull from State.Connections
local function cleanupConnection(conn, connectionsTable)
    if conn then
        conn:Disconnect()
        if connectionsTable then
            local index = table.find(connectionsTable, conn)
            if index then
                table.remove(connectionsTable, index)
            end
        end
    end
    return nil
end

-- Helper function to reset/disable the ESP
local function clearESP(State)
    BBQ.Enabled = false
    BBQ.Adornee = nil
    DummyDestroyedConn = cleanupConnection(DummyDestroyedConn, State and State.Connections)
end

-- Helper function to lock ESP onto a target
local function setupESP(target, State)
    BBQ.Enabled = true
    BBQ.Adornee = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
    
    -- Disconnect old destroying listener if switching targets
    DummyDestroyedConn = cleanupConnection(DummyDestroyedConn, State.Connections)
    
    -- Track target destruction
    DummyDestroyedConn = target.Destroying:Connect(function()
        clearESP(State)
    end)
    table.insert(State.Connections, DummyDestroyedConn)
end

function DummyESP.Init(State)
    if State.Toggles.DummyESP then
        -- Initial scan
        local dummy = Characters:FindFirstChild("Dummy")
        if dummy then
            setupESP(dummy, State)
        end

        -- Listen for new Dummies spawning
        if not ChildAddedConn then
            ChildAddedConn = Characters.ChildAdded:Connect(function(child)
                if child.Name == "Dummy" then
                    setupESP(child, State)
                end
            end)
            table.insert(State.Connections, ChildAddedConn)
        end

        -- Listen for Dummy being removed
        if not ChildRemovedConn then
            ChildRemovedConn = Characters.ChildRemoved:Connect(function(child)
                if child.Name == "Dummy" and BBQ.Adornee and BBQ.Adornee:IsDescendantOf(child) then
                    clearESP(State)
                end
            end)
            table.insert(State.Connections, ChildRemovedConn)
        end
    else
        -- Clean up absolutely everything from State.Connections on toggle off
        ChildAddedConn = cleanupConnection(ChildAddedConn, State.Connections)
        ChildRemovedConn = cleanupConnection(ChildRemovedConn, State.Connections)
        clearESP(State)
    end
end

return DummyESP
