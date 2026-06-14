local AntiVoid = {}

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))

local LocalPlayer = Players.LocalPlayer

-- [CONFIGURATION CONSTANTS]
local MAIN_CENTER = Vector3.zero
local MAP_RADIUS = 350
local DOMAIN_DETECTION_RADIUS = 600 -- Beyond this, it assumes you are in a domain/different map section

-- [DYNAMIC VARIATION DATA]
local currentCenter = MAIN_CENTER

-- [MAIN INITIALIZATION]
function AntiVoid.Init(State)
    local Connection = RunService.Heartbeat:Connect(function()
        local Enabled = State.Toggles.AntiVoid
        
        if not Enabled then return end
        
        -- Ensure the character and RootPart exist and are valid
        local Character = LocalPlayer.Character
        if not Character then return end
        
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if not RootPart then return end
        
        local currentPosition = RootPart.Position
        
        -- [DYNAMIC DOMAIN DETECTION]
        -- If player is way further than the main map boundaries, shift center to their general domain area
        local distanceFromMain = (Vector3.new(currentPosition.X, MAIN_CENTER.Y, currentPosition.Z) - MAIN_CENTER).Magnitude
        
        if distanceFromMain > DOMAIN_DETECTION_RADIUS then
            -- Snap our tracking center to the domain's local center area (rounded to increments to maintain stability)
            currentCenter = Vector3.new(
                math.round(currentPosition.X / 500) * 500,
                currentPosition.Y,
                math.round(currentPosition.Z / 500) * 500
            )
        else
            -- Back in the main arena
            currentCenter = MAIN_CENTER
        end
        
        -- Recalculate dynamic bounding boxes based on the current active zone
        local MIN_X = currentCenter.X - MAP_RADIUS
        local MAX_X = currentCenter.X + MAP_RADIUS
        local MIN_Z = currentCenter.Z - MAP_RADIUS
        local MAX_Z = currentCenter.Z + MAP_RADIUS
        
        -- [CLAMP LOGIC]
        if currentPosition.X < MIN_X or currentPosition.X > MAX_X or currentPosition.Z < MIN_Z or currentPosition.Z > MAX_Z then
            
            -- Clamp coordinates based on the dynamically selected center zone
            local clampedX = math.clamp(currentPosition.X, MIN_X, MAX_X)
            local clampedZ = math.clamp(currentPosition.Z, MIN_Z, MAX_Z)
            
            local currentVelocity = RootPart.AssemblyLinearVelocity
            
            RootPart.CFrame = CFrame.new(Vector3.new(clampedX, currentPosition.Y, clampedZ)) * RootPart.CFrame.Rotation
            RootPart.AssemblyLinearVelocity = currentVelocity
        end
    end)
    
    table.insert(State.Connections, Connection)
end

return AntiVoid
