local InstantInteract = {}
local ProximityPromptService = cloneref(game:GetService("ProximityPromptService"))

-- Weak table to cache original durations without preventing garbage collection
local originalDurations = setmetatable({}, {__mode = "k"})
local cache = originalDurations

-- Connection trackers
local promptShownConn = nil
local promptHiddenConn = nil
local toggleConn = nil

-- Completely cleans up connections and restores existing overridden prompts
local function cleanupInstantInteract()
    if promptShownConn then promptShownConn:Disconnect() promptShownConn = nil end
    if promptHiddenConn then promptHiddenConn:Disconnect() promptHiddenConn = nil end

    -- Restore any cached prompts currently in memory back to their original state
    for prompt, originalTime in pairs(cache) do
        if prompt and prompt.Parent then
            prompt.HoldDuration = originalTime
        end
    end
    table.clear(cache)
end

function InstantInteract.Init(State)
    local toggleObject = State.Toggles.InstantInteract

    local function handleToggleChange()
        local isEnabled = toggleObject.Value

        if isEnabled then
            if not promptShownConn then
                promptShownConn = ProximityPromptService.PromptShown:Connect(function(prompt)
                    if not prompt then return end
                    local current = prompt.HoldDuration
                    if current == 0 then return end -- Skip if already instant
                    
                    cache[prompt] = cache[prompt] or current
                    prompt.HoldDuration = 0
                end)
            end

            if not promptHiddenConn then
                promptHiddenConn = ProximityPromptService.PromptHidden:Connect(function(prompt)
                    if not prompt or not prompt.Parent then return end -- Skip if prompt was destroyed/removed
                    local original = cache[prompt]
                    if original then
                        prompt.HoldDuration = original
                    end
                end)
            end
        else
            cleanupInstantInteract()
        end
    end

    toggleConn = toggleObject:GetPropertyChangedSignal("Value"):Connect(handleToggleChange)
    table.insert(State.Connections, toggleConn)

    handleToggleChange()
end

return InstantInteract
