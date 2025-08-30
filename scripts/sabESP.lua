--[[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Abodiey/Roblox/refs/heads/main/scripts/sabESP.lua"))()
]]
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local PlotsFolder = workspace:WaitForChild("Plots")

local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Variables for character, root, and backpack
local backpack = player:WaitForChild("Backpack")
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local cloneTool

-- Listen for when the character is added or respawned
player.CharacterAdded:Connect(function(newCharacter)
    -- Reset character, root, and backpack variables when the character is added
    character = newCharacter
    root = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
	cloneTool = backpack:WaitForChild("Quantum Cloner")
end)

-- Destroy any previous ESPContainer or GUI
local oldContainer = CoreGui:FindFirstChild("ESPContainer")
if oldContainer then oldContainer:Destroy() end

local oldGui = CoreGui:FindFirstChild("ESPControlGui")
if oldGui then oldGui:Destroy() end

-- Create new container
local container = Instance.new("Folder")
container.Name = "ESPContainer"
container.Parent = CoreGui

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ESPControlGui"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 150)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = false -- we'll handle dragging manually
mainFrame.Parent = gui

-- Create a frame for buttons
local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 1, -30)  -- Adjust height so the top bar can fit
frame.Position = UDim2.new(0, 0, 0, 30)  -- Position below the top bar
frame.BackgroundTransparency = 1
frame.Parent = mainFrame


local dragging, dragInput, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Create a UIListLayout for vertical stacking
local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)  -- Optional spacing between buttons
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.Parent = frame

-- Add buttons to the frame (will be handled by UIListLayout)
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 30)
toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggle.BackgroundTransparency = mainFrame.BackgroundTransparency
toggle.BorderSizePixel = 0
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.SourceSansBold
toggle.TextSize = 18
toggle.RichText = true
toggle.Text = 'ESP: <font color="rgb(0,255,0)">ON</font>'  -- Green for ON initially
toggle.Parent = frame

local input = Instance.new("TextBox")
input.Size = UDim2.new(1, -20, 0, 30)
input.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
input.BackgroundTransparency = mainFrame.BackgroundTransparency
input.BorderSizePixel = 0
input.TextColor3 = Color3.new(1, 1, 1)
input.Font = Enum.Font.SourceSans
input.TextSize = 16
input.Text = "10000"
input.PlaceholderText = "Min Gen ($/s)"
input.Parent = frame

-- New TP Forward Button
local tpForwardButton = Instance.new("TextButton")
tpForwardButton.Size = UDim2.new(1, -20, 0, 30)
tpForwardButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
tpForwardButton.BackgroundTransparency = mainFrame.BackgroundTransparency
tpForwardButton.BorderSizePixel = 0
tpForwardButton.TextColor3 = Color3.new(1, 1, 1)
tpForwardButton.Font = Enum.Font.SourceSansBold
tpForwardButton.TextSize = 18
tpForwardButton.Text = "TP Forward"
tpForwardButton.Parent = frame

-- Create buttons for minimize/close that are outside the UIListLayout
local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 20, 0, 20)
minimize.Position = UDim2.new(1, -25, 0, 5)
minimize.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
minimize.BorderSizePixel = 0
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.Font = Enum.Font.SourceSansBold
minimize.TextSize = 14
minimize.Text = "-"
minimize.Parent = mainFrame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -50, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
closeButton.BorderSizePixel = 0
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 14
closeButton.Text = "X"
closeButton.Visible = false
closeButton.Parent = mainFrame


-- Round corners for all UI elements
for _, guiObject in pairs(gui:GetDescendants()) do
	if not guiObject:IsA("GuiObject") then continue end
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 15)
	corner.Parent = guiObject
end

-- Minimize functionality
local minimized = false
local originalSize = mainFrame.Size

minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	toggle.Visible = not minimized
	input.Visible = not minimized
	tpForwardButton.Visible = not minimized
	closeButton.Visible = minimized
	mainFrame.Size = minimized and UDim2.new(originalSize.X.Scale, originalSize.X.Offset, originalSize.Y.Scale, 30) or originalSize
	minimize.Text = minimized and "+" or "-"
end)

-- Close functionality
closeButton.MouseButton1Click:Connect(function()
	if gui then gui:Destroy() end
	if container then container:Destroy() end
end)

cloneTool = cloneTool or character:FindFirstChild("Quantum Cloner") or backpack:FindFirstChild("Quantum Cloner")

-- action for "TP Forward" button
tpForwardButton.MouseButton1Click:Connect(function()
    if not cloneTool or not cloneTool.Parent then
		cloneTool = backpack:WaitForChild("Quantum Cloner")
	end
	if cloneTool.Parent ~= character then
		cloneTool.Parent = character
	end
	cloneTool:Activate()
	task.wait()
	game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RE/QuantumCloner/OnTeleport"):FireServer()
	task.wait()
	if cloneTool.Parent ~= backpack then
		cloneTool.Parent = backpack
	end
end)

-- State
local espEnabled = true
local minGeneration = 10000

-- Toggle ESP state
toggle.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	toggle.Text = espEnabled and 'ESP: <font color="rgb(0,255,0)">ON</font>' or 'ESP: <font color="rgb(255,0,0)">OFF</font>'
end)

-- Enable RichText so the text can be interpreted with color formatting
toggle.RichText = true

-- Handle input validation
input.FocusLost:Connect(function()
	local raw = input.Text:upper():gsub("%s+", ""):gsub(",", "") -- normalize
	local isRate = raw:lower():sub(-2) == "/s"
	if isRate then raw = raw:sub(1, -3) end -- remove "/s"

	local number = tonumber(raw)

	if not number then
		local match = raw:match("^(%d+%.?%d*)([KMBT])$")
		if match then
			local value, suffix = raw:match("^(%d+%.?%d*)([KMBT])$")
			value = tonumber(value)
			local multipliers = {
				K = 1e3,
				M = 1e6,
				B = 1e9,
				T = 1e12
			}
			if value and multipliers[suffix] then
				number = value * multipliers[suffix]
			end
		end
	end

	if number then
		minGeneration = number
		input.Text = tostring(number) .. (isRate and "/s" or "") -- optional feedback
	else
		input.Text = "Invalid"
	end
end)

-- Converts "$100K/s" → 100000, "$10.4M/s" → 10400000, etc.
local function parseGeneration(genStr)
	genStr = genStr:gsub("%$", ""):gsub("/s", "")
	local num, suffix = genStr:match("([%d%.]+)([KMB]?)")
	num = tonumber(num)
	if not num then return 0 end

	if suffix == "K" then
		num *= 1e3
	elseif suffix == "M" then
		num *= 1e6
	elseif suffix == "B" then
		num *= 1e9
	end
	return num
end

local function colorToHex(color)
	local r = math.floor(color.R * 255)
	local g = math.floor(color.G * 255)
	local b = math.floor(color.B * 255)
	return string.format("#%02X%02X%02X", r, g, b)
end

-- Function to create the ESP
local function createESP(targetPart, richText, value)
	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = targetPart
	billboard.Size = UDim2.new(0, 100 + math.clamp(value / 1e5, 0, 200), 0, 60)
	billboard.AlwaysOnTop = true

	-- Create the text label for the ESP
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextStrokeTransparency = 0
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.RichText = true
	label.Text = richText
	label.Parent = billboard

	-- Assuming `container` is a valid object where the ESP should be parented
	billboard.Parent = container
	return label
end

-- Main loop
task.spawn(function()
	while container.Parent == CoreGui do
		local plotSignsProcessed = {}  -- Keep track of processed plot signs to avoid redundant operations

		-- Destroy existing ESPs only if necessary
		for _, gui in ipairs(container:GetChildren()) do
			if gui:IsA("BillboardGui") then
				gui:Destroy()
			end
		end

		-- Wait for ESP to be enabled before continuing
		if not espEnabled then
			task.wait(1)
			continue
		end

		-- Iterate through each plot (optimized for processing)
		for _, plot in ipairs(PlotsFolder:GetChildren()) do
			local plotSign = plot:FindFirstChild("PlotSign")
			if plotSign then
				local surfaceGui = plotSign:FindFirstChild("SurfaceGui")
				if surfaceGui then
					local frame = surfaceGui:FindFirstChild("Frame")
					if frame then
						local nameLabel = frame:FindFirstChild("TextLabel")
						-- Only if textlabel and the plot doesn't belongs to the local player
						if nameLabel and nameLabel.Text ~= "Empty Base" and nameLabel.Text:gsub("'s Base", "") ~= player.DisplayName then

							-- Create the ESP using the plotSign and nameLabel.Text
							local value = 500000  -- Replace with any dynamic value you want for sizing, e.g., generation number

							-- Call createESP with the plotSign as targetPart
							local text = nameLabel.Text:gsub("'s Base", "")
							text = '<font color="#FFFFFF">' .. text .. '</font>'
							createESP(plotSign, text, value).TextWrapped = false
						end
					end
				end
			end

			-- Handle podiums and spawn data (only if podiums exist)
			local podiums = plot:FindFirstChild("AnimalPodiums")
			if podiums then
				local highestGen = 0
				local podiumData = {}

				-- Iterate through each podium to gather podium data
				for _, podium in ipairs(podiums:GetChildren()) do
					local base = podium:FindFirstChild("Base")
					if base then
						local spawn = base:FindFirstChild("Spawn")
						if spawn then
							local attachment = spawn:FindFirstChild("Attachment")
							if attachment then
								local overhead = attachment:FindFirstChild("AnimalOverhead")
								if overhead then
									local generation = overhead:FindFirstChild("Generation")
									local mutation = overhead:FindFirstChild("Mutation")
									local displayName = overhead:FindFirstChild("DisplayName")
									local price = overhead:FindFirstChild("Price")

									-- Check for valid generation text and minimum generation filter
									if generation and generation:IsA("TextLabel") and generation.Text:match("/s$") and generation.Visible then
										local genValue = parseGeneration(generation.Text)
										if genValue < minGeneration then continue end

										-- Update podiumData if a new highest generation is found
										if genValue > highestGen then
											highestGen = genValue
											podiumData = {}
										end

										if genValue == highestGen then
											local lines = {}

											-- Helper function to add rich text to lines
											local function addRich(label)
												if label and label:IsA("TextLabel") and label.Visible and label.Text ~= "" then
													local hex = colorToHex(label.TextColor3)
													table.insert(lines, string.format("<font color='%s'>%s</font>", hex, label.Text))
												end
											end

											-- Handle mutation and add rich text labels
											if mutation and mutation.Visible and mutation.Text:lower() == "rainbow" then
												local rainbowText = ""
												local chars = {"R", "A", "I", "N", "B", "O", "W"}
												local colors = {"#FF0000", "#FF7F00", "#FFFF00", "#00FF00", "#0000FF", "#4B0082", "#8B00FF"}
												for i, char in ipairs(chars) do
													rainbowText = rainbowText .. string.format("<font color='%s'>%s</font>", colors[i], char)
												end
												table.insert(lines, rainbowText)
											else
												addRich(mutation)
											end

											-- Add other rich text labels
											addRich(displayName)
											addRich(generation)
											addRich(price)

											-- Concatenate all lines into a rich text string
											local richText = table.concat(lines, "\n")
											-- Store the podium data
											table.insert(podiumData, {part = spawn, text = richText, value = genValue})
										end
									end
								end
							end
						end
					end
				end

				-- Create ESPs for each podium entry in podiumData
				for _, data in ipairs(podiumData) do
					createESP(data.part, data.text, data.value)
				end
			end
		end

		-- Wait for the next iteration with some conditions
		task.wait(0.1)
	end
end)
