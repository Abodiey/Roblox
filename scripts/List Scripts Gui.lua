-- Configuration
local author = "Abodiey"
local repo = "Roblox"
local branch = "main"
local subfolder = "scripts"

local guiName = "GithubHTMLLoader"

-- Build URLs
local githubHTMLURL = "https://github.com/" .. author .. "/" .. repo .. "/tree/" .. branch .. "/" .. subfolder
local rawBaseURL = "https://raw.githubusercontent.com/" .. author .. "/" .. repo .. "/" .. branch .. "/" .. subfolder .. "/"

repeat
	local gui = game:GetService("CoreGui"):FindFirstChild(guiName)
	if gui then gui:Destroy() end
	task.wait()
until not game:GetService("CoreGui"):FindFirstChild(guiName)

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = guiName
gui.Parent = game:GetService("CoreGui")
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 320)
frame.Position = UDim2.new(0.5, -125, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = gui

local titleLabel = Instance.new("TextLabel")
titleLabel.Text = author.. "'s Scripts"
titleLabel.Size = UDim2.new(0, 200, 0, 30)
titleLabel.Position = UDim2.new(0, 10, 0, 5)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.BackgroundTransparency = 1
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = frame

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 20, 0, 20)
closeButton.Position = UDim2.new(1, -25, 0, 5)
closeButton.Text = "X"
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 16
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
closeButton.BorderSizePixel = 0
closeButton.Parent = frame
closeButton.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -40)
scroll.Position = UDim2.new(0, 5, 0, 35)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = scroll

local function newButton(text)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 30)
	button.Text = text
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 16
	button.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.AutoButtonColor = true
	button.BorderColor3 = Color3.fromRGB(120, 120, 120)
	button.Parent = scroll
	return button
end

local loadingButton = newButton("Loading...")

-- Fetch GitHub HTML
local html = game:HttpGet(githubHTMLURL)

-- Extract .lua filenames from raw HTML
local fileNames = {}
for match in html:gmatch(subfolder .. "/([^%s\">]+%.lua)") do
	table.insert(fileNames, match) -- Stores only the file name (strips folder prefix)
end

-- Preview the results
print("🧠 Files found on GitHub page:")
for _, name in ipairs(fileNames) do
	print("• " .. name)
end

loadingButton:Destroy()
-- Create buttons for each file
for _, filename in ipairs(fileNames) do
	local button = newButton("📄 " .. filename)
	button.MouseButton1Click:Connect(function()
		gui:Destroy()
		task.spawn(function()
			local rawURL = rawBaseURL .. filename:gsub(" ", "%%20")
			local maxRetries = 50
			local attempt = 0
			local content

			repeat
				local success, response = pcall(function()
					return game:HttpGet(rawURL)
				end)

				if success and response then
					content = response
				else
					attempt += 1
					task.wait(0.5)
				end
			until content or attempt >= maxRetries

			if content then
				local success, result = pcall(function()
					return loadstring(content)()
				end)

				if success then
					print("\n✅ Code executed successfully.", "\n")
				else
					warn("\n❌ Error while running loaded code:\n" .. tostring(result))
				end
			else
				warn("🚫 No content available to execute after"  .. maxRetries .. " attempts.")
			end
		end)
	end)
end

task.defer(function()
	scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
end)
