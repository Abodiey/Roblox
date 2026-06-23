local Noclip = {}

local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local lp = Players.LocalPlayer
local charFolder = workspace:WaitForChild("Characters")

local storedParts = {}
setmetatable(storedParts, {__mode = "k"}) 

local lastToggle = false

-- Whitelist of part names for R6 and your specific assets
local TARGET_NAMES = {
    ["Head"] = true, ["Torso"] = true, 
    ["Left Leg"] = true, ["Right Leg"] = true, 
    ["Left Arm"] = true, ["Right Arm"] = true,
    ["Collide"] = true, ["Mask"] = true
}

function Noclip.Init(State)
    local connection = RunService.Stepped:Connect(function()
        local enabled = State.Toggles.Noclip
        local myChar = lp.Character

        -- 1. Restore Logic (Checks before updating lastToggle)
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
        local players = charFolder:GetChildren()
        for i = 1, #players do
            local char = players[i]
            if char ~= myChar then
                if char.Name == "FrameNPC" then
                        local torso = char.Torso
                        storedParts[torso] = true
                        torso.CanCollide = false
                        continue
                end
                if char.Name == "MechamaruBot" then
                    local torso = char.Torso
                    storedParts[torso] = true
                    torso.CanCollide = false
                    local head = char.Head
                    storedParts[head] = true
                    head.CanCollide = false
                    continue
                end
                -- Only check immediate children and specific deep paths
                local children = char:GetChildren()
                for j = 1, #children do
                    local v = children[j]
                    
                    -- Check if it's a target part OR the specific GojoMask folder
                    if TARGET_NAMES[v.Name] and v:IsA("BasePart") then
                        if v.CanCollide then
                            storedParts[v] = true
                            v.CanCollide = false
                        end
                    elseif v.Name == "SetAssets" then
                        -- Highly specific path optimization for GojoMask
                        local mask = v:GetAttribute("Moveset") == "Gojo" and v:FindFirstChild("GojoMask") and v.GojoMask:FindFirstChild("Mask")
                        if mask and mask:IsA("BasePart") and mask.CanCollide then
                            storedParts[mask] = true
                            v.GojoMask.Mask.CanCollide = false
                        end

                        -- Highly specific path optimization for ArmWrap
                        local armWrap = v:GetAttribute("Moveset") == "Hanami" and v:FindFirstChild("ArmWrap") and v.ArmWrap:FindFirstChild("Collide")
                        if armWrap and armWrap:IsA("BasePart") and armWrap.CanCollide then
                            storedParts[armWrap] = true
                            v.ArmWrap.CanCollide = false
                        end
                    end

                    -- Check for "Collide" child inside the R6 parts
                    if TARGET_NAMES[v.Name] then
                        local childCollide = v:FindFirstChild("Collide")
                        if childCollide and childCollide:IsA("BasePart") and childCollide.CanCollide then
                            storedParts[childCollide] = true
                            childCollide.CanCollide = false
                        end
                    end
                end
            end
        end
    end)

    table.insert(State.Connections, connection)
end

return Noclip
