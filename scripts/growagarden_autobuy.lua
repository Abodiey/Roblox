--loadstring(game:HttpGet("https://raw.githubusercontent.com/Abodiey/Roblox/refs/heads/main/scripts/growagarden_autobuy.lua"))()
if not game.PlaceId == 126884695634066 then return end
type table = {
	[any]: any
}

_G.Configuration = {
	--// Reporting
	["Enabled"] = true,
	--// User
	["Anti-AFK"] = true,
	["Auto-Reconnect"] = true,
	["Rendering Enabled"] = true,
	--// Functions
	["Auto-Buy-Seeds"] = true,
	["Auto-Buy-Gear"] = true,
	["Auto-Buy-Eggs"] = true,
	["Auto-Buy-Bee-Egg"] = true,
	["Auto-Craft-Anti-Bee-Egg"] = true,
	["Auto-Craft-Crafters-Seed-Pack"] = true,
	--// Options
	["Seeds-To-Buy"] = {"Carrot","Strawberry","Blueberry","Orange Tulip","Tomato","Corn","Daffodil","Pumpkin","Apple","Bamboo","Coconut","Cactus","Dragon Fruit","Mango","Grape","Mushroom","Pepper","Cacao","Beanstalk","Ember Lily","Sugar Apple"},
	["Gears-To-Buy"] = {"Watering Can","Trowel","Recall Wrench","Basic Sprinkler","Advanced Sprinkler","Godly Sprinkler","Lightning Rod","Master Sprinkler"},
	["Eggs-To-Buy"] = {1,2,3}
}


--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local VirtualUser = cloneref(game:GetService("VirtualUser"))
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer

local function GetConfigValue(Key: string)
	return _G.Configuration[Key]
end

--// Set rendering enabled
local Rendering = GetConfigValue("Rendering Enabled")
RunService:Set3dRenderingEnabled(Rendering)


--// Anti idle
LocalPlayer.Idled:Connect(function()
	--// Check if Anti-AFK is enabled
	local AntiAFK = GetConfigValue("Anti-AFK")
	if not AntiAFK then return end

	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

--// Auto reconnect
GuiService.ErrorMessageChanged:Connect(function()
	local IsSingle = #Players:GetPlayers() <= 1
	local PlaceId = game.PlaceId
	local JobId = game.JobId

	--// Check if Auto-Reconnect is enabled
	local AutoReconnect = GetConfigValue("Auto-Reconnect")
	if not AutoReconnect then return end

	queue_on_teleport("https://raw.githubusercontent.com/Abodiey/Roblox/refs/heads/main/scripts/growagarden_autobuy.lua")

	--// Join a different server if the player is solo
	if IsSingle then
		TeleportService:Teleport(PlaceId, LocalPlayer)
		return
	end

	TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
end)

task.spawn(function()
while GetConfigValue("Enabled") do
	local AutoBuySeeds = GetConfigValue("Auto-Buy-Seeds")
	if AutoBuySeeds then
		local SeedsToBuy = GetConfigValue("Seeds-To-Buy")
		for _,Seed in pairs(SeedsToBuy) do
			game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuySeedStock"):FireServer(Seed)
			task.wait()
		end
	end
	task.wait()
end
end)

--_G.Gears = {"Watering Can","Trowel","Recall Wrench","Basic Sprinkler","Advanced Sprinkler","Godly Sprinkler","Lightning Rod","Master Sprinkler","Cleaning Spray","Favorite Tool","Harvest Tool","Friendship Pot"}
task.spawn(function()
while GetConfigValue("Enabled") do
	local AutoBuyGear = GetConfigValue("Auto-Buy-Gear")
	if AutoBuyGear then
		local GearsToBuy = GetConfigValue("Gears-To-Buy")
		for _,Gear in pairs(GearsToBuy) do
			game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyGearStock"):FireServer(Gear)
			task.wait()
			task.wait()
		end
	end
	task.wait()
end
end)

task.spawn(function()
while GetConfigValue("Enabled") do
	local AutoBuyEggs = GetConfigValue("Auto-Buy-Eggs")
	if AutoBuyEggs then
		local EggsToBuy = GetConfigValue("Eggs-To-Buy")
		for _,Egg in pairs(EggsToBuy) do
			game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyPetEgg"):FireServer(Egg)
			task.wait(1)
		end
	end
	task.wait(60)
end
end)

task.spawn(function()
while GetConfigValue("Enabled") do
	local AutoBuyBeeEgg = GetConfigValue("Auto-Buy-Bee-Egg")
	if AutoBuyBeeEgg then
		game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyEventShopStock"):FireServer("Bee Egg")
	end
	task.wait(60)
end
end)

task.spawn(function()
while GetConfigValue("Enabled") do
	local AutoCraftAntiBeeEgg = GetConfigValue("Auto-Craft-Anti-Bee-Egg")
	if AutoCraftAntiBeeEgg then
				local args = {
			"Claim",
			workspace:WaitForChild("Interaction"):WaitForChild("UpdateItems"):WaitForChild("NewCrafting"):WaitForChild("EventCraftingWorkBench"),
			"GearEventWorkbench",
			1
		}
		game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
		local BeeEgg
			for _,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
				if v and v.Name and string.match(v.Name, "^".."Bee Egg") then
					BeeEgg = v
				break
			end
		end
		if not BeeEgg then
			for _,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
				if v and v.Name and string.match(v.Name, "^".."Bee Egg") then
					BeeEgg = v
					break
				end
			end
		end
		if not BeeEgg then task.wait(10) return end
		game.Players.LocalPlayer.Character.Humanoid:EquipTool(BeeEgg)
		local args = {
			"Cancel",
			workspace:WaitForChild("Interaction"):WaitForChild("UpdateItems"):WaitForChild("NewCrafting"):WaitForChild("EventCraftingWorkBench"),
			"GearEventWorkbench"
		}
		game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
		task.wait(1)
		local args = {
			"SetRecipe",
			workspace:WaitForChild("Interaction"):WaitForChild("UpdateItems"):WaitForChild("NewCrafting"):WaitForChild("EventCraftingWorkBench"),
			"GearEventWorkbench",
			"Anti Bee Egg"
		}
		game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
		task.wait(1)
		local prompt = Workspace.Interaction.UpdateItems.NewCrafting.EventCraftingWorkBench:FindFirstChild("CraftingProximityPrompt", true)
		fireproximityprompt(prompt)
		task.wait(1)
		local args = {
			"Craft",
			workspace:WaitForChild("Interaction"):WaitForChild("UpdateItems"):WaitForChild("NewCrafting"):WaitForChild("EventCraftingWorkBench"),
			"GearEventWorkbench"
		}
		game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
	end
	task.wait(30)
	local AutoCraftCraftersSeedPack = GetConfigValue("Auto-Craft-Crafters-Seed-Pack")
	if AutoCraftCraftersSeedPack then
		local args = {
			"Claim",
			workspace:WaitForChild("Interaction"):WaitForChild("UpdateItems"):WaitForChild("NewCrafting"):WaitForChild("SeedEventCraftingWorkBench"),
			"SeedEventWorkbench",
			1
		}
		game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
		local FlowerSeedPack 
		for _,v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
			if v and v.Name and string.match(v.Name, "^".."Flower Seed Pack") then
				FlowerSeedPack = v
				break
			end
		end
		if not FlowerSeedPack then
			for _,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
				if v and v.Name and string.match(v.Name, "^".."Flower Seed Pack") then
					FlowerSeedPack = v
					break
				end
			end
		end
		if not FlowerSeedPack then task.wait(10) return end
		game.Players.LocalPlayer.Character.Humanoid:EquipTool(FlowerSeedPack)
		local args = {
			"Cancel",
			workspace:WaitForChild("Interaction"):WaitForChild("UpdateItems"):WaitForChild("NewCrafting"):WaitForChild("SeedEventCraftingWorkBench"),
			"SeedEventWorkbench"
		}
		game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
		task.wait(1)
		local args = {
			"SetRecipe",
			workspace:WaitForChild("Interaction"):WaitForChild("UpdateItems"):WaitForChild("NewCrafting"):WaitForChild("SeedEventCraftingWorkBench"),
			"SeedEventWorkbench",
			"Crafters Seed Pack"
		}
		game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
		task.wait(1)
		local prompt = Workspace.Interaction.UpdateItems.NewCrafting.SeedEventCraftingWorkBench:FindFirstChild("CraftingProximityPrompt", true)
		fireproximityprompt(prompt)
		task.wait(1)
		local args = {
			"Craft",
			workspace:WaitForChild("Interaction"):WaitForChild("UpdateItems"):WaitForChild("NewCrafting"):WaitForChild("SeedEventCraftingWorkBench"),
			"SeedEventWorkbench"
		}
		game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
	end
	task.wait(60)
end
end)
