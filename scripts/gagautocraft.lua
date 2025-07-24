-- 🍳 Select your recipe and egg type by setting [true]
local recipes = {
	["Dinosaur Egg"] = true, -- > Common
	["Primal Egg"] = false, --> Dinosaur
}

local eggTypes = {
	["Common"] = true, --> Dinosaur
	["Dinosaur"] = false, --> Primal
}

local waitForZenEnd = false
local kick = false
local rejoin = true
local rejoinType = 1
local recipePrice = 5500000
local maxWeight = 30
local tptotable = true

if not game or not game.PlaceId then
	repeat task.wait() until game and game.PlaceId
end

if game.PlaceId ~= 63442347817033 * 2 then
	return
end

print("Starting\nStarting\nStarting")

local recipeName
local eggType

for name, isSelected in pairs(recipes) do
	if isSelected then
		recipeName = name
		break
	end
end

for name, isSelected in pairs(eggTypes) do
	if isSelected then
		eggType = name
		break
	end
end

while waitForZenEnd do
	local time = os.date("*t")
	if time.min and (time.min >= 11 or time.min < 59) then
		break
	end
	task.wait(1)
end

local player = game.Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local sheckles = player:WaitForChild("leaderstats"):WaitForChild("Sheckles")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local craftEvent = replicatedStorage:WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService")
local dinoEvent

repeat
	local success, result = pcall(function()
		local rs = replicatedStorage
		return rs:FindFirstChild("Modules")
			and rs.Modules:FindFirstChild("UpdateService")
			and rs.Modules.UpdateService:FindFirstChild("DinoEvent")
	end)

	if success and result then
		dinoEvent = result
	else
		success, result = pcall(function()
			return workspace:FindFirstChild("DinoEvent")
		end)

		if success and result then
			dinoEvent = result
		end
	end

	task.wait(0.1)
until dinoEvent
local craftingTable = dinoEvent:WaitForChild("DinoCraftingTable")
if dinoEvent.Parent ~= workspace then
	dinoEvent.Parent = workspace
end

while not craftingTable:FindFirstChild("CraftingProximityPrompt", true) do
	runService.RenderStepped:Wait()
end

local prompt = craftingTable:FindFirstChild("CraftingProximityPrompt", true)

if tptotable then
	local character = player.Character or player.CharacterAdded:Wait()
	character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(prompt.Parent.Position) + Vector3.new(0, 2, 0)
end

local function craft(...)
	local args = type(...) == "table" and ... or {...}
	table.insert(args, 2, craftingTable)
	table.insert(args, 3, "DinoEventWorkbench")
	craftEvent:FireServer(table.unpack(args))
end

if prompt and prompt.ActionText ~= "Select Recipe" then
	print("Cancelling old craft")
end

while prompt and prompt.ActionText ~= "Select Recipe" do
	craft("Cancel")
	runService.RenderStepped:Wait()
end

task.spawn(function()
	for i = 1, 3 do
		replicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyPetEgg"):FireServer("Common Egg")
		runService.RenderStepped:Wait()
	end
end)

-- Alternate egg type lookup
local alternateEggType = {
	Common = "Dinosaur",
	Dinosaur = "Common",
}

-- Try selected and alternate egg types
local eggTypeOptions = { eggType, alternateEggType[eggType] }
local eggItem, boneBlossomItem

print("Finding backpack items")

for _, eggKind in ipairs(eggTypeOptions) do
	for _, item in ipairs(backpack:GetChildren()) do
		if item:IsA("Tool") then
			-- Find matching egg item
			if not eggItem and item.Name:find(eggKind .. " Egg") then
				eggItem = item
				eggType = eggKind
			end
			-- Find valid Bone Blossom item
			if not boneBlossomItem
				and item.Name:find("Bone Blossom")
				and item.Name:find("kg")
				and item:GetAttribute("d") == false
				and #item:GetAttributes() < 10
			then
				boneBlossomItem = item
			end
			if eggItem and boneBlossomItem then break end
		end
	end
	if eggItem then break end
end

if eggItem then
	print("Found eggItem:", eggItem.Name)
end
if boneBlossomItem then
	print("Found boneBlossomItem:", boneBlossomItem.Name)
end
if not boneBlossomItem then
	print("No bone blossom!, Harvesting...")
	local conn
	conn = backpack.ChildAdded:Connect(function(item)
		if not boneBlossomItem and item:IsA("Tool") and item.Name:find("Bone Blossom") and item.Name:find("kg") and item:GetAttribute("d") == false and #item:GetAttributes() < 10 then
			boneBlossomItem = item
			print("Found Bone Blossom Item!, " .. boneBlossomItem.Name)
			if conn then conn:Disconnect() end
		end
	end)

	local important
	for _, plot in pairs(workspace:WaitForChild("Farm"):GetChildren()) do
		local node = plot:FindFirstChild("Important") or plot:FindFirstChild("Importanert")
		if node then
			local data = node:FindFirstChild("Data")
			if data and data:FindFirstChild("Owner") and data.Owner.Value == player.Name then
				important = node
				break
			end
		end
	end

	if important then
		local buffr = buffer.fromstring("\001\001\000\001")
		while not boneBlossomItem do
			for _, plant in ipairs(important:WaitForChild("Plants_Physical"):GetChildren()) do
				if plant.Name:find("Bone Blossom") and plant:FindFirstChild("Fruits") and not plant:GetAttribute("Favorited") then
					for _, fruit in pairs(plant.Fruits:GetChildren()) do
						local weight = fruit:FindFirstChild("Weight")
						if not fruit:GetAttribute("Favorited") and weight and weight.Value < maxWeight and #fruit:GetAttributes() < 10 then --and not fruit:GetAttribute("Tranquil")
							replicatedStorage:FindFirstChild("ByteNetReliable"):FireServer(
								buffr,
								{ fruit }
							)
							task.wait(1)
						end
						if boneBlossomItem then break end
					end
				end
				if boneBlossomItem then break end
			end
			if boneBlossomItem then break end
			task.wait(1)
		end
	end
end

local eggUUID = eggItem and eggItem:GetAttribute("c")
local boneBlossomUUID = boneBlossomItem and boneBlossomItem:GetAttribute("c")

if eggUUID and boneBlossomUUID then
	print("Crafting,", "eggType:", eggType, "Recipe Name:", recipeName)
	craft("SetRecipe", recipeName)
	craft("InputItem", 1, {ItemType = "PetEgg", ItemData = { UUID = eggUUID }})
	craft("InputItem", 2, {ItemType = "Holdable", ItemData = { UUID = boneBlossomUUID }})
	craft("Craft")
	while sheckles and (kick or rejoin) do
		local oldValue = sheckles.Value
		sheckles.Changed:Wait()
		local newValue = sheckles.Value

		-- Break the loop if the value drops by 5.5 million or more
		if newValue ~= oldValue and newValue <= oldValue - recipePrice then
			break
		end
	end
	if kick then
		player:Kick("Done!")
	end
	if rejoin then
		if rejoinType == 1 then
			game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
		elseif rejoinType == 2 then
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
		end
	end
else
	warn("⚠️ Missing required items: " ..
		(not eggUUID and eggType.." Egg" or "") ..
		(not boneBlossomUUID and "Bone Blossom" or ""))
end

print("Ending\nEnding\nEnding")
