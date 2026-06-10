local QTE = {}
local VIM = cloneref(game:GetService("VirtualInputManager"))
local Players = cloneref(game:GetService("Players"))
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

function QTE.Init(State)
    local conn = PlayerGui.ChildAdded:Connect(function(child)
        if State.Toggles.QTE and child.Name == "QTE" then
            local label = child:FindFirstChild("QTE_PC")
            if not label then return end

            task.spawn(function()
                while State.Toggles.QTE and child.Parent == PlayerGui do
                    local healthBar = child.Health.Bar1

                    if healthBar.Size.X.Scale > 0.75 then
                        task.wait(0.1)
                        continue
                    end

                    local key = label.Text:match("%a")
                    if key then
                        local keyCode = Enum.KeyCode[key:upper()]
                        VIM:SendKeyEvent(true, keyCode, false, game)
                        task.wait()
                        VIM:SendKeyEvent(false, keyCode, false, game)
                    end
                end
            end)
        end
    end)
    table.insert(State.Connections, conn)
end

return QTE
