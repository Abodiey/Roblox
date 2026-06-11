local Rayfield
local BaseUrl = "https://raw.githubusercontent.com/Abodiey/Roblox/refs/heads/main/scripts/jjs/"

getgenv().CatstarState = {
    Connections = setmetatable({}, { __mode = "v" }),
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

getgenv().cloneref = cloneref or function(O) return O end
local CoreGui = cloneref(game:GetService("CoreGui"))

getgenv().CatstarCleanup = function()
    if Rayfield then pcall(function() Rayfield:Destroy() end) end
    for _, EspName in {"ItemESP", "PlayerESP"} do
        local Esp = CoreGui:FindFirstChild(EspName)
        if Esp and Esp.Parent then Esp:Destroy() end
    end
    for _, Conn in pairs(getgenv().CatstarState.Connections) do if Conn then pcall(function() Conn:Disconnect() end) end end
    table.clear(getgenv().CatstarState.Connections)
    getgenv().CatstarCleanup, getgenv().CatstarState = nil, nil
end

local function Load(Name)
    local Success, RawCode
    local Url = BaseUrl .. Name .. ".lua"

    if request then
        local ReqSuccess, Response = pcall(function()
            return request({
                Url = Url,
                Method = "GET"
            })
        end)
        
        Success = ReqSuccess and type(Response) == "table" and Response.StatusCode == 200
        if Success then
            RawCode = Response.Body
        else
            RawCode = not ReqSuccess and tostring(Response) or (Response and "Status " .. tostring(Response.StatusCode) or "Unknown error")
        end
    else
        Success, RawCode = pcall(function()
            return game.HttpGet(game, Url)
        end)
    end
    
    if not Success or type(RawCode) ~= "string" then 
        warn("Failed to fetch " .. Name .. ": " .. tostring(RawCode)) 
        return nil 
    end
    
    local Chunk, CompileError = loadstring(RawCode, "=" .. Name)
    if CompileError then 
        warn("Syntax error in " .. Name .. ": " .. CompileError) 
        return nil 
    end
    
    local RuntimeSuccess, Result = xpcall(Chunk, debug.traceback)
    if not RuntimeSuccess then 
        warn("Runtime error in " .. Name .. ":\n" .. tostring(Result)) 
        return nil 
    end
    
    return Result
end

local Modules = {}
for _, Name in {"BlackFlash", "Ratio", "Noclip", "DomainNoclip", "Aimbot", "QTE", "Train", "Aura", "ItemESP", "ESP", "DummyESP", "Targeting"} do
    Modules[Name] = Load(Name)
end

local File, Day = "RF_Cache.lua", "--" .. os.date("%d")
local Content = isfile(File) and readfile(File)

if not Content or Content:sub(1, #Day) ~= Day then
    local Success, RayData = pcall(game.HttpGet, game, "https://sirius.menu/rayfield")
    if Success and RayData then
        Content = Day .. "\n" .. RayData
        writefile(File, Content)
    end
end

if not Content or Content == "" then 
    warn("Could not load Rayfield") 
    return 
end
Rayfield = loadstring(Content)()

local Window = Rayfield:CreateWindow({
    Name = "CATSTAR PRO V6.2",
    ConfigurationSaving = { Enabled = true, FolderName = "CatstarPro", DisableRayfieldPrompts = true }
})

local Tabs = {
    Combat = Window:CreateTab("Combat & QTE"),
    Visuals = Window:CreateTab("Visuals"),
    Target = Window:CreateTab("Targeting")
}

local UI_Map = {
    BlackFlash   = {Tabs.Combat, "Toggle",  {Name = "Enable BlackFlash", CurrentValue = getgenv().CatstarState.Toggles.BlackFlash, Callback = function(V) getgenv().CatstarState.Toggles.BlackFlash = V end}},
    Ratio        = {Tabs.Combat, "Toggle",  {Name = "Enable Ratio", CurrentValue = getgenv().CatstarState.Toggles.Ratio, Callback = function(V) getgenv().CatstarState.Toggles.Ratio = V end}},
    Noclip       = {Tabs.Combat, "Toggle",  {Name = "Enable Noclip through Players", CurrentValue = getgenv().CatstarState.Toggles.Noclip, Callback = function(V) getgenv().CatstarState.Toggles.Noclip = V end}},
    DomainNoclip = {Tabs.Combat, "Toggle",  {Name = "Enable Noclip through Domains", CurrentValue = getgenv().CatstarState.Toggles.DomainNoclip, Callback = function(V) getgenv().CatstarState.Toggles.DomainNoclip = V end}},
    QTE          = {Tabs.Combat, "Toggle",  {Name = "Auto QTE", CurrentValue = getgenv().CatstarState.Toggles.QTE, Callback = function(V) getgenv().CatstarState.Toggles.QTE = V end}},
    Aura         = {Tabs.Visuals, "Toggle", {Name = "Message Aura", CurrentValue = getgenv().CatstarState.Toggles.MsgAura, Callback = function(V) getgenv().CatstarState.Toggles.MsgAura = V end}},
    ItemESP      = {Tabs.Visuals, "Toggle", {Name = "Item ESP", CurrentValue = getgenv().CatstarState.Toggles.ItemEsp, Callback = function(V) getgenv().CatstarState.Toggles.ItemEsp = V end}},
    ESP          = {Tabs.Visuals, "Toggle", {Name = "Player ESP", CurrentValue = getgenv().CatstarState.Toggles.Esp, Callback = function(V) getgenv().CatstarState.Toggles.Esp = V end}},
    DummyESP     = {Tabs.Visuals, "Toggle", {Name = "Dummy ESP", CurrentValue = getgenv().CatstarState.Toggles.DummyESP, Callback = function(V) getgenv().CatstarState.Toggles.DummyESP = V end}},
    Train        = {Tabs.Combat, "Button",  {Name = "Spawn Train", Callback = function() if Modules.Train then Modules.Train.Spawn() end end}}
}

for ModName, Setup in pairs(UI_Map) do
    local Mod = Modules[ModName]
    if Mod then
        Setup[1]["Create" .. Setup[2]](Setup[1], Setup[3])
        if ModName ~= "Train" then 
            Mod.Init(getgenv().CatstarState) 
        else
            local TrainLabel = Tabs.Combat:CreateLabel("Train Status: Checking...")
            Mod.Init(TrainLabel)
        end
        task.wait()
    end
end

if Modules.Aimbot then
    Tabs.Combat:CreateKeybind({Name = "Aimbot", CurrentKeybind = "C", Callback = function() Modules.Aimbot.Toggle(getgenv().CatstarState) end})
    Tabs.Combat:CreateToggle({Name = "Team Check", CurrentValue = getgenv().CatstarState.Toggles.TeamCheck, Callback = function(V) getgenv().CatstarState.Toggles.TeamCheck = V end})
    Modules.Aimbot.Init(getgenv().CatstarState)
end

if Modules.Targeting then
    Tabs.Target:CreateInput({Name = "Search Player", PlaceholderText = "Enter name...", Callback = function(T) getgenv().CatstarState.TargetIdentifier = T end})
    Tabs.Target:CreateButton({Name = "Spectate", Callback = function() Modules.Targeting.Spectate(getgenv().CatstarState.TargetIdentifier) end})
end

loadstring(BaseUrl .. "fixes.lua")()
