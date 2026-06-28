local Gamepasses = {}
local Players = cloneref(game:GetService("Players"))

local plr = Players.LocalPlayer
if not plr then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    plr = Players.LocalPlayer
end

local gamepassesFolder = plr:WaitForChild("Gamepasses",99)
local passIds = {"1151174294", "718699461", "984868818", "857428668", "718947270", "742180133"}

-- Cache original gamepass states at startup so they are never overwritten with false
local originalStates = {}
if gamepassesFolder then
    for _, id in ipairs(passIds) do
        originalStates[id] = gamepassesFolder:GetAttribute(id) or false
    end
end

function Gamepasses.Init(State)
    local toggleObject = State.Toggles.Gamepasses

    local function handleToggleChange()
        if not gamepassesFolder then return end
        
        local isEnabled = toggleObject.Value
        if isEnabled then
            for _, id in ipairs(passIds) do
                gamepassesFolder:SetAttribute(id, true)
            end
        else
            for _, id in ipairs(passIds) do
                gamepassesFolder:SetAttribute(id, originalStates[id])
            end
        end
    end

    local toggleConn = toggleObject:GetPropertyChangedSignal("Value"):Connect(handleToggleChange)
    table.insert(State.Connections, toggleConn)

    handleToggleChange()
end

return Gamepasses
