local Train = {}

-- Kept outside as the global baseline reference
local Map = workspace:WaitForChild("Map")

local CurrentThread

function Train.Init(ButtonComponent)
    -- Dynamically look for "Destructible", "Model", and descendants inside the function
    local Destructible = Map:FindFirstChild("Destructible")
    local Main = Destructible and Destructible:FindFirstChild("Model")
    Main = Main and Main:FindFirstChild("StationControl")

    local Prompt = Main and Main:FindFirstChild("ButtonTrain")
    Prompt = Prompt and Prompt:FindFirstChild("Button")
    Prompt = Prompt and Prompt:FindFirstChild("Button")

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

        -- Quick safety check to see if the Prompt was deleted mid-lifecycle
        if not Prompt:IsDescendantOf(game) then return end

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
                local Duration = 180 -- 3 minutes in seconds
                
                -- LEAK PROTECTION: Loop terminates instantly if Prompt is destroyed/removed from game
                while Duration > 0 and Prompt:IsDescendantOf(game) and not Prompt.Enabled do
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
    -- Dynamically look for everything under Map when called
    local Destructible = Map:FindFirstChild("Destructible")
    local Main = Destructible and Destructible:FindFirstChild("Model")
    Main = Main and Main:FindFirstChild("StationControl")

    local Prompt = Main and Main:FindFirstChild("ButtonTrain")
    Prompt = Prompt and Prompt:FindFirstChild("Button")
    Prompt = Prompt and Prompt:FindFirstChild("Button")

    local Event = Main and Main:FindFirstChild("Handle")
    Event = Event and Event:FindFirstChild("Train")

    if Prompt and Prompt.Enabled and Event then
        Event:FireServer()
    end
end

return Train
