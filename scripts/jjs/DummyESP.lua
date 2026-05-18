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

-- Thread controller variable
local isLoopRunning = false

function DummyESP.Init(State)
    if State.Toggles.DummyESP then
        if isLoopRunning then return end -- Prevent duplicating the loop if Init is called multiple times
        isLoopRunning = true

        -- Run the polling loop on a separate fast task thread
        task.spawn(function()
            while isLoopRunning and State.Toggles.DummyESP do
                local dummy = Characters:FindFirstChild("Dummy")

                if dummy then
                    local targetPart = dummy.PrimaryPart or dummy:FindFirstChildWhichIsA("BasePart")
                    
                    if targetPart then
                        -- Update or maintain the ESP position
                        if BBQ.Adornee ~= targetPart then
                            BBQ.Adornee = targetPart
                        end
                        if not BBQ.Enabled then
                            BBQ.Enabled = true
                        end
                    else
                        -- Dummy exists but has no valid parts yet
                        BBQ.Enabled = false
                        BBQ.Adornee = nil
                    end
                else
                    -- Dummy does not exist / was removed
                    if BBQ.Enabled then
                        BBQ.Enabled = false
                        BBQ.Adornee = nil
                    end
                end

                task.wait(0.1) -- Fast enough to feel responsive, slow enough to be lightweight
            end
            
            -- Fallback cleanup when loop terminates naturally
            BBQ.Enabled = false
            BBQ.Adornee = nil
        end)
    else
        -- Kill the loop and clear UI immediately when toggle turns off
        isLoopRunning = false
        BBQ.Enabled = false
        BBQ.Adornee = nil
    end
end

return DummyESP
