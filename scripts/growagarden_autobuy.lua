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
	["Auto-Buy-Bee-Egg"] = true
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

_G.Enabled = true
_G.Seeds = {"Carrot","Strawberry","Blueberry","Orange Tulip","Tomato","Corn","Daffodil","Pumpkin","Apple","Bamboo","Coconut","Cactus","Dragon Fruit","Mango","Grape","Mushroom","Pepper","Cacao","Beanstalk","Ember Lily","Sugar Apple"}
task.spawn(function()
while GetConfigValue("Enabled") do
	local AutoBuySeeds = GetConfigValue("Auto-Buy-Seeds")
	if AutoBuySeeds then
		for _,Seed in pairs(_G.Seeds) do
			game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuySeedStock"):FireServer(Seed)
			task.wait()
		end
	end
	task.wait()
end
end)

--_G.Gears = {"Watering Can","Trowel","Recall Wrench","Basic Sprinkler","Advanced Sprinkler","Godly Sprinkler","Lightning Rod","Master Sprinkler","Cleaning Spray","Favorite Tool","Harvest Tool","Friendship Pot"}
_G.Gears = {"Watering Can","Trowel","Recall Wrench","Basic Sprinkler","Advanced Sprinkler","Godly Sprinkler","Lightning Rod","Master Sprinkler"}
task.spawn(function()
while GetConfigValue("Enabled") do
	local AutoBuyGear = GetConfigValue("Auto-Buy-Gear")
	if AutoBuyGear then
		for _,Gear in pairs(_G.Gears) do
			game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyGearStock"):FireServer(Gear)
			task.wait()
		end
	end
	task.wait()
end
end)

_G.Eggs = {1,2,3}
task.spawn(function()
while GetConfigValue("Enabled") do
	local AutoBuyEggs = GetConfigValue("Auto-Buy-Eggs")
	if AutoBuyEggs then
		for _,Egg in pairs(_G.Eggs) do
			game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyPetEgg"):FireServer(Egg)
			task.wait(1)
		end
	end
	task.wait()
end
end)

task.spawn(function()
while GetConfigValue("Enabled") do
	local AutoBuyBeeEgg = GetConfigValue("Auto-Buy-Bee-Egg")
	if AutoBuyBeeEgg then
		game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("BuyEventShopStock"):FireServer("Bee Egg")
	end
	task.wait()
end
end)
