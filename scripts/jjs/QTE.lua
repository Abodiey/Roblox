local QTE = {}
local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local Event = ReplicatedStorage:WaitForChild("Knit", 99):WaitForChild("Knit", 99):WaitForChild("Services", 99):WaitForChild("FinalJudgementService", 99):WaitForChild("RE", 99):WaitForChild("Effects", 99)

function QTE.Init(State)
    local remoteTarget = nil

    local conn1 = Event.OnClientEvent:Connect(function(mode, targetEvent)

        if mode ~= "QTE" then return end
        if typeof(targetEvent) ~= "Instance" then return end
        if not targetEvent:IsA("RemoteEvent") then return end

        local character = Player.Character
        if not character then return end
        if not targetEvent:IsDescendantOf(character) then return end

        remoteTarget = targetEvent

        if not State.Toggles.QTE then return end
        task.spawn(function()
            local currentDelay = QTE.InitialDelay
            local startTime = os.clock()
            while true do
                if not State.Toggles.QTE then break end
                if not remoteTarget then break end
                if not remoteTarget.Parent then break end

                remoteTarget:FireServer(true)
                
                task.wait()
            end
        end)
    end)
    table.insert(State.Connections, conn1)
end

return QTE
