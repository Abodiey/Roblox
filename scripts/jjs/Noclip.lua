local Noclip = {}

-- Localize Services and Global Functions
local charFolder = workspace:WaitForChild("Characters")
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local lp = Players.LocalPlayer

-- Localize Global Engine Functions
local pairs = pairs
local table = table
local table_insert = table.insert
local table_clear = table.clear
local getChildren = game.GetChildren
local isA = game.IsA
local findFirstChild = game.FindFirstChild

-- Localize Attribute Methods to bypass framework lookup overhead
local getAttribute = game.GetAttribute
local getAttributeChangedSignal = game.GetAttributeChangedSignal

local storedParts = {}
setmetatable(storedParts, {__mode = "k"}) 

-- State tracking tables for optimization
local deadCache = {}
local movesetCache = {}

-- Separate tracking tables for connections to avoid string concatenation
local deadJanitor = {}
local movesetJanitor = {}

-- Loop connection tracker
local loopConn = nil
local toggleConn = nil

-- Whitelist of part names for R6 and specific assets
local TARGET_NAMES = {
    ["Head"] = true, ["Torso"] = true, 
    ["Left Leg"] = true, ["Right Leg"] = true, 
    ["Left Arm"] = true, ["Right Arm"] = true,
    ["Collide"] = true, ["Mask"] = true
}

-- Absolute leak prevention: clean up allocations immediately when entities leave
charFolder.ChildRemoved:Connect(function(char)
    deadCache[char] = nil
    movesetCache[char] = nil
    
    local dConn = deadJanitor[char]
    if dConn then dConn:Disconnect() deadJanitor[char] = nil end
    
    local mConn = movesetJanitor[char]
    if mConn then mConn:Disconnect() movesetJanitor[char] = nil end
end)

-- Restores collision states and completely flushes caches
local function cleanupNoclip()
    if loopConn then
        loopConn:Disconnect()
        loopConn = nil
    end

    for part in pairs(storedParts) do
        if part and part.Parent then
            part.CanCollide = true
        end
    end
    table_clear(storedParts)
end

function Noclip.Init(State)
    local toggleObject = State.Toggles.Noclip

    local function handleToggleChange()
        local isEnabled = toggleObject.Value

        if isEnabled then
            if not loopConn then
                loopConn = RunService.Stepped:Connect(function()
                    local myChar = lp.Character
                    local players = getChildren(charFolder)

                    for i = 1, #players do
                        local char = players[i]
                        
                        if char ~= myChar then
                            -- Setup event listeners on first sight using localized method calls
                            if not deadJanitor[char] then
                                if getAttribute(char, "Dead") then
                                    deadCache[char] = true
                                end
                                deadJanitor[char] = getAttributeChangedSignal(char, "Dead"):Connect(function()
                                    deadCache[char] = getAttribute(char, "Dead") or nil
                                end)

                                movesetCache[char] = getAttribute(char, "Moveset")
                                movesetJanitor[char] = getAttributeChangedSignal(char, "Moveset"):Connect(function()
                                    movesetCache[char] = getAttribute(char, "Moveset")
                                end)
                            end

                            if deadCache[char] then 
                                continue 
                            end

                            local charName = char.Name
                            
                            -- Flat guard clauses for distinct NPC fast paths
                            if charName == "FrameNPC" then
                                local torso = findFirstChild(char, "Torso")
                                if not torso then 
                                    char:Destroy() 
                                else
                                    storedParts[torso] = true
                                    torso.CanCollide = false
                                end
                                continue
                            elseif charName == "MechamaruBot" then
                                local torso, head = char.Torso, char.Head
                                if torso and head then
                                    storedParts[torso], storedParts[head] = true, true
                                    torso.CanCollide, head.CanCollide = false, false
                                end
                                continue
                            elseif charName == "HarutaSwordNPC" then
                                local harutaSword = findFirstChild(char, "HarutaSword")
                                local hand = harutaSword and findFirstChild(harutaSword, "Hand")
                                local root = hand and findFirstChild(hand, "Handle")
                                if root then
                                    storedParts[root] = true
                                    root.CanCollide = false
                                end
                                continue
                            end

                            -- Fetch from local cache pointer
                            local moveset = movesetCache[char]
                            local children = getChildren(char)

                            for j = 1, #children do
                                local v = children[j]
                                local vName = v.Name

                                if TARGET_NAMES[vName] and isA(v, "BasePart") then
                                    if v.CanCollide then
                                        storedParts[v] = true
                                        v.CanCollide = false
                                    end
                                    
                                    local childCollide = findFirstChild(v, "Collide")
                                    if childCollide and isA(childCollide, "BasePart") and childCollide.CanCollide then
                                        storedParts[childCollide] = true
                                        childCollide.CanCollide = false
                                    end

                                elseif vName == "SetAssets" and moveset then
                                    if moveset == "Gojo" then
                                        local gojoMask = findFirstChild(v, "GojoMask")
                                        local mask = gojoMask and findFirstChild(gojoMask, "Mask")
                                        if mask and mask.CanCollide then
                                            storedParts[mask] = true
                                            mask.CanCollide = false
                                        end
                                    elseif moveset == "Hanami" then
                                        local armWrap = findFirstChild(v, "ArmWrap")
                                        if armWrap and armWrap.CanCollide then
                                            storedParts[armWrap] = true
                                            armWrap.CanCollide = false
                                        end
                                    end
                                end
                            end

                        end
                    end
                end)
            end
        else
            cleanupNoclip()
        end
    end

    toggleConn = toggleObject:GetPropertyChangedSignal("Value"):Connect(handleToggleChange)
    table_insert(State.Connections, toggleConn)

    handleToggleChange()
end

return Noclip
