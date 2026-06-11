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

function Train.Init(StatusLabel)
    if not Main or not Prompt then
        if StatusLabel then StatusLabel:Set("Train Status: Map Error") end
        return
    end

    local function UpdateLabel()
        if StatusLabel then
            local Ready = Prompt.Enabled
            StatusLabel:Set("Train Status: " .. (Ready and "Ready to Spawn" or "On Cooldown"))
        end
    end

    UpdateLabel()
    
    local Connection = Prompt:GetPropertyChangedSignal("Enabled"):Connect(UpdateLabel)
    table.insert(getgenv().CatstarState.Connections, Connection)
end

function Train.Spawn()
    if Prompt and Prompt.Enabled and Event then
        Event:FireServer()
    end
end

return Train
