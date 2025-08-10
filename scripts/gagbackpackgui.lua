-- // Configuration

local targetPlayerName = ""

-- // Preperation
if #game.Players:GetPlayers() <= 1 then
	targetPlayerName = game.Players.LocalPlayer.Name
	print("No other players, choosing self:", targetPlayerName, "\n")
end
-- // Script
local function getClosestPlayer()
	local closestPlayer = nil
	local shortestDistance = math.huge
	local localPlayer = game.Players.LocalPlayer

	-- Wait for local character and HumanoidRootPart safely
	local localCharacter = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local localHRP = localCharacter:FindFirstChild("HumanoidRootPart")
	if not localHRP then
		localHRP = localCharacter:WaitForChild("HumanoidRootPart", 5)
	end
	if not localHRP then return nil end -- Abort if missing

	for _, player in ipairs(game.Players:GetPlayers()) do
		if player ~= localPlayer then
			local character = player.Character or player.CharacterAdded:Wait()

			-- Stop if character isn't loaded and player left
			if not player:IsDescendantOf(game.Players) then
				continue
			end

			local hrp = character:FindFirstChild("HumanoidRootPart")
			if not hrp then
				-- Wait briefly for HRP (but don't hang forever)
				local startTime = tick()
				repeat
					hrp = character:FindFirstChild("HumanoidRootPart")
					if not player:IsDescendantOf(game.Players) then break end
					task.wait(0.1)
				until hrp or tick() - startTime > 5
			end

			-- Skip if still missing or player is gone
			if hrp and player:IsDescendantOf(game.Players) then
				local distance = (hrp.Position - localHRP.Position).Magnitude
				if distance < shortestDistance then
					shortestDistance = distance
					closestPlayer = player
				end
			end
		end
	end

	return closestPlayer
end



local function findPlayerByPrefix(keyword)
	if not keyword or keyword == "" then return nil end

	keyword = keyword:lower()
	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Name:lower():sub(1, #keyword) == keyword then
			return player
		end
	end
	return nil
end


-- Example usage
local target = findPlayerByPrefix(targetPlayerName)
if target then
	print("Found prefix, player is:", target.Name, "\n")
else
	target = getClosestPlayer()
	if target then
		print("Found closest, player is:", target.Name, "\n")
	else
		warn("No other players found.", "\n")
		return
	end
end


-- // Remove Existing GUI
local playerGui	= game.Players.LocalPlayer:WaitForChild("PlayerGui")
local existingGui  = playerGui:FindFirstChild("BackpackViewer")
if existingGui then
	existingGui:Destroy()
end

-- // Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name			= "BackpackViewer"
screenGui.Parent		  = playerGui
screenGui.ResetOnSpawn	= false

local mainFrame = Instance.new("Frame")
mainFrame.Size			= UDim2.new(0, 300, 0, 400)
mainFrame.Position		= UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3= Color3.fromRGB(35, 35, 35)
mainFrame.Active		  = true
mainFrame.Draggable	   = true
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 0
mainFrame.Parent		  = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size				= UDim2.new(1, -40, 0, 50)
titleLabel.Position			= UDim2.new(0, 20, 0, 10)
titleLabel.BackgroundTransparency= 1
titleLabel.Text				= target.Name .. "'s Backpack"
titleLabel.Font				= Enum.Font.SourceSansBold
titleLabel.TextSize			= 20
titleLabel.TextScaled			= true
titleLabel.TextColor3		  = Color3.new(1, 1, 1)
titleLabel.TextXAlignment	  = Enum.TextXAlignment.Center
titleLabel.TextStrokeTransparency = 1
titleLabel.BorderSizePixel	 = 0
titleLabel.Parent			  = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size				= UDim2.new(0, 20, 0, 20)
closeButton.Position			= UDim2.new(1, -25, 0, 5)
closeButton.Text				= "X"
closeButton.Font				= Enum.Font.SourceSansBold
closeButton.TextSize			= 18
closeButton.TextScaled		  = true
closeButton.BackgroundColor3	= Color3.fromRGB(255, 85, 85)
closeButton.TextColor3		  = Color3.new(1, 1, 1)
closeButton.BorderSizePixel	 = 0
closeButton.Parent			  = mainFrame

local filterBox = Instance.new("TextBox")
filterBox.Size				= UDim2.new(1, -20, 0, 30)
filterBox.Position			= UDim2.new(0, 10, 0, 100)
filterBox.PlaceholderText	 = "Filter by keyword (e.g. KG)"
filterBox.Font				= Enum.Font.SourceSans
filterBox.TextSize			= 18
filterBox.Text				= ""
filterBox.TextColor3		  = Color3.new(0, 0, 0)
filterBox.BackgroundColor3	= Color3.fromRGB(255, 255, 255)
filterBox.ClearTextOnFocus	= false
filterBox.BorderSizePixel	 = 0
filterBox.TextStrokeTransparency = 1
filterBox.Parent			  = mainFrame

-- Checkbox
local matchModeToggle = Instance.new("TextButton")
matchModeToggle.Size				= UDim2.new(0, 40, 0, 30)
matchModeToggle.Position			= UDim2.new(0, 10, 0, 60)
matchModeToggle.Text				= "OFF"
matchModeToggle.TextColor3		  = Color3.new(1, 1, 1)
matchModeToggle.BackgroundColor3	= Color3.fromRGB(255, 60, 60)
matchModeToggle.Font				= Enum.Font.SourceSansBold
matchModeToggle.TextSize			= 14
matchModeToggle.TextScaled		  = true
matchModeToggle.TextXAlignment	  = Enum.TextXAlignment.Center
matchModeToggle.TextYAlignment	  = Enum.TextYAlignment.Center
matchModeToggle.BorderSizePixel	 = 0
matchModeToggle.TextStrokeTransparency = 1
matchModeToggle.ZIndex			  = 2
matchModeToggle.Parent			  = mainFrame

-- Label
local matchModeLabel = Instance.new("TextLabel")
matchModeLabel.Size				   = UDim2.new(1, -20, 0, 40)
matchModeLabel.Position			   = UDim2.new(0, 10, 0, 60)
matchModeLabel.Text				   = "Match Mode: Case-insensitive"
matchModeLabel.TextXAlignment		 = Enum.TextXAlignment.Center
matchModeLabel.Font				   = Enum.Font.SourceSans
matchModeLabel.TextSize			   = 16
matchModeLabel.TextColor3			 = Color3.new(1, 1, 1)
matchModeLabel.BackgroundTransparency = 1
matchModeLabel.BorderSizePixel		= 0
matchModeLabel.TextStrokeTransparency = 1
matchModeLabel.Parent				 = mainFrame

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 20, 0, 20)
minimizeButton.Position = UDim2.new(1, -50, 0, 5)
minimizeButton.Text = "_"
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.TextSize = 18
minimizeButton.TextScaled = true
minimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.BorderSizePixel = 0
minimizeButton.Parent = mainFrame

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Position		= UDim2.new(0, 10, 0, 140)
scrollingFrame.Size			= UDim2.new(1, -20, 1, -150)
scrollingFrame.CanvasSize	  = UDim2.new(0, 0, 0, 0)
scrollingFrame.BackgroundColor3= Color3.fromRGB(50, 50, 50)
scrollingFrame.ScrollBarThickness= 8
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ZIndex		  = 1
scrollingFrame.Parent		  = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent  = scrollingFrame


-- // Logic to List & Sort Items (Reverted & Double‐Sorted with Enhanced Rarity)

local connections  = {}
local isExactMatch = false

-- Mutation‐priority keywords
local mutationPriority = {
	"Ascended", "Tranquil", "IronSkin", "Radiant", "Shocked",
	"Rainbow", "Golden", "Tiny", "Mega", "Windy",
	"Frozen", "Inverted", "Shiny",
}

-- Category priority (Pets → Fruits → Seeds → Other)
local categoryPriority = { Pets = 1, Fruits = 2, Seeds = 3, Other = 4 }

-- Name‐priority list (substring, case‐sensitive)
local namePriority = {
	"Panda",
	"Kitsune", "Disco Bee", "Raccoon", "Spinosaurus",
	"Butterfly", "Fennec Fox", "T-Rex", "Mimic Octopus",
	"Dragonfly", "French Fry Ferret", "Red Fox", "Queen Bee", "Chicken Zombie",
	"Dilophosaurus", "Blood Owl", "Moon Cat", 
}

-- Rarity map & ordering
local rarityMap = {
	Transcendant = {
		--Unobtainable
		"Bone Blossom",
	},
	Prismatic	= {
		--Obtainable
		"Kitsune", "Corrupted Kitsune",
		--Unobtainable
		"Elephant Ears", "Tranquil Bloom",
		--Obtainable
		"Beanstalk", "Ember Lily", "Sugar Apple", "Burning Bud", "Giant Pinecone", "Elder Strawberry",
	},
	Divine	   = {
		--Unobtainable
		"Blood Owl", "Raccoon", "Fennec Fox", "Spinosaurus", "T-Rex", "Mizuchi",
		--Obtainable
		"Red Fox", "Dragonfly", "Disco Bee", "Queen Bee", "French Fry Ferret", "Lobster Thermidor",
		--Unobtainable
		"Candy Blossom", "Venus Fly Trap", "Cursed Fruit", "Soul Fruit",
		--Obtainable
		"Sunflower", 
	},
	Mythical	 = {
		--Unobtainable
		"Hamster", "Chicken Zombie", "Firefly", "Owl", "Golden Bee", "Echo Frog", "Cooked Owl", 
		"Blood Kiwi", "Night Owl", "Hyacinth Macaw", "Axolotl", "Dilophosaurus", "Ankylosaurus", "Pterodactyl",
		"Brontosaurus", "Kappa", "Koi", "Raiju", "Junkbot",
		--Obtainable
		"Brown Mouse", "Giant Ant", "Praying Mantis", "Red Giant Ant", "Squirrel", "Bear Bee", "Butterfly", 
		"Pack Bee", "Mimic Octopus",
	},
	Legendary = {
		--Unobtainable
		"Cow", "Polar Bear", "Sea Otter", "Silver Monkey", "Panda", "Blood Hedgehog", "Frog", 
		"Mole", "Moon Cat", "Bald Eagle", "Turtle", "Sand Snake", "Meerkat", "Parasaurolophus", 
		"Iguanadon", "Pachycephalosaurus", "Raptor", "Triceratops", "Stegosaurus", "Football", "Kodama", 
		"Corrupted Kodama", "Tanuki", "Tanchozuru",
		--Obtainable
		"Grey Mouse", "Tarantula Hawk", "Caterpillar", "Snail", "Petal Bee", "Moth", "Scarlet Macaw", 
		"Ostrich", "Peacock", "Capybara", "Gorilla Chef", "Hotdog Daschund",
	},
	Rare	  = {
		--Unobtainable
		"Kiwi", "Hedgehog", "Monkey", "Orange Tabby", "Pig", "Rooster", "Spotted Deer",
		"Tsuchinoko", "Nihonzaru",
		--Obtainable
		"Flamingo", "Toucan", "Sea Turtle", "Orangutan", "Seal", "Honey Bee", "Wasp",
	},
	Uncommon  = {
		--Unobtainable
		"Black Bunny", "Cat", "Chicken", "Deer", "Shiba Inu", "Maneki-neko",
		--Obtainable
		"Bee", "Sunny-Side Chicken", "Bacon Pig",
	},
	Common	= {
		--Obtainable
		"Starfish", "Crab", "Seagull", "Bunny", "Dog", "Golden Lab",
	}
}

local rarityPriority = {
	"Transcendant", "Prismatic", "Divine", "Mythical",
	"Legendary",	"Rare",	  "Uncommon", "Common",
}

-- Localize
local strFind = string.find

-- Helpers

-- Index in priority list by first plain substring hit
local function getPriorityIndex(list, str)
	for i, v in ipairs(list) do
		if strFind(str, v, 1, true) then
			return i
		end
	end
	return #list + 1
end

-- True if name contains any mutation keyword
local function isMutated(name)
	for _, key in ipairs(mutationPriority) do
		if strFind(name, key, 1, true) then
			return true
		end
	end
	return false
end

-- Parse age & weight
local function parseItemData(name)
	local age	= tonumber(name:match("%[Age%s*(%d+)%]"))
	local weight = tonumber(name:match("%[(%d+%.?%d*)%s*KG%]"))
		or tonumber(name:match("%[(%d+%.?%d*)kg%]"))
	return age, weight
end

-- Simple categorize by substrings
local function categorize(name)
	if strFind(name, "KG", 1, true) then
		return "Pets"
	elseif strFind(name, "kg", 1, true) then
		return "Fruits"
	elseif strFind(name, "Seed", 1, true) then
		return "Seeds"
	else
		return "Other"
	end
end

-- Enhanced determineRarity per your spec
local function determineRarity(name)
	-- Multi-word: first-match wins
	if strFind(name, " ", 1, true) then
		for _, rar in ipairs(rarityPriority) do
			for _, key in ipairs(rarityMap[rar]) do
				if strFind(name, key, 1, true) then
					return rar
				end
			end
		end
		return "Common"
	end

	-- Single-word: best single-keyword match per rarity
	local bestRarity, bestCount = "Common", 0

	for _, rar in ipairs(rarityPriority) do
		local maxCount = 0
		for _, key in ipairs(rarityMap[rar]) do
			local count, i = 0, 1
			while true do
				local s, e = strFind(name, key, i, true)
				if not s then break end
				count = count + 1
				i	 = e + 1
			end
			if count > maxCount then
				maxCount = count
			end
		end
		if maxCount > bestCount then
			bestCount  = maxCount
			bestRarity = rar
		end
	end

	return bestRarity
end

-- Full comparator: mutated pets first → category → name-priority → rarity → weight → age → alpha
local function sortItems(a, b)
	-- 1) Pets mutated first
	if a.category == "Pets" and b.category == "Pets" then
		local aMut, bMut = isMutated(a.name), isMutated(b.name)
		if aMut ~= bMut then
			return aMut
		end
	end

	-- 2) Category
	local cA, cB = categoryPriority[a.category], categoryPriority[b.category]
	if cA ~= cB then
		return cA < cB
	end

	-- 3) Name‐priority
	local nA = getPriorityIndex(namePriority, a.name)
	local nB = getPriorityIndex(namePriority, b.name)
	local aNP, bNP = (nA <= #namePriority), (nB <= #namePriority)
	if aNP ~= bNP then
		return aNP
	end
	if aNP and bNP and nA ~= nB then
		return nA < nB
	end

	-- 4) Rarity
	local rA = getPriorityIndex(rarityPriority, a.rarity)
	local rB = getPriorityIndex(rarityPriority, b.rarity)
	if rA ~= rB then
		return rA < rB
	end

	-- 5) Weight (heaviest first; always returns a boolean)
	if a.weight and b.weight then
		return a.weight > b.weight
	elseif a.weight ~= nil or b.weight ~= nil then
		-- one has weight, the other doesn’t
		return a.weight ~= nil
	end

	-- 6) Age (older first; missing ages rank above)
	if a.age ~= b.age then
		if a.age == nil then
			return true
		elseif b.age == nil then
			return false
		else
			return a.age > b.age
		end
	end

	-- 7) Alphabetical fallback
	return a.name < b.name
end


-- Build & display
local function listBackpack()
	local ply = target
	if not ply or not ply:FindFirstChild("Backpack") then
		titleLabel.Text = "Player or Backpack not found"
		return
	end
	titleLabel.Text	= ply.DisplayName .. "'s Backpack"
	-- Clear old
	for _, c in ipairs(scrollingFrame:GetChildren()) do
		if c:IsA("TextLabel") then
			c:Destroy()
		end
	end

	-- Gather counts
	local filter = filterBox.Text
	local norm   = filter:lower()
	local counts, reps = {}, {}
	local items = ply.Backpack:GetChildren() -- Start with tools in Backpack

	-- Add equipped tools from Character
	for _, obj in ipairs(ply.Character:GetChildren()) do
		if obj:IsA("Tool") then
			table.insert(items, obj)
		end
	end

	for _, item in ipairs(ply.Backpack:GetChildren()) do
		local nm = item.Name
		local ok

		if filter == "" then
			-- no filter, everything matches
			ok = true
		elseif isExactMatch then
			-- exact (case-sensitive) match
			ok = strFind(nm, filter, 1, true)
		else
			-- non-exact (case-insensitive) match
			ok = strFind(nm:lower(), norm, 1, true)
		end

		if ok then
			counts[nm] = (counts[nm] or 0) + 1
			reps[nm]	= true
		end
	end

	-- Build tempList
	local tempList = {}
	for nm, ct in pairs(counts) do
		table.insert(tempList, {
			name	 = nm,
			count	= ct,
			category = categorize(nm),
			rarity   = determineRarity(nm),
			age, weight = parseItemData(nm)
		})
	end

	-- 1st sort
	table.sort(tempList, sortItems)

	-- 2nd grouping
	local finalList = {}
	-- mutated pets
	for _, d in ipairs(tempList) do
		if d.category == "Pets" and isMutated(d.name) then
			table.insert(finalList, d)
		end
	end
	-- others
	for _, d in ipairs(tempList) do
		if not (d.category == "Pets" and isMutated(d.name)) then
			table.insert(finalList, d)
		end
	end

	-- Render
	for _, data in ipairs(finalList) do
		local lbl = Instance.new("TextLabel")
		lbl.Size				   = UDim2.new(1, -10, 0, 30)
		lbl.BackgroundTransparency = 1
		lbl.Text				   = (data.count > 1)
			and (data.name .. " x" .. data.count)
			or data.name
		lbl.TextColor3			 = Color3.new(1, 1, 1)
		lbl.Font				   = Enum.Font.SourceSans
		lbl.TextSize			   = 18
		lbl.BorderSizePixel		= 0
		lbl.Parent				 = scrollingFrame
	end

	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end

-- Events & init
connections[#connections+1] = matchModeToggle.MouseButton1Click:Connect(function()
	isExactMatch = not isExactMatch
	if isExactMatch then
		matchModeToggle.Text			 = "ON"
		matchModeToggle.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
		matchModeLabel.Text			  = "Match Mode: Case-sensitive"
	else
		matchModeToggle.Text			 = "OFF"
		matchModeToggle.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
		matchModeLabel.Text			  = "Match Mode: Case-insensitive"
	end
	listBackpack()
end)
connections[#connections+1] = filterBox:GetPropertyChangedSignal("Text"):Connect(listBackpack)
connections[#connections+1] = closeButton.MouseButton1Click:Connect(function()
	if screenGui then
		screenGui:Destroy()
	end
end)

screenGui.Destroying:Connect(function()
	for _, c in ipairs(connections) do
		if c and c.Disconnect then c:Disconnect() end
	end
end)

local UserInputService = game:GetService("UserInputService")
local dragging = false
local dragInput, dragStart, startPos

-- 🛠️ Handles frame movement based on input delta
local function update(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end

-- 🟡 Begin Drag
connections[#connections + 1] = mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position

		local endConnection
		endConnection = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				if endConnection then endConnection:Disconnect() end
			end
		end)
	end
end)

-- 🔄 Track valid drag input type
connections[#connections + 1] = mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

-- 🚚 Move frame as input changes
connections[#connections + 1] = UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		update(input)
	end
end)

local isMinimized = false
local originalSize = mainFrame.Size
local previouslyVisibleChildren = {}
local originalTitlePosition = titleLabel.Position
local originalTitleSize = titleLabel.Size
local originalTextAlignment = titleLabel.TextXAlignment
local originalTextScaled = titleLabel.TextScaled

connections[#connections + 1] = minimizeButton.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized

	if isMinimized then
		-- Save visible children that need to be hidden
		previouslyVisibleChildren = {}
		mainFrame.Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 50)

		for _, child in ipairs(mainFrame:GetChildren()) do
			if child ~= titleLabel and child ~= closeButton and child ~= minimizeButton then
				if child.Visible then
					table.insert(previouslyVisibleChildren, child)
					child.Visible = false
				end
			end
		end

		-- Reposition and resize titleLabel
		titleLabel.Position = UDim2.new(0, 5, 0, 5)
		titleLabel.Size = UDim2.new(1, -70, 0, 40) -- leaves room for minimize + close
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.TextScaled = true

	else
		mainFrame.Size = originalSize

		-- Restore only previously visible children
		for _, child in ipairs(previouslyVisibleChildren) do
			if not child.Visible then
				child.Visible = true
			end
		end

		-- Restore titleLabel properties
		titleLabel.Position = originalTitlePosition
		titleLabel.Size = originalTitleSize
		titleLabel.TextXAlignment = originalTextAlignment
		titleLabel.TextScaled = originalTextScaled
	end
end)

listBackpack()
