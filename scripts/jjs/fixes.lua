-- =============================================================================
-- [ 1. SERVICES & GLOBAL VARIABLES ]
-- =============================================================================
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Debris = cloneref(game:GetService("Debris"))
local Workspace = cloneref(game:GetService("Workspace"))

local AddItem = Debris.AddItem
local Effects = Workspace:WaitForChild("Effects", 99999)

local LTM = "LocalTransparencyModifier"
local OldIndex = nil
local Connections = {}

local Whitelist = {
    ["FinalBeam"] = true,
    ["Beam"] = true,
    ["PlasmaWave"] = true,
}

-- =============================================================================
-- [ 2. METAMETHOD HOOKS ]
-- =============================================================================
if hookmetamethod then
    OldIndex = hookmetamethod(game, "__newindex", function(Self, Prop, Val)
        if Prop ~= LTM then 
            return OldIndex(Self, Prop, Val) 
        end

        if Val == false then
            return OldIndex(Self, Prop, 0)
        end

        if Val == true and (Self:IsA("BasePart") or Self:IsA("ParticleEmitter")) then
            return OldIndex(Self, Prop, 0.7)
        end

        return OldIndex(Self, Prop, Val)
    end)
end

-- =============================================================================
-- [ 3. HELPER FUNCTIONS ]
-- =============================================================================
local function HookRemote(descendant)
    if descendant:IsA("RemoteEvent") or descendant:IsA("UnreliableRemoteEvent") then
        Connections[descendant] = descendant.OnClientEvent:Connect(function() end)
    end
end

local function SetupService(serviceName)
    local service = ReplicatedStorage:WaitForChild(serviceName, 99999)
    if not service then return end
    
    for _, d in ipairs(service:GetDescendants()) do 
        HookRemote(d) 
    end
    table.insert(Connections, service.DescendantAdded:Connect(HookRemote))
end

local function HandleEffect(child)
    if Whitelist[child.Name] then
        AddItem(Debris, child, 60)
    end
end

-- =============================================================================
-- [ 4. SCRIPT EXECUTION ]
-- =============================================================================
-- Initialize Remote Interceptors
SetupService("DebreeService")
SetupService("HandicapService")

-- Initialize Effects Garbage Collector
if Effects then
    for _, child in ipairs(Effects:GetChildren()) do
        HandleEffect(child)
    end
    table.insert(Connections, Effects.ChildAdded:Connect(HandleEffect))
end

-- =============================================================================
-- [ 5. CLEANUP THREAD ]
-- =============================================================================
task.delay(30, function()
    for _, conn in pairs(Connections) do 
        pcall(function() 
            conn:Disconnect() 
        end) 
    end
    table.clear(Connections)
    Connections = nil
end)
