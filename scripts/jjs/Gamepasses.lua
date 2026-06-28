local Gamepasses = {}
local Players = cloneref(game:GetService("Players"))

-- Secure LocalPlayer references safely
local plr = Players.LocalPlayer
if not plr then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    plr = Players.LocalPlayer
end

local gamepassesFolder = plr:WaitForChild("Gamepasses")
local passIds = {"1151174294", "718699461", "984868818", "857428668", "718947270", "742180133"}

function Gamepasses.Init(State)
    -- Spawn a persistent thread since Init is only called once at startup
    task.spawn(function()
        local wasActive = false

        while true do
            -- Checks if the specific toggle is true or false
            local isActive = State.Toggles.Gamepasses

            if isActive and not wasActive then
                -- Toggle just turned ON: Spoof the gamepasses to true
                wasActive = true
                for _, id in ipairs(passIds) do
                    if gamepassesFolder then
                        gamepassesFolder:SetAttribute(id, true)
                    end
                end

            elseif not isActive and wasActive then
                -- Toggle just turned OFF: Revert them back to false
                wasActive = false
                for _, id in ipairs(passIds) do
                    if gamepassesFolder then
                        gamepassesFolder:SetAttribute(id, false)
                    end
                end
            end

            -- Sleep interval to poll the toggle state with zero overhead
            task.wait(0.1)
        end
    end)
end

return Gamepasses
