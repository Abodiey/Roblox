local QTE = {}
local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui
local Event = ReplicatedStorage:WaitForChild("Knit", 99):WaitForChild("Knit", 99):WaitForChild("Services", 99):WaitForChild("FinalJudgementService", 99):WaitForChild("RE", 99):WaitForChild("Effects", 99)

QTE.InitialDelay = 1
QTE.MinimumDelay = 0.1
QTE.RampSpeed = 0.08

function QTE.Init(State)
    local remoteTarget = nil

    local conn1 = Event.OnClientEvent:Connect(function(mode, targetEvent, ...)
        print(mode, targetEvent, ...)

        if typeof(mode) ~= "string" then return end
        if not string.find(mode, "QTE") then return end
        if typeof(targetEvent) ~= "Instance" then return end
        if not targetEvent:IsA("RemoteEvent") then return end
        
        local character = Player.Character
        if not character then return end
        if not targetEvent:IsDescendantOf(character) then return end

        remoteTarget = targetEvent

        local child = PlayerGui:WaitForChild("QTE", 5)
        if not child then return end
        if not State.Toggles.QTE then return end

        task.spawn(function()
            local currentDelay = QTE.InitialDelay
            local startTime = os.clock()

            while true do
                if not State.Toggles.QTE then break end
                if child.Parent ~= PlayerGui then break end
                if not remoteTarget then break end
                if not remoteTarget.Parent then break end

                local healthBar = child.Health.Bar1

                if healthBar.Size.X.Scale > 0.75 then
                    task.wait()
                    continue
                end

                if os.clock() - startTime > 5 and healthBar.Size.X.Scale < 0.55 then
                    remoteTarget:FireServer(true)
                    task.wait()
                    continue
                end

                remoteTarget:FireServer(true)
                
                task.wait(currentDelay)
                currentDelay = math.max(QTE.MinimumDelay, currentDelay - QTE.RampSpeed)
            end
        end)
    end)
    table.insert(State.Connections, conn1)
end

return QTE
