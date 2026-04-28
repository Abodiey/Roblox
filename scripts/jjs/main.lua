--[[ 
    CATSTAR PRO V6.2 | Main Loader
]]

if _G.CatstarCleanup then _G.CatstarCleanup() end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local baseUrl = "https://raw.githubusercontent.com/Abodiey/Roblox/refs/heads/main/scripts/jjs/"

_G.CatstarState = {
    Connections = {},
    Toggles = { BlackFlash = true, Noclip = false, QTE = true, MsgAura = true, ItemEsp = false, Esp = true, Aim = false },
    LockedTarget = nil,
    TargetIdentifier = ""
}

-- Comprehensive Cleanup
_G.CatstarCleanup = function()
    Rayfield:Destroy()
    local iEsp, pEsp = game.CoreGui:FindFirstChild("ItemESP"), game.CoreGui:FindFirstChild("PlayerESP")
    if iEsp then iEsp:Destroy() end
    if pEsp then pEsp:Destroy() end
    for _, conn in pairs(_G.CatstarState.Connections) do if conn then conn:Disconnect() end end
    table.clear(_G.CatstarState.Connections)
    _G.CatstarCleanup = nil
    _G.CatstarState = nil
end

-- Simple Load with Error Printing
local function Load(name)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(baseUrl .. name .. ".lua"))()
    end)
    
    if success then
        return result
    else
        warn("Failed to load " .. name .. ": " .. tostring(result))
        return nil
    end
end

-- Load Features
local BlackFlash = Load("BlackFlash")
local Noclip = Load("Noclip")
local Aimbot = Load("Aimbot")
local QTE = Load("QTE")
local Aura = Load("Aura")
local ItemESP = Load("ItemESP")
local ESP = Load("ESP")
local Targeting = Load("Targeting")

local Window = Rayfield:CreateWindow({
   Name = "CATSTAR PRO V6.2",
   ConfigurationSaving = { Enabled = true, FolderName = "CatstarPro", DisableRayfieldPrompts = true }
})

-- Initialize Tabs
local CombatTab = Window:CreateTab("Combat & QTE")
local VisualsTab = Window:CreateTab("Visuals")
local TargetTab = Window:CreateTab("Targeting")

-- UI Bindings (Only initialize if Load returned successfully)
if BlackFlash then
    CombatTab:CreateToggle({Name = "Enable BlackFlash", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.BlackFlash = v end})
    BlackFlash.Init(_G.CatstarState)
end

if Noclip then
    CombatTab:CreateToggle({Name = "Enable Noclip through Players", CurrentValue = false, Callback = function(v) _G.CatstarState.Toggles.Noclip = v end})
    Noclip.Init(_G.CatstarState)
end

if Aimbot then
    CombatTab:CreateKeybind({Name = "Aimbot", CurrentKeybind = "C", Callback = function() Aimbot.Toggle(_G.CatstarState) end})
    Aimbot.Init(_G.CatstarState)
end

if QTE then
    CombatTab:CreateToggle({Name = "Auto QTE", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.QTE = v end})
    QTE.Init(_G.CatstarState)
end

if Aura then
    VisualsTab:CreateToggle({Name = "Message Aura", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.MsgAura = v end})
    Aura.Init(_G.CatstarState)
end

if ItemESP then
    VisualsTab:CreateToggle({Name = "Item ESP", CurrentValue = false, Callback = function(v) _G.CatstarState.Toggles.ItemEsp = v end})
    ItemESP.Init(_G.CatstarState)
end

if ESP then
    VisualsTab:CreateToggle({Name = "Player ESP", CurrentValue = false, Callback = function(v) _G.CatstarState.Toggles.Esp = v end})
    ESP.Init(_G.CatstarState)
end

if Targeting then
    TargetTab:CreateInput({Name = "Search Player", PlaceholderText = "Enter name...", Callback = function(t) _G.CatstarState.TargetIdentifier = t end})
    TargetTab:CreateButton({Name = "Spectate", Callback = function() Targeting.Spectate(_G.CatstarState.TargetIdentifier) end})
end
