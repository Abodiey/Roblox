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

local ChildConnection = nil

function DummyESP.Init(State)
    if State.Toggles.DummyESP then
        local dummy = Characters:FindFirstChild("Dummy")
        if dummy then
            BBQ.Adornee = dummy.PrimaryPart or dummy:FindFirstChildWhichIsA("BasePart")
        end

        if not ChildConnection then
            ChildConnection = Characters.ChildAdded:Connect(function(child)
                if child.Name == "Dummy" then
                    BBQ.Adornee = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart")
                end
            end)
            table.insert(State.Connections, ChildConnection)
        end
    else
        if ChildConnection then
            ChildConnection:Disconnect()
            ChildConnection = nil
        end
        BBQ.Adornee = nil
    end
end

return DummyESP
