if not game:IsLoaded() then game.Loaded:Wait() end
if game.PlaceId ~= 2753915549 and game.PlaceId ~= 4442272183 and game.PlaceId ~= 7449423635 then return end
local anyFruitFound = false
for i,v in pairs(game:GetService("Workspace"):GetChildren()) do
	if v and v:FindFirstChild("Fruit") and v:FindFirstChild("Fruit"):FindFirstChild("Fruit") and v:FindFirstChild("Fruit"):FindFirstChild("Fruit").MeshId thens
		anyFruitFound = true
		break	
	end
end
if not friendIngame and anyFruitFound then
	local Team = "Pirates"
	if not game:GetService("Players").LocalPlayer.Team or game:GetService("Players").LocalPlayer.Team.Name ~= Team then 
		game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", Team) 
	end
	repeat task.wait() until game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart").Position ~= Vector3.new(0,100000,0)
	game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
	local function onCharacterChild(v)
		if v and v:FindFirstChild("Fruit") and v:FindFirstChild("Fruit"):FindFirstChild("Fruit") and v:FindFirstChild("Fruit"):FindFirstChild("Fruit").MeshId and v:FindFirstChild("Handle") then
			local character = game:GetService("Players").LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:Wait()
			local humanoid = character:FindFirstChild("Humanoid")
			repeat task.wait() humanoid:UnequipTools() until not v or not v.Parent or not character or not humanoid or v.Parent~=character
		end
	end
	game:GetService("Players").LocalPlayer:WaitForChild("Backpack").ChildAdded:Connect(function(v)
		if v and v:FindFirstChild("Fruit") and v:FindFirstChild("Handle") then
			repeat
				local storeName = v.Name:gsub(" Fruit","")
				storeName = storeName.."-"..storeName
				pcall(function()
					storeName = v:GetAttribute("OriginalName") or storeName
				end)
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", storeName, v)
				task.wait(.1)
			until not v or not v.Parent or v.Parent ~= game:GetService("Players").LocalPlayer.Backpack
		end
	end)
	if game:GetService("Players").LocalPlayer.Character then
		game:GetService("Players").LocalPlayer.Character.ChildAdded:Connect(onCharacterChild)
	end
	game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function(char)
		char.ChildAdded:Connect(onCharacterChild)
	end)
	local TPSpeed = 350
	for i,v in ipairs(game:GetService("Workspace"):GetChildren()) do
		if v and v:FindFirstChild("Fruit") and v:FindFirstChild("Handle") then
			local done, cancelled = false, false
			local character = game:GetService("Players").LocalPlayer.Character or game:GetService("Players").LocalPlayer.CharacterAdded:Wait()
			local humanoid = character:FindFirstChild("Humanoid")
			local HRP = character:WaitForChild("HumanoidRootPart")
			local Target = v.Handle
			local Tween = game:GetService("TweenService"):Create(HRP, TweenInfo.new((v.Handle.Position - HRP.Position).Magnitude / TPSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(v.Handle.Position)})
			Tween:Play()
			task.spawn(function()
				repeat task.wait() until not v or not v.Parent or not HRP or (v.Parent ~= game:GetService("Workspace") and v.Parent ~= character)
				if Tween then
					Tween:Cancel()
				end
				cancelled = true
			end)
			task.spawn(function()
				while Tween.PlaybackState == Enum.PlaybackState.Playing do
					task.wait()
					humanoid.Sit = false
				end
				done = true
			end)
			repeat task.wait() until done or cancelled
			if cancelled then
				continue
			end
			if v and v.Parent == game:GetService("Workspace") and HRP then
				local dist = (HRP.Position - v.Handle.Position).Magnitude
				if humanoid and dist < 500 then
					humanoid:EquipTool(v.Handle)
				end
			end
		end
	end
	game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TeleportToSpawn")
end
local countdownTime = 10
local gui = Instance.new("ScreenGui",game:GetService("CoreGui"))
local button = Instance.new("TextLabel",gui)
button.Text = ""
button.BackgroundTransparency = 0.7
button.BackgroundColor3 = Color3.new(0,0,0)
button.TextScaled = true
button.TextColor3 = Color3.new(1,1,1)
button.TextStrokeTransparency = 0.1
button.Size = UDim2.fromScale(1,1)
button.Interactable = false
button.Active = false
local startTime = os.clock()
task.spawn(function()
	repeat
		task.wait()
		button.Text = "Abodiey's Fruit Collect\nDone, Deleting gui in "..math.abs(math.ceil(countdownTime-(os.clock()-startTime))).."s..."
	until not button or os.clock()-startTime > countdownTime+1
	gui:Destroy()
end)
local serverUrl = "http://127.0.0.1:8000"

local HttpService = game:GetService("HttpService")
HttpService.HttpEnabled = true
local JobId = game.JobId
local function fetchLatestMessage()
	local success, response = pcall(function()
		return game:HttpGet(serverUrl .. "/")
	end)
	if success then
		if response and response ~= "" then
			response = response:gsub('\\', ''):gsub('%[%"', ""):gsub('%"%]', ""):gsub('","',""):gsub('","',""):split("|")
			print("Received from server: " .. response[1].."\n\n"..response[2])  -- Print the response from the server
			if response[1] and JobId~=response[1] and response[2] then
				print("teleporting to "..response[1])
				print("loadstring "..response[2])
				loadstring(response[2])()
			end
		else
			print("No response from server.")
		end
	else
		warn("Failed to fetch response: " .. tostring(response))
	end
end
fetchLatestMessage()
