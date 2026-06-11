local Train = {}

function Train.Init()
    local main = workspace.Map.Destructible.Model.StationControl
    local prompt = main.ButtonTrain.Button.Button
    if not prompt or not prompt.Enabled then return end
    local Event = main.Handle.Train
    Event:FireServer()
end

return Train
