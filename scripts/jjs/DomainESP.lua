local DomainESP = {}

local Domains = workspace:WaitForChild("Domains")
local activeEsp = {}

local CULL_DISTANCE = 1000

-- Sphere configuration: 8 segments per ring across 3 planes = 24 lines total
local SEGMENTS = 8
local TOTAL_LINES = SEGMENTS * 3

-- Precompute sine and cosine tables to eliminate per-frame trig calculations
local SIN_VALS = table.create(SEGMENTS)
local COS_VALS = table.create(SEGMENTS)
for i = 1, SEGMENTS do
    local angle = (i - 1) * (2 * math.pi / SEGMENTS)
    SIN_VALS[i] = math.sin(angle)
    COS_VALS[i] = math.cos(angle)
end

-- Clip a 3D line segment against the camera near plane (Z = -0.1 in camera space)
local function clipLineToCamera(p1, p2, camCF, invCF)
    local cp1 = invCF * p1
    local cp2 = invCF * p2
    
    local nearZ = -0.1 -- Near plane in camera space
    
    if cp1.Z > nearZ and cp2.Z > nearZ then
        return nil, nil -- Fully behind camera
    end
    
    if cp1.Z > nearZ then
        local t = (nearZ - cp1.Z) / (cp2.Z - cp1.Z)
        cp1 = cp1:Lerp(cp2, t)
    elseif cp2.Z > nearZ then
        local t = (nearZ - cp2.Z) / (cp1.Z - cp2.Z)
        cp2 = cp2:Lerp(cp1, t)
    end
    
    -- Transform back to world space
    return camCF * cp1, camCF * cp2
end

local function createEsp(domain)
    if activeEsp[domain] then return end

    local lines = table.create(TOTAL_LINES)
    for i = 1, TOTAL_LINES do
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
        for i = 1, TOTAL_LINES do
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
    for i = 1, TOTAL_LINES do 
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
                for i = 1, TOTAL_LINES do 
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

                -- Distance Culling check executed upfront
                if distance <= CULL_DISTANCE then
                    local size = domain.Size
                    local radius = math.max(size.X, math.max(size.Y, size.Z)) * 0.5

                    -- 1. Text Projection
                    local textPoint, textOnScreen = camera:WorldToViewportPoint(pos + Vector3.new(0, radius + 1, 0))
                    if textOnScreen and textPoint.Z > 0 then
                        espData.Text.Position = Vector2.new(textPoint.X, textPoint.Y)
                        espData.Text.Visible = true
                    else
                        espData.Text.Visible = false
                    end

                    -- 2. Sphere Wireframe Projection (3 Rings: XZ, XY, YZ planes)
                    local lineIdx = 1
                    for i = 1, SEGMENTS do
                        local nextI = (i % SEGMENTS) + 1

                        local cosI, sinI = COS_VALS[i], SIN_VALS[i]
                        local cosNext, sinNext = COS_VALS[nextI], SIN_VALS[nextI]

                        -- Ring 1: XZ Plane (Horizontal)
                        do
                            local w1 = cframe * Vector3.new(cosI * radius, 0, sinI * radius)
                            local w2 = cframe * Vector3.new(cosNext * radius, 0, sinNext * radius)
                            local clipped1, clipped2 = clipLineToCamera(w1, w2, camCF, invCF)
                            local line = espData.Lines[lineIdx]

                            if clipped1 and clipped2 then
                                local s1 = camera:WorldToViewportPoint(clipped1)
                                local s2 = camera:WorldToViewportPoint(clipped2)
                                line.From = Vector2.new(s1.X, s1.Y)
                                line.To = Vector2.new(s2.X, s2.Y)
                                line.Visible = true
                            else
                                line.Visible = false
                            end
                            lineIdx = lineIdx + 1
                        end

                        -- Ring 2: XY Plane (Vertical 1)
                        do
                            local w1 = cframe * Vector3.new(cosI * radius, sinI * radius, 0)
                            local w2 = cframe * Vector3.new(cosNext * radius, sinNext * radius, 0)
                            local clipped1, clipped2 = clipLineToCamera(w1, w2, camCF, invCF)
                            local line = espData.Lines[lineIdx]

                            if clipped1 and clipped2 then
                                local s1 = camera:WorldToViewportPoint(clipped1)
                                local s2 = camera:WorldToViewportPoint(clipped2)
                                line.From = Vector2.new(s1.X, s1.Y)
                                line.To = Vector2.new(s2.X, s2.Y)
                                line.Visible = true
                            else
                                line.Visible = false
                            end
                            lineIdx = lineIdx + 1
                        end

                        -- Ring 3: YZ Plane (Vertical 2)
                        do
                            local w1 = cframe * Vector3.new(0, cosI * radius, sinI * radius)
                            local w2 = cframe * Vector3.new(0, cosNext * radius, sinNext * radius)
                            local clipped1, clipped2 = clipLineToCamera(w1, w2, camCF, invCF)
                            local line = espData.Lines[lineIdx]

                            if clipped1 and clipped2 then
                                local s1 = camera:WorldToViewportPoint(clipped1)
                                local s2 = camera:WorldToViewportPoint(clipped2)
                                line.From = Vector2.new(s1.X, s1.Y)
                                line.To = Vector2.new(s2.X, s2.Y)
                                line.Visible = true
                            else
                                line.Visible = false
                            end
                            lineIdx = lineIdx + 1
                        end
                    end
                else
                    -- Out of range: hide drawings
                    espData.Text.Visible = false
                    for i = 1, TOTAL_LINES do
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
