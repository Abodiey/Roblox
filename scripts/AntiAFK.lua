--Anti AFK Script
if not game:IsLoaded() then
	game.Loaded:Wait()
end
pcall(function()
	local cloneref = cloneref or function(o) return o end
	local Players = cloneref(game:GetService("Players"))
	local VirtualUser = cloneref(game:GetService("VirtualUser"))
	Players.LocalPlayer.Idled:Connect(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
		pcall(function()
			VirtualUser:Button2Down(Vector2.new(0,0),game.Workspace.CurrentCamera.CFrame)
			wait(1)
			VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		end)
	end)
end)
