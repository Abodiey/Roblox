local QTE = {}
local VIM = game:GetService("VirtualInputManager")

function QTE.Init(State)
    local conn = game:GetService("Players").LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
        if State.Toggles.QTE and child.Name == "QTE" then
            local label = child:WaitForChild("QTE_PC", 5)
            if label then
                task.spawn(function()
                    while State.Toggles.QTE and label.Parent == child do
                        local key = label.Text:match("%a")
                        if key then
                            VIM:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                            task.wait(0.1)
                            VIM:SendKeyEvent(false, Enum.KeyCode[key], false, game)
                        end
                        task.wait(0.01)
                    end
                end)
            end
        end
    end)
    table.insert(State.Connections, conn)
end

return QTE
