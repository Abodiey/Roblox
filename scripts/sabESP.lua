--[[
loadstring(game:HttpGet("https://raw.githubusercontent.com/Abodiey/Roblox/refs/heads/main/scripts/sabESP.lua"))()
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local PlotsFolder = workspace:WaitForChild("Plots")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

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

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = false -- we'll handle dragging manually
frame.Parent = gui



local dragging, dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -20, 0, 30)
toggle.Position = UDim2.new(0, 10, 0, 10)
toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Font = Enum.Font.SourceSansBold
toggle.TextSize = 18
toggle.Text = "ESP: ON"
toggle.Parent = frame

local input = Instance.new("TextBox")
input.Size = UDim2.new(1, -20, 0, 30)
input.Position = UDim2.new(0, 10, 0, 50)
input.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
input.TextColor3 = Color3.new(1, 1, 1)
input.Font = Enum.Font.SourceSans
input.TextSize = 16
input.Text = "10000"
input.PlaceholderText = "Min Gen ($/s)"
input.Parent = frame

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0, 20, 0, 20)
minimize.Position = UDim2.new(1, -25, 0, 5)
minimize.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.Font = Enum.Font.SourceSansBold
minimize.TextSize = 14
minimize.Text = "-"
minimize.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -50, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 14
closeButton.Text = "X"
closeButton.Visible = false
closeButton.Parent = frame

closeButton.MouseButton1Click:Connect(function()
	if gui then gui:Destroy() end
	if container then container:Destroy() end
end)

local minimized = false

minimize.MouseButton1Click:Connect(function()
	minimized = not minimized
	toggle.Visible = not minimized
	input.Visible = not minimized
	closeButton.Visible = minimized
	frame.Size = minimized and UDim2.new(0, 200, 0, 30) or UDim2.new(0, 200, 0, 100)
	minimize.Text = minimized and "+" or "-"
end)

-- State
local espEnabled = true
local minGeneration = 10000

toggle.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	toggle.Text = espEnabled and "ESP: ON" or "ESP: OFF"
end)

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
			if plotSign and not plotSignsProcessed[plotSign] then
				plotSignsProcessed[plotSign] = true  -- Mark the plotSign as processed

				local surfaceGui = plotSign:FindFirstChild("SurfaceGui")
				if surfaceGui then
					local frame = surfaceGui:FindFirstChild("Frame")
					if frame then
						local nameLabel = frame:FindFirstChild("TextLabel")
						-- Skip if no textlabel OR the plot belongs to the local player
						if not nameLabel or nameLabel.Text:gsub("'s Base", "") == LocalPlayer.DisplayName then
							continue
						end

						-- Create the ESP using the plotSign and nameLabel.Text
						local value = 100000  -- Replace with any dynamic value you want for sizing, e.g., generation number

						-- Call createESP with the plotSign as targetPart
						local ESP = createESP(plotSign, nameLabel.Text, value)
						nameLabel:GetPropertyChanged("Text"):Connect(function()
							ESP.Text = (nameLabel.Text ~= "Empty Base") and nameLabel.Text or ""
						end)
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
