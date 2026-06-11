--updateRikaTransparency fix (lazy jjs devs)
local LTM = "LocalTransparencyModifier"
local oldIndex
oldIndex = hookmetamethod(game, "__newindex", function(self, prop, val)
    -- 1. Instantly drop out if the property isn't ours
    if prop ~= LTM then 
        return oldIndex(self, prop, val) 
    end
    -- 2. Fast-path check: If it's a boolean, intercept it immediately
    if val == false then
        return oldIndex(self, prop, 0)
    elseif val == true then
        -- We only do the costly IsA check IF a boolean actually slips through
        if self:IsA("BasePart") or self:IsA("ParticleEmitter") then
            return oldIndex(self, prop, 0.7)
        end
    end
    -- 3. If it's already a number, let it through with zero overhead
    return oldIndex(self, prop, val)
end)

--BloodyZee fix (lazy jjs devs)
task.spawn(function()
    local effects = workspace:WaitForChild("Effects", 30)
    if not effects then return end
    local bloodyzee = game.ReplicatedStorage.Modules:WaitForChild("BloodyZee", 30)
    if not bloodyzee then return end
    if effects:FindFirstChild("Blood") then return end
    local blood = Instance.new("Folder")
    blood.Name = "Blood"
    blood.Parent = effects
end)

--fix weird visual stuff staying
local Debris = cloneref(game:GetService("Debris"))
for _, folderName in {"Effects", "Beams"} do
    task.spawn(function()
        local folder = workspace:WaitForChild(folderName, 30)
        if not folder then return end
        
        -- Init: Clean up everything already in the folder
        for _, child in folder:GetChildren() do
            Debris:AddItem(child, 60)
        end
        
        -- Future: Clean up anything added later
        folder.ChildAdded:Connect(function(child)
            Debris:AddItem(child, 60)
        end)
    end)
end
