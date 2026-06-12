local AntiVoid = {}

local RunService = cloneref(game:GetService("RunService"))

-- [CONFIGURATION CONSTANTS]
local CENTER_POINT = Vector3.zero
local MAP_RADIUS = 350
local WALL_HEIGHT = 999
local WALL_THICKNESS = 5

local FINAL_Y = CENTER_POINT.Y + (WALL_HEIGHT / 2)
local FULL_SIDE_LENGTH = (MAP_RADIUS * 2) + WALL_THICKNESS

-- [DIRECTIONAL BLUEPRINTS]
local WALL_BLUEPRINTS = {
    {Offset = Vector3.new(0, 0, 1),  Size = Vector3.new(FULL_SIDE_LENGTH, WALL_HEIGHT, WALL_THICKNESS)}, -- Front
    {Offset = Vector3.new(0, 0, -1), Size = Vector3.new(FULL_SIDE_LENGTH, WALL_HEIGHT, WALL_THICKNESS)}, -- Back
    {Offset = Vector3.new(1, 0, 0),  Size = Vector3.new(WALL_THICKNESS, WALL_HEIGHT, FULL_SIDE_LENGTH)}, -- Right
    {Offset = Vector3.new(-1, 0, 0), Size = Vector3.new(WALL_THICKNESS, WALL_HEIGHT, FULL_SIDE_LENGTH)}  -- Left
}

local activeBarriers = {}

-- [HELPER FUNCTIONS]
local function destroyBarriers()
    for _, barrier in ipairs(activeBarriers) do
        if barrier then barrier:Destroy() end
    end
    table.clear(activeBarriers)
end

local function createBarriers()
    for _, blueprint in ipairs(WALL_BLUEPRINTS) do
        local barrier = Instance.new("Part")
        local wallPosition = Vector3.new(
            CENTER_POINT.X + (blueprint.Offset.X * MAP_RADIUS),
            FINAL_Y,
            CENTER_POINT.Z + (blueprint.Offset.Z * MAP_RADIUS)
        )
        
        barrier.Size = blueprint.Size
        barrier.CFrame = CFrame.new(wallPosition)
        barrier.Anchored = true
        barrier.CanCollide = true
        barrier.CanTouch = false
        barrier.CanQuery = false
        barrier.Transparency = 1
        barrier.CastShadow = false
        
        barrier.Parent = workspace
        table.insert(activeBarriers, barrier)
    end
end

-- [MAIN INITIALIZATION]
function AntiVoid.Init(State)
    local Connection = RunService.Stepped:Connect(function()
        local Enabled = State.Toggles.AntiVoid
        
        if Enabled then
            if #activeBarriers == 0 then
                createBarriers()
            end
        else
            if #activeBarriers > 0 then
                destroyBarriers()
            end
        end
    end)
    
    table.insert(State.Connections, Connection)
end

return AntiVoid
