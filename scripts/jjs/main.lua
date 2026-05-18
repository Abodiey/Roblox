--[[ 
    CATSTAR PRO V6.2 | Main Loader
]]
while not game or not game["GameId"] do
    task.wait()
end
if game["GameId"] ~= 3508322461 then return end
print("Catstar Running")

if _G.CatstarCleanup then _G.CatstarCleanup() end

local Rayfield
local baseUrl = "https://raw.githubusercontent.com/Abodiey/Roblox/refs/heads/main/scripts/jjs/"

_G.CatstarState = {
    Connections = {},
    Toggles = { BlackFlash = true, Ratio = true, Noclip = true, DomainNoclip = true, QTE = true, MsgAura = true, ItemEsp = false, Esp = true, DummyESP = true, Aim = false, TeamCheck = true },
    LockedTarget = nil,
    TargetIdentifier = ""
}

_G.CatstarCleanup = function()
    if Rayfield then Rayfield:Destroy() end
    local iEsp, pEsp = game.CoreGui:FindFirstChild("ItemESP"), game.CoreGui:FindFirstChild("PlayerESP")
    if iEsp then iEsp:Destroy() end
    if pEsp then pEsp:Destroy() end
    for _, conn in pairs(_G.CatstarState.Connections) do if conn then conn:Disconnect() end end
    table.clear(_G.CatstarState.Connections)
    _G.CatstarCleanup = nil
    _G.CatstarState = nil
end

-- Updated Load function with 30s timeout
local function Load(name)
    local result = nil
    local completed = false

    local success, err = pcall(function()
        result = loadstring(game:HttpGet(baseUrl .. name .. ".lua"))()
    end)
        
    if not success then
        warn("Failed to load " .. name .. ": " .. tostring(err))
    end
    return result
end

-- Wrap the entire setup in task.spawn to prevent main thread hanging
task.spawn(function()
    -- Load Features
    local BlackFlash = Load("BlackFlash")
    local Ratio = Load("Ratio")
    local Noclip = Load("Noclip")
    local DomainNoclip = Load("DomainNoclip")
    local Aimbot = Load("Aimbot")
    local QTE = Load("QTE")
    local Train = Load("Train")
    local Aura = Load("Aura")
    local ItemESP = Load("ItemESP")
    local ESP = Load("ESP")
    local DummyESP = Load("DummyESP")
    local Targeting = Load("Targeting")

    local file, day = "RF_Cache.lua", "--" .. os.date("%d")
    local content = isfile(file) and readfile(file)

    if not content or content:sub(1, #day) ~= day then
        local success, rayData = pcall(function() return game:HttpGet("https://sirius.menu/rayfield") end)
        if success then
            content = day .. "\n" .. rayData
            writefile(file, content)
        end
    end

    if not content then warn("Could not load Rayfield") return end
    Rayfield = loadstring(content)()

    local Window = Rayfield:CreateWindow({
       Name = "CATSTAR PRO V6.2",
       ConfigurationSaving = { Enabled = true, FolderName = "CatstarPro", DisableRayfieldPrompts = true }
    })

    local CombatTab = Window:CreateTab("Combat & QTE")
    local VisualsTab = Window:CreateTab("Visuals")
    local TargetTab = Window:CreateTab("Targeting")

    if BlackFlash then
        CombatTab:CreateToggle({Name = "Enable BlackFlash", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.BlackFlash = v end})
        BlackFlash.Init(_G.CatstarState)
    end
        
    if Ratio then
        CombatTab:CreateToggle({Name = "Enable Ratio", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.Ratio = v end})
        Ratio.Init(_G.CatstarState)
    end

    if Noclip then
        CombatTab:CreateToggle({Name = "Enable Noclip through Players", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.Noclip = v end})
        Noclip.Init(_G.CatstarState)
    end

    if DomainNoclip then
        CombatTab:CreateToggle({Name = "Enable Noclip through Domains", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.DomainNoclip = v end})
        DomainNoclip.Init(_G.CatstarState)
    end

    if Aimbot then
        CombatTab:CreateKeybind({Name = "Aimbot", CurrentKeybind = "C", Callback = function() Aimbot.Toggle(_G.CatstarState) end})
        CombatTab:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(Value) _G.CatstarState.Toggles.TeamCheck = Value end})
        Aimbot.Init(_G.CatstarState)
    end

    if QTE then
        CombatTab:CreateToggle({Name = "Auto QTE", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.QTE = v end})
        QTE.Init(_G.CatstarState)
    end

    if Train then
        CombatTab:CreateButton({Name = "Spawn Train", Callback = function() Train.Init() end})
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
        VisualsTab:CreateToggle({Name = "Player ESP", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.Esp = v end})
        ESP.Init(_G.CatstarState)
    end

    if DummyESP then
        VisualsTab:CreateToggle({Name = "Dummy ESP", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.DummyESP = v end})
        DummyESP.Init(_G.CatstarState)
    end
        
    if Targeting then
        TargetTab:CreateInput({Name = "Search Player", PlaceholderText = "Enter name...", Callback = function(t) _G.CatstarState.TargetIdentifier = t end})
        TargetTab:CreateButton({Name = "Spectate", Callback = function() Targeting.Spectate(_G.CatstarState.TargetIdentifier) end})
    end
end)

-- Effects Fix
local Effects = workspace:WaitForChild("Effects", 10)
if Effects then
    Effects.ChildAdded:Connect(function(c)
        task.delay(30, function()
            if c and c.Parent then
                c:Destroy()
            end
        end)
    end)
end
