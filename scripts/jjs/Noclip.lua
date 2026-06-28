local Noclip = {}

-- Localize Services and Global Functions
local charFolder = workspace:WaitForChild("Characters")
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local lp = Players.LocalPlayer

local pairs = pairs
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

local lastToggle = false

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
    if dConn then
        dConn:Disconnect()
        deadJanitor[char] = nil
    end
    
    local mConn = movesetJanitor[char]
    if mConn then
        mConn:Disconnect()
        movesetJanitor[char] = nil
    end
end)

function Noclip.Init(State)
    local connection = RunService.Stepped:Connect(function()
        local enabled = State.Toggles.Noclip
        local myChar = lp.Character

        -- 1. Restore Logic
        if lastToggle and not enabled then
            for part in pairs(storedParts) do
                if part and part.Parent then
                    part.CanCollide = true
                end
            end
            table.clear(storedParts)
        end
        lastToggle = enabled

        if not enabled then return end

        -- 2. Optimized Targeted Scan
        local players = getChildren(charFolder)
        for i = 1, #players do
            local char = players[i]
            
            if char ~= myChar then
                -- Setup event listeners on first sight using localized method calls
                if not deadJanitor[char] then
                    -- Initial Dead check
                    if getAttribute(char, "Dead") then
                        deadCache[char] = true
                    end
                    deadJanitor[char] = getAttributeChangedSignal(char, "Dead"):Connect(function()
                        deadCache[char] = getAttribute(char, "Dead") or nil
                    end)

                    -- Initial Moveset cache
                    movesetCache[char] = getAttribute(char, "Moveset")
                    movesetJanitor[char] = getAttributeChangedSignal(char, "Moveset"):Connect(function()
                        movesetCache[char] = getAttribute(char, "Moveset")
                    end)
                end

                -- O(1) boolean check instead of an expensive framework invocation
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
                    storedParts[torso], storedParts[head] = true, true
                    torso.CanCollide, head.CanCollide = false, false
                    continue
                elseif charName == "HarutaSwordNPC" then
                    local root = char.HarutaSword.Hand.Handle
                    storedParts[root] = true
                    root.CanCollide = false
                    continue
                end

                -- Fetch from local cache pointer
                local moveset = movesetCache[char]

                -- Cleaned structural target scan
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
                        -- Safe conditional gates
                        if moveset == "Gojo" then
                            local mask = v.GojoMask.Mask
                            if mask.CanCollide then
                                storedParts[mask] = true
                                mask.CanCollide = false
                            end
                        elseif moveset == "Hanami" then
                            local armWrap = v.ArmWrap
                            if armWrap.CanCollide then
                                storedParts[armWrap] = true
                                armWrap.CanCollide = false
                            end
                        end
                    end
                end

            end
        end
    end)

    table.insert(State.Connections, connection)
end

return Noclip
