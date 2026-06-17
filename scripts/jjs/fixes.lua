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

local Whitelist = {
    ["FinalBeam"] = true,
    ["Beam"] = true,
    ["PlasmaWave"] = true,
}

if not Effects then return end
local AddItem = Debris.AddItem
            
for _, Child in ipairs(Effects:GetChildren()) do
    local Name = Child.Name
    if Name ~= BloodName and Whitelist[Name] then
        AddItem(Debris, Child, 60)
    end
end
            
Effects.ChildAdded:Connect(function(Child)
    local Name = Child.Name
    if Name ~= BloodName and Whitelist[Name] then
        AddItem(Debris, Child, 60)
    end
end)
