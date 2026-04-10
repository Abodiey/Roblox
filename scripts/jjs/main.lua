-- [[ Main Script ]]
if _G.CatstarCleanup then _G.CatstarCleanup() end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local LocalPlayer = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ActiveConnections = {}

-- State
local State = {
    AimActive = false,
    QTEActive = true,
    BlackflashActive = true,
    LockedTarget = nil
}

-- Shared doMove Utility
local function doMove(moveNumber)
    local movesetGui = LocalPlayer.PlayerGui:FindFirstChild("Main") and LocalPlayer.PlayerGui.Main:FindFirstChild("Moveset")
    local character = LocalPlayer.Character
    local knitRE = ReplicatedStorage:WaitForChild("Knit"):WaitForChild("Knit"):WaitForChild("Services")
    if not (movesetGui and character:FindFirstChild("Moveset")) then return end

    local frames = {}
    for _, v in pairs(movesetGui:GetChildren()) do if v:IsA("Frame") then table.insert(frames, v) end end
    table.sort(frames, function(a, b) return (a.LayoutOrder or 0) < (b.LayoutOrder or 0) end)

    local targetFrame = frames[moveNumber]
    if targetFrame then
        local moveName = targetFrame.Name
        local service = knitRE:FindFirstChild(moveName:gsub(" ", "") .. "Service")
        if service then
            service:WaitForChild("RE"):WaitForChild("Activated"):FireServer(character.Moveset:FindFirstChild(moveName))
        end
    end
end

-- Load External Modules (Replace URLs with your actual raw links)
local qteModule = loadstring(game:HttpGet("URL_TO_QTE_FILE"))()
local bfModule = loadstring(game:HttpGet("URL_TO_BF_FILE"))()
local aimModule = loadstring(game:HttpGet("URL_TO_AIM_FILE"))()

-- Initialize Modules
table.insert(ActiveConnections, qteModule(function() return State.QTEActive end))
table.insert(ActiveConnections, bfModule(doMove, function() return State.BlackflashActive end))
table.insert(ActiveConnections, aimModule(function() return State.AimActive end, function() return State.LockedTarget end, function(v) State.AimActive = v end))

-- UI Setup (Simplified)
local Window = Rayfield:CreateWindow({Name = "CATSTAR PRO V6.2", ConfigurationSaving = {Enabled = true, FolderName = "CatstarPro"}})
local MainTab = Window:CreateTab("Combat & QTE")

MainTab:CreateToggle({Name = "Auto Blackflash", CurrentValue = true, Callback = function(V) State.BlackflashActive = V end})
MainTab:CreateToggle({Name = "Auto QTE", CurrentValue = true, Callback = function(V) State.QTEActive = V end})

MainTab:CreateKeybind({
    Name = "Aimbot",
    CurrentKeybind = "C",
    Callback = function()
        if State.AimActive then 
            State.AimActive = false 
        else
            -- Simple Nearest Logic
            local nearest, dist = nil, math.huge
            for _, obj in pairs(workspace.Characters:GetChildren()) do
                if obj ~= LocalPlayer.Character and obj:FindFirstChild("HumanoidRootPart") then
                    local sPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(obj.HumanoidRootPart.Position)
                    if onScreen then
                        local mDist = (Vector2.new(LocalPlayer:GetMouse().X, LocalPlayer:GetMouse().Y) - Vector2.new(sPos.X, sPos.Y)).Magnitude
                        if mDist < dist then dist = mDist; nearest = obj end
                    end
                end
            end
            if nearest then State.LockedTarget = nearest; State.AimActive = true end
        end
    end,
})

_G.CatstarCleanup = function()
    Rayfield:Destroy()
    for _, conn in pairs(ActiveConnections) do if conn then conn:Disconnect() end end
    _G.CatstarCleanup = nil
end
