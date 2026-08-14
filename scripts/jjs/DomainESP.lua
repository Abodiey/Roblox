local DomainESP = {}

local Domains = workspace:WaitForChild("Domains")
local activeEsp = {}

local CULL_DISTANCE = 1000

-- Static edge indices to eliminate table creation per frame
local EDGE_PAIRS = {
    {1, 2}, {2, 3}, {3, 4}, {4, 1},
    {5, 6}, {6, 7}, {7, 8}, {8, 5},
    {1, 5}, {2, 6}, {3, 7}, {4, 8}
}

-- Static unit offsets for the 8 bounding box corners
local CORNER_OFFSETS = {
    Vector3.new(-1, -1, -1),
    Vector3.new( 1, -1, -1),
    Vector3.new( 1, -1,  1),
    Vector3.new(-1, -1,  1),
    Vector3.new(-1,  1, -1),
    Vector3.new( 1,  1, -1),
    Vector3.new( 1,  1,  1),
    Vector3.new(-1,  1,  1)
}

-- Pre-allocated buffer table for projected corner calculations
local cornersBuffer = table.create(8)

-- Optimized camera space clipping (Inlined math to minimize heap garbage)
local function clipLineToCamera(p1, p2, camCF, invCF)
    local cp1 = invCF * p1
    local cp2 = invCF * p2
    local nearZ = -0.1

    if cp1.Z > nearZ and cp2.Z > nearZ then
        return nil, nil
    end

    if cp1.Z > nearZ then
        local t = (nearZ - cp1.Z) / (cp2.Z - cp1.Z)
        cp1 = cp1:Lerp(cp2, t)
    elseif cp2.Z > nearZ then
        local t = (nearZ - cp2.Z) / (cp1.Z - cp2.Z)
        cp2 = cp2:Lerp(cp1, t)
    end

    return camCF * cp1, camCF * cp2
end

local function createEsp(domain)
    if activeEsp[domain] then return end

    local lines = table.create(12)
    for i = 1, 12 do
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Transparency = 1
        line.Visible = false
        lines[i] = line
    end

    local textLabel = Drawing.new("Text")
    textLabel.Text = "Domain"
    textLabel.Size = 16
    textLabel.Center = true
    textLabel.Outline = true
    textLabel.Color = Color3.fromRGB(255, 255, 255)
    textLabel.Visible = false

    local espData = {
        Lines = lines,
        Text = textLabel,
        Connections = {}
    }
    activeEsp[domain] = espData

    local function updateColor()
        local color = domain.CanCollide and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        for i = 1, 12 do
            lines[i].Color = color
        end
    end
    updateColor()

    table.insert(espData.Connections, domain:GetPropertyChangedSignal("CanCollide"):Connect(updateColor))
end

local function removeEsp(domain)
    local espData = activeEsp[domain]
    if not espData then return end

    for _, conn in ipairs(espData.Connections) do 
        conn:Disconnect() 
    end
    for i = 1, 12 do 
        espData.Lines[i]:Remove() 
    end
    if espData.Text then 
        espData.Text:Remove() 
    end

    activeEsp[domain] = nil
end

function DomainESP.Init(State)
    local toggleObject = State.Toggles.DomainESP

    local renderConn = game:GetService("RunService").RenderStepped:Connect(function()
        if not toggleObject.Value then
            for _, espData in pairs(activeEsp) do
                for i = 1, 12 do 
                    espData.Lines[i].Visible = false 
                end
                if espData.Text then 
                    espData.Text.Visible = false 
                end
            end
            return
        end

        local camera = workspace.CurrentCamera
        if not camera then return end

        local camCF = camera.CFrame
        local cameraPos = camCF.Position
        local invCF = camCF:Inverse()

        for domain, espData in pairs(activeEsp) do
            if domain and domain.Parent then
                local cframe = domain.CFrame
                local pos = cframe.Position
                local distance = (pos - cameraPos).Magnitude

                -- Distance Culling check executed upfront to bypass vector math
                if distance <= CULL_DISTANCE then
                    local size = domain.Size * 0.5

                    -- 1. Text Projection
                    local textPoint, textOnScreen = camera:WorldToViewportPoint(pos + Vector3.new(0, size.Y + 1, 0))
                    if textOnScreen and textPoint.Z > 0 then
                        espData.Text.Position = Vector2.new(textPoint.X, textPoint.Y)
                        espData.Text.Visible = true
                    else
                        espData.Text.Visible = false
                    end

                    -- 2. Populate 3D Box Corners in pre-allocated buffer
                    for i = 1, 8 do
                        local offset = CORNER_OFFSETS[i]
                        cornersBuffer[i] = cframe * Vector3.new(size.X * offset.X, size.Y * offset.Y, size.Z * offset.Z)
                    end

                    -- 3. Edge Clipping & Line Rendering
                    for i = 1, 12 do
                        local edge = EDGE_PAIRS[i]
                        local w1, w2 = cornersBuffer[edge[1]], cornersBuffer[edge[2]]
                        local clipped1, clipped2 = clipLineToCamera(w1, w2, camCF, invCF)
                        local line = espData.Lines[i]

                        if clipped1 and clipped2 then
                            local s1 = camera:WorldToViewportPoint(clipped1)
                            local s2 = camera:WorldToViewportPoint(clipped2)
                            line.From = Vector2.new(s1.X, s1.Y)
                            line.To = Vector2.new(s2.X, s2.Y)
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    end
                else
                    -- Out of range: hide drawing elements without math overhead
                    espData.Text.Visible = false
                    for i = 1, 12 do
                        espData.Lines[i].Visible = false
                    end
                end
            end
        end
    end)

    table.insert(State.Connections, renderConn)
    table.insert(State.Connections, Domains.ChildAdded:Connect(createEsp))
    table.insert(State.Connections, Domains.ChildRemoved:Connect(removeEsp))

    for _, child in ipairs(Domains:GetChildren()) do
        createEsp(child)
    end
end

return DomainESP
