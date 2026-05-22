--[[ 
    CATSTAR PRO V6.2 | Main Loader
]]
while not game or not game["GameId"] do task.wait() end
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

local CoreGui = cloneref(game:GetService("CoreGui"))

_G.CatstarCleanup = function()
    if Rayfield then Rayfield:Destroy() end
    for _, espName in {"ItemESP", "PlayerESP"} do
        local esp = CoreGui:FindFirstChild(espName)
        if esp then esp:Destroy() end
    end
    for _, conn in pairs(_G.CatstarState.Connections) do if conn then conn:Disconnect() end end
    table.clear(_G.CatstarState.Connections)
    _G.CatstarCleanup, _G.CatstarState = nil, nil
end

local function Load(name)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(baseUrl .. name .. ".lua"))()
    end)
    if not success then warn("Failed to load " .. name .. ": " .. tostring(result)) return nil end
    return result
end

local modules = {}
for _, name in {"BlackFlash", "Ratio", "Noclip", "DomainNoclip", "Aimbot", "QTE", "Train", "Aura", "ItemESP", "ESP", "DummyESP", "Targeting"} do
    modules[name] = Load(name)
end

local file, day = "RF_Cache.lua", "--" .. os.date("%d")
local content = isfile(file) and readfile(file)

if not content or content:sub(1, #day) ~= day then
    local success, rayData = pcall(game.HttpGet, game, "https://sirius.menu/rayfield")
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

local tabs = {
    Combat = Window:CreateTab("Combat & QTE"),
    Visuals = Window:CreateTab("Visuals"),
    Target = Window:CreateTab("Targeting")
}

local UI_Map = {
    BlackFlash   = {tabs.Combat, "Toggle",  {Name = "Enable BlackFlash", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.BlackFlash = v end}},
    Ratio        = {tabs.Combat, "Toggle",  {Name = "Enable Ratio", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.Ratio = v end}},
    Noclip       = {tabs.Combat, "Toggle",  {Name = "Enable Noclip through Players", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.Noclip = v end}},
    DomainNoclip = {tabs.Combat, "Toggle",  {Name = "Enable Noclip through Domains", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.DomainNoclip = v end}},
    QTE          = {tabs.Combat, "Toggle",  {Name = "Auto QTE", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.QTE = v end}},
    Aura         = {tabs.Visuals, "Toggle", {Name = "Message Aura", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.MsgAura = v end}},
    ItemESP      = {tabs.Visuals, "Toggle", {Name = "Item ESP", CurrentValue = false, Callback = function(v) _G.CatstarState.Toggles.ItemEsp = v end}},
    ESP          = {tabs.Visuals, "Toggle", {Name = "Player ESP", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.Esp = v end}},
    DummyESP     = {tabs.Visuals, "Toggle", {Name = "Dummy ESP", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.DummyESP = v end}},
    Train        = {tabs.Combat, "Button",  {Name = "Spawn Train", Callback = function() modules.Train.Init() end}}
}

for modName, setup in pairs(UI_Map) do
    local mod = modules[modName]
    if mod then
        setup[1]["Create" .. setup[2]](setup[1], setup[3])
        if modName ~= "Train" then mod.Init(_G.CatstarState) end
    end
end

if modules.Aimbot then
    tabs.Combat:CreateKeybind({Name = "Aimbot", CurrentKeybind = "C", Callback = function() modules.Aimbot.Toggle(_G.CatstarState) end})
    tabs.Combat:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) _G.CatstarState.Toggles.TeamCheck = v end})
    modules.Aimbot.Init(_G.CatstarState)
end

if modules.Targeting then
    tabs.Target:CreateInput({Name = "Search Player", PlaceholderText = "Enter name...", Callback = function(t) _G.CatstarState.TargetIdentifier = t end})
    tabs.Target:CreateButton({Name = "Spectate", Callback = function() modules.Targeting.Spectate(_G.CatstarState.TargetIdentifier) end})
end

local Effects = workspace:WaitForChild("Effects", 30)
if Effects then
    Effects.ChildAdded:Connect(function(c)
        if string.find(c.Name, "Rika") or c:FindFirstChild("Rika", true) then
            for _, descendant in ipairs(c:GetDescendants()) do
                if descendant.Name == "Client" and descendant:IsA("BaseScript") then
                    toclipboard(decompile(descendant))
                    descendant.Disabled = true
                    warn("[Fix] Disabled broken Rika script: " .. descendant:GetFullName())
                end
            end
        end
        task.delay(30, function() if c and c.Parent then c:Destroy() end end)
    end)
end
