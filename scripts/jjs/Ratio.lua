local Ratio = {}

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local RunService = cloneref(game:GetService("RunService"))

local RightActivated = ReplicatedStorage:WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("NanamiService"):WaitForChild("RE"):WaitForChild("RightActivated")
local charFolder = workspace:WaitForChild("Characters")
local monitored = setmetatable({}, {__mode = "k"})

local function monitor(char, ratio)
    monitored[ratio] = true
    local cursor = ratio:FindFirstChild("Bar") and ratio.Bar:FindFirstChild("Cursor")
    if not cursor then return end

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not cursor or not cursor.Parent then connection:Disconnect() return end
        if cursor.Position.Y.Scale < 0.45 then
            connection:Disconnect()
            RightActivated:FireServer(char)
        end
    end)
end

function Ratio.Init(State)
    local scanner = task.spawn(function()
        while true do
            task.wait(0.1)
            if not State.Toggles.Ratio then continue end

            local children = charFolder:GetChildren()
            for i = 1, #children do
                local char = children[i]
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local ratio = hrp and hrp:FindFirstChild("Ratio")

                if ratio and not monitored[ratio] then
                    monitor(char, ratio)
                end
            end
        end
    end)
    table.insert(State.Connections, {
        Disconnect = function()
            task.cancel(scanner)
        end
    })
end

return Ratio
