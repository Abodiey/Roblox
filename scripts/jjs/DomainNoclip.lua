local DomainNoclip = {}

local domains = workspace:WaitForChild("Domains")
local RunService = cloneref(game:GetService("RunService"))

-- Cache the original __index method
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    -- Fast Path: Ensure it is the target property and not an exploit thread call
    if key == "CanCollide" and not checkcaller() then
        -- Run inside a strict protection layer to preserve stack traces
        local success, isTargetPart = pcall(function()
            return typeof(self) == "Instance" and self:IsA("BasePart") and self:IsDescendantOf(domains)
        end)
        
        if success and isTargetPart then
            -- We spoof true. Because it is executing on the game script's thread invocation,
            -- the environment, identity level, and call stack match perfectly.
            return true 
        end
    end
    
    -- Forward any unexpected checks (.AKEHKEKHA) directly to the original engine index.
    -- This ensures Roblox throws its native "not a valid member" error with the correct script environment.
    return oldIndex(self, key)
end)

function DomainNoclip.Init(State)
    local connection = RunService.Stepped:Connect(function()
        local enabled = State.Toggles.DomainNoclip
        if not enabled then return end 
        
        for _, v in ipairs(domains:GetChildren()) do
            if v:IsA("BasePart") then 
                v.CanCollide = false 
            end
        end
    end)
    table.insert(State.Connections, connection)
end

return DomainNoclip
