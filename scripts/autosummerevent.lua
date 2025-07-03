--loadstring(game:HttpGet("https://raw.githubusercontent.com/Abodiey/Roblox/refs/heads/main/scripts/autosummerevent.lua"))()
if game.PlaceId ~= tonumber(63442347817033*2) then return end
print"loading1"
local SummerFruits = {"Sugar Apple","Feijoa","Loquat","Prickly Pear","Bell Pepper","Kiwi","Pineapple","Banana","Avocado","Green Apple","Watermelon","Cauliflower","Tomato","Strawberry","Carrot"}
local runService = game:GetService("RunService")
local player = game.Players.LocalPlayer
while not player do task.wait() end
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
	notificationGui.ChildAdded:Connect(function(v)
		if not isSummerHarvest then return end
		local lbl = v:FindFirstChildOfClass("TextLabel")
		if lbl and lbl.Text == "Max backpack space! Go sell!" then
			event:FireServer("SubmitAllPlants")
		end
	end)
end)
task.spawn(function()
	if _G.AutoLog then return end
	_G.AutoLog = true
	local function getTime()
		local t = DateTime.now().UnixTimestamp + 10800 -- +3 hours in seconds
		local h, m = math.floor(t%86400/3600), math.floor(t%3600/60)
		return string.format("%d:%02d %s", h>12 and h-12 or h==0 and 12 or h, m, h<12 and "AM" or "PM")
	end
	local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
	gui.IgnoreGuiInset = true
	local guiObject = Instance.new("TextLabel", gui)
	guiObject.AnchorPoint = Vector2.new(1, 0)
	guiObject.Position = UDim2.new(1, 0, 0, 0)
	guiObject.TextScaled = true
	guiObject.Text = getTime().."\nRewards Collected: None yet..."
	guiObject.Size = UDim2.fromScale(0.4, 1/10)
	guiObject.BackgroundColor3 = Color3.new(0, 0, 0)
	guiObject.BackgroundTransparency = 3/4
	guiObject.TextColor3 = Color3.new(1, 1, 1)
	guiObject.TextStrokeTransparency = 3/4
	local label = workspace:WaitForChild("SummerHarvestEvent"):WaitForChild("RewardSign"):FindFirstChild("SurfaceGui", true):WaitForChild("PointTextLabel")
	local oldRewards = tonumber(label.Text:match("%d+"))
	local newRewards
	label:GetPropertyChangedSignal("Text"):Connect(function()
		if not _G.AutoLog then return end
		local newRewards = tonumber(label.Text:match("%d+"))
		if newRewards < oldRewards then 
			local text = tostring(getTime().."\nRewards Collected: "..oldRewards)
			guiObject.Text = text
		end
		oldRewards = newRewards
	end)
end)
local function CheckTableEquality(t1,t2)
	for i,v in next, t1 do if t2[i]~=v then return false end end
	for i,v in next, t2 do if t1[i]~=v then return false end end
	return true
end

task.spawn(function()
	if _G.AutoHarvest then return end
	local event = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("SummerHarvestRemoteEvent")
	if isSummerHarvest then event:FireServer("SubmitAllPlants") end
	local ByteNetReliable = game:GetService("ReplicatedStorage"):WaitForChild("ByteNetReliable")
	local buffer = buffer.fromstring("\001\001\000\001")
	local TemplateSummerTreesList = {["Sugar Apple"] = {},["Feijoa"] = {},["Loquat"] = {},["Pricky Pear"] = {},["Bell Pepper"] = {},["Kiwi"] = {},["Pineapple"] = {},["Banana"] = {},["Avocado"] = {},["Green Apple"] = {},["Tomato"] = {}}
	local SummerTreesList = TemplateSummerTreesList
	for _,v in pairs(important:WaitForChild("Plants_Physical"):GetChildren()) do
		if v and SummerTreesList[v.Name] and v:FindFirstChild("Fruits") then
			table.insert(SummerTreesList[v.Name], v.Fruits)
		end
	end
	if not CheckTableEquality(TemplateSummerTreesList, SummerTreesList) then return end
	_G.AutoHarvest = true
	while _G.AutoHarvest do
		while not isSummerHarvest do task.wait() end
		for _,Tree in pairs(SummerTreesList) do
			if not isSummerHarvest then break end
			for _,Fruits in pairs(Tree) do
				if not isSummerHarvest then break end
				for _, v in pairs(Fruits:GetChildren()) do --returns v.Fruits's children, a Fruit
					if not isSummerHarvest then break end
					ByteNetReliable:FireServer(
						buffer,
						{ v }
					)
					runService.Heartbeat:Wait()
				end
			end
		end
		event:FireServer("SubmitAllPlants")
		task.wait(1/2)
	end
end)
print"loaded1"
