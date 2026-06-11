local Debris = cloneref(game:GetService("Debris"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

local LTM = "LocalTransparencyModifier"
local OldIndex

OldIndex = hookmetamethod(game, "__newindex", function(Self, Prop, Val)
    if Prop ~= LTM then 
        return OldIndex(Self, Prop, Val) 
    end

    if Val == false then
        return OldIndex(Self, Prop, 0)
    elseif Val == true then
        if Self:IsA("BasePart") or Self:IsA("ParticleEmitter") then
            return OldIndex(Self, Prop, 0.7)
        end
    end

    return OldIndex(Self, Prop, Val)
end)

local Effects = workspace:WaitForChild("Effects")
local Beams = workspace:WaitForChild("Beams")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Bloodyzee = Modules and Modules:FindFirstChild("BloodyZee")

local BloodName = "Blood"

local function CreateBlood()
    if not Effects or not Bloodyzee then return end
    
    local Blood = Instance.new("Folder")
    Blood.Name = BloodName
    
    Blood.Destroying:Connect(function()
        task.defer(CreateBlood)
    end)
    
    Blood.Parent = Effects
end

if Effects and Bloodyzee and not Effects:FindFirstChild(BloodName) then
    CreateBlood()
end

for _, Folder in ipairs({Effects, Beams}) do
    if Folder then
        task.spawn(function()
            local AddItem = Debris.AddItem
            
            for _, Child in ipairs(Folder:GetChildren()) do
                if Child.Name ~= BloodName then
                    AddItem(Debris, Child, 60)
                end
            end
            
            Folder.ChildAdded:Connect(function(Child)
                if Child.Name ~= BloodName then
                    AddItem(Debris, Child, 60)
                end
            end)
        end)
    end
end
