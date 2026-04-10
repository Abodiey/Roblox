-- File: auto_qte.lua
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = game:GetService("Players").LocalPlayer
local qteSettings = { checkMS = 10, randomness = 150 }

return function(getQTEActive)
    local connection = LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
        if getQTEActive() and child.Name == "QTE" then
            local label = child:WaitForChild("QTE_PC", 5)
            if label then
                task.spawn(function()
                    while getQTEActive() and label.Parent == child do
                        local key = label.Text:match("%a")
                        if key then
                            task.wait(math.random(0, qteSettings.randomness) / 1000)
                            VIM:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                            task.wait(0.1)
                            VIM:SendKeyEvent(false, Enum.KeyCode[key], false, game)
                        end
                        task.wait(qteSettings.checkMS / 1000)
                    end
                end)
            end
        end
    end)
    return connection
end
