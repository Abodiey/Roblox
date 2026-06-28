local DomainNoclip = {}

-- Localize Services & Core API
local cloneref = cloneref
local game = game
local RunService = cloneref(game:GetService("RunService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local workspace = cloneref(game:GetService("Workspace"))

-- Localize Global Engine Functions
local ipairs = ipairs
local pairs = pairs
local table = table
local table_insert = table.insert
local Instance = Instance
local Color3 = Color3
local Enum = Enum

local Domains = workspace:WaitForChild("Domains")
local cachedHighlights = {}

-- Loop connection tracker
local loopConn = nil

local function updateHighlightColor(domain, highlight)
    if domain.CanCollide then
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    else
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
    end
end

local function applyHighlight(domain, State)
    if cachedHighlights[domain] then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "DomainHighlight"
    highlight.FillTransparency = 0.75
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Adornee = domain
    highlight.Parent = CoreGui

    cachedHighlights[domain] = highlight

    updateHighlightColor(domain, highlight)

    local propConn = domain:GetPropertyChangedSignal("CanCollide"):Connect(function()
        updateHighlightColor(domain, highlight)
    end)
    table_insert(State.Connections, propConn)

    local destroyConn
    destroyConn = domain.AncestryChanged:Connect(function(_, parent)
        if not parent then
            propConn:Disconnect()
            destroyConn:Disconnect()
            highlight:Destroy()
            cachedHighlights[domain] = nil
        end
    end)
    table_insert(State.Connections, destroyConn)
end

function DomainNoclip.Init(State)
    local toggleObject = State.Toggles.DomainNoclip

    local function handleToggleChange()
        local isEnabled = toggleObject.Value

        if isEnabled then
            if not loopConn then
                loopConn = RunService.Stepped:Connect(function()
                    local objects = Domains:GetChildren()
                    for i = 1, #objects do
                        local v = objects[i]
                        if v:IsA("BasePart") then 
                            v.CanCollide = false
                        end
                    end
                end)
                table_insert(State.Connections, loopConn)
            end
        else
            if loopConn then
                loopConn:Disconnect()
                loopConn = nil
            end
            
            local objects = Domains:GetChildren()
            for i = 1, #objects do
                local v = objects[i]
                if v:IsA("BasePart") then 
                    v.CanCollide = true
                end
            end
        end
    end

    -- Persistent indicator streaming loop (Runs regardless of toggle status)
    local childAddedConn = Domains.ChildAdded:Connect(function(child)
        if child:IsA("BasePart") then
            applyHighlight(child, State)
            if toggleObject.Value then
                child.CanCollide = false
            end
        end
    end)
    table_insert(State.Connections, childAddedConn)

    -- Initial load scan for existing domains
    local existing = Domains:GetChildren()
    for i = 1, #existing do
        local v = existing[i]
        if v:IsA("BasePart") then
            applyHighlight(v, State)
        end
    end

    -- Hook up value state updates mapping directly inside the wrapper directory
    local toggleConn = toggleObject:GetPropertyChangedSignal("Value"):Connect(handleToggleChange)
    table_insert(State.Connections, toggleConn)

    handleToggleChange()
end

return DomainNoclip
