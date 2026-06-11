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

function Train.Init(ButtonComponent)
    if not Main or not Prompt then
        if ButtonComponent then 
            ButtonComponent:Set("Spawn Train (Map Error)") 
        end
        return
    end

    local function UpdateButtonText()
        if CurrentThread then
            task.cancel(CurrentThread)
            CurrentThread = nil
        end

        if not ButtonComponent then return end

        if Prompt.Enabled then
            ButtonComponent:Set("Spawn Train (Ready)")
        else
            ButtonComponent:Set("Spawn Train (Unknown Cooldown)")
        end
    end

    UpdateButtonText()
    
    local Connection = Prompt:GetPropertyChangedSignal("Enabled"):Connect(UpdateButtonText)
    table.insert(getgenv().CatstarState.Connections, Connection)

    local DisableConnection = Prompt:GetPropertyChangedSignal("Enabled"):Connect(function()
        if not Prompt.Enabled and ButtonComponent then
            if CurrentThread then task.cancel(CurrentThread) end
            
            CurrentThread = task.spawn(function()
                local Duration = 180
                while Duration > 0 and not Prompt.Enabled do
                    local Minutes = math.floor(Duration / 60)
                    local Seconds = Duration % 60
                    ButtonComponent:Set(string.format("Spawn Train (%dm %02ds)", Minutes, Seconds))
                    task.wait(1)
                    Duration = Duration - 1
                end
                UpdateButtonText()
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
