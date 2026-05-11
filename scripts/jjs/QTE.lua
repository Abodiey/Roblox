local QTE = {}
local VIM = cloneref(game:GetService("VirtualInputManager"))
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

function QTE.Init(State)
    local conn = PlayerGui.ChildAdded:Connect(function(child)
        if State.Toggles.QTE and child.Name == "QTE" then
            local label = child:WaitForChild("QTE_PC", 5)
            if label then
                task.spawn(function()
                    while State.Toggles.QTE and label.Parent == child do
                        local key = label.Text:match("%a")
                        if key then
                            VIM:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                            task.wait() task.wait()
                            VIM:SendKeyEvent(false, Enum.KeyCode[key], false, game)
                        end
                        task.wait(1/50)
                    end
                end)
            end
        end
    end)
    table.insert(State.Connections, conn)
end

return QTE
