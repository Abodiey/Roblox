local maxWeight = 30
local waitForZenEnd = true
local kick = false
local rejoin = true
local rejointype = 1

if not game or not game.PlaceId then
	repeat task.wait() until game and game.PlaceId
end

if game.PlaceId ~= 63442347817033 * 2 then
	return
end

while waitForZenEnd do
	local time = os.date("*t")
	if time.min and time.min >= 11 then
		break
	end
	task.wait(1)
end

local RunService = game:GetService("RunService")

local player = game.Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local character = player.Character or player.CharacterAdded:Wait()

local sheckles = player:WaitForChild("leaderstats"):WaitForChild("Sheckles")
local craftEvent = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService")
local craftingTable = workspace:WaitForChild("DinoEvent"):WaitForChild("DinoCraftingTable")

local function craft(...)
	local args = type(...) == "table" and ... or {...}
	table.insert(args, 2, craftingTable)
	table.insert(args, 3, "DinoEventWorkbench")
	craftEvent:FireServer(table.unpack(args))
end

while not craftingTable:FindFirstChild("CraftingProximityPrompt", true) do
	task.wait()
end

local prompt = craftingTable:FindFirstChild("CraftingProximityPrompt", true) 

local function promptwait(text)
	while prompt and prompt.ActionText ~= text do
		RunService.RenderStepped:Wait()
	end
end

if prompt.ActionText ~= "Select Recipe" then
	craft("Cancel")
	promptwait("Select Recipe")
end

local commonEggItem, boneBlossomItem

for _, item in ipairs(backpack:GetChildren()) do
	if item:IsA("Tool") then
		if not commonEggItem and item.Name:find("Common Egg") then
			commonEggItem = item
		end
		if not boneBlossomItem and item.Name:find("Bone Blossom") and item.Name:find("kg") and item:GetAttribute("d") == false and #item:GetAttributes() < 10 then
			boneBlossomItem = item
		end
		-- Break early if both found
		if commonEggItem and boneBlossomItem then break end
	end
end

if not boneBlossomItem then
	local conn
	conn = backpack.ChildAdded:Connect(function(item)
		if not boneBlossomItem and item:IsA("Tool") and item.Name:find("Bone Blossom") and item.Name:find("kg") and item:GetAttribute("d") == false and #item:GetAttributes() < 10 then
			boneBlossomItem = item
			conn:Disconnect()
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
		for _, plant in ipairs(important:WaitForChild("Plants_Physical"):GetChildren()) do
			if plant.Name:find("Bone Blossom") and plant:FindFirstChild("Fruits") then
				for _, fruit in pairs(plant.Fruits:GetChildren()) do
					local weight = fruit:FindFirstChild("Weight")
					if weight and weight.Value < maxWeight and not fruit:GetAttribute("Tranquil") and #fruit:GetAttributes() < 10 then
						game:GetService("ReplicatedStorage"):FindFirstChild("ByteNetReliable"):FireServer(
							buffer.fromstring("\001\001\000\001"),
							{ fruit }
						)
						task.wait(0.1)
					end
					if boneBlossomItem then break end
				end
			end
			if boneBlossomItem then break end
		end
	end
end

local commonEggUUID = commonEggItem and commonEggItem:GetAttribute("c")
local boneBlossomUUID = boneBlossomItem and boneBlossomItem:GetAttribute("c")

local commonEggName = commonEggItem and commonEggItem.Name

if commonEggUUID and boneBlossomUUID then
	craft("SetRecipe","Dinosaur Egg")
	promptwait("Submit Item")
	craft("InputItem", 1, {ItemType = "PetEgg", ItemData = { UUID = commonEggUUID }})
	repeat RunService.RenderStepped:Wait() until not commonEggItem or not commonEggItem.Parent or commonEggName ~= commonEggItem.Name
	craft("InputItem", 2, {ItemType = "Holdable", ItemData = { UUID = boneBlossomUUID }})
	repeat RunService.RenderStepped:Wait() until not boneBlossomItem or not boneBlossomItem.Parent
	craft("Craft")
	while sheckles and (kick or rejoin) do
		local oldValue = sheckles.Value
		sheckles.Changed:Wait()
		local newValue = sheckles.Value

		-- Break the loop if the value drops by 5.5 million or more
		if newValue ~= oldValue and newValue <= oldValue - 5500000 then
			break
		end
	end
	if kick then
		player:Kick("Done!")
	end
	if rejoin then
		if rejointype == 1 then
			game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
		elseif rejointype == 2 then
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
		end
	end
else
	warn("⚠️ Missing required items: " ..
		(not commonEggUUID and "Common Egg " or "") ..
		(not boneBlossomUUID and "Bone Blossom" or ""))
end
