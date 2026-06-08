--[[ 
    CATSTAR PRO V6.2 | Main Loader
]]
while not game or not game["GameId"] or game["GameId"] == 0 do task.wait() end
if game["GameId"] ~= tonumber("3508" .. "322" .. "461") then return end
print("Catstar Running")

if getgenv().CatstarCleanup then getgenv().CatstarCleanup() end

local Rayfield
local baseUrl = "https://raw.github" .. "usercontent.com/" .. "Abo" .. "diey/" .. "Rob" .. "lox/refs/heads/main/scripts/" .. "j" .. "j" .. "s/"

getgenv().CatstarState = {
    Connections = setmetatable({}, { __mode = "v" }), -- Weak values allow disconnected links to be garbage collected
    Toggles = { 
        BlackFlash = false, 
        Ratio = false, 
        Noclip = true, 
        DomainNoclip = true, 
        QTE = true, 
        MsgAura = true, 
        ItemEsp = false, 
        Esp = true, 
        DummyESP = true, 
        Aim = false, 
        TeamCheck = true 
    },
    LockedTarget = nil,
    TargetIdentifier = ""
}

local CoreGui = cloneref(game:GetService("CoreGui"))

getgenv().CatstarCleanup = function()
    if Rayfield then pcall(function() Rayfield:Destroy() end) end
    for _, espName in {"ItemESP", "PlayerESP"} do
        local esp = CoreGui:FindFirstChild(espName)
        if esp and esp.Parent then esp:Destroy() end
    end
    for _, conn in pairs(getgenv().CatstarState.Connections) do if conn then pcall(function() conn:Disconnect() end) end end
    table.clear(getgenv().CatstarState.Connections)
    getgenv().CatstarCleanup, getgenv().CatstarState = nil, nil
end

local function Load(name)
    local success, rawCode = pcall(function()
        return game:HttpGet(baseUrl .. name .. ".lua")
    end)
    
    if not success or type(rawCode) ~= "string" then 
        warn("Failed to fetch " .. name .. ": " .. tostring(rawCode)) 
        return nil 
    end
    
    -- Compile the code and name the chunk for clean console errors
    local chunk, compileError = loadstring(rawCode, "=" .. name)
    if compileError then 
        warn("Syntax error in " .. name .. ": " .. compileError) 
        return nil 
    end
    
    -- Run it via xpcall using debug.traceback. 
    -- This intercepts the error deep inside the script and returns the value if successful!
    local runtimeSuccess, result = xpcall(chunk, debug.traceback)
    
    if not runtimeSuccess then 
        warn("Runtime error in " .. name .. ":\n" .. tostring(result)) 
        return nil 
    end
    
    -- Successfully return the script's returned value/module
    return result
end

local modules = {}
for _, name in {"BlackFlash", "Ratio", "Noclip", "DomainNoclip", "Aimbot", "QTE", "Train", "Aura", "ItemESP", "ESP", "DummyESP", "Targeting"} do
    modules[name] = Load(name)
end

local file, day = "RF_Cache.lua", "--" .. os.date("%d")
local content = isfile(file) and readfile(file)

-- Fallback to HttpGet if file doesn't exist, is empty, or the day prefix doesn't match
if not content or content:sub(1, #day) ~= day then
    local success, rayData = pcall(game.HttpGet, game, "https://sirius.menu/rayfield")
    if success and rayData then
        content = day .. "\n" .. rayData
        writefile(file, content)
    end
end

-- Final check to ensure we have content from either source
if not content or content == "" then 
    warn("Could not load Rayfield") 
    return 
end
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
    BlackFlash   = {tabs.Combat, "Toggle",  {Name = "Enable BlackFlash", CurrentValue = false, Callback = function(v) getgenv().CatstarState.Toggles.BlackFlash = v end}},
    Ratio        = {tabs.Combat, "Toggle",  {Name = "Enable Ratio", CurrentValue = false, Callback = function(v) getgenv().CatstarState.Toggles.Ratio = v end}},
    Noclip       = {tabs.Combat, "Toggle",  {Name = "Enable Noclip through Players", CurrentValue = true, Callback = function(v) getgenv().CatstarState.Toggles.Noclip = v end}},
    DomainNoclip = {tabs.Combat, "Toggle",  {Name = "Enable Noclip through Domains", CurrentValue = true, Callback = function(v) getgenv().CatstarState.Toggles.DomainNoclip = v end}},
    QTE          = {tabs.Combat, "Toggle",  {Name = "Auto QTE", CurrentValue = true, Callback = function(v) getgenv().CatstarState.Toggles.QTE = v end}},
    Aura         = {tabs.Visuals, "Toggle", {Name = "Message Aura", CurrentValue = true, Callback = function(v) getgenv().CatstarState.Toggles.MsgAura = v end}},
    ItemESP      = {tabs.Visuals, "Toggle", {Name = "Item ESP", CurrentValue = false, Callback = function(v) getgenv().CatstarState.Toggles.ItemEsp = v end}},
    ESP          = {tabs.Visuals, "Toggle", {Name = "Player ESP", CurrentValue = true, Callback = function(v) getgenv().CatstarState.Toggles.Esp = v end}},
    DummyESP     = {tabs.Visuals, "Toggle", {Name = "Dummy ESP", CurrentValue = true, Callback = function(v) getgenv().CatstarState.Toggles.DummyESP = v end}},
    Train        = {tabs.Combat, "Button",  {Name = "Spawn Train", Callback = function() modules.Train.Init() end}}
}

for modName, setup in pairs(UI_Map) do
    local mod = modules[modName]
    if mod then
        setup[1]["Create" .. setup[2]](setup[1], setup[3])
        if modName ~= "Train" then mod.Init(getgenv().CatstarState) end
    end
end

if modules.Aimbot then
    tabs.Combat:CreateKeybind({Name = "Aimbot", CurrentKeybind = "C", Callback = function() modules.Aimbot.Toggle(getgenv().CatstarState) end})
    tabs.Combat:CreateToggle({Name = "Team Check", CurrentValue = true, Callback = function(v) getgenv().CatstarState.Toggles.TeamCheck = v end})
    modules.Aimbot.Init(getgenv().CatstarState)
end

if modules.Targeting then
    tabs.Target:CreateInput({Name = "Search Player", PlaceholderText = "Enter name...", Callback = function(t) getgenv().CatstarState.TargetIdentifier = t end})
    tabs.Target:CreateButton({Name = "Spectate", Callback = function() modules.Targeting.Spectate(getgenv().CatstarState.TargetIdentifier) end})
end

local Effects = workspace:WaitForChild("Effects", 30)
if Effects then
    Effects.ChildAdded:Connect(function(c)
        if c and c.Name == "Rika" then
            local descendant = c:FindFirstChild("Client")
            if descendant and descendant:IsA("BaseScript") then
                descendant.Disabled = true
                local success, result = pcall(function()
                    return decompile(descendant)
                end)

                if success and result then
                    toclipboard(tostring(result))
                else
                    warn("Failed to decompile object: " .. tostring(descendant))
                end
                warn("[Fix] Disabled broken Rika script: " .. descendant:GetFullName())
            end
        end
        task.delay(60, function() if c and c.Parent then c:Destroy() end end)
    end)
end

local Beams = workspace:WaitForChild("Beams", 30)
if Beams then
    Beams.ChildAdded:Connect(function(c)
        task.delay(60, function() if c and c.Parent then c:Destroy() end end)
    end)
end
