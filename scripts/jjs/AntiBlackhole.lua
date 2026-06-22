local AntiBlackHole = {}

local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local YukiService = ReplicatedStorage:WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("YukiService")
local EffectsEvent = YukiService:WaitForChild("RE"):WaitForChild("Effects")

local workspaceRef = cloneref(game:GetService("Workspace"))
local effects = workspaceRef:WaitForChild("Effects", 9999)

-- Variables to cache character components without the "my" suffix
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart", 9999)
local humanoid = character:WaitForChild("Humanoid", 9999)

-- Listen for resets/respawns to update the cached components
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	hrp = newCharacter:WaitForChild("HumanoidRootPart", 9999)
	humanoid = newCharacter:WaitForChild("Humanoid", 9999)
end)

local activeConnection = nil

function AntiBlackHole.Init(State)
	local Connection = EffectsEvent.OnClientEvent:Connect(function(effectName, blackHolePart)
		local Enabled = State.Toggles.AntiBlackHole
		if not Enabled or effectName ~= "BlackHole" or not blackHolePart then return end

		-- CRITICAL CHECK: Ignore if we are the one casting it
		if character and blackHolePart:IsDescendantOf(character) then 
			return 
		end

		if activeConnection then 
			activeConnection:Disconnect() 
		end

		local startTime = os.clock()
		local duration = 3.8

		activeConnection = RunService.Stepped:Connect(function(_, deltaTime)
			-- Recheck toggle status mid-loop to support instant toggling off
			if not State.Toggles.AntiBlackHole then
				activeConnection:Disconnect()
				activeConnection = nil
				return
			end

			local blackHoleVfx = effects and effects:FindFirstChild("BlackHole2")

			-- Safety cutoff check: stop if duration passed, part is missing, or the visual blackhole model is gone
			if os.clock() - startTime >= duration or not blackHolePart.Parent or not blackHoleVfx then
				activeConnection:Disconnect()
				activeConnection = nil
				return
			end

			-- Verify cached player components are still completely valid
			if not (hrp and humanoid and hrp.Parent and humanoid.Parent) then return end

			local targetPos = blackHolePart.Position
			local distance = (hrp.Position - targetPos).Magnitude

			if distance <= 100 then
				local pullFactor = 1 - math.clamp(distance / 100, 0, 1)
				local lookDirection = CFrame.lookAt(hrp.Position, targetPos).LookVector

				local baseMultiplier = (humanoid.FloorMaterial == Enum.Material.Air) and 300 or 2000
				local counterVelocity = lookDirection * (pullFactor * baseMultiplier * deltaTime)

				-- If we are dangerously close (e.g., within the kill zone of 25 studs), add a massive pushing force away
				if distance <= 25 then
					local pushDirection = -lookDirection
					-- Applies a steady outward velocity push proportional to how close you are
					local escapeVelocity = pushDirection * ((1 - (distance / 25)) * 120)
					hrp.AssemblyLinearVelocity = (hrp.AssemblyLinearVelocity - counterVelocity) + escapeVelocity
				else
					-- Otherwise, just completely neutralize the pull velocity
					hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity - counterVelocity
				end
			end
		end)
	end)

	table.insert(State.Connections, Connection)
end

return AntiBlackHole
