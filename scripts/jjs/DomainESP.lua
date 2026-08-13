local DomainESP = {}

local Domains = workspace:WaitForChild("Domains")
local activeEsp = {}

local function create3DBox(domain)
    if activeEsp[domain] then return end

    -- Create 12 lines for the 3D bounding box
    local lines = {}
    for i = 1, 12 do
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Transparency = 1
        line.Visible = false
        lines[i] = line
    end

    local espData = {
        Lines = lines,
        Connections = {}
    }
    activeEsp[domain] = espData

    -- Update box color based on collisions
    local function updateColor()
        local color = domain.CanCollide and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        for _, line in ipairs(lines) do
            line.Color = color
        end
    end
    updateColor()

    local propConn = domain:GetPropertyChangedSignal("CanCollide"):Connect(updateColor)
    table.insert(espData.Connections, propConn)
end

local function remove3DBox(domain)
    local espData = activeEsp[domain]
    if not espData then return end

    for _, conn in ipairs(espData.Connections) do
        conn:Disconnect()
    end
    for _, line in ipairs(espData.Lines) do
        line:Remove()
    end

    activeEsp[domain] = nil
end

function DomainESP.Init(State)
    local toggleObject = State.Toggles.DomainESP

    -- Render loop to update 3D box positions
    local renderConn = game:GetService("RunService").RenderStepped:Connect(function()
        if not toggleObject.Value then
            for _, espData in pairs(activeEsp) do
                for _, line in ipairs(espData.Lines) do
                    line.Visible = false
                end
            end
            return
        end

        local camera = workspace.CurrentCamera

        for domain, espData in pairs(activeEsp) do
            if domain then
                local cframe = domain.CFrame
                local size = domain.Size / 2

                -- Calculate the 8 3D corners of the bounding box
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

                -- Convert 3D world corners to 2D screen positions
                local screenPoints = {}
                local allOnScreen = true

                for i = 1, 8 do
                    local point, onScreen = camera:WorldToViewportPoint(corners[i])
                    if not onScreen then
                        allOnScreen = false
                    end
                    screenPoints[i] = Vector2.new(point.X, point.Y)
                end

                if allOnScreen then
                    -- Index pairs representing the 12 edges of a cube
                    local edgePairs = {
                        {1, 2}, {2, 3}, {3, 4}, {4, 1}, -- Bottom face
                        {5, 6}, {6, 7}, {7, 8}, {8, 5}, -- Top face
                        {1, 5}, {2, 6}, {3, 7}, {4, 8}  -- Vertical edges
                    }

                    for i, edge in ipairs(edgePairs) do
                        local line = espData.Lines[i]
                        line.From = screenPoints[edge[1]]
                        line.To = screenPoints[edge[2]]
                        line.Visible = true
                    end
                else
                    for _, line in ipairs(espData.Lines) do
                        line.Visible = false
                    end
                end
            end
        end
    end)
    table.insert(State.Connections, renderConn)

    -- Stream management
    local childAddedConn = Domains.ChildAdded:Connect(create3DBox)
    table.insert(State.Connections, childAddedConn)

    local childRemovedConn = Domains.ChildRemoved:Connect(remove3DBox)
    table.insert(State.Connections, childRemovedConn)

    -- Initial scan
    for _, child in ipairs(Domains:GetChildren()) do
        create3DBox(child)
    end
end

return DomainESP
