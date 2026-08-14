local DomainESP = {}

local Domains = workspace:WaitForChild("Domains")
local activeEsp = {}

local CULL_DISTANCE = 1000

-- Clip a 3D line segment against the camera near plane (Z = -0.1 in camera space)
local function clipLineToCamera(p1, p2, camera)
    local camCF = camera.CFrame
    local invCF = camCF:Inverse()
    
    -- Transform to camera space
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

    local lines = {}
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
        for _, line in ipairs(lines) do
            line.Color = color
        end
    end
    updateColor()

    table.insert(espData.Connections, domain:GetPropertyChangedSignal("CanCollide"):Connect(updateColor))
end

local function removeEsp(domain)
    local espData = activeEsp[domain]
    if not espData then return end

    for _, conn in ipairs(espData.Connections) do conn:Disconnect() end
    for _, line in ipairs(espData.Lines) do line:Remove() end
    if espData.Text then espData.Text:Remove() end

    activeEsp[domain] = nil
end

function DomainESP.Init(State)
    local toggleObject = State.Toggles.DomainESP

    local renderConn = game:GetService("RunService").RenderStepped:Connect(function()
        if not toggleObject.Value then
            for _, espData in pairs(activeEsp) do
                for _, line in ipairs(espData.Lines) do line.Visible = false end
                if espData.Text then espData.Text.Visible = false end
            end
            return
        end

        local camera = workspace.CurrentCamera
        local cameraPos = camera.CFrame.Position

        for domain, espData in pairs(activeEsp) do
            if domain then
                local cframe = domain.CFrame
                local size = domain.Size / 2
                local distance = (cframe.Position - cameraPos).Magnitude

                -- Text
                local textPoint, textOnScreen = camera:WorldToViewportPoint(cframe.Position + Vector3.new(0, size.Y + 1, 0))
                if textOnScreen and textPoint.Z > 0 then
                    espData.Text.Position = Vector2.new(textPoint.X, textPoint.Y)
                    espData.Text.Visible = true
                else
                    espData.Text.Visible = false
                end

                -- 3D Box Lines
                if distance <= CULL_DISTANCE then
                    local corners = {
                        cframe * Vector3.new(-size.X, -size.Y, -size.Z),
                        cframe * Vector3.new(size.X, -size.Y, -size.Z),
                        cframe * Vector3.new(size.X, -size.Y, size.Z),
                        cframe * Vector3.new(-size.X, -size.Y, size.Z),
                        cframe * Vector3.new(-size.X, size.Y, -size.Z),
                        cframe * Vector3.new(size.X, size.Y, -size.Z),
                        cframe * Vector3.new(size.X, size.Y, size.Z),
                        cframe * Vector3.new(-size.X, size.Y, size.Z)
                    }

                    local edgePairs = {
                        {1, 2}, {2, 3}, {3, 4}, {4, 1},
                        {5, 6}, {6, 7}, {7, 8}, {8, 5},
                        {1, 5}, {2, 6}, {3, 7}, {4, 8}
                    }

                    for i, edge in ipairs(edgePairs) do
                        local w1, w2 = corners[edge[1]], corners[edge[2]]
                        local clipped1, clipped2 = clipLineToCamera(w1, w2, camera)
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
                    for _, line in ipairs(espData.Lines) do line.Visible = false end
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
