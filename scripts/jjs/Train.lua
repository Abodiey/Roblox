local Train = {}

function Train.Init()
    local Map = workspace:FindFirstChild("Map")
    if Map then
        local Remote = Map:FindFirstChild("Train", true)
        if Remote and Remote:IsA("RemoteEvent") then
            Remote:FireServer()
        end
    end
end

return Train
