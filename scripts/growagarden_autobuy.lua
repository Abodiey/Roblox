--[[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Abodiey/Roblox/refs/heads/main/scripts/growagarden_autobuy.lua"))()
_G.Configuration["Discord"]["Webhook"] = "linkhere"
_G.Configuration["Discord"]["Enabled"] = true
]]
task.spawn(function()
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
				{"Feijoa","startswith",Color3.new(1, 1/2, 0)},
				{"Loquat","startswith",Color3.new(1, 1/2, 0)},
				{"Prickly Pear","startswith",Color3.new(1/2, 0, 0)},

				{"Master Sprinkler","startswith",Color3.new(0,1,0)},
				{"Tanning Mirror","startswith",Color3.new(0,1,0)},

				{"Paradise Egg","startswith",Color3.new(1,1 ,0)},
				{"Rare Summer Egg","startswith",Color3.new(0.1, 1/4, 1)},
				{"Common Summer Egg","startswith",Color3.new(1, 1, 0)},
			}
		},
		["Auto-Buy-Seeds"] = {
			["Enabled"] = true,
		},
		["Auto-Buy-Gear"] = {
			["Enabled"] = true,
			["Exclude"] = {"Friendship Pot"},
		},
		["Auto-Buy-Eggs"] = {
			["Enabled"] = true
		},
		["Auto-Buy-Event-Shop"] = {
			["Enabled"] = true,
			["Exclude"] = {"Delphinium", "Lily of the Valley", "Mutation Spray Burnt", "Oasis Crate"},
		},
		["Auto-Craft"] = {
			["Enabled"] = true,
			["Craft"] = {
				["Anti Bee Egg"] = true,
				["Mutation Spray Choc"] = true,
				["Reclaimer"] = true,
				["Crafters Seed Pack"] = false,
			}
		},
		["Auto-Honey-Machine"] = {
			["Enabled"] = false,
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
		if itemName and (searchMethodName == "equals" and itemName == name) or (searchMethodName == "startswith" and string.match(itemName, "^" .. name)) or (searchMethodName == "contains" and itemName:find(name)) then
			return true
		else
			return false
		end
	end

	local function getItem(name: string, searchMethodName: string) --equals, startswith, contains
		local item
		for _, v in pairs(LocalPlayer.Character:GetChildren()) do
			if v and searchMethod(v.Name, searchMethodName, name) then
				item = v
				break
			end
		end

		if item then return item end
		for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
			if v and searchMethod(v.Name, searchMethodName, name) then
				item = v
				break
			end
		end
		return item
	end
	print("initalizing..")
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
				if item and not string.match(item.Name, "kg%]$") and not item:GetAttribute("Watching") then
					item:SetAttribute("Watching", true)
					local previousAmount = tonumber(string.match(item.Name, "%d+"))
					item:GetPropertyChangedSignal("Name"):Connect(function()
						local newAmount = tonumber(string.match(item.Name, "%d+"))
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
					break
				end
			end
			backpack.ChildAdded:Connect(function(item: Instance) 
				if item and not string.match(item.Name, "kg%]$") and not item:GetAttribute("Watching") then
					for _,v in pairs(alertList) do
						local name = v[1]
						local method = v[2]
						local color = v[3]
						if searchMethod(item.Name, method, name) then
							item:SetAttribute("Watching", true)
							local previousAmount = tonumber(string.match(item.Name, "%d+"))
							item:GetPropertyChangedSignal("Name"):Connect(function()
								local newAmount = tonumber(string.match(item.Name, "%d+"))
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
							break
						end
					end
				end
			end)
		end
	end)
	task.spawn(function()

		local seedEvent = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuySeedStock")
		local gearEvent = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyGearStock")
		local eventShopEvent = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyEventShopStock")
		local eggEvent = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyPetEgg")

		local function initSeedShop()
			if not GetConfigValue("Auto-Buy-Seeds")["Enabled"] then return end
			local seedShop = game:GetService("Players").LocalPlayer.PlayerGui.Seed_Shop
			local frames = seedShop.Frame.ScrollingFrame

			local items = {}

			for _, item in ipairs(frames:GetChildren()) do
				local mainFrame = item:FindFirstChild("Main_Frame")
				if not mainFrame then continue end
				local stockText = mainFrame.Stock_Text 

				local stockNumber = tonumber(stockText.Text:match("%d+"))
				if not stockNumber then continue end

				for count = 1, stockNumber do
					seedEvent:FireServer(item.Name)
					task.wait()
				end
			end
		end
		local function initGearShop()
			if not GetConfigValue("Auto-Buy-Gear")["Enabled"] then return end
			local gearShop = game:GetService("Players").LocalPlayer.PlayerGui.Gear_Shop
			local frames = gearShop.Frame.ScrollingFrame

			local items = {}
			local exclude = GetConfigValue("Auto-Buy-Gear")["Exclude"]
			for _, item in ipairs(frames:GetChildren()) do
				if exclude and table.find(exclude, item.Name) then continue end
				local mainFrame = item:FindFirstChild("Main_Frame")
				if not mainFrame then continue end
				local stockText = mainFrame.Stock_Text 

				local stockNumber = tonumber(stockText.Text:match("%d+"))
				if not stockNumber then continue end

				for count = 1, stockNumber do
					gearEvent:FireServer(item.Name)
					task.wait()
				end
			end
		end
		local function initEventShop()
			if not GetConfigValue("Auto-Buy-Event-Shop")["Enabled"] then return end
			local eventShop = game:GetService("Players").LocalPlayer.PlayerGui.EventShop_UI
			local frames = eventShop.Frame.ScrollingFrame

			local items = {}
			local exclude = GetConfigValue("Auto-Buy-Event-Shop")["Exclude"]
			for _, item in ipairs(frames:GetChildren()) do
				if exclude and table.find(exclude, item.Name) then continue end
				local mainFrame = item:FindFirstChild("Main_Frame")
				if not mainFrame then continue end
				local stockText = mainFrame.Stock_Text 

				local stockNumber = tonumber(stockText.Text:match("%d+"))
				if not stockNumber then continue end

				for count = 1, stockNumber do
					eventShopEvent:FireServer(item.Name)
					task.wait()
				end
			end
		end
		local function initEggShop()
			if not GetConfigValue("Auto-Buy-Eggs")["Enabled"] then return end
			for count = 1, 3 do
				eggEvent:FireServer(count)
				task.wait()
			end
		end
		local function processSeedStockUpdate(stockTable)
			if not GetConfigValue("Auto-Buy-Seeds")["Enabled"] then return end
			for seedName, info in pairs(stockTable) do
				if seedName and info and info.Stock then
					for count = 1, info.Stock do
						seedEvent:FireServer(seedName)
						task.wait()
					end
				end

			end
		end
		local function processGearStockUpdate(stockTable)
			if not GetConfigValue("Auto-Buy-Gear")["Enabled"] then return end
			local exclude = GetConfigValue("Auto-Buy-Gear")["Exclude"]
			for gearName, info in pairs(stockTable) do
				if gearName and info and info.Stock and (not exclude or not table.find(exclude, gearName)) then
					for count = 1, info.Stock do
						gearEvent:FireServer(gearName)
						task.wait()
					end
				end

			end
		end
		local function processEventStockUpdate(stockTable)
			if not GetConfigValue("Auto-Buy-Event-Shop")["Enabled"] then return end
			local exclude = GetConfigValue("Auto-Buy-Event-Shop")["Exclude"]
			for seedName, info in pairs(stockTable) do
				if seedName and info and info.Stock and (not exclude or not table.find(exclude, seedName)) then
					for count = 1, info.Stock do
						eventShopEvent:FireServer(seedName)
						task.wait()
					end
				end

			end
		end

		initEventShop()
		initEggShop()
		initGearShop()
		initSeedShop()
		local function onDataStreamEvent(eventType, object, tbl)

			--[[
			Here's an example of the data we get:
			{
				"type": "UpdateData",
				"source": "DataStreamEvent",
				"table": [
				["ROOT/SeedStock/Stocks", {
					"Carrot": {"MaxStock": 20, "Stock": 20},
					"Strawberry": {"MaxStock": 5, "Stock": 5},
					"Apple": {"MaxStock": 1, "Stock": 1},
					"Tomato": {"MaxStock": 1, "Stock": 1},
					"Blueberry": {"MaxStock": 5, "Stock": 5}
				}],
				["ROOT/SeedStock/Seed", 5829582]
				],
				"timestamp": 1748874601,
				"object": "yourusername_DataServiceProfile"
			}
			]]

			if eventType == "UpdateData" and object:find(game.Players.LocalPlayer.Name) and type(tbl) == "table" then

				for _, pair in ipairs(tbl) do

					if type(pair) == "table" and #pair >= 2 then

						local path = pair[1]
						local data = pair[2]
						if type(data) == "table" then
							if path == "ROOT/SeedStock/Stocks" then
								processSeedStockUpdate(data)
							elseif path == "ROOT/GearStock/Stocks" then
								processGearStockUpdate(data)
							elseif path == "ROOT/EventShopStock/Stocks" then
								processEventStockUpdate(data)
								initEggShop()
							end
						end
					end
				end
			end
		end

		game:GetService("ReplicatedStorage").GameEvents.DataStream.OnClientEvent:Connect(onDataStreamEvent)
	end)

	task.spawn(function()
		local event = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("HoneyMachineService_RE")
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
								event:FireServer("MachineInteract")
								task.wait(1)
								break
							end
						end
						task.wait()
					end
				elseif Workspace.HoneyCombpressor.Spout.Jar:FindFirstChild"HoneyCombpressorPrompt" then --honey machine done, click collect
					event:FireServer("MachineInteract")
					task.wait(1)
				end
			end
			task.wait()
		end
	end)

	task.spawn(function()
		local event = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("CraftingGlobalObjectService")
		local EventCraftingWorkBench = workspace:WaitForChild("CraftingTables"):WaitForChild("EventCraftingWorkBench")
		local SeedEventCraftingWorkBench = workspace:WaitForChild("CraftingTables"):WaitForChild("SeedEventCraftingWorkBench")
		while GetConfigValue("Enabled") do
			local AutoCraft = GetConfigValue("Auto-Craft")
			if AutoCraft["Enabled"] then 
				local EventCraftingPrompt = EventCraftingWorkBench:FindFirstChild("CraftingProximityPrompt", true)
				if EventCraftingPrompt and EventCraftingPrompt.ActionText == "Claim" then
					local args = {"Claim",EventCraftingWorkBench,"GearEventWorkbench",1}
					event:FireServer(unpack(args))
					task.wait()
				end
				local SeedEventCraftingPrompt = SeedEventCraftingWorkBench:WaitForChild("Model"):FindFirstChild("CraftingProximityPrompt", true)
				if SeedEventCraftingPrompt and SeedEventCraftingPrompt.ActionText == "Claim" then
					local args = {"Claim",SeedEventCraftingWorkBench,"SeedEventWorkbench",1}
					event:FireServer(unpack(args))
					task.wait()
				end
			else
				task.wait(1)
				return
			end
			local AutoCraftAntiBeeEgg = AutoCraft["Craft"]["Anti Bee Egg"]
			if AutoCraftAntiBeeEgg then
				local EventCraftingPrompt = EventCraftingWorkBench:FindFirstChild("CraftingProximityPrompt", true)
				if EventCraftingPrompt and EventCraftingPrompt.ActionText ~= "Skip" then
					if EventCraftingPrompt.ActionText == "Claim" then
						local args = {"Claim",EventCraftingWorkBench,"GearEventWorkbench",1}
						event:FireServer(unpack(args))
						task.wait(1)
					end

					local BeeEgg = getItem("Bee Egg", "startswith")
					if BeeEgg and EventCraftingPrompt and (EventCraftingPrompt.ActionText == "Submit Item" or string.match(EventCraftingPrompt.ActionText, "^".."Start Crafting")) then
						local args = {"Cancel",EventCraftingWorkBench,"GearEventWorkbench"}
						event:FireServer(unpack(args))
						task.wait(1)
					end
					if BeeEgg and EventCraftingPrompt and EventCraftingPrompt.ActionText == "Select Recipe" then
						local args = {"SetRecipe",EventCraftingWorkBench,"GearEventWorkbench","Anti Bee Egg"}
						event:FireServer(unpack(args))
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
						event:FireServer(unpack(args))
						task.wait(1)
						local args = {"Craft",EventCraftingWorkBench,"GearEventWorkbench"}
						event:FireServer(unpack(args))
					end
				end
			end
			task.wait(3)
			local AutoCraftChocSpray = AutoCraft["Craft"]["Mutation Spray Choc"]
			if AutoCraftChocSpray then
				local EventCraftingPrompt = EventCraftingWorkBench:FindFirstChild("CraftingProximityPrompt", true)
				if EventCraftingPrompt and EventCraftingPrompt.ActionText ~= "Skip" then
					if EventCraftingPrompt.ActionText == "Claim" then
						local args = {"Claim",EventCraftingWorkBench,"GearEventWorkbench",1}
						event:FireServer(unpack(args))
						task.wait(1)
					end

					local Cacao = getItem("Cacao %[", "contains")
					local cleaningSpray = getItem("Cleaning Spray", "startswith")
					if Cacao and cleaningSpray and EventCraftingPrompt and (EventCraftingPrompt.ActionText == "Submit Item" or string.match(EventCraftingPrompt.ActionText, "^".."Start Crafting")) then
						local args = {"Cancel",EventCraftingWorkBench,"GearEventWorkbench"}
						event:FireServer(unpack(args))
						task.wait(1)
					end
					if Cacao and cleaningSpray and EventCraftingPrompt and EventCraftingPrompt.ActionText == "Select Recipe" then
						local args = {"SetRecipe",EventCraftingWorkBench,"GearEventWorkbench","Mutation Spray Choc"}
						event:FireServer(unpack(args))
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
						event:FireServer(unpack(args))
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
						event:FireServer(unpack(args))
						task.wait(1)
						local args = {"Craft",EventCraftingWorkBench,"GearEventWorkbench"}
						event:FireServer(unpack(args))
					end
				end
			end
			task.wait(3)
			local AutoCraftReclaimer = AutoCraft["Craft"]["Reclaimer"]
			if AutoCraftReclaimer then
				local EventCraftingPrompt = EventCraftingWorkBench:FindFirstChild("CraftingProximityPrompt", true)
				if EventCraftingPrompt and EventCraftingPrompt.ActionText ~= "Skip" then
					if EventCraftingPrompt.ActionText == "Claim" then
						local args = {"Claim",EventCraftingWorkBench,"GearEventWorkbench",1}
						event:FireServer(unpack(args))
						task.wait(1)
					end

					local commonEgg = getItem("Common Egg", "startswith")
					local harvestTool = getItem("Harvest Tool", "startswith")
					if commonEgg and harvestTool and EventCraftingPrompt and (EventCraftingPrompt.ActionText == "Submit Item" or string.match(EventCraftingPrompt.ActionText, "^".."Start Crafting")) then
						local args = {"Cancel",EventCraftingWorkBench,"GearEventWorkbench"}
						event:FireServer(unpack(args))
						task.wait(1)
					end
					if commonEgg and harvestTool and EventCraftingPrompt and EventCraftingPrompt.ActionText == "Select Recipe" then
						local args = {"SetRecipe",EventCraftingWorkBench,"GearEventWorkbench","Reclaimer"}
						event:FireServer(unpack(args))
						task.wait(1)

						local itemUUID = commonEgg:GetAttribute("c")
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
						event:FireServer(unpack(args))
						task.wait(1)
						local itemUUID = harvestTool:GetAttribute("c")
						local args = {
							"InputItem",
							EventCraftingWorkBench,
							"GearEventWorkbench",
							2,
							{
								ItemType = "Harvest Tool",
								ItemData = {
									UUID = itemUUID
								}
							}
						}
						event:FireServer(unpack(args))
						task.wait(1)
						local args = {"Craft",EventCraftingWorkBench,"GearEventWorkbench"}
						event:FireServer(unpack(args))
					end
				end
			end
			task.wait(3)
			local AutoCraftCraftersSeedPack = AutoCraft["Craft"]["Crafters Seed Pack"]
			if AutoCraftCraftersSeedPack then
				local SeedEventCraftingPrompt = SeedEventCraftingWorkBench:WaitForChild("Model"):FindFirstChild("CraftingProximityPrompt", true)
				if SeedEventCraftingPrompt and SeedEventCraftingPrompt.ActionText ~= "Skip" then
					if SeedEventCraftingPrompt and SeedEventCraftingPrompt.ActionText == "Claim" then
						local args = {"Claim",SeedEventCraftingWorkBench,"SeedEventWorkbench",1}
						event:FireServer(unpack(args))
						task.wait(1)
					end

					local FlowerSeedPack = getItem("Flower Seed Pack", "startswith")
					if FlowerSeedPack and SeedEventCraftingPrompt and SeedEventCraftingPrompt.ActionText == "Select Recipe" then
						if (SeedEventCraftingPrompt.ActionText == "Submit Item" or string.match(SeedEventCraftingPrompt.ActionText, "^".."Start Crafting")) then
							local args = {"Cancel",SeedEventCraftingWorkBench,"SeedEventWorkbench"}
							event:FireServer(unpack(args))
							task.wait(1)
						end
						local args = {"SetRecipe",SeedEventCraftingWorkBench,"SeedEventWorkbench","Crafters Seed Pack"}
						event:FireServer(unpack(args))
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
						event:FireServer(unpack(args))
						task.wait(1)
						local args = {"Craft",SeedEventCraftingWorkBench,"SeedEventWorkbench"}
						event:FireServer(unpack(args))
					end
				end
			end
			task.wait(5)
		end
	end)

end)
