--loadstring(game:HttpGet("https://raw.githubusercontent.com/Abodiey/Roblox/refs/heads/main/scripts/growagarden_autobuy.lua"))()
--[[
_G.Configuration["Discord"]["Webhook"] = "linkhere"
_G.Configuration["Discord"]["Enabled"] = true
]]
if game.PlaceId ~= tonumber(63442347817033*2) then return end
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
	["Discord"] = {
		["Enabled"] = false, --override in autoexecute
		["Webhook"] = "",
		["Alert"] = {
			{"Bug Egg","startswith",Color3.new(0,1,0)},
			{"Mythical Egg","startswith",Color3.new(1, 1, 0)},
			{"Legendary Egg","startswith",Color3.new(1,0,0)},
			
			{"Sugar Apple","startswith",Color3.new(0,1,0)},
			{"Ember Lily","startswith",Color3.new(1, 1/2, 0)},
			{"Beanstalk","startswith",Color3.new(0,1,0)},
			{"Grape","startswith",Color3.new(1/2, 0, 1)},
			
			{"Master Sprinkler","startswith",Color3.new(0,1,0)},
			{"Lightning Rod","startswith",Color3.new(0.75, 0.75, 0.75)},
			
			{"Bee Egg","startswith",Color3.new(1,0.5,0)},
			{"Honey Sprinkler","startswith",Color3.new(1, 0.5, 0)},
		}
	},
	["Auto-Buy-Seeds"] = {
		["Enabled"] = true,
		["Buy"] = {"Carrot","Strawberry","Blueberry","Orange Tulip","Tomato","Corn","Daffodil","Watermelon","Pumpkin","Apple","Bamboo","Coconut","Cactus","Dragon Fruit","Mango","Grape","Mushroom","Pepper","Cacao","Beanstalk","Ember Lily","Sugar Apple"}
	},
	["Auto-Buy-Gear"] = {
		["Enabled"] = true,
		["Buy"] = {"Watering Can","Trowel","Recall Wrench","Basic Sprinkler","Advanced Sprinkler","Godly Sprinkler","Lightning Rod","Master Sprinkler"}
	},
	["Auto-Buy-Eggs"] = {
		["Enabled"] = true,
		["Buy"] = {1,2,3}
	},
	["Auto-Buy-Honey-Shop"] = {
		["Enabled"] = true,
		["Buy"] = {"Bee Egg","Flower Seed Pack","Honey Sprinkler"}
	},
	["Auto-Craft"] = {
		["Enabled"] = true,
		["Craft"] = {
			["Anti Bee Egg"] = true,
			["Crafters Seed Pack"] = true,
			["Mutation Spray Choc"] = true
		}
	},
	["Auto-Honey-Machine"] = {
		["Enabled"] = true,
		["Convert"] = {"Coconut"}
	},
}


--// Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local cloneref = cloneref or function(o) return o end
local VirtualUser = cloneref(game:GetService("VirtualUser"))
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local function GetConfigValue(Key: string)
	return _G.Configuration[Key]
end

local function ConvertColor3(Color: Color3): number
	local Hex = Color:ToHex()
	return tonumber(Hex, 16)
end

local function GetDataPacket(Data, Target: string)
	for _, Packet in Data do
		local Name = Packet[1]
		local Content = Packet[2]

		if Name == Target then
			return Content
		end
	end

	return 
end

local function WebhookSend(Color: Color3, Fields: table)
	local Enabled = GetConfigValue("Discord")["Enabled"]
	local Webhook = GetConfigValue("Discord")["Webhook"]

	--// Check if reports are enabled
	if not Enabled then return end

	local Color = ConvertColor3(Color)

	--// Webhook data
	local TimeStamp = DateTime.now():ToIsoDate()
	local Body = {
		embeds = {
			{
				color = Color,
				fields = Fields,
				footer = {
					text = "Created by depso" -- Please keep
				},
				timestamp = TimeStamp
			}
		}
	}

	local RequestData = {
		Url = Webhook,
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = HttpService:JSONEncode(Body)
	}

	--// Send POST request to the webhook
	task.spawn(request, RequestData)
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

	local queue_on_teleport = queue_on_teleport or function() end
	queue_on_teleport("https://raw.githubusercontent.com/Abodiey/Roblox/refs/heads/main/scripts/growagarden_autobuy.lua")

	--// Join a different server if the player is solo
	if IsSingle then
		TeleportService:Teleport(PlaceId, LocalPlayer)
		return
	end

	TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
end)

local function searchMethod(itemName: string, searchMethodName: string, name: string)
	local searchMethodName = searchMethodName or ""
	searchMethodName = searchMethodName:lower()
	if itemName then
		if (searchMethodName == "equals" and itemName == name) or (searchMethodName == "startswith" and string.match(itemName, "^" .. name)) or (searchMethodName == "contains" and itemName:find(name)) then
			return true
		end
	end
	return false
end

local function getItem(name: string, searchMethodName: string) --equals, startswith, contains
	local searchMethodName = searchMethodName or ""
	searchMethodName = searchMethodName:lower()
	local item
	for _, v in pairs(LocalPlayer.Character:GetChildren()) do
		if v and v.Name and searchMethod(v.Name, searchMethodName, name) then
			item = v
			break
		end
	end

	if item then return item end
	for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
		if v and v.Name and searchMethod(v.Name, searchMethodName, name) then
			item = v
			break
		end
	end
	return item
end

task.spawn(function()
	if GetConfigValue("Enabled") then
		local Discord = GetConfigValue("Discord")
		while not Discord["Enabled"] do
			task.wait()
		end
		local alertList = Discord["Alert"]
		local backpack = LocalPlayer.Backpack
		for _,v in pairs(alertList) do
			local name = v[1]
			local method = v[2]
			local color = v[3]
			local item = getItem(name, method)
			if item and item.Name and not item:GetAttribute("Watching") then
				task.spawn(function()
					item:SetAttribute("Watching", true)
					local previousAmount = tonumber(item.Name:match("%d+"))
					item:GetPropertyChangedSignal("Name"):Connect(function()
						local newAmount = tonumber(item.Name:match("%d+"))
						if newAmount > previousAmount then
							WebhookSend(color, {
								{
									name = name,
									value = "@everyone "..name,
									inline = true
								}
							})
						end
						previousAmount = newAmount
					end)
				end)
			end
		end
		backpack.ChildAdded:Connect(function(item: Instance) 
			if item and item.Name and not item:GetAttribute("Watching") then
				for _,v in pairs(alertList) do
					local name = v[1]
					local method = v[2]
					local color = v[3]
					if searchMethod(item.Name, method, name) then
						task.spawn(function()
							item:SetAttribute("Watching", true)
							local previousAmount = tonumber(item.Name:match("%d+"))
							item:GetPropertyChangedSignal("Name"):Connect(function()
								local newAmount = tonumber(item.Name:match("%d+"))
								if newAmount > previousAmount then
									WebhookSend(color, {
										{
											name = name,
											value = "@everyone "..name,
											inline = true
										}
									})
								end
							end)
						end)
					end
				end
			end
		end)
	end
end)
task.spawn(function()
	while GetConfigValue("Enabled") do
		local AutoBuySeeds = GetConfigValue("Auto-Buy-Seeds")
		if AutoBuySeeds["Enabled"] then
			local SeedsToBuy = AutoBuySeeds["Buy"]
			for _,Seed in pairs(SeedsToBuy) do
				game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuySeedStock"):FireServer(Seed)
				task.wait()task.wait()
			end
		end
		task.wait()
	end
end)

--List of Gears = {"Watering Can","Trowel","Recall Wrench","Basic Sprinkler","Advanced Sprinkler","Godly Sprinkler","Lightning Rod","Master Sprinkler","Cleaning Spray","Favorite Tool","Harvest Tool","Friendship Pot"}
task.spawn(function()
	while GetConfigValue("Enabled") do
		local AutoBuyGear = GetConfigValue("Auto-Buy-Gear")
		if AutoBuyGear["Enabled"] then
			local GearToBuy = AutoBuyGear["Buy"]
			for _,Gear in pairs(GearToBuy) do
				game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyGearStock"):FireServer(Gear)
				task.wait() task.wait() task.wait() task.wait()
			end
		end
		task.wait()
	end
end)

task.spawn(function()
	while GetConfigValue("Enabled") do
		local AutoBuyEggs = GetConfigValue("Auto-Buy-Eggs")
		if AutoBuyEggs["Enabled"] then
			local EggsToBuy = AutoBuyEggs["Buy"]
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
		local AutoBuyHoneyShop = GetConfigValue("Auto-Buy-Honey-Shop")
		if AutoBuyHoneyShop["Enabled"] then
			local HoneysToBuy = AutoBuyHoneyShop["Buy"]
			for _,Item in pairs(HoneysToBuy) do
				game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyEventShopStock"):FireServer(tostring(Item))
				task.wait(1)
			end
		end
		task.wait(10)
	end
end)

task.spawn(function()
	while GetConfigValue("Enabled") do
		local AutoHoneyMachine = GetConfigValue("Auto-Honey-Machine")
		if AutoHoneyMachine["Enabled"] then
			while not Workspace.HoneyCombpressor.Onett:FindFirstChild"HoneyCombpressorPrompt" and not Workspace.HoneyCombpressor.Spout.Jar:FindFirstChild"HoneyCombpressorPrompt" do task.wait() end
			if Workspace.HoneyCombpressor.Onett:FindFirstChild"HoneyCombpressorPrompt" then --honey machine empty, give a fruit to onett
				while Workspace.HoneyCombpressor.Onett:FindFirstChild"HoneyCombpressorPrompt" and not Workspace.HoneyCombpressor.Spout.Jar:FindFirstChild"HoneyCombpressorPrompt" do
					local fruit
					for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
						if v and v.Name:find("Pollinated") and (not v:GetAttribute("d") or v:GetAttribute("d") ~= true) and AutoHoneyMachine["Enabled"] then
							for ii,vv in pairs(AutoHoneyMachine["Convert"]) do
								if v.Name:find(vv) then
									fruit = v
									break
								end
								if fruit then break end
							end
							if i%1000 == 0 then task.wait() end
						end
						if fruit then
							game.Players.LocalPlayer.Character.Humanoid:EquipTool(fruit)
							game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("HoneyMachineService_RE"):FireServer("MachineInteract")
							task.wait(1)
							break
						end
					end
					task.wait()
				end
			elseif Workspace.HoneyCombpressor.Spout.Jar:FindFirstChild"HoneyCombpressorPrompt" then --honey machine done, click collect
				game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("HoneyMachineService_RE"):FireServer("MachineInteract")
				task.wait(1)
			end
		end
		task.wait()
	end
end)

task.spawn(function()
	while GetConfigValue("Enabled") do
		local AutoCraft = GetConfigValue("Auto-Craft")
		local AutoCraftAntiBeeEgg = AutoCraft["Craft"]["Anti Bee Egg"]
		if AutoCraft["Enabled"] and AutoCraftAntiBeeEgg then
			local EventCraftingWorkBench = workspace.NewCrafting.EventCraftingWorkBench
			local EventCraftingPrompt = EventCraftingWorkBench:FindFirstChild("CraftingProximityPrompt", true)
			if EventCraftingPrompt and EventCraftingPrompt.ActionText ~= "Skip" then
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

				local BeeEgg = getItem("Bee Egg", "startswith")
				if BeeEgg and EventCraftingPrompt and EventCraftingPrompt.ActionText == "Select Recipe" then
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
			end
		end
		task.wait(3)
		local AutoCraft = GetConfigValue("Auto-Craft")
		local AutoCraftChocSpray = AutoCraft["Craft"]["Mutation Spray Choc"]
		if AutoCraft["Enabled"] and AutoCraftChocSpray then
			local EventCraftingWorkBench = Workspace.NewCrafting.EventCraftingWorkBench
			local EventCraftingPrompt = EventCraftingWorkBench:FindFirstChild("CraftingProximityPrompt", true)
			if EventCraftingPrompt and EventCraftingPrompt.ActionText ~= "Skip" then
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

				local Cacao = getItem("Cacao %[", "contains")
				local cleaningSpray = getItem("Cleaning Spray", "startswith")
				if cleaningSpray and Cacao and EventCraftingPrompt and EventCraftingPrompt.ActionText == "Select Recipe" then
					local args = {"SetRecipe",EventCraftingWorkBench,"GearEventWorkbench","Mutation Spray Choc"}
					game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
					task.wait(1)

					local itemUUID = cleaningSpray:GetAttribute("c")
					local args = {
						"InputItem",
						EventCraftingWorkBench,
						"GearEventWorkbench",
						1,
						{
							ItemType = "SprayBottle",
							ItemData = {
								UUID = itemUUID
							}
						}
					}
					game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService"):FireServer(unpack(args))
					task.wait(1)
					local itemUUID = Cacao:GetAttribute("c")
					local args = {
						"InputItem",
						EventCraftingWorkBench,
						"GearEventWorkbench",
						2,
						{
							ItemType = "Holdable",
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
			end
		end
		task.wait(3)
		local AutoCraft = GetConfigValue("Auto-Craft")
		local AutoCraftCraftersSeedPack = AutoCraft["Craft"]["Crafters Seed Pack"]
		if AutoCraft["Enabled"] and AutoCraftCraftersSeedPack then
			local SeedEventCraftingWorkBench = workspace.NewCrafting.SeedEventCraftingWorkBench
			local SeedEventCraftingPrompt = SeedEventCraftingWorkBench:FindFirstChild("CraftingProximityPrompt", true)
			if SeedEventCraftingPrompt and SeedEventCraftingPrompt.ActionText ~= "Skip" then
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
				local FlowerSeedPack = getItem("Flower Seed Pack", "startswith")
				if FlowerSeedPack and SeedEventCraftingPrompt and SeedEventCraftingPrompt.ActionText == "Select Recipe" then
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
			end
		end
		task.wait(5)
	end
end)
