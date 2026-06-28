local DiamondInTheSky = {}

-- Upvalue Caching Optimization
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local PreSimulation = RunService.PreSimulation
local Vector3_new = Vector3.new

local player = Players.LocalPlayer

-- Runtime cached references and connection states
local character = nil
local rootPart = nil
local activeSwingForce = nil

local addedConn, removedConn, attrConn
local forceAddedConn, forceRemovedConn
local loopConn
local charAddedConn, charRemovingConn

-- Core velocity adjustment loop targeting the force object itself
local function setVelocity(State)
    if activeSwingForce then
        local currentVelocity = activeSwingForce.Velocity
        local mult = State.Variables.SpeedMultiplier
        activeSwingForce.Velocity = Vector3_new(currentVelocity.X * mult, currentVelocity.Y, currentVelocity.Z * mult)
    end
end

-- Manages the PreSimulation connection state dynamically
local function toggleLoop(shouldEnable, State)
    if shouldEnable then
        if not loopConn then
            loopConn = PreSimulation:Connect(function()
                setVelocity(State)
            end)
        end
    else
        if loopConn then
            loopConn:Disconnect()
            loopConn = nil
        end
    end
end

-- Validates the active Emote's name attribute
local function checkEmote(emoteInstance, State)
    if attrConn then attrConn:Disconnect() end
    
    local isActive = (emoteInstance:GetAttribute("EmoteName") == "Diamond in the sky")
    toggleLoop(isActive, State)
    
    attrConn = emoteInstance:GetAttributeChangedSignal("EmoteName"):Connect(function()
        local isNowActive = (emoteInstance:GetAttribute("EmoteName") == "Diamond in the sky")
        toggleLoop(isNowActive, State)
    end)
end

-- Clear all listeners and states cleanly on removal/respawn
local function cleanup()
    if addedConn then addedConn:Disconnect() addedConn = nil end
    if removedConn then removedConn:Disconnect() removedConn = nil end
    if attrConn then attrConn:Disconnect() attrConn = nil end
    if forceAddedConn then forceAddedConn:Disconnect() forceAddedConn = nil end
    if forceRemovedConn then forceRemovedConn:Disconnect() forceRemovedConn = nil end
    if loopConn then loopConn:Disconnect() loopConn = nil end
    
    character = nil
    rootPart = nil
    activeSwingForce = nil
end

-- Main setup function triggered upon spawning
local function setup(newCharacter, State)
    cleanup()
    
    character = newCharacter
    rootPart = character:WaitForChild("HumanoidRootPart", 99999)

    -- Track the SwingForce instance entering/leaving the RootPart
    activeSwingForce = rootPart:FindFirstChild("SwingForce")
    
    forceAddedConn = rootPart.ChildAdded:Connect(function(child)
        if child.Name == "SwingForce" then
            activeSwingForce = child
        end
    end)

    forceRemovedConn = rootPart.ChildRemoved:Connect(function(child)
        if child == activeSwingForce then
            activeSwingForce = nil
        end
    end)

    -- Handle the Info tracking folder structure
    local infoFolder = character:WaitForChild("Info", 99999)
    if infoFolder and character == newCharacter then
        local currentEmote = infoFolder:FindFirstChild("Emote")
        if currentEmote then
            checkEmote(currentEmote, State)
        end

        addedConn = infoFolder.ChildAdded:Connect(function(child)
            if child.Name == "Emote" then
                checkEmote(child, State)
            end
        end)

        removedConn = infoFolder.ChildRemoved:Connect(function(child)
            if child.Name == "Emote" then
                if loopConn then loopConn:Disconnect() loopConn = nil end
                if attrConn then attrConn:Disconnect() attrConn = nil end
            end
        end)
    end
end

-- Structural master cleanup of character connection events when toggle goes off
local function deepCleanup()
    cleanup()
    if charAddedConn then charAddedConn:Disconnect() charAddedConn = nil end
    if charRemovingConn then charRemovingConn:Disconnect() charRemovingConn = nil end
end

function DiamondInTheSky.Init(State)
    -- Spawn a persistent thread since Init is only called once at startup
    task.spawn(function()
        local wasActive = false

        while true do
            -- Target toggle state directly
            local isActive = State.Toggles.DiamondInTheSky

            if isActive and not wasActive then
                -- Toggle just turned ON: Activate listeners and build setup
                wasActive = true
                
                if player.Character then
                    setup(player.Character, State)
                end
                
                charAddedConn = player.CharacterAdded:Connect(function(char)
                    setup(char, State)
                end)
                charRemovingConn = player.CharacterRemoving:Connect(cleanup)

            elseif not isActive and wasActive then
                -- Toggle just turned OFF: Clear everything completely
                wasActive = false
                deepCleanup()
            end

            -- Sleep interval to check state pointer with zero overhead
            task.wait(0.1)
        end
    end)
end

return DiamondInTheSky
