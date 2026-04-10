local Blackflash = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DB = {
    [100962226150441] = {delay = 0.18, move = 3},
    [95852624447551] = {delay = 0.18, move = 3},
    [100081544058065] = {delay = 0.3, move = 2}
}

local function doMove(moveNumber)
    local main = Players.LocalPlayer.PlayerGui:FindFirstChild("Main")
    local movesetGui = main and main:FindFirstChild("Moveset")
    if not movesetGui then return end

    local frames = {}
    for _, v in pairs(movesetGui:GetChildren()) do if v:IsA("Frame") then table.insert(frames, v) end end
    table.sort(frames, function(a, b) return (a.LayoutOrder or 0) < (b.LayoutOrder or 0) end)

    local target = frames[moveNumber]
    if target then
        local service = ReplicatedStorage:WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services"):FindFirstChild(target.Name:gsub(" ", "") .. "Service")
        if service then service:WaitForChild("RE"):WaitForChild("Activated"):FireServer(Players.LocalPlayer.Character.Moveset:FindFirstChild(target.Name)) end
    end
end

function Blackflash.Init(State)
    local function setup(char)
        local conn = char:WaitForChild("Humanoid"):WaitForChild("Animator").AnimationPlayed:Connect(function(track)
            if not State.Toggles.Blackflash then return end
            local cfg = DB[tonumber(track.Animation.AnimationId:match("%d+$"))]
            if cfg then task.delay(cfg.delay, function() doMove(cfg.move) end) end
        end)
        table.insert(State.Connections, conn)
    end
    if Players.LocalPlayer.Character then setup(Players.LocalPlayer.Character) end
    table.insert(State.Connections, Players.LocalPlayer.CharacterAdded:Connect(setup))
end

return Blackflash
