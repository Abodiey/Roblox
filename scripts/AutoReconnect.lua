if not game:IsLoaded() then
    game.Loaded:Wait()
end
local currentPlaceId = game.PlaceId
local currentJobId = game.JobId
game:GetService("GuiService").ErrorMessageChanged:Connect(function()
	local success,okbutton = pcall(function()
		return game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame.ButtonArea.OkButton.ButtonText
	end)
	if success and okbutton then game:GetService("GuiService"):ClearError() return end
	if #game.Players:GetPlayers() <= 1 then
		game.Players.LocalPlayer:Kick("\nRejoining...")
		task.wait(1)
		repeat
			local pingSuccess = (game:HttpGet("example.com") and true) or false
			repeat task.wait() until pingSuccess ~= nil
			if pingSuccess then
				game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
			end
			task.wait(10)
		until currentJobId ~= game.JobId
	else
		repeat
			local pingSuccess = (game:HttpGet("example.com") and true) or false
			repeat task.wait() until pingSuccess ~= nil
			if pingSuccess then
				game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
			end
			task.wait(10)
		until currentJobId ~= game.JobId
	end
end)
