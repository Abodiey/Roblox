local Debris = cloneref(game:GetService("Debris"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LTM = "LocalTransparencyModifier"
local oldIndex

oldIndex = hookmetamethod(game, "__newindex", function(self, prop, val)
    if prop ~= LTM then 
        return oldIndex(self, prop, val) 
    end

    if val == false then
        return oldIndex(self, prop, 0)
    elseif val == true then
        if self:IsA("BasePart") or self:IsA("ParticleEmitter") then
            return oldIndex(self, prop, 0.7)
        end
    end

    return oldIndex(self, prop, val)
end)

local effects = workspace:WaitForChild("Effects")
local beams = workspace:WaitForChild("Beams")
local modules = ReplicatedStorage:WaitForChild("Modules")
local bloodyzee = modules and modules:FindFirstChild("BloodyZee")

if effects and bloodyzee and not effects:FindFirstChild("Blood") then
    local blood = Instance.new("Folder")
    blood.Name = "Blood"
    blood.Parent = effects
end

for _, folder in ipairs({effects, beams}) do
    if folder then
        task.spawn(function()
            for _, child in ipairs(folder:GetChildren()) do
                Debris:AddItem(child, 60)
            end
            
            folder.ChildAdded:Connect(function(child)
                Debris:AddItem(child, 60)
            end)
        end)
    end
end
