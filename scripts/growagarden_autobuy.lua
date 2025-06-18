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
	["Auto-Reconnect"] = false,
	["Rendering Enabled"] = true,
	--// Functions
	["Auto-Buy-Seeds"] = {
		["Enabled"] = true,
		["Buy"] = {"Carrot","Strawberry","Blueberry","Orange Tulip","Tomato","Corn","Daffodil","Pumpkin","Apple","Bamboo","Coconut","Cactus","Dragon Fruit","Mango","Grape","Mushroom","Pepper","Cacao","Beanstalk","Ember Lily","Sugar Apple"}
	}
	["Auto-Buy-Gear"] = {
		["Enabled"] = true,
		["Buy"] = {"Watering Can","Trowel","Recall Wrench","Basic Sprinkler","Advanced Sprinkler","Godly Sprinkler","Lightning Rod","Master Sprinkler"},
	["Auto-Buy-Eggs"] = {
		["Enabled"] = true,
		["Buy"] = {1,2,3}
	["Auto-Buy-Honey-Shop"] = {
		["Enabled"] = true,
		["Buy"] = {"Bee Egg"}
	},
	["Auto-Craft-Anti-Bee-Egg"] = false,
	["Auto-Craft-Crafters-Seed-Pack"] = false,
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

local function getItem(name, startsWith, equals)
    local item = false
    local isEquipped = false
    for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v and v.Name then
            if (equals and v.Name == name) or (startsWith and string.match(v.Name, "^" .. name)) then
                item = v
                isEquipped = true
                break
            end
        end
    end
    if not item then
        for _, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
            if v and v.Name then
                if (equals and v.Name == name) or (startsWith and string.match(v.Name, "^" .. name)) then
                    item = v
                    isEquipped = false
                    break
                end
            end
        end
    end

    return item, isEquipped
end

task.spawn(function()
while GetConfigValue("Enabled") do
	local AutoBuySeeds = GetConfigValue("Auto-Buy-Seeds")["Enabled"]
	if AutoBuySeeds then
		local SeedsToBuy = GetConfigValue("Auto-Buy-Seeds")["Buy"]
		for _,Seed in pairs(SeedsToBuy) do
			game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuySeedStock"):FireServer(Seed)
			task.wait()
		end
	end
	task.wait()
end
end)

--List of Gears = {"Watering Can","Trowel","Recall Wrench","Basic Sprinkler","Advanced Sprinkler","Godly Sprinkler","Lightning Rod","Master Sprinkler","Cleaning Spray","Favorite Tool","Harvest Tool","Friendship Pot"}
task.spawn(function()
while GetConfigValue("Enabled") do
	local AutoBuyGear = GetConfigValue("Auto-Buy-Gear")["Enabled"]
	if AutoBuyGear then
		local GearsToBuy = GetConfigValue("Auto-Buy-Gear")["Buy"]
		for _,Gear in pairs(GearsToBuy) do
			game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyGearStock"):FireServer(Gear)
			task.wait() task.wait()
		end
	end
	task.wait()
end
end)

task.spawn(function()
while GetConfigValue("Enabled") do
	local AutoBuyEggs = GetConfigValue("Auto-Buy-Eggs")["Enabled"]
	if AutoBuyEggs then
		local EggsToBuy = GetConfigValue("Auto-Buy-Eggs")["Buy"]
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
	local AutoBuyHoneyShop = GetConfigValue("Auto-Buy-Honey-Shop")["Enabled"]
	if AutoBuyHoneyShop then
		local HoneysToBuy = GetConfigValue("Auto-Buy-Honey-Shop")["Buy"]
		for _,Item in pairs(HoneysToBuy) do
			game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyEventShopStock"):FireServer(Item)
			task.wait(1)
		end
	end
	task.wait(60)
end
end)

task.spawn(function()
while GetConfigValue("Enabled") do
	local AutoCraftAntiBeeEgg = GetConfigValue("Auto-Craft-Anti-Bee-Egg")
	if AutoCraftAntiBeeEgg then
		local EventCraftingWorkBench = Workspace.Interaction.UpdateItems.NewCrafting.EventCraftingWorkBench
		local EventCraftingPrompt = EventCraftingWorkBench:FindFirstChild("CraftingProximityPrompt", true)
		if EventCraftingPrompt and EventCraftingPrompt.ActionText == "Skip" then return end
		
		if EventCraftingPrompt and EventCraftingPrompt.ActionText == "Claim" then
 			local args = {"Claim",EventCraftingWorkBench,"GearEventWorkbench",1}
			game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
			task.wait(1)
		end
		
		if EventCraftingPrompt and (EventCraftingPrompt.ActionText == "Submit Item" or string.match(EventCraftingPrompt.ActionText, "^".."Start Crafting")) then
		    local args = {"Cancel",EventCraftingWorkBench,"GearEventWorkbench"}
		    game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
		    task.wait(1)
		end
		
		local BeeEgg, isEquipped = getItem("Bee Egg", true)
		if not BeeEgg or not EventCraftingPrompt or EventCraftingPrompt.ActionText ~= "Select Recipe" then return end
		local args = {"SetRecipe",EventCraftingWorkBench,"GearEventWorkbench","Anti Bee Egg"}
		game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
		task.wait(1)
		
		local itemUUID = BeeEgg:GetAttribute("c")
		local args = {
			"InputItem",
			EventCraftingWorkBench,
			"GearEventWorkbench",
			1,
			{
				ItemType = "PetEgg",
				ItemData = {
					UUID = itemUUID
				}
			}
		}
		game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
		task.wait(1)
		local args = {"Craft",EventCraftingWorkBench,"GearEventWorkbench"}
		game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
	end
	task.wait(10)
	local AutoCraftCraftersSeedPack = GetConfigValue("Auto-Craft-Crafters-Seed-Pack")
	if AutoCraftCraftersSeedPack then
		local SeedEventCraftingWorkBench = Workspace.Interaction.UpdateItems.NewCrafting.SeedEventCraftingWorkBench
		local SeedEventCraftingPrompt = SeedEventCraftingWorkBench:FindFirstChild("CraftingProximityPrompt", true)
		if SeedEventCraftingPrompt and SeedEventCraftingPrompt.ActionText == "Skip" then return end
		if SeedEventCraftingPrompt and SeedEventCraftingPrompt.ActionText == "Claim" then
			local args = {"Claim",SeedEventCraftingWorkBench,"SeedEventWorkbench",1}
			game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
			task.wait(1)
		end
		if SeedEventCraftingPrompt and SeedEventCraftingPrompt.ActionText == "Submit Item" or string.match(SeedEventCraftingPrompt.ActionText, "^".."Start Crafting") then
			local args = {"Cancel",SeedEventCraftingWorkBench,"SeedEventWorkbench"}
			game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
			task.wait(1)
		end
		local FlowerSeedPack, isEquipped = getItem("Flower Seed Pack", true)
		if not FlowerSeedPack or not SeedEventCraftingPrompt or SeedEventCraftingPrompt.ActionText ~= "Select Recipe" then return end
		local args = {"SetRecipe",SeedEventCraftingWorkBench,"SeedEventWorkbench","Crafters Seed Pack"}
		game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
		task.wait(1)
		local itemUUID = FlowerSeedPack:GetAttribute("c")
		local args = {
			"InputItem",
			SeedEventCraftingWorkBench,
			"SeedEventWorkbench",
			1,
			{
				ItemType = "Seed Pack",
				ItemData = {
					UUID = itemUUID
				}
			}
		}
		game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
		task.wait(1)
		local args = {"Craft",SeedEventCraftingWorkBench,"SeedEventWorkbench"}
		game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
	end
	task.wait(10)
end
end)
