local maxWeight = 30
local waitForZenEnd = false
local kick = false
local rejoin = true
local rejointype = 1
local tptotable = true
local Recipe = "Primal Egg" --"Dinosaur Egg"
local eggType = "Dinosaur" --"Common"

if not game or not game.PlaceId then
	repeat task.wait() until game and game.PlaceId
end

if game.PlaceId ~= 63442347817033 * 2 then
	return
end

print("Starting\nStarting\nStarting")

while waitForZenEnd do
	local time = os.date("*t")
	if time.min and (time.min >= 11 or time.min < 59) then
		break
	end
	task.wait(1)
end

local RunService = game:GetService("RunService")

local player = game.Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")


local sheckles = player:WaitForChild("leaderstats"):WaitForChild("Sheckles")
local craftEvent = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService")

local dinoEvent

repeat
    local success, result = pcall(function()
        local rs = game:GetService("ReplicatedStorage")
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

if dinoEvent.Parent ~= workspace then
    dinoEvent.Parent = workspace
end

local craftingTable = dinoEvent:WaitForChild("DinoCraftingTable")

while not craftingTable:FindFirstChild("CraftingProximityPrompt", true) do
	task.wait()
end

local prompt = craftingTable:FindFirstChild("CraftingProximityPrompt", true)

if tptotable then
	local character = player.Character or player.CharacterAdded:Wait()
	character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(prompt.Parent.Position) + Vector3.new(0, 2, 0)
end

local function promptwait(text)
	while prompt and prompt.ActionText ~= text do
		RunService.RenderStepped:Wait()
	end
end

local function craft(...)
	local args = type(...) == "table" and ... or {...}
	table.insert(args, 2, craftingTable)
	table.insert(args, 3, "DinoEventWorkbench")
	craftEvent:FireServer(table.unpack(args))
end

if prompt.ActionText ~= "Select Recipe" then
	craft("Cancel")
	promptwait("Select Recipe")
end

local eggItem, boneBlossomItem

for _, item in ipairs(backpack:GetChildren()) do
	if item:IsA("Tool") then
		if not eggItem and item.Name:find(eggType.." Egg") then
			eggItem = item
		end
		if not boneBlossomItem and item.Name:find("Bone Blossom") and item.Name:find("kg") and item:GetAttribute("d") == false and #item:GetAttributes() < 10 then
			boneBlossomItem = item
		end
		-- Break early if both found
		if eggItem and boneBlossomItem then break end
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
		while not boneBlossomItem do
			for _, plant in ipairs(important:WaitForChild("Plants_Physical"):GetChildren()) do
				if plant.Name:find("Bone Blossom") and plant:FindFirstChild("Fruits") then
					for _, fruit in pairs(plant.Fruits:GetChildren()) do
						local weight = fruit:FindFirstChild("Weight")
						if weight and weight.Value < maxWeight and not fruit:GetAttribute("Tranquil") and #fruit:GetAttributes() < 10 then
							game:GetService("ReplicatedStorage"):FindFirstChild("ByteNetReliable"):FireServer(
								buffer.fromstring("\001\001\000\001"),
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
	craft("SetRecipe", Recipe)
	craft("InputItem", 1, {ItemType = "PetEgg", ItemData = { UUID = eggUUID }})
	craft("InputItem", 2, {ItemType = "Holdable", ItemData = { UUID = boneBlossomUUID }})
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
		(not eggUUID and eggType.." Egg" or "") ..
		(not boneBlossomUUID and "Bone Blossom" or ""))
end

print("Ending\nEnding\nEnding")
