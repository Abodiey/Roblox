local AntiVoid = {}

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))

local LocalPlayer = Players.LocalPlayer

local CENTER_POINT = Vector3.zero
local MAP_RADIUS = 346
local TELEPORT_THRESHOLD = 100 
local WALL_HEIGHT = 500

local MIN_X = CENTER_POINT.X - MAP_RADIUS
local MAX_X = CENTER_POINT.X + MAP_RADIUS
local MIN_Z = CENTER_POINT.Z - MAP_RADIUS
local MAX_Z = CENTER_POINT.Z + MAP_RADIUS

local lastPosition = nil
local wallsFolder = nil

local function createWalls()
	if wallsFolder then return end
	
	wallsFolder = Instance.new("Folder")
	wallsFolder.Name = "AntiVoidVisualWalls"
	wallsFolder.Parent = workspace

	local thickness = 1
	local sizeX = (MAX_X - MIN_X)
	local sizeZ = (MAX_Z - MIN_Z)

	local wallConfigs = {
		-- Positive X (East)
		{ Size = Vector3.new(thickness, WALL_HEIGHT, sizeZ), CFrame = CFrame.new(MAX_X, CENTER_POINT.Y + (WALL_HEIGHT / 2), CENTER_POINT.Z) },
		-- Negative X (West)
		{ Size = Vector3.new(thickness, WALL_HEIGHT, sizeZ), CFrame = CFrame.new(MIN_X, CENTER_POINT.Y + (WALL_HEIGHT / 2), CENTER_POINT.Z) },
		-- Positive Z (South)
		{ Size = Vector3.new(sizeX, WALL_HEIGHT, thickness), CFrame = CFrame.new(CENTER_POINT.X, CENTER_POINT.Y + (WALL_HEIGHT / 2), MAX_Z) },
		-- Negative Z (North)
		{ Size = Vector3.new(sizeX, WALL_HEIGHT, thickness), CFrame = CFrame.new(CENTER_POINT.X, CENTER_POINT.Y + (WALL_HEIGHT / 2), MIN_Z) },
	}

	for _, config in ipairs(wallConfigs) do
		local part = Instance.new("Part")
		part.Size = config.Size
		part.CFrame = config.CFrame
		part.Anchored = true
		part.CanCollide = false
		part.Transparency = 0.75
		part.Material = Enum.Material.SmoothPlastic
		part.CastShadow = false
		part.Parent = wallsFolder
	end
end

local function removeWalls()
	if wallsFolder then
		wallsFolder:Destroy()
		wallsFolder = nil
	end
end

function AntiVoid.Init(State)
	local Connection = RunService.Heartbeat:Connect(function()
		local Enabled = State.Toggles.AntiVoid.Value
		
		if not Enabled then 
			lastPosition = nil
			removeWalls()
			return 
		end
		
		createWalls()
		
		local Character = LocalPlayer.Character
		if not Character then 
			lastPosition = nil
			return 
		end
		
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
		
		if lastPosition then
			local distanceMoved = (currentPosition - lastPosition).Magnitude
			if distanceMoved > TELEPORT_THRESHOLD then
				lastPosition = currentPosition
				return
			end
		end
		
		if currentPosition.X < MIN_X or currentPosition.X > MAX_X or currentPosition.Z < MIN_Z or currentPosition.Z > MAX_Z then
			local clampedX = math.clamp(currentPosition.X, MIN_X, MAX_X)
			local clampedZ = math.clamp(currentPosition.Z, MIN_Z, MAX_Z)
			
			local targetPosition = Vector3.new(clampedX, currentPosition.Y, clampedZ)
			
			local currentCFrame = Character:GetPivot()
			Character:PivotTo(CFrame.new(targetPosition) * currentCFrame.Rotation)
			
			RootPart.AssemblyLinearVelocity = Vector3.zero
			RootPart.AssemblyAngularVelocity = Vector3.zero
			
			lastPosition = targetPosition
		else
			lastPosition = currentPosition
		end
	end)
	
	table.insert(State.Connections, Connection)
end

return AntiVoid
