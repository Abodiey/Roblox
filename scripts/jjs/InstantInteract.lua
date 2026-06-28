local InstantInteract = {}
local ProximityPromptService = cloneref(game:GetService("ProximityPromptService"))

-- Weak table to cache original durations without preventing garbage collection
local originalDurations = setmetatable({}, {__mode = "k"})
local cache = originalDurations

-- Connection trackers
local promptShownConn = nil
local promptHiddenConn = nil

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
    -- Spawn a persistent thread since Init is only called once at startup
    task.spawn(function()
        local wasActive = false

        while true do
            -- Target toggle state pointer
            local isActive = not not (State.Toggles and State.Toggles.InstantInteract)

            if isActive and not wasActive then
                -- Toggle just turned ON: Establish listeners
                wasActive = true

                promptShownConn = ProximityPromptService.PromptShown:Connect(function(prompt)
                    if not prompt then return end
                    local current = prompt.HoldDuration
                    if current == 0 then return end -- Skip if already instant
                    
                    cache[prompt] = cache[prompt] or current
                    prompt.HoldDuration = 0
                end)

                promptHiddenConn = ProximityPromptService.PromptHidden:Connect(function(prompt)
                    if not prompt or not prompt.Parent then return end -- Skip if prompt was destroyed/removed
                    local original = cache[prompt]
                    if original then
                        prompt.HoldDuration = original
                    end
                end)

            elseif not isActive and wasActive then
                -- Toggle just turned OFF: Restore durations and disconnect signals
                wasActive = false
                cleanupInstantInteract()
            end

            -- Sleep interval to poll the toggle state with zero overhead
            task.wait(0.1)
        end
    end)
end

return InstantInteract
