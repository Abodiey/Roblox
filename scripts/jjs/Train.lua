local Train = {}

-- Localize Services & Core API
local cloneref = cloneref
local game = game
local workspace = cloneref(game:GetService("Workspace"))

-- Localize Global Engine Functions
local task = task
local math = math
local m_floor = math.floor
local string = string
local s_format = string.format
local table = table
local table_insert = table.insert
local coroutine = coroutine
local c_status = coroutine.status
local c_close = coroutine.close

-- Kept outside as the global baseline reference
local Map = workspace:WaitForChild("Map")

local CurrentThread = nil

-- Helper to safely terminate an active thread only if it's alive
local function stopCurrentThread()
    if CurrentThread then
        local status = c_status(CurrentThread)
        if status == "suspended" or status == "running" then
            -- coroutine.close is safe and standard in Luau for closing active threads
            c_close(CurrentThread)
        end
        CurrentThread = nil
    end
end

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
        stopCurrentThread()

        if not ButtonComponent then return end
        if not PromptParent:IsDescendantOf(game) then return end

        local Prompt = PromptParent:FindFirstChild("Button")
        if Prompt then
            ButtonComponent:Set("Spawn Train (Ready)")
        else
            ButtonComponent:Set("Spawn Train (Unknown Cooldown)")
        end
    end

    local function StartCooldown()
        stopCurrentThread()
        
        if not ButtonComponent then return end

        CurrentThread = task.spawn(function()
            local Duration = 180 -- 3 minutes in seconds
            
            while Duration > 0 and PromptParent:IsDescendantOf(game) and not PromptParent:FindFirstChild("Button") do
                local Minutes = m_floor(Duration / 60)
                local Seconds = Duration % 60
                ButtonComponent:Set(s_format("Spawn Train (%dm %02ds)", Minutes, Seconds))
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
    
    -- Listen for the prompt appearing or disappearing, route connections to the passed State table
    local ChildAddedConnection = PromptParent.ChildAdded:Connect(function(child)
        if child.Name == "Button" then
            UpdateButtonText()
        end
    end)
    table_insert(State.Connections, ChildAddedConnection)

    local ChildRemovedConnection = PromptParent.ChildRemoved:Connect(function(child)
        if child.Name == "Button" then
            StartCooldown()
        end
    end)
    table_insert(State.Connections, ChildRemovedConnection)
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
