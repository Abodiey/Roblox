if not game:IsLoaded() then
    game.Loaded:Wait()
end
local currentJobId = game.JobId
game:GetService("GuiService").ErrorMessageChanged:Connect(function()
	local LeaveButtonExists, _ = pcall(function()
		return game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame.ButtonArea.LeaveButton.ButtonText
	end)
	local ReconnectButtonExists, _ = pcall(function()
		return game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame.ButtonArea.ReconnectButton.ButtonText
	end)
	if ReconnectButtonExists or LeaveButtonExists then
		if #game:GetService("Players"):GetPlayers() <= 1 then
			game.Players.LocalPlayer:Kick("\nRejoining...")
			task.wait(1)
			repeat
				local pingSuccess = (game:HttpGet("example.com") and true) or false
				if pingSuccess == nil then
					repeat task.wait() until pingSuccess ~= nil
				end
				if pingSuccess == true then
					game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
				end
				task.wait(10)
			until currentJobId ~= game.JobId
		else
			repeat
				local pingSuccess = (game:HttpGet("example.com") and true) or false
				if pingSuccess == nil then
					repeat task.wait() until pingSuccess ~= nil
				end
				if pingSuccess == true then
					game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
				end
				task.wait(10)
			until currentJobId ~= game.JobId
		end
	end
end)
