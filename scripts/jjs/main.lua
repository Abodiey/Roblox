--[[ 
    CATSTAR PRO V6.2 | Main Loader
]]
while not game.GameId or game.GameId == 0 do task.wait() end
if game.GameId ~= 3508322461 then return end
print("Catstar Running")

getgenv().cloneref = cloneref or function(O) return O end
local StarterGui = cloneref(game:GetService("StarterGui"))

task.spawn(function()
    local Success = false
    while not Success do
        Success = pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Catstar Pro",
                Text = "Loading...",
                Duration = 5
            })
        end)
        if not Success then task.wait(0.5) end
    end
end)

local Rayfield
local BaseUrl = "https://raw.githubusercontent.com/Abodiey/Roblox/refs/heads/main/scripts/jjs/"

getgenv().CatstarState = {
    Connections = setmetatable({}, { __mode = "v" }),
    Toggles = { 
        BlackFlash = false, 
        Ratio = false,
        AutoBurst = true,
        AntiVoid = false,
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

-- Run game fixes before iterating over feature modules
Load("fixes")

local Modules = {}
for _, Name in {"BlackFlash", "Ratio", "AntiVoid", "Noclip", "DomainNoclip", "Aimbot", "QTE", "Train", "Aura", "ItemESP", "ESP", "DummyESP", "Targeting", "AutoBurst"} do
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

local MainTab = Window:CreateTab("Main", 4483362458)

-- ==========================================
-- ORDERLY INTERFACE CONFIGURATION
-- ==========================================
local UiLayout = {
    {Type = "Section",  Name = "Combat & QTE"},
    {Type = "Toggle",   Module = "BlackFlash",   Args = {Name = "Auto BlackFlash", CurrentValue = CatstarState.Toggles.BlackFlash, Callback = function(V) CatstarState.Toggles.BlackFlash = V end}},
    {Type = "Toggle",   Module = "Ratio",        Args = {Name = "Auto Nanami Ratio", CurrentValue = CatstarState.Toggles.Ratio, Callback = function(V) CatstarState.Toggles.Ratio = V end}},
    {Type = "Toggle",   Module = "AutoBurst",    Args = {Name = "Auto Burst", CurrentValue = CatstarState.Toggles.AutoBurst, Callback = function(V) CatstarState.Toggles.AutoBurst = V end}},
    {Type = "Toggle",   Module = "AntiVoid",     Args = {Name = "Anti Void", CurrentValue = CatstarState.Toggles.AntiVoid, Callback = function(V) CatstarState.Toggles.AntiVoid = V end}},
    {Type = "Toggle",   Module = "Noclip",       Args = {Name = "Noclip through Players", CurrentValue = CatstarState.Toggles.Noclip, Callback = function(V) CatstarState.Toggles.Noclip = V end}},
    {Type = "Toggle",   Module = "DomainNoclip", Args = {Name = "Noclip through Domains", CurrentValue = CatstarState.Toggles.DomainNoclip, Callback = function(V) CatstarState.Toggles.DomainNoclip = V end}},
    {Type = "Toggle",   Module = "QTE",          Args = {Name = "Auto QTE", CurrentValue = CatstarState.Toggles.QTE, Callback = function(V) CatstarState.Toggles.QTE = V end}},
    {Type = "Button",   Module = "Train",        Args = {Name = "Spawn Train", Callback = function() if Modules.Train then Modules.Train.Spawn() end end}},
    {Type = "Keybind",  Module = "Aimbot",       Args = {Name = "Aimbot Keybind", CurrentKeybind = "C", Callback = function() Modules.Aimbot.Toggle(CatstarState) end}},
    {Type = "Toggle",   Module = "Aimbot",       Args = {Name = "Team Check", CurrentValue = CatstarState.Toggles.TeamCheck, Callback = function(V) CatstarState.Toggles.TeamCheck = V end}},
    
    {Type = "Section",  Name = "Visuals"},
    {Type = "Toggle",   Module = "Aura",         Args = {Name = "Message Aura", CurrentValue = CatstarState.Toggles.MsgAura, Callback = function(V) CatstarState.Toggles.MsgAura = V end}},
    {Type = "Toggle",   Module = "ItemESP",      Args = {Name = "Item ESP", CurrentValue = CatstarState.Toggles.ItemEsp, Callback = function(V) CatstarState.Toggles.ItemEsp = V end}},
    {Type = "Toggle",   Module = "ESP",          Args = {Name = "Player ESP", CurrentValue = CatstarState.Toggles.Esp, Callback = function(V) CatstarState.Toggles.Esp = V end}},
    {Type = "Toggle",   Module = "DummyESP",     Args = {Name = "Dummy ESP", CurrentValue = CatstarState.Toggles.DummyESP, Callback = function(V) CatstarState.Toggles.DummyESP = V end}},
    
    {Type = "Section",  Name = "Targeting"},
    {Type = "Input",    Module = "Targeting",    Args = {Name = "Search Player", PlaceholderText = "Enter name...", Callback = function(T) CatstarState.TargetIdentifier = T end}},
    {Type = "Button",   Module = "Targeting",    Args = {Name = "Spectate", Callback = function() Modules.Targeting.Spectate(CatstarState.TargetIdentifier) end}}
}

-- ==========================================
-- AUTOMATED SEAMLESS GENERATION
-- ==========================================
local InitializedModules = {}

for _, Element in ipairs(UiLayout) do
    if Element.Type == "Section" then
        MainTab:CreateSection(Element.Name)
    else
        local Mod = Modules[Element.Module]
        if Mod then
            local Component = MainTab["Create" .. Element.Type](MainTab, Element.Args)
            
            if not InitializedModules[Element.Module] then
                InitializedModules[Element.Module] = true
                
                if type(Mod) == "table" and type(Mod.Init) == "function" then
                    if Element.Module == "Train" then
                        Mod.Init(Component)
                    else
                        Mod.Init(CatstarState)
                    end
                else
                    if not Mod.Spectate then warn(Element.Module .. " does not have an .Init function") end
                end
            end
            task.wait()
        end
    end
end

StarterGui:SetCore("SendNotification", {
    Title = "Catstar Pro",
    Text = "Successfully loaded!",
    Duration = 5
})
