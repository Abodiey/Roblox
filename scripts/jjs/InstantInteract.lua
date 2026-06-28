local InstantInteract = {}

-- Localize Services & Core API
local cloneref = cloneref
local game = game
local ProximityPromptService = cloneref(game:GetService("ProximityPromptService"))

-- Localize Global Engine Functions
local pairs = pairs
local table = table
local table_insert = table.insert
local table_clear = table.clear

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
    table_clear(cache)
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

    local toggleConn = toggleObject:GetPropertyChangedSignal("Value"):Connect(handleToggleChange)
    table_insert(State.Connections, toggleConn)

    handleToggleChange()
end

return InstantInteract
