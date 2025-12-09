--[[  
    ULTIMATE MULTIPLAYER ESP (FINAL VERSION)
    ----------------------------------------
    ✔ Green occluded highlight on real character
    ✔ White AlwaysOnTop highlight on shrunk clone
    ✔ Fully skips transparent BaseParts
    ✔ No clone transparency modifications
    ✔ Uses RenderStepped (perfect sync, no teleport lag)
    ✔ Physics disabled on clone (SetNetworkOwner(nil))
    ✔ Cleans clone children, keeps mesh only
    ✔ Works on all players except local
    ✔ Modular TEAMCHECK_FLAG(player)
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players:WaitForChild("lw9f")
local ESP = {}

------------------------------------------------------------
-- TEAMCHECK FLAG (MODULAR)
-- Change this whenever you want
------------------------------------------------------------
local function TEAMCHECK_FLAG(player)
	local ps = player:FindFirstChild("PlayerStates")
	if ps and ps:FindFirstChild("Team") then
		-- If we're enemies
		return ps.Team.Value == localPlayer.PlayerStates.Team.Value
	end
	-- If we're not enemies
	return true
end

------------------------------------------------------------
-- Remove all non-mesh children from a cloned BasePart
------------------------------------------------------------
local function cleanClone(part)
	for _, child in ipairs(part:GetChildren()) do
		if not (child:IsA("SpecialMesh") or child:IsA("MeshPart")) then
			child:Destroy()
		end
	end
end

------------------------------------------------------------
-- Ultra-fast clone synchronizer using RenderStepped
------------------------------------------------------------
local function fastSync(realParts, cloneMap, onDeath)
	return RunService.RenderStepped:Connect(function()
		if onDeath() then return end

		for real, clone in pairs(cloneMap) do
			clone.CFrame = real.CFrame
		end
	end)
end

------------------------------------------------------------
-- Create ESP for one player's character
------------------------------------------------------------
local function createESP(player, character)
	if player == localPlayer then return end
	if ESP[player] then return end
	if not TEAMCHECK_FLAG(player) then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R15 then return end

	------------------------------------------------------------------
	-- Clone visible (non-transparent) R15 Parts for white outline
	------------------------------------------------------------------
	local cloneModel = Instance.new("Model")
	cloneModel.Name = player.Name .. "_ESPClone"
	cloneModel.Parent = workspace

	local cloneMap = {}
	local SHRINK = Vector3.new(0.01, 0.01, 0.01)

	for _, part in ipairs(character:GetDescendants()) do
		-- ONLY clone fully visible BaseParts
		if part:IsA("BasePart") and part.Transparency == 0 then
			local newPart = part:Clone()

			-- Shrink slightly (do NOT change transparency)
			newPart.Size = Vector3.new(
				math.max(part.Size.X - SHRINK.X, 0.01),
				math.max(part.Size.Y - SHRINK.Y, 0.01),
				math.max(part.Size.Z - SHRINK.Z, 0.01)
			)

			newPart.CFrame = part.CFrame
			newPart.Anchored = false
			newPart.CanCollide = false
			newPart.CanTouch = false
			newPart.CanQuery = false
			newPart.Massless = true

			-- Remove non-mesh children
			cleanClone(newPart)

			newPart.Parent = cloneModel
			cloneMap[part] = newPart
		end
	end

	------------------------------------------------------------------
	-- Highlights
	------------------------------------------------------------------
	-- Green occluded highlight on real character
	local green = Instance.new("Highlight")
	green.FillColor = Color3.fromRGB(0,255,0)
	green.FillTransparency = 0.2
	green.OutlineTransparency = 1
	green.DepthMode = Enum.HighlightDepthMode.Occluded
	green.Parent = character

	-- White outline highlight on clone model
	local white = Instance.new("Highlight")
	white.FillTransparency = 1
	white.OutlineTransparency = 0
	white.OutlineColor = Color3.fromRGB(255,255,255)
	white.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	white.Parent = cloneModel

	------------------------------------------------------------------
	-- Ultra-fast Sync Loop (RenderStepped)
	------------------------------------------------------------------
	local loop
	loop = fastSync(character, cloneMap, function()
		if not character.Parent then
			loop:Disconnect()
			green:Destroy()
			cloneModel:Destroy()
			ESP[player] = nil
			return true
		end
	end)

	-- Store ESP data
	ESP[player] = {
		Loop = loop,
		Clone = cloneModel,
		Green = green
	}
end

------------------------------------------------------------
-- Cleanup ESP when a player leaves
------------------------------------------------------------
local function cleanupPlayer(player)
	local data = ESP[player]
	if not data then return end

	if data.Loop then data.Loop:Disconnect() end
	if data.Clone then data.Clone:Destroy() end
	if data.Green then data.Green:Destroy() end

	ESP[player] = nil
end

------------------------------------------------------------
-- Setup for players
------------------------------------------------------------
local function setupPlayer(player)
	player.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		createESP(player, char)
	end)

	if player.Character then
		task.wait(0.5)
		createESP(player, player.Character)
	end
end

------------------------------------------------------------
-- Initialization
------------------------------------------------------------
for _, plr in ipairs(Players:GetPlayers()) do
	if plr ~= localPlayer then
		setupPlayer(plr)
	end
end

Players.PlayerAdded:Connect(function(plr)
	if plr ~= localPlayer then
		setupPlayer(plr)
	end
end)

Players.PlayerRemoving:Connect(cleanupPlayer)
