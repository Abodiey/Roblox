local ESPEffects = {}

local cloneReference = cloneref or function(object) return object end
local ReplicatedStorage = cloneReference(game:GetService("ReplicatedStorage"))

function ESPEffects.Init(State, Cache, ActiveMarks, specialCooldowns)
    local o_clock = os.clock
    local table_insert = table.insert

        -- Get Knit and descendants using WaitForChild
        local KnitFolder = ReplicatedStorage:WaitForChild("Knit")
        local Knit = KnitFolder:WaitForChild("Knit")
        local Services = Knit:WaitForChild("Services")
    
        -- Charles Mark
        local CharlesService = Services:WaitForChild("CharlesService")
        local CharlesRE = CharlesService:WaitForChild("RE")
        local CharlesEffects = CharlesRE:WaitForChild("Effects")
        local markConn = CharlesEffects.OnClientEvent:Connect(function(action, charInstance, pos, markValueObject)
            if action == "Mark" and typeof(charInstance) == "Instance" and typeof(markValueObject) == "Instance" then
                -- Store mark with timestamp
                ActiveMarks[charInstance] = {
                    mark = markValueObject,
                    timestamp = o_clock()
                }
            end
        end)
        table_insert(State.Connections, markConn)
    
        -- Itadori Feint
        local ItadoriService = Services:WaitForChild("ItadoriService")
        local ItadoriRE = ItadoriService:WaitForChild("RE")
        local ItadoriEffects = ItadoriRE:WaitForChild("Effects")
        local feintConn = ItadoriEffects.OnClientEvent:Connect(function(action, charInstance, ...)
            if action == "Feint" and typeof(charInstance) == "Instance" then
                for p, c in pairs(Cache) do
                    if p.Character == charInstance then
                        local spec = specialCooldowns["Itadori"]
                        if spec then
                            c.SpecialCooldownEnd = o_clock() + spec.Duration
                        end
                        break
                    end
                end
            end
        end)
        table_insert(State.Connections, feintConn)
    
        -- Hakari Counter
        local HakariService = Services:WaitForChild("HakariService")
        local HakariRE = HakariService:WaitForChild("RE")
        local HakariEffects = HakariRE:WaitForChild("Effects")
        local counterConn = HakariEffects.OnClientEvent:Connect(function(action, charInstance, ...)
            if action == "Counter" and typeof(charInstance) == "Instance" then
                for p, c in pairs(Cache) do
                    if p.Character == charInstance then
                        local spec = specialCooldowns["Hakari"]
                        if spec then
                            c.SpecialCooldownEnd = o_clock() + spec.Duration
                        end
                        break
                    end
                end
            end
        end)
        table_insert(State.Connections, counterConn)
end

return ESPEffects

