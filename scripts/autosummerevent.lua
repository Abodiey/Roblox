--loadstring(game:HttpGet("https://raw.githubusercontent.com/Abodiey/Roblox/refs/heads/main/scripts/autosummerevent.lua"))()
if game.PlaceId ~= tonumber(63442347817033*2) then return end
local SummerFruits = {"Sugar Apple","Feijoa","Loquat","Prickly Pear","Bell Pepper","Kiwi","Pineapple","Banana","Avocado","Green Apple","Watermelon","Cauliflower","Tomato","Strawberry","Carrot"}
local runService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local playergui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local important
for _, plot in pairs(workspace:WaitForChild("Farm"):GetChildren()) do
	local _important = plot:FindFirstChild("Important") or plot:FindFirstChild("Importanert")
	if _important then
		local data = _important:FindFirstChild("Data")
		if data and data:FindFirstChild("Owner") and data.Owner.Value == player.Name then
			important = _important
			break
		end
	end
end

local isSummerHarvest = false
local summerHarvestLabel = workspace:WaitForChild("SummerHarvestEvent"):WaitForChild("Sign"):FindFirstChild("BillboardGui", true):WaitForChild("TextLabel")
local function refreshSummerHarvest()
	if summerHarvestLabel.Text == "Next Summer Harvest:" then
		isSummerHarvest = false
	else
		isSummerHarvest = true
	end
end
refreshSummerHarvest()
summerHarvestLabel:GetPropertyChangedSignal("Text"):Connect(refreshSummerHarvest)

task.spawn(function()
	if _G.AutoSubmit then return end
	_G.AutoSubmit = true
	local event = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("SummerHarvestRemoteEvent")
	local notificationGui = playergui:WaitForChild("Top_Notification"):WaitForChild("Frame")
	while _G.AutoSubmit do
		local v = notificationGui.ChildAdded:Wait()
		if v and v:FindFirstChild("TextLabel") then
			if v.TextLabel.Text == "Max backpack space! Go sell!" then
				event:FireServer("SubmitAllPlants")
			end
		end
		runService.Heartbeat:Wait()
	end
end)
task.spawn(function()
	if _G.AutoLog then return end
	_G.AutoLog = true
	local function getTime()
		local t = DateTime.now().UnixTimestamp + 10800 -- +3 hours in seconds
		local h, m = math.floor(t%86400/3600), math.floor(t%3600/60)
		return string.format("%d:%02d %s", h>12 and h-12 or h==0 and 12 or h, m, h<12 and "AM" or "PM")
	end
	--[[
	local gui = Instance.new("ScreenGui", playergui")
	local guiObject = Instance.new("TextLabel", gui)
	guiObject.AnchorPoint = Vector2.new(1, 0)
	guiObject.Position = UDim2.new(1, 0, 0, 0)
	guiObject.Text = getTime().."\nRewards Collected: None yet..."
	guiObject.TextScaled = true
	]]--
	local label = workspace:WaitForChild("SummerHarvestEvent"):WaitForChild("RewardSign"):FindFirstChild("SurfaceGui", true):WaitForChild("PointTextLabel")
	local oldRewards = tonumber(label.Text:match("%d+"))
	local newRewards
	while _G.AutoLog do
		label:GetPropertyChangedSignal("Text"):Wait()
		local newRewards = tonumber(label.Text:match("%d+"))
		if newRewards < oldRewards then 
			local text = ("Rewards Collected: "..oldRewards)
			--guiObject.Text = getTime()..text
			print(text)
			toclipboard(text)
			oldRewards = newRewards
		elseif newRewards > oldRewards then
			oldRewards = newRewards
		end
	end
end)
task.spawn(function()
	if _G.AutoHarvest then return end
	_G.AutoHarvest = true
	local event = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("SummerHarvestRemoteEvent")
	local SummerTrees = {["Sugar Apple"] = {},["Feijoa"] = {},["Loquat"] = {},["Pricky Pear"] = {},["Bell Pepper"] = {},["Kiwi"] = {},["Pineapple"] = {},["Banana"] = {},["Avocado"] = {},["Green Apple"] = {},["Tomato"] = {}}
	for _,v in pairs(important:WaitForChild("Plants_Physical"):GetChildren()) do
		if v and SummerTrees[v.Name] and v:FindFirstChild("Fruits") then
			table.insert(SummerTrees[v.Name], v.Fruits)
		end
	end
	while _G.AutoHarvest do
		while not isSummerHarvest do runService.Heartbeat:Wait() end
		local count = 0
		event:FireServer("SubmitAllPlants")
		for _,BunchOfTree in pairs(SummerTrees) do
			for _,Fruits in pairs(BunchOfTree) do
				for i, v in pairs(Fruits:GetChildren()) do --returns v.Fruits's children, a Fruit
					local ByteNetReliable = game:GetService("ReplicatedStorage").ByteNetReliable
					ByteNetReliable:FireServer(
						buffer.fromstring("\001\001\000\001"),
						{ v }
					)
					runService.Heartbeat:Wait()
					count+=1
					if count >= 50 and isSummerHarvest then event:FireServer("SubmitAllPlants") count = 0 end
					--end
				end
			end
		end
		event:FireServer("SubmitAllPlants")
		task.wait(1)
	end
end)
print"autoloaded"
