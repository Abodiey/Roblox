local Noclip = {}

-- Services
local charFolder = workspace:WaitForChild("Characters")
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local lp = Players.LocalPlayer

-- Localized methods
local pairs = pairs
local table_insert = table.insert
local table_clear = table.clear
local getChildren = game.GetChildren
local isA = game.IsA
local findFirstChild = game.FindFirstChild
local getAttribute = game.GetAttribute
local getAttributeChangedSignal = game.GetAttributeChangedSignal

-- Parts whose collision should be disabled.
local TARGET_NAMES = {
    Head = true,
    Torso = true,
    ["Left Leg"] = true,
    ["Right Leg"] = true,
    ["Left Arm"] = true,
    ["Right Arm"] = true,
    Collide = true,
    Mask = true,
}

-- Parts we actually changed. Weak keys prevent stale instances from being retained.
local storedParts = {}
setmetatable(storedParts, { __mode = "k" })

-- Character state/cache
local deadCache = {}
local movesetCache = {}
local characterConnections = {}
local partConnections = {}

local loopConn = nil
local toggleConn = nil
local characterAddedConn = nil

local enabled = false
local reconciling = false

local function disconnectList(list)
    for i = #list, 1, -1 do
        local connection = list[i]
        if connection then
            connection:Disconnect()
        end
        list[i] = nil
    end
end

local function rememberAndDisable(part)
    if not part or not part.Parent or not isA(part, "BasePart") then
        return
    end

    if part.CanCollide then
        storedParts[part] = true
        part.CanCollide = false
    end

    -- Collision can be changed by the game after we initially process the part.
    -- Listening to the property is cheaper than checking every part every frame.
    if not partConnections[part] then
        local conn
        conn = part:GetPropertyChangedSignal("CanCollide"):Connect(function()
            if enabled and part.Parent and part.CanCollide then
                part.CanCollide = false
            end
        end)
        partConnections[part] = conn
    end
end

local function forgetPart(part)
    local conn = partConnections[part]
    if conn then
        conn:Disconnect()
        partConnections[part] = nil
    end
    storedParts[part] = nil
end

local function processPart(part, moveset)
    if not isA(part, "BasePart") then
        return
    end

    local name = part.Name
    if TARGET_NAMES[name] then
        rememberAndDisable(part)
        return
    end

    if name == "SetAssets" and moveset then
        if moveset == "Gojo" then
            local gojoMask = findFirstChild(part, "GojoMask")
            local mask = gojoMask and findFirstChild(gojoMask, "Mask")
            rememberAndDisable(mask)
        elseif moveset == "Hanami" then
            rememberAndDisable(findFirstChild(part, "ArmWrap"))
        end
    end
end

local function processCharacter(char)
    if not enabled or char == lp.Character or not char.Parent then
        return
    end

    if deadCache[char] then
        return
    end

    local charName = char.Name

    -- Special NPC handling kept identical to the previous behavior.
    if charName == "FrameNPC" then
        local torso = findFirstChild(char, "Torso")
        if not torso then
            char:Destroy()
        else
            rememberAndDisable(torso)
        end
        return
    elseif charName == "MechamaruBot" then
        local torso = findFirstChild(char, "Torso")
        local head = findFirstChild(char, "Head")

        -- These two parts intentionally retain their old behavior.
        if torso then
            storedParts[torso] = true
            torso.CanCollide = true
        end
        if head then
            rememberAndDisable(head)
        end
        return
    elseif charName == "HarutaSwordNPC" then
        local harutaSword = findFirstChild(char, "HarutaSword")
        local hand = harutaSword and findFirstChild(harutaSword, "Hand")
        local root = hand and findFirstChild(hand, "Handle")
        rememberAndDisable(root)
        return
    end

    local moveset = movesetCache[char]
    local children = getChildren(char)

    for i = 1, #children do
        processPart(children[i], moveset)
    end
end

local function setupCharacter(char)
    if not char or characterConnections[char] then
        return
    end

    deadCache[char] = getAttribute(char, "Dead") and true or nil
    movesetCache[char] = getAttribute(char, "Moveset")

    local connections = {}
    characterConnections[char] = connections

    connections[#connections + 1] = getAttributeChangedSignal(char, "Dead"):Connect(function()
        deadCache[char] = getAttribute(char, "Dead") and true or nil
        if enabled and not deadCache[char] then
            processCharacter(char)
        end
    end)

    connections[#connections + 1] = getAttributeChangedSignal(char, "Moveset"):Connect(function()
        movesetCache[char] = getAttribute(char, "Moveset")
        if enabled then
            processCharacter(char)
        end
    end)

    -- Handle parts/assets created after the character was first seen.
    connections[#connections + 1] = char.DescendantAdded:Connect(function(descendant)
        if not enabled or deadCache[char] or char == lp.Character then
            return
        end

        if isA(descendant, "BasePart") then
            processPart(descendant, movesetCache[char])
        elseif descendant.Name == "SetAssets" then
            processCharacter(char)
        end
    end)

    -- Process once immediately when the character is discovered.
    if enabled then
        processCharacter(char)
    end
end

local function cleanupCharacter(char)
    local connections = characterConnections[char]
    if connections then
        disconnectList(connections)
        characterConnections[char] = nil
    end

    deadCache[char] = nil
    movesetCache[char] = nil
end

local function cleanupNoclip()
    enabled = false

    if loopConn then
        loopConn:Disconnect()
        loopConn = nil
    end

    if characterAddedConn then
        characterAddedConn:Disconnect()
        characterAddedConn = nil
    end

    for char, connections in pairs(characterConnections) do
        disconnectList(connections)
        characterConnections[char] = nil
        deadCache[char] = nil
        movesetCache[char] = nil
    end

    for part, connection in pairs(partConnections) do
        if connection then
            connection:Disconnect()
        end
        partConnections[part] = nil
    end

    -- Restore only parts that this script actually changed.
    for part in pairs(storedParts) do
        if part and part.Parent then
            part.CanCollide = true
        end
    end
    table_clear(storedParts)
end

local function enableNoclip()
    if enabled then
        return
    end

    enabled = true

    -- Characters are normally added/removed infrequently, so event-driven setup
    -- avoids scanning the entire character folder every frame.
    characterAddedConn = charFolder.ChildAdded:Connect(setupCharacter)

    for _, char in ipairs(getChildren(charFolder)) do
        setupCharacter(char)
    end
end

function Noclip.Init(State)
    local toggleObject = State.Toggles.Noclip

    toggleConn = toggleObject:GetPropertyChangedSignal("Value"):Connect(function()
        if toggleObject.Value then
            enableNoclip()
        else
            cleanupNoclip()
        end
    end)
    table_insert(State.Connections, toggleConn)

    if toggleObject.Value then
        enableNoclip()
    end
end

return Noclip
