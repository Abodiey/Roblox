local Train = {}

-- Kept outside as the global baseline reference
local Map = workspace:WaitForChild("Map")

local CurrentThread

function Train.Init(ButtonComponent)
    -- Dynamically look for "Destructible", "Model", and descendants inside the function
    local Destructible = Map:FindFirstChild("Destructible")
    local Main = Destructible and Destructible:FindFirstChild("Model")
    Main = Main and Main:FindFirstChild("StationControl")

    -- Find the parent container that holds the prompt
    local ButtonTrain = Main and Main:FindFirstChild("ButtonTrain")
    local Button1 = ButtonTrain and ButtonTrain:FindFirstChild("Button")
    local PromptParent = Button1 and Button1:FindFirstChild("Button")

    if not Main or not PromptParent then
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

        -- Safety check to see if the parent container itself is still in the game
        if not PromptParent:IsDescendantOf(game) then return end

        -- Check if the prompt child exists
        local Prompt = PromptParent:FindFirstChild("Button")
        if Prompt then
            ButtonComponent:Set("Spawn Train (Ready)")
        else
            ButtonComponent:Set("Spawn Train (Unknown Cooldown)")
        end
    end

    local function StartCooldown()
        if CurrentThread then task.cancel(CurrentThread) end
        
        if not ButtonComponent then return end

        CurrentThread = task.spawn(function()
            local Duration = 180 -- 3 minutes in seconds
            
            -- Loop runs while prompt is missing, but stops if it reappears or map breaks
            while Duration > 0 and PromptParent:IsDescendantOf(game) and not PromptParent:FindFirstChild("Button") do
                local Minutes = math.floor(Duration / 60)
                local Seconds = Duration % 60
                ButtonComponent:Set(string.format("Spawn Train (%dm %02ds)", Minutes, Seconds))
                task.wait(1)
                Duration = Duration - 1
            end
            
            UpdateButtonText()
        end)
    end

    -- Initial state check
    UpdateButtonText()
    if not PromptParent:FindFirstChild("Button") then
        StartCooldown()
    end
    
    -- Listen for the prompt appearing or disappearing
    local ChildAddedConnection = PromptParent.ChildAdded:Connect(function(child)
        if child.Name == "Button" then
            UpdateButtonText()
        end
    end)
    table.insert(getgenv().CatstarState.Connections, ChildAddedConnection)

    local ChildRemovedConnection = PromptParent.ChildRemoved:Connect(function(child)
        if child.Name == "Button" then
            StartCooldown()
        end
    end)
    table.insert(getgenv().CatstarState.Connections, ChildRemovedConnection)
end

function Train.Spawn()
    -- Dynamically look for everything under Map when called
    local Destructible = Map:FindFirstChild("Destructible")
    local Main = Destructible and Destructible:FindFirstChild("Model")
    Main = Main and Main:FindFirstChild("StationControl")

    local ButtonTrain = Main and Main:FindFirstChild("ButtonTrain")
    local Button1 = ButtonTrain and ButtonTrain:FindFirstChild("Button")
    local PromptParent = Button1 and Button1:FindFirstChild("Button")
    local Prompt = PromptParent and PromptParent:FindFirstChild("Button")

    local Event = Main and Main:FindFirstChild("Handle")
    Event = Event and Event:FindFirstChild("Train")

    -- Removed Prompt.Enabled check since existence implies availability
    if Prompt and Event then
        Event:FireServer()
    end
end

return Train
