local Aura = {}
local TextChatService = game:GetService("TextChatService")
local lastMsg = {}

function Aura.Init(State)
    local conn = game:GetService("RunService").Heartbeat:Connect(function()
        if not State.Toggles.MsgAura or not workspace:FindFirstChild("Characters") then return end
        for _, char in pairs(workspace.Characters:GetChildren()) do
            if char ~= game.Players.LocalPlayer.Character and char:FindFirstChild("Board") then
                pcall(function()
                    local msg = char.Board.SurfaceGui.TextLabel.Text
                    if msg ~= "" and lastMsg[char.Name] ~= msg then
                        lastMsg[char.Name] = msg
                        TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage("[<b>" .. char.Name .. "</b>]: " .. msg)
                    end
                end)
            end
        end
    end)
    table.insert(State.Connections, conn)
end

return Aura
