local DomainESP = {}

local Domains = workspace:WaitForChild("Domains")
local activeEsp = {}

-- Max distance (in studs) to render the 3D lines
local CULL_DISTANCE = 1000 -- Balls are big, keep cull distance high

local function createSphereEsp(domain)
    if activeEsp[domain] then return end

    -- Spheres are big. Assume size is uniform, get diameter.
    -- Size/2 is radius.
    local sphereRadius = math.max(domain.Size.X, domain.Size.Y, domain.Size.Z) / 2

    -- Create two circles to represent the sphere structure
    local circles = {}
    for i = 1, 2 do
        local circle = Drawing.new("Circle")
        circle.Thickness = 2
        circle.NumSides = 96 -- Makes it very smooth/circular
        circle.Transparency = 1
        circle.Filled = false
        circle.Visible = false
        circles[i] = circle
    end

    -- Create text label
    local textLabel = Drawing.new("Text")
    textLabel.Text = "Domain"
    textLabel.Size = 20 -- Larger text for big domains
    textLabel.Center = true
    textLabel.Outline = true
    textLabel.Color = Color3.fromRGB(255, 255, 255)
    textLabel.Visible = false

    local espData = {
        Circles = circles,
        Text = textLabel,
        Radius = sphereRadius,
        Connections = {}
    }
    activeEsp[domain] = espData

    -- Update structure color based on collisions
    local function updateColor()
        local color = domain.CanCollide and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        for _, circle in ipairs(circles) do
            circle.Color = color
        end
    end
    updateColor()

    local propConn = domain:GetPropertyChangedSignal("CanCollide"):Connect(updateColor)
    table.insert(espData.Connections, propConn)
end

local function removeEsp(domain)
    local espData = activeEsp[domain]
    if not espData then return end

    for _, conn in ipairs(espData.Connections) do
        conn:Disconnect()
    end
    for _, circle in ipairs(espData.Circles) do
        circle:Remove()
    end
    if espData.Text then
        espData.Text:Remove()
    end

    activeEsp[domain] = nil
end

function DomainESP.Init(State)
    -- Verify toggle structure exists, otherwise create dummy
    if not State.Toggles or not State.Toggles.DomainESP then
        warn("DomainESP toggle not found in State. Creating dummy toggle.")
        State.Toggles = State.Toggles or {}
        State.Toggles.DomainESP = { Value = true } -- Default enabled if not defined
    end
    
    local toggleObject = State.Toggles.DomainESP

    -- Render loop to update positions and visibility
    local renderConn = game:GetService("RunService").RenderStepped:Connect(function()
        if not toggleObject.Value then
            for _, espData in pairs(activeEsp) do
                for _, circle in ipairs(espData.Circles) do
                    circle.Visible = false
                end
                if espData.Text then
                    espData.Text.Visible = false
                end
            end
            return
        end

        local camera = workspace.CurrentCamera
        local cameraCF = camera.CFrame
        local cameraPos = cameraCF.Position
        local sphereRadius = 0
        local worldCenter = Vector3.new()

        for domain, espData in pairs(activeEsp) do
            if domain then
                worldCenter = domain.Position
                sphereRadius = espData.Radius
                local distVec = worldCenter - cameraPos
                local distance = distVec.Magnitude

                -- 1. Handle Text Label (Always visible if in front)
                -- Position it slightly above the radius
                local textWorldPos = worldCenter + Vector3.new(0, sphereRadius + 2, 0)
                local textPoint, textOnScreen = camera:WorldToViewportPoint(textWorldPos)

                if textOnScreen and textPoint.Z > 0 then
                    espData.Text.Position = Vector2.new(textPoint.X, textPoint.Y)
                    espData.Text.Visible = true
                else
                    espData.Text.Visible = false
                end

                -- 2. Handle Sphere Circles (Culled by distance)
                if distance <= CULL_DISTANCE then
                    -- Get the center point of the sphere on screen
                    local screenCenterPoint, screenOnScreen = camera:WorldToViewportPoint(worldCenter)

                    -- Only process if center is roughly in front
                    if screenOnScreen and screenCenterPoint.Z > 0 then
                        -- Math to find the correct 2D radius for the circle on screen
                        -- A larger sphere closer to the screen covers more screen space.
                        local adjRadius = (sphereRadius / distance) * (camera.ViewportSize.Y / 2)

                        -- Circles structure optimization:
                        local circHorizontal = espData.Circles[1]
                        local circVertical = espData.Circles[2]

                        circHorizontal.Position = Vector2.new(screenCenterPoint.X, screenCenterPoint.Y)
                        circHorizontal.Radius = adjRadius
                        circHorizontal.Visible = true

                        -- Optional: Slightly offset second circle to make it look 3D
                        circVertical.Position = Vector2.new(screenCenterPoint.X, screenCenterPoint.Y)
                        -- Scale the vertical axis based on angle (foreshortening)
                        -- As you look down/up, the vertical ring appears more elliptical.
                        local angleFactor = math.abs(distVec.Unit:Dot(Vector3.new(0, 1, 0)))
                        circVertical.Radius = adjRadius * (1 - angleFactor * 0.4) 
                        circVertical.Visible = true
                    else
                        -- Center off-screen, hide circles
                        espData.Circles[1].Visible = false
                        espData.Circles[2].Visible = false
                    end
                else
                    -- Beyond cull distance
                    for _, circle in ipairs(espData.Circles) do
                        circle.Visible = false
                    end
                end
            end
        end
    end)
    table.insert(State.Connections, renderConn)

    -- Stream management
    local childAddedConn = Domains.ChildAdded:Connect(createSphereEsp)
    table.insert(State.Connections, childAddedConn)

    local childRemovedConn = Domains.ChildRemoved:Connect(removeEsp)
    table.insert(State.Connections, childRemovedConn)

    -- Initial scan
    for _, child in ipairs(Domains:GetChildren()) do
        createSphereEsp(child)
    end
end

return DomainESP
