-- File: auto_blackflash.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer

local BlackflashDatabase = {
    [100962226150441] = {delay = 0.18, move = 3},
    [95852624447551] = {delay = 0.18, move = 3},
    [74145636023952] = {delay = 0.18, move = 3},
    [72475960800126] = {delay = 0.20, move = 3},
    [100081544058065] = {delay = 0.3, move = 2},
    [123167492985370] = {delay = 0.6, move = 2},
}

return function(doMove, getBFActive)
    local function SetupBlackflash(character)
        local animator = character:WaitForChild("Humanoid", 10):WaitForChild("Animator", 10)
        local conn = animator.AnimationPlayed:Connect(function(track)
            if not getBFActive() then return end
            local rawID = tonumber(track.Animation.AnimationId:match("%d+$"))
            local config = BlackflashDatabase[rawID]
            if config then
                task.delay(config.delay, function()
                    if character.Humanoid.Health > 0 then doMove(config.move) end
                end)
            end
        end)
        return conn
    end

    local mainConn = LocalPlayer.CharacterAdded:Connect(SetupBlackflash)
    if LocalPlayer.Character then SetupBlackflash(LocalPlayer.Character) end
    return mainConn
end
