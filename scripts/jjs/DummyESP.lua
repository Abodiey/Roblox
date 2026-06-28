local DummyESP = {}
local Characters = workspace:WaitForChild("Characters")
local CoreGui = cloneref(game:GetService("CoreGui"))

while CoreGui:FindFirstChild("DummyHighlightESP") do
    CoreGui.DummyHighlightESP:Destroy()
    task.wait()
end

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
uiStroke.Color = Color3.fromRGB(0, 255, 0) 

BBQ.Parent = CoreGui
strokeFrame.Parent = BBQ
uiStroke.Parent = strokeFrame

local childAddedConn = nil
local childRemovedConn = nil
local attributeConn = nil
local toggleConn = nil

local function updateESPColor(dummy)
    if not dummy then return end
    
    if dummy:GetAttribute("Dead") == true then
        uiStroke.Color = Color3.fromRGB(255, 0, 0) 
    else
        uiStroke.Color = Color3.fromRGB(0, 255, 0) 
    end
end

local function refreshTargetDummy()
    if attributeConn then
        attributeConn:Disconnect()
        attributeConn = nil
    end

    local children = Characters:GetChildren()
    local targetDummy = nil

    for i = #children, 1, -1 do
        local child = children[i]
        if child and child.Name == "Dummy" then
            targetDummy = child
            break
        end
    end

    if targetDummy then
        task.spawn(function()
            local hrp = targetDummy:WaitForChild("HumanoidRootPart", 5)
            
            if targetDummy and targetDummy.Parent and hrp then
                BBQ.Adornee = hrp
                updateESPColor(targetDummy)
                BBQ.Enabled = true

                attributeConn = targetDummy:GetAttributeChangedSignal("Dead"):Connect(function()
                    updateESPColor(targetDummy)
                end)
            end
        end)
    else
        BBQ.Enabled = false
        BBolGui = nil
        BBQ.Adornee = nil
    end
end

local function cleanupESP()
    if childAddedConn then childAddedConn:Disconnect() childAddedConn = nil end
    if childRemovedConn then childRemovedConn:Disconnect() childRemovedConn = nil end
    if attributeConn then attributeConn:Disconnect() attributeConn = nil end

    BBQ.Enabled = false
    BBQ.Adornee = nil
end

function DummyESP.Init(State)
    local toggleObject = State.Toggles.DummyESP

    local function handleStateChange()
        if toggleObject.Value then
            refreshTargetDummy()

            if not childAddedConn then
                childAddedConn = Characters.ChildAdded:Connect(function(child)
                    if child and child.Name == "Dummy" then
                        refreshTargetDummy()
                    end
                end)
            end

            if not childRemovedConn then
                childRemovedConn = Characters.ChildRemoved:Connect(function(child)
                    if child and child.Name == "Dummy" then
                        refreshTargetDummy()
                    end
                end)
            end
        else
            cleanupESP()
        end
    end

    toggleConn = toggleObject:GetPropertyChangedSignal("Value"):Connect(handleStateChange)
    table.insert(State.Connections, toggleConn)

    handleStateChange()
end

return DummyESP
