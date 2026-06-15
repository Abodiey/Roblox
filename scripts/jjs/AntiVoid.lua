local AntiVoid = {}

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))

local LocalPlayer = Players.LocalPlayer

-- [CONFIGURATION CONSTANTS]
local CENTER_POINT = Vector3.zero
local MAP_RADIUS = 350
local TELEPORT_THRESHOLD = 100 -- Maximum valid distance a player can travel in one frame

-- Calculate the bounding box based on the center and radius
local MIN_X = CENTER_POINT.X - MAP_RADIUS
local MAX_X = CENTER_POINT.X + MAP_RADIUS
local MIN_Z = CENTER_POINT.Z - MAP_RADIUS
local MAX_Z = CENTER_POINT.Z + MAP_RADIUS

local lastPosition = nil

-- [MAIN INITIALIZATION]
function AntiVoid.Init(State)
    local Connection = RunService.Heartbeat:Connect(function()
        local Enabled = State.Toggles.AntiVoid
        
        if not Enabled then 
            lastPosition = nil
            return 
        end
        
        -- Ensure the character and RootPart exist and are valid
        local Character = LocalPlayer.Character
        if not Character then 
            lastPosition = nil
            return 
        end
        
        -- [DOMAIN CHECK]
        local Info = Character:FindFirstChild("Info")
        if Info and Info:FindFirstChild("DomainTag") then
            lastPosition = nil 
            return
        end
        
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if not RootPart then 
            lastPosition = nil
            return 
        end
        
        local currentPosition = RootPart.Position
        
        -- If we have a recorded last position, check for massive gameplay teleports
        if lastPosition then
            local distanceMoved = (currentPosition - lastPosition).Magnitude
            if distanceMoved > TELEPORT_THRESHOLD then
                lastPosition = currentPosition
                return
            end
        end
        
        -- Check if the player is outside the boundary box
        if currentPosition.X < MIN_X or currentPosition.X > MAX_X or currentPosition.Z < MIN_Z or currentPosition.Z > MAX_Z then
            
            -- Clamp the coordinates mathematically so they cannot exceed the radius
            local clampedX = math.clamp(currentPosition.X, MIN_X, MAX_X)
            local clampedZ = math.clamp(currentPosition.Z, MIN_Z, MAX_Z)
            
            local targetPosition = Vector3.new(clampedX, currentPosition.Y, clampedZ)
            
            -- Use PivotTo to safely shift all limbs, ragdoll joints, and welds together
            local currentCFrame = Character:GetPivot()
            Character:PivotTo(CFrame.new(targetPosition) * currentCFrame.Rotation)
            
            -- Kill the outward velocity to prevent ragdoll physics from pushing through on the next frame
            RootPart.AssemblyLinearVelocity = Vector3.zero
            RootPart.AssemblyAngularVelocity = Vector3.zero
            
            -- Track the clamped position as the last valid position
            lastPosition = targetPosition
        else
            -- Track the normal walking position
            lastPosition = currentPosition
        end
    end)
    
    table.insert(State.Connections, Connection)
end

return AntiVoid
