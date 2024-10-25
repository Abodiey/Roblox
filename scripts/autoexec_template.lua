local URL = "https://raw.githubusercontent.com/Abodiey/Roblox/main/scripts/NAMEHERE"
repeat
	task.wait()
	pcall(function()
		_ = game:HttpGet(URL)
	end)
until _
loadstring(_)()
