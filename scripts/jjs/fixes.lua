local Debris = cloneref(game:GetService("Debris"))
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
local BloodyZee = Modules:FindFirstChild("BloodyZee")

if Effects and BloodyZee and not Effects:FindFirstChild("Blood") then
    local Blood = Instance.new("Folder")
    Blood.Name = "Blood"
    Blood.Parent = Effects
end

for _, Folder in ipairs({Effects, Beams}) do
    if Folder then
        task.spawn(function()
            for _, Child in ipairs(Folder:GetChildren()) do
                Debris:AddItem(Child, 60)
            end
            
            Folder.ChildAdded:Connect(function(Child)
                Debris:AddItem(Child, 60)
            end)
        end)
    end
end
