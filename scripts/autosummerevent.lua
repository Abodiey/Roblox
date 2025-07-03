--loadstring(game:HttpGet("https://raw.githubusercontent.com/Abodiey/Roblox/refs/heads/main/scripts/autosummerevent.lua"))()
if game.PlaceId ~= tonumber(63442347817033*2) then return end
print("loading1")
local RunService = game:GetService("RunService")
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
	isSummerHarvest = summerHarvestLabel.Text ~= "Next Summer Harvest:"
end
refreshSummerHarvest()
summerHarvestLabel:GetPropertyChangedSignal("Text"):Connect(refreshSummerHarvest)

local submitevent = game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("SummerHarvestRemoteEvent")
local notificationGui = playergui:WaitForChild("Top_Notification"):WaitForChild("Frame")
local debounce = false
_G.AutoSubmit = true
notificationGui.ChildAdded:Connect(function(v)
	if debounce then return end
	local lbl = v:FindFirstChildOfClass("TextLabel")
	if lbl and lbl.Text == "Max backpack space! Go sell!" then
		if isSummerHarvest then
			debounce = true
			submitevent:FireServer("SubmitAllPlants")
			for c = 1, 5 do RunService.Stepped:Wait() end
			debounce = false
		end
	end
end)


local function getTime()
	local t = DateTime.now().UnixTimestamp + 10800 -- +3 hours in seconds
	local h, m = math.floor(t%86400/3600), math.floor(t%3600/60)
	return string.format("%d:%02d %s", h>12 and h-12 or h==0 and 12 or h, m, h<12 and "AM" or "PM")
end

_G.AutoLog = true
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
local previousConnections = getconnections(label:GetPropertyChangedSignal("Text"))

for _, connection in pairs(previousConnections) do
	if connection then connection:Disconnect() end
end
local oldRewards = tonumber(label.Text:match("%d+"))
local newRewards
label:GetPropertyChangedSignal("Text"):Connect(function()
	local newRewards = tonumber(label.Text:match("%d+"))
	if newRewards < oldRewards then 
		local text = tostring(getTime().."\nRewards Collected: "..oldRewards)
		guiObject.Text = text
	end
	oldRewards = newRewards
end)


--local function CheckTableEquality(t1,t2)
--	for i,v in next, t1 do if t2[i]~=v then return false end end
--	for i,v in next, t2 do if t1[i]~=v then return false end end
--	return true
--end

_G.AutoHarvest = true
local SummerFruits = {
	"Sugar Apple","Pitcher Plant","Feijoa","Loquat","Prickly Pear","Bell Pepper",
	"Kiwi","Pineapple","Banana","Avocado","Green Apple",
	"Watermelon","Cauliflower","Tomato","Strawberry","Carrot"
}

-- Build a name→list-of-fruits map in O(#trees + #fruits)
local function buildBuckets(plantsPhysical)
	local buckets = {}
	-- initialize empty lists for each fruit type
	for _, name in ipairs(SummerFruits) do
		buckets[name] = {}
	end

	-- single pass through trees
	for _, tree in ipairs(plantsPhysical:GetChildren()) do
		local fruitsFolder = tree:FindFirstChild("Fruits")
		if fruitsFolder and buckets[tree.Name] then
			for _, fruit in ipairs(fruitsFolder:GetChildren()) do
				table.insert(buckets[tree.Name], fruit)
			end
		end
	end

	return buckets
end

-- Flatten buckets into ordered queue in O(#fruitTypes + totalFruits)
local function buildFruitQueue(plantsPhysical)
	local buckets   = buildBuckets(plantsPhysical)
	local queue     = {}

	for _, name in ipairs(SummerFruits) do
		for _, fruit in ipairs(buckets[name]) do
			table.insert(queue, fruit)
		end
	end

	return queue
end

local ByteNetReliable = game:GetService("ReplicatedStorage")
	:WaitForChild("ByteNetReliable")
local buffer          = buffer.fromstring("\001\001\000\001")

-- Given: buildFruitQueue(plantsPhysical) → returns {Fruit…}

local function processFruitQueue(queue)
	submitevent:FireServer("SubmitAllPlants")
	
	for _, fruit in ipairs(queue) do
		-- send one fruit per frame
		ByteNetReliable:FireServer(buffer, { fruit })
		RunService.Heartbeat:Wait()
	end

	-- once done, submit all plants
	submitevent:FireServer("SubmitAllPlants")
	return
end

-- Example usage in your harvest cycle:
local function startHarvestCycle()
	while isSummerHarvest do
		local plantsPhys = important:WaitForChild("Plants_Physical")
		local queue      = buildFruitQueue(plantsPhys)
		processFruitQueue(queue)
		RunService.Heartbeat:Wait()
	end
end

-- Check if harvest event already started:
refreshSummerHarvest()
if isSummerHarvest then
	startHarvestCycle()
end
-- Trigger on the harvest‐available event:
summerHarvestLabel:GetPropertyChangedSignal("Text"):Connect(function()
	if summerHarvestLabel.Text ~= "Next Summer Harvest:" then
		if not isSummerHarvest then refreshSummerHarvest() end
		startHarvestCycle()
	end
end)

print"loaded1"
