local DomainNoclip = {}

local RunService = cloneref(game:GetService("RunService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Domains = workspace:WaitForChild("Domains")

local cachedHighlights = {}

local function updateHighlightColor(domain, highlight)
    if domain.CanCollide then
        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    else
        highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
    end
end

local function applyHighlight(domain, State)
    if cachedHighlights[domain] then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "DomainHighlight"
    highlight.FillOpacity = 1
    highlight.OutlineOpacity = 0
    highlight.DepthMode = Enum.HighlightDepthMode.Occluded
    highlight.Adornee = domain
    highlight.Parent = CoreGui

    cachedHighlights[domain] = highlight

    local function syncVisuals()
        if State.Toggles.DomainNoclip.Value then
            highlight.OutlineOpacity = 1
            updateHighlightColor(domain, highlight)
        else
            highlight.OutlineOpacity = 0
        end
    end

    local propertyConn = domain:GetPropertyChangedSignal("CanCollide"):Connect(function()
        if State.Toggles.DomainNoclip.Value then
            updateHighlightColor(domain, highlight)
        end
    end)
    table.insert(State.Connections, propertyConn)

    local destroyConn
    destroyConn = domain.AncestryChanged:Connect(function(_, parent)
        if not parent then
            propertyConn:Disconnect()
            destroyConn:Disconnect()
            highlight:Destroy()
            cachedHighlights[domain] = nil
        end
    end)

    syncVisuals()
end

function DomainNoclip.Init(State)
    local toggleObject = State.Toggles.DomainNoclip

    local stepConn = RunService.Stepped:Connect(function()
        if not toggleObject.Value then return end
        
        for _, v in ipairs(Domains:GetChildren()) do
            if v:IsA("BasePart") then 
                v.CanCollide = false
            end
        end
    end)
    table.insert(State.Connections, stepConn)

    local function handleToggleChange()
        local isEnabled = toggleObject.Value
        
        if isEnabled then
            for _, v in ipairs(Domains:GetChildren()) do
                if v:IsA("BasePart") then
                    applyHighlight(v, State)
                end
            end
        else
            for domain, highlight in pairs(cachedHighlights) do
                highlight.OutlineOpacity = 0
            end
            
            for _, v in ipairs(Domains:GetChildren()) do
                if v:IsA("BasePart") then 
                    v.CanCollide = true
                end
            end
        end
    end

    local childAddedConn = Domains.ChildAdded:Connect(function(child)
        if child:IsA("BasePart") then
            if toggleObject.Value then
                child.CanCollide = false
                applyHighlight(child, State)
            else
                applyHighlight(child, State)
            end
        end
    end)
    table.insert(State.Connections, childAddedConn)

    for _, v in ipairs(Domains:GetChildren()) do
        if v:IsA("BasePart") then
            applyHighlight(v, State)
        end
    end

    local toggleConn = toggleObject:GetPropertyChangedSignal("Value"):Connect(handleToggleChange)
    table.insert(State.Connections, toggleConn)

    handleToggleChange()
end

return DomainNoclip
