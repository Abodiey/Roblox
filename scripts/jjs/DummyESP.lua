local DummyESP = {}
local Characters = workspace:WaitForChild("Characters")
local CoreGui = cloneref(game:GetService("CoreGui"))

-- Clean up any legacy ESP instances left over from previous runs
while CoreGui:FindFirstChild("DummyHighlightESP") do
    CoreGui.DummyHighlightESP:Destroy()
    task.wait()
end

-- Create the ESP Gui Elements
local BBQ = Instance.new("BillboardGui")
BBQ.Name = "DummyHighlightESP"
BBQ.Size = UDim2.new(4, 0, 6, 0)
BBQ.AlwaysOnTop = true
BBQ.ResetOnSpawn = false
BBQ.Enabled = false

local strokeFrame = Instance.new("Frame")
strokeFrame.Size = UDim2.new(1, 0, 1, 0)
strokeFrame.BackgroundTransparency = 1

local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 2
uiStroke.Color = Color3.fromRGB(0, 255, 0) -- Default starting color

BBQ.Parent = CoreGui
strokeFrame.Parent = BBQ
uiStroke.Parent = strokeFrame

-- Persistent internal connection trackers
local childAddedConn = nil
local childRemovedConn = nil
local attributeConn = nil

-- Helper function to update stroke color based on "Dead" attribute
local function updateESPColor(dummy)
    if not dummy then return end
    
    if dummy:GetAttribute("Dead") == true then
        uiStroke.Color = Color3.fromRGB(255, 0, 0) -- Red if dead
    else
        uiStroke.Color = Color3.fromRGB(0, 255, 0) -- Green if alive
    end
end

-- Helper function to find and attach to the LAST dummy in the folder
local function refreshTargetDummy()
    if attributeConn then
        attributeConn:Disconnect()
        attributeConn = nil
    end

    local children = Characters:GetChildren()
    local targetDummy = nil

    -- Loop backwards to find the LAST dummy added to the folder
    for i = #children, 1, -1 do
        local child = children[i]
        if child and child.Name == "Dummy" then
            targetDummy = child
            break
        end
    end

    if targetDummy then
        task.spawn(function()
            -- Wait safely for HumanoidRootPart
            local hrp = targetDummy:WaitForChild("HumanoidRootPart", 5)
            
            if targetDummy and targetDummy.Parent and hrp then
                BBQ.Adornee = hrp
                updateESPColor(targetDummy)
                BBQ.Enabled = true

                -- Listen for the "Dead" attribute changing on this specific dummy
                attributeConn = targetDummy:GetAttributeChangedSignal("Dead"):Connect(function()
                    updateESPColor(targetDummy)
                end)
            end
        end)
    else
        BBQ.Enabled = false
        BBQ.Adornee = nil
    end
end

-- Completely disconnects listeners and cleans up UI
local function cleanupESP()
    if childAddedConn then childAddedConn:Disconnect() childAddedConn = nil end
    if childRemovedConn then childRemovedConn:Disconnect() childRemovedConn = nil end
    if attributeConn then attributeConn:Disconnect() attributeConn = nil end

    BBQ.Enabled = false
    BBQ.Adornee = nil
end

function DummyESP.Init(State)
    -- Spawn a persistent thread since Init is only called once
    task.spawn(function()
        local wasActive = false

        while true do
            local isActive = not not (State.Toggles and State.Toggles.DummyESP)

            if isActive and not wasActive then
                -- Toggle just turned ON: Bind listeners and find current last dummy
                wasActive = true
                refreshTargetDummy()

                childAddedConn = Characters.ChildAdded:Connect(function(child)
                    if child and child.Name == "Dummy" then
                        refreshTargetDummy()
                    end
                end)

                childRemovedConn = Characters.ChildRemoved:Connect(function(child)
                    if child and child.Name == "Dummy" then
                        refreshTargetDummy()
                    end
                end)

            elseif not isActive and wasActive then
                -- Toggle just turned OFF: Cleanup signals completely
                wasActive = false
                cleanupESP()
            end

            -- Sleep loop. Since it only checks a boolean state pointer, 
            -- a 0.1s wait uses zero noticeable CPU overhead.
            task.wait(0.1)
        end
    end)
end

return DummyESP
