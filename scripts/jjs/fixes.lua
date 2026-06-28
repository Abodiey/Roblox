-- =============================================================================
-- [ 1. SERVICES & SETTINGS ]
-- =============================================================================
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Debris = cloneref(game:GetService("Debris"))

local Effects = workspace:WaitForChild("Effects", 99999)
local Domains = workspace:WaitForChild("Domains", 99999)

local Connections = {}
local DomainConnections = {}
local Whitelist = { ["FinalBeam"] = true, ["Beam"] = true, ["PlasmaWave"] = true }

-- =============================================================================
-- [ 2. HOOKS & HELPERS ]
-- =============================================================================
if hookmetamethod then
    local OldIndex; OldIndex = hookmetamethod(game, "__newindex", function(Self, Prop, Val)
        if Prop ~= "LocalTransparencyModifier" then return OldIndex(Self, Prop, Val) end
        if Val == false then return OldIndex(Self, Prop, 0) end
        if Val == true and (Self:IsA("BasePart") or Self:IsA("ParticleEmitter")) then return OldIndex(Self, Prop, 0.7) end
        return OldIndex(Self, Prop, Val)
    end)
end

local function HookRemote(descendant)
    if descendant:IsA("RemoteEvent") or descendant:IsA("UnreliableRemoteEvent") then
        Connections[descendant] = descendant.OnClientEvent:Connect(function() end)
    end
end

local function SetupService(name)
    local service = ReplicatedStorage:WaitForChild(name, 99999)
    if not service then return end
    for _, d in ipairs(service:GetDescendants()) do HookRemote(d) end
    table.insert(Connections, service.DescendantAdded:Connect(HookRemote))
end

-- =============================================================================
-- [ 3. DOMAINS & EFFECTS HANDLERS ]
-- =============================================================================
local function HandleDomainChild(domainChild)
    -- Find a direct child that is an UnreliableRemoteEvent (waits up to 5s)
    local remote = domainChild:WaitForChild("UnreliableRemoteEvent", 5)
    if not remote or not remote:IsA("UnreliableRemoteEvent") then return end

    local conn = remote.OnClientEvent:Connect(function() end)
    DomainConnections[domainChild] = conn
end

local function ClearDomainChild(domainChild)
    local conn = DomainConnections[domainChild]
    if conn then
        pcall(function() conn:Disconnect() end)
        DomainConnections[domainChild] = nil
    end
end

local function HandleEffect(child)
    if Whitelist[child.Name] then Debris.AddItem(Debris, child, 60) end
end

-- =============================================================================
-- [ 4. INITIALIZATION & CLEANUP ]
-- =============================================================================
SetupService("DebreeService")
SetupService("HandicapService")

if Effects then
    for _, child in ipairs(Effects:GetChildren()) do HandleEffect(child) end
    table.insert(Connections, Effects.ChildAdded:Connect(HandleEffect))
end

if Domains then
    for _, child in ipairs(Domains:GetChildren()) do task.spawn(HandleDomainChild, child) end
    Domains.ChildAdded:Connect(HandleDomainChild)
    Domains.ChildRemoved:Connect(ClearDomainChild)
end

task.delay(30, function()
    for _, conn in pairs(Connections) do pcall(function() conn:Disconnect() end) end
    table.clear(Connections)
end)
