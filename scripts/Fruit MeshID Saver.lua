if not game:IsLoaded() then
	game.Loaded:Wait()
end
wait(5)
if game.PlaceId == 2753915549 or game.PlaceId == 4442272183 or game.PlaceId == 7449423635 then
	local filename = "blox_fruits_meshids.txt"
	pcall(function()
		if not isfile(filename) then
			repeat pcall(function() writefile(filename,"~") end) task.wait() until isfile(filename)
		end
	end)
	local function get_file_content()
		pcall(function()
			if not isfile(filename) then
				repeat pcall(function() writefile(filename,"~") end) task.wait() until isfile(filename)
			end
		end)
		local file_content
		repeat pcall(function() file_content = readfile(filename) end) task.wait() until file_content
		return file_content
	end
	local function saveFruitData(id,fruitName)
		local file_content = get_file_content()
		repeat task.wait() until file_content
		if id and id ~= "" and fruitName and fruitName ~= "" and fruitName ~= "Fruit" and fruitName ~= "Fruit " and fruitName ~= " Fruit" and fruitName ~= "(Eating)" then
			if not file_content:find(fruitName) then
				local text = id.." = "..fruitName
				if file_content:find("~") then
					pcall(function()
						writefile(filename,text)
					end)
				else
					pcall(function()
						appendfile(filename,"\n"..text)
					end)
				end
			end
		end
	end
	local function saveIfFruit(v)
		if v and v:FindFirstChild("Fruit") and v:FindFirstChild("Fruit"):FindFirstChild("Fruit") and v:FindFirstChild("Fruit"):FindFirstChild("Fruit").MeshId then
			local id = v:FindFirstChild("Fruit"):FindFirstChild("Fruit").MeshId
			local fruitName = v.Name
			if id and fruitName then
				saveFruitData(id,fruitName)
			end
		end
	end
	for _,child in pairs(game:GetService("Workspace"):GetChildren()) do
		saveIfFruit(child)
	end
	game:GetService("Workspace").ChildAdded:Connect(saveIfFruit)
	for _,player in pairs(game:GetService("Players"):GetPlayers()) do
		if player.Character then
			player.Character.ChildAdded:Connect(saveIfFruit)
		end
		player.CharacterAdded:Connect(function(Character)
			player.Character.ChildAdded:Connect(saveIfFruit)
		end)
		task.spawn(function()
			player:WaitForChild("Backpack").ChildAdded:Connect(saveIfFruit)
		end)
	end
	game:GetService("Players").PlayerAdded:Connect(function(player)
		if player.Character then
			player.Character.ChildAdded:Connect(saveIfFruit)
		end
		player.CharacterAdded:Connect(function(Character)
			Character.ChildAdded:Connect(saveIfFruit)
		end)
		player:WaitForChild("Backpack").ChildAdded:Connect(saveIfFruit)
	end)
end
