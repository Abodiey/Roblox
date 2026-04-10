--[[ 
    CATSTAR PRO V6.2 | Main Loader
]]

if _G.CatstarCleanup then _G.CatstarCleanup() end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local baseUrl = "https://raw.githubusercontent.com/YourUsername/YourRepo/main/modules/" -- Update this!

_G.CatstarState = {
    Connections = {},
    Toggles = { Blackflash = true, QTE = true, MsgAura = true, ItemEsp = false, Aim = false },
    LockedTarget = nil,
    TargetIdentifier = ""
}

-- Comprehensive Cleanup
_G.CatstarCleanup = function()
    Rayfield:Destroy()
    local esp = game.CoreGui:FindFirstChild("RayfieldItemESP")
    if esp then esp:Destroy() end
    for _, conn in pairs(_G.CatstarState.Connections) do if conn then conn:Disconnect() end end
    table.clear(_G.CatstarState.Connections)
    _G.CatstarCleanup = nil
    _G.CatstarState = nil
end

local function Load(name)
    return loadstring(game:HttpGet(baseUrl .. name .. ".lua"))()
end

local Window = Rayfield:CreateWindow({
   Name = "CATSTAR PRO V6.2",
   ConfigurationSaving = { Enabled = true, FolderName = "CatstarPro" }
})

-- Initialize Tabs
local CombatTab = Window:CreateTab("Combat & QTE")
local VisualsTab = Window:CreateTab("Visuals")
local TargetTab = Window:CreateTab("Targeting")

-- Load Features
local Blackflash = Load("Blackflash")
local Aimbot = Load("Aimbot")
local QTE = Load("QTE")
local Aura = Load("Aura")
local ESP = Load("ESP")
local Targeting = Load("Targeting")

-- UI Bindings
CombatTab:CreateToggle({Name = "Enable Blackflash", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.Blackflash = v end})
Blackflash.Init(_G.CatstarState)

CombatTab:CreateKeybind({Name = "Rigid Aim Lock", CurrentKeybind = "C", Callback = function() Aimbot.Toggle(_G.CatstarState) end})
Aimbot.Init(_G.CatstarState)

CombatTab:CreateToggle({Name = "Auto QTE", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.QTE = v end})
QTE.Init(_G.CatstarState)

VisualsTab:CreateToggle({Name = "Message Aura", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.MsgAura = v end})
VisualsTab:CreateToggle({Name = "Item ESP", CurrentValue = false, Callback = function(v) _G.CatstarState.Toggles.ItemEsp = v end})
Aura.Init(_G.CatstarState)
ESP.Init(_G.CatstarState)

TargetTab:CreateInput({Name = "Search Player", Callback = function(t) _G.CatstarState.TargetIdentifier = t end})
TargetTab:CreateButton({Name = "Spectate", Callback = function() Targeting.Spectate(_G.CatstarState.TargetIdentifier) end})
