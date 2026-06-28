local Train = {}

-- Localize Services & Core API
local cloneref = cloneref
local game = game
local workspace = cloneref(game:GetService("Workspace"))

-- Localize Global Engine Functions
local table = table

-- Kept outside as the global baseline reference
local Map = workspace:WaitForChild("Map")

function Train.Init(ButtonComponent, State)
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
        if not ButtonComponent then return end
        if not PromptParent:IsDescendantOf(game) then return end

        local Prompt = PromptParent:FindFirstChild("Button")
        if Prompt then
            ButtonComponent:Set("Spawn Train (Ready)")
        else
            ButtonComponent:Set("Spawn Train (On Cooldown)")
        end
    end

    -- Initial state check
    UpdateButtonText()
    
    -- Listen for the prompt appearing or disappearing, route connections to the passed State table
    local ChildAddedConnection = PromptParent.ChildAdded:Connect(function(child)
        if child.Name == "Button" then
            UpdateButtonText()
        end
    end)
    table.insert(State.Toggles, ChildAddedConnection) -- Stored directly inside Value Folder wrapper state structure safely

    local ChildRemovedConnection = PromptParent.ChildRemoved:Connect(function(child)
        if child.Name == "Button" then
            UpdateButtonText()
        end
    end)
    table.insert(State.Toggles, ChildRemovedConnection)
end

function Train.Spawn()
    local Destructible = Map:FindFirstChild("Destructible")
    local Main = Destructible and Destructible:FindFirstChild("Model")
    Main = Main and Main:FindFirstChild("StationControl")

    local ButtonTrain = Main and Main:FindFirstChild("ButtonTrain")
    local Button1 = ButtonTrain and ButtonTrain:FindFirstChild("Button")
    local PromptParent = Button1 and Button1:FindFirstChild("Button")
    local Prompt = PromptParent and PromptParent:FindFirstChild("Button")

    local Event = Main and Main:FindFirstChild("Handle")
    Event = Event and Event:FindFirstChild("Train")

    if Prompt and Event then
        Event:FireServer()
    end
end

return Train
