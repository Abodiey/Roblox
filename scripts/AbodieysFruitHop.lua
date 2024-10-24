if not game:IsLoaded() then game.Loaded:Wait() end
if game.PlaceId ~= 2753915549 and game.PlaceId ~= 4442272183 and game.PlaceId ~= 7449423635 then return end
--gui start
local gui = Instance.new("ScreenGui",game:GetService("CoreGui"))
local toggleOnButton = Instance.new("TextButton",gui)
local toggledOn = true
pcall(function()
	if isfile("abodiey_fruit_hop_off.txt") then
		toggledOn = false
	end
end)
if toggledOn then
	toggleOnButton.Text = "Abodiey's Fruit Hop"..": ON"
	toggleOnButton.TextColor3 = Color3.new(0,1,0)
	pcall(function()
		delfile("abodiey_fruit_hop_off.txt")
	end)
else
	toggleOnButton.Text = "Abodiey's Fruit Hop"..": OFF"
	toggleOnButton.TextColor3 = Color3.new(1,0,0)
	pcall(function()
		writefile("abodiey_fruit_hop_off.txt","hi")
	end)
end
toggleOnButton.BackgroundTransparency = 0
toggleOnButton.BackgroundColor3 = Color3.new(0,0,0)
toggleOnButton.TextScaled = true
toggleOnButton.ZIndex = 2
toggleOnButton.Size = UDim2.fromOffset(200,50)
toggleOnButton.AnchorPoint = Vector2.new(0.5,0)
toggleOnButton.Position = UDim2.fromScale(0.5,0)
toggleOnButton.MouseButton1Click:Connect(function()
	toggledOn = not toggledOn
	if toggledOn then
		toggleOnButton.Text = "Abodiey's Fruit Hop"..": ON"
		toggleOnButton.TextColor3 = Color3.new(0,1,0)
		pcall(function()
			delfile("abodiey_fruit_hop_off.txt")
		end)
	else
		toggleOnButton.Text = "Abodiey's Fruit Hop"..": OFF"
		toggleOnButton.TextColor3 = Color3.new(1,0,0)
		pcall(function()
			writefile("abodiey_fruit_hop_off.txt","hi")
		end)
	end
end)
repeat task.wait() until toggledOn == true
--gui end
local friendIngame = false
for _,LoopPlayer in pairs(game:GetService("Players"):GetPlayers()) do
	if LoopPlayer and LoopPlayer ~= game:GetService("Players").LocalPlayer then
		local isFriend
		repeat 
			pcall(function()
				isFriend = game:GetService("Players").LocalPlayer:IsFriendsWith(LoopPlayer.UserId)
			end)
			task.wait()
		until isFriend ~= nil
		if isFriend and isFriend == true then
			friendIngame = true
			break
		end
	end
end
local anyFruitFound = false
for i,v in pairs(game:GetService("Workspace"):GetChildren()) do
	if v and v:FindFirstChild("Fruit") and v:FindFirstChild("Fruit"):FindFirstChild("Fruit") and v:FindFirstChild("Fruit"):FindFirstChild("Fruit").MeshId then
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
				task.wait()
				local storeName = v.Name:gsub(" Fruit","")
				storeName = storeName.."-"..storeName
				pcall(function()
					storeName = v:GetAttribute("OriginalName") or storeName
				end)
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", storeName, v)
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
			print("> Found "..v.Name)
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
local function HopServer()
	local function Hop()
		for i = 1, 200 do
			local serverlist = game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer(i)
			for k,v in pairs(serverlist) do
				if k ~= game.JobId and v.Count < 9 then
					game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport",k)
					return true
				end
			end
		end
		return false
	end
	if not getgenv().Loaded then
		local function child(childinstance)
			if childinstance.Name == "ErrorPrompt" then
				if childinstance.Visible then
					if childinstance.TitleFrame.ErrorTitle.Text == "Teleport Failed" then
						HopServer()
					end
				end
				childinstance:GetPropertyChangedSignal("Visible"):Connect(function()
					if childinstance.Visible then
						if childinstance.TitleFrame.ErrorTitle.Text == "Teleport Failed" then
							HopServer()
						end
					end
				end)
			end
		end
		for k,v in pairs(game:GetService("CoreGui").RobloxPromptGui.promptOverlay:GetChildren()) do
			child(v)
		end
		game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(child)
		getgenv().Loaded = true
	end
	while not Hop() do task.wait() end
end

local countdownTime = 5
local retryTime = 60
local betweenClickTime = 1
local rejoinAccepted
repeat task.wait()
	local button = Instance.new("TextButton",gui)
	button.Text = ""
	button.BackgroundTransparency = 0.5
	button.BackgroundColor3 = Color3.new(0,0,0)
	button.TextScaled = true
	button.TextColor3 = Color3.new(1,1,1)
	button.TextStrokeTransparency = 0.1
	button.Size = UDim2.fromScale(1,1)
	local count = 0
	local cancelled = false
	button.MouseButton1Click:Connect(function()
		count += 1 -- add 1 to the number of clicks

		if count % 2 == 0 then -- you reached the threshold
			cancelled = true
		end

		task.wait(betweenClickTime) -- just wait to invalidate the click
		count -= 1 -- invalidate the click
	end)
	local startTime = os.clock()
	repeat
		task.wait()
		button.Text = "Abodiey's Fruit Hop\nRejoining in "..math.abs(math.ceil(countdownTime-(os.clock()-startTime))).."s...\n(Double click to cancel)"
	until cancelled or os.clock()-startTime > countdownTime+1
	if cancelled then
		button.Text = "Abodiey's Fruit Hop\nCancelled!\nRetrying in "..retryTime.."s."
		button.BackgroundTransparency = 1
		button.Interactable = false
		button.Active = false
		task.wait(1)
		button:Destroy()
		task.wait(retryTime-1)
	else
		button.Text = "Abodiey's Fruit Hop\nRejoining..."
		task.wait()
		rejoinAccepted = true
	end
until rejoinAccepted--first sea: 2753915549, second sea: 4442272183, third sea: 7449423635
HopServer()
-- repeat
-- 	local pingSuccess = (game:HttpGet("example.com") and true) or false
-- 	repeat task.wait() until pingSuccess ~= nil
-- 	if pingSuccess then
-- 		HopServer()
-- 		task.wait()
-- 	end
-- until not game:GetService("Players").LocalPlayer
