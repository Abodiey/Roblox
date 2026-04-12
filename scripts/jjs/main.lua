--[[ 
    CATSTAR PRO V6.2 | Main Loader
]]

if _G.CatstarCleanup then _G.CatstarCleanup() end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local baseUrl = "https://raw.githubusercontent.com/Abodiey/Roblox/refs/heads/main/scripts/jjs/"

_G.CatstarState = {
    Connections = {},
    Toggles = { BlackFlash = true, QTE = true, MsgAura = true, ItemEsp = false, Aim = false },
    LockedTarget = nil,
    TargetIdentifier = ""
}

-- Comprehensive Cleanup
_G.CatstarCleanup = function()
    if Rayfield then Rayfield:Destroy() end
    local esp = game:GetService("CoreGui"):FindFirstChild("RayfieldItemESP")
    if esp then esp:Destroy() end
    for _, conn in pairs(_G.CatstarState.Connections) do if conn then conn:Disconnect() end end
    table.clear(_G.CatstarState.Connections)
    _G.CatstarCleanup = nil
    _G.CatstarState = nil
end

-- Enhanced Load Function with Error Reporting
local function Load(name)
    local fullUrl = baseUrl .. name .. ".lua"
    
    -- 1. Fetch Source
    local success, content = pcall(game.HttpGet, game, fullUrl)
    if not success then
        warn(" [CATSTAR ERROR] Failed to fetch " .. name .. ": " .. tostring(content))
        return { Init = function() end, Toggle = function() end } -- Return dummy table to prevent crashes
    end

    -- 2. Compile Source
    local func, compileErr = loadstring(content)
    if not func then
        warn(" [CATSTAR ERROR] Syntax error in " .. name .. ": " .. tostring(compileErr))
        return { Init = function() end, Toggle = function() end }
    end

    -- 3. Execute and Return
    local execSuccess, result = pcall(func)
    if not execSuccess then
        warn(" [CATSTAR ERROR] Runtime error during load of " .. name .. ": " .. tostring(result))
        return { Init = function() end, Toggle = function() end }
    end

    return result
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
local BlackFlash = Load("BlackFlash")
local Aimbot     = Load("Aimbot")
local QTE        = Load("QTE")
local Aura       = Load("Aura")
local ESP        = Load("ESP")
local Targeting  = Load("Targeting")

-- UI Bindings & Initialization
-- We use pcall during .Init in case a specific feature script has a bug in its setup logic
local function SafeInit(module, name)
    local success, err = pcall(function() module.Init(_G.CatstarState) end)
    if not success then
        warn(" [CATSTAR ERROR] Failed to initialize " .. name .. ": " .. tostring(err))
    end
end

CombatTab:CreateToggle({Name = "Enable BlackFlash", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.BlackFlash = v end})
SafeInit(BlackFlash, "BlackFlash")

CombatTab:CreateKeybind({Name = "Aimbot", CurrentKeybind = "C", Callback = function() Aimbot.Toggle(_G.CatstarState) end})
SafeInit(Aimbot, "Aimbot")

CombatTab:CreateToggle({Name = "Auto QTE", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.QTE = v end})
SafeInit(QTE, "QTE")

VisualsTab:CreateToggle({Name = "Message Aura", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.MsgAura = v end})
VisualsTab:CreateToggle({Name = "Item ESP", CurrentValue = false, Callback = function(v) _G.CatstarState.Toggles.ItemEsp = v end})
SafeInit(Aura, "Aura")
SafeInit(ESP, "ESP")

TargetTab:CreateInput({Name = "Search Player", PlaceholderText = "Enter name...", Callback = function(t) _G.CatstarState.TargetIdentifier = t end})
TargetTab:CreateButton({Name = "Spectate", Callback = function() 
    pcall(function() Targeting.Spectate(_G.CatstarState.TargetIdentifier) end) 
end})
