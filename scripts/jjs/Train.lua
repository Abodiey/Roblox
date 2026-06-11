local Train = {}

local Main = workspace:WaitForChild("Map")
Main = Main:WaitForChild("Destructible")
Main = Main:WaitForChild("Model")
Main = Main:WaitForChild("StationControl")

local Prompt = Main:WaitForChild("ButtonTrain")
Prompt = Prompt:WaitForChild("Button")
Prompt = Prompt:WaitForChild("Button")

local Event = Main:WaitForChild("Handle")
Event = Event:WaitForChild("Train")

local CurrentThread

function Train.Init(StatusParagraph)
    if not Main or not Prompt then
        if StatusParagraph then 
            StatusParagraph:Set({Title = "Spawn Train", Content = "Train Status: Map Error"}) 
        end
        return
    end

    local function UpdateLabel()
        if CurrentThread then
            task.cancel(CurrentThread)
            CurrentThread = nil
        end

        if not StatusParagraph then return end

        if Prompt.Enabled then
            StatusParagraph:Set({
                Title = "Spawn Train",
                Content = "Train Status: Ready"
            })
        else
            StatusParagraph:Set({
                Title = "Spawn Train",
                Content = "Train Status: Not Ready"
            })
        end
    end

    UpdateLabel()
    
    local Connection = Prompt:GetPropertyChangedSignal("Enabled"):Connect(UpdateLabel)
    table.insert(getgenv().CatstarState.Connections, Connection)

    local DisableConnection = Prompt:GetPropertyChangedSignal("Enabled"):Connect(function()
        if not Prompt.Enabled and StatusParagraph then
            if CurrentThread then task.cancel(CurrentThread) end
            
            CurrentThread = task.spawn(function()
                local Duration = 180
                while Duration > 0 and not Prompt.Enabled do
                    local Minutes = math.floor(Duration / 60)
                    local Seconds = Duration % 60
                    StatusParagraph:Set({
                        Title = "Spawn Train",
                        Content = string.format("Train Status: Cooldown (%dm %02ds)", Minutes, Seconds)
                    })
                    task.wait(1)
                    Duration = Duration - 1
                end
                UpdateLabel()
            end)
        end
    end)
    table.insert(getgenv().CatstarState.Connections, DisableConnection)
end

function Train.Spawn()
    if Prompt and Prompt.Enabled and Event then
        Event:FireServer()
    end
end

return Train
