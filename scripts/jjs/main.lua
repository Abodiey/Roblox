while not game.GameId or game.GameId == 0 do task.wait() end
if game.GameId ~= 3508322461 then return end
print("Catstar Running")

getgenv().cloneref = cloneref or function(O) return O end
local cloneref = cloneref
local StarterGui = cloneref(game:GetService("StarterGui"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local Players = cloneref(game:GetService("Players"))

task.defer(function()
    if not Players.LocalPlayer then
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    end

    local robloxGui = CoreGui:WaitForChild("RobloxGui", 99)
    if robloxGui then
        robloxGui:WaitForChild("NotificationFrame", 99)
    end

    StarterGui:SetCore("SendNotification", {
            Title = "Catstar Pro",
            Text = "Loading...",
            Duration = 5
    })
end)

local Rayfield
local BaseUrl = "https://raw.githubusercontent.com/Abodiey/Roblox/refs/heads/main/scripts/jjs/"

local StateStructure = {
    Connections = setmetatable({}, { __mode = "v" }),
    Toggles = { 
        BlackFlash = false, 
        Ratio = false,
        AutoBurst = true,
        AntiVoid = false,
        AntiBlackhole = true,
        Noclip = true, 
        DomainNoclip = false,
        InstantInteract = true,
        QTE = true,
        Gamepasses = true,
        KillSound = true,
        MsgAura = true, 
        ItemEsp = false, 
        Esp = true, 
        DummyESP = true, 
        Aim = false, 
        TeamCheck = true,
        DiamondInTheSky = false
    },
    Variables = {
        SpeedMultiplier = 15,
        LockedTarget = nil,
        TargetIdentifier = ""
    },
}

getgenv().CatstarState = StateStructure
local CatstarState = StateStructure

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

task.spawn(function()
        Load("fixes")
end)

local Modules = {}
local ModuleStatus = {}

local ModuleList = {"ESP", "Aimbot", "Gamepasses", "Noclip", "AutoBurst", "Aura", "AntiBlackhole", "DummyESP", "QTE", "DomainNoclip", "ItemESP", "BlackFlash", "Ratio", "AntiVoid", "Train", "Targeting", "KillSound", "DiamondInTheSky"}

for _, Name in ipairs(ModuleList) do
    ModuleStatus[Name] = "Loading"
end

task.spawn(function()
    if not Players.LocalPlayer then
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    end
    for _, Name in ipairs(ModuleList) do
        task.spawn(function()
            local Result = Load(Name)
            if Result then
                Modules[Name] = Result
                ModuleStatus[Name] = "Ready"
            else
                ModuleStatus[Name] = "Failed"
            end
        end)
    end
end)

local File, Day = "RF_Cache.lua", "--" .. os.date("%d")
local Content = isfile(File) and readfile(File)

if not Content or Content:sub(1, #Day) ~= Day then
    local Success, RayData
    local RayUrl = "https://sirius.menu/rayfield"
    
    if request then
        local ReqSuccess, Response = pcall(function()
            return request({
                Url = RayUrl,
                Method = "GET"
            })
        end)
        Success = ReqSuccess and type(Response) == "table" and Response.StatusCode == 200
        if Success then
            RayData = Response.Body
        end
    end
    
    if not Success then
        Success, RayData = pcall(game.HttpGet, game, RayUrl)
    end
    
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

local UiLayout = {
    {Type = "Section",  Name = "Combat & QTE"},
    {Type = "Toggle",   Module = "BlackFlash",   Args = {Name = "Auto BlackFlash", CurrentValue = CatstarState.Toggles.BlackFlash, Callback = function(V) CatstarState.Toggles.BlackFlash = V end}},
    {Type = "Toggle",   Module = "Ratio",        Args = {Name = "Auto Nanami Ratio", CurrentValue = CatstarState.Toggles.Ratio, Callback = function(V) CatstarState.Toggles.Ratio = V end}},
    {Type = "Toggle",   Module = "AutoBurst",    Args = {Name = "Auto Burst", CurrentValue = CatstarState.Toggles.AutoBurst, Callback = function(V) CatstarState.Toggles.AutoBurst = V end}},
    {Type = "Toggle",   Module = "AntiVoid",     Args = {Name = "Anti Void", CurrentValue = CatstarState.Toggles.AntiVoid, Callback = function(V) CatstarState.Toggles.AntiVoid = V end}},
    {Type = "Toggle",   Module = "AntiBlackhole",Args = {Name = "Anti Blackhole", CurrentValue = CatstarState.Toggles.AntiBlackhole, Callback = function(V) CatstarState.Toggles.AntiBlackhole = V end}},
    {Type = "Toggle",   Module = "Noclip",       Args = {Name = "Noclip through Players", CurrentValue = CatstarState.Toggles.Noclip, Callback = function(V) CatstarState.Toggles.Noclip = V end}},
    {Type = "Toggle",   Module = "DomainNoclip", Args = {Name = "Noclip through Domains", CurrentValue = CatstarState.Toggles.DomainNoclip, Callback = function(V) CatstarState.Toggles.DomainNoclip = V end}},
    {Type = "Toggle",   Module="InstantInteract",Args = {Name = "Instant Interact with Proximity Prompts", CurrentValue = CatstarState.Toggles.InstantInteract, Callback = function(V) CatstarState.Toggles.InstantInteract = V end}},
    {Type = "Toggle",   Module = "QTE",          Args = {Name = "Auto QTE", CurrentValue = CatstarState.Toggles.QTE, Callback = function(V) CatstarState.Toggles.QTE = V end}},
    {Type = "Toggle",   Module = "DiamondInTheSky", Args = {Name = "Faster Diamond In The Sky Emote", CurrentValue = CatstarState.Toggles.DiamondInTheSky, Callback = function(V) CatstarState.Toggles.DiamondInTheSky = V end}},
    {Type = "Slider",   Module = "DiamondInTheSky", Args = {Name = "Diamond In The Sky Speed", Min = 1, Max = 50, CurrentValue = CatstarState.Variables.SpeedMultiplier, Callback = function(V) CatstarState.Variables.SpeedMultiplier = V end}},
    {Type = "Toggle",   Module = "Gamepasses",   Args = {Name = "Free Gamepasses", CurrentValue = CatstarState.Toggles.Gamepasses, Callback = function(V) CatstarState.Toggles.Gamepasses = V end}},
    {Type = "Toggle",   Module = "KillSound",    Args = {Name = "Free Kill Sound", CurrentValue = CatstarState.Toggles.KillSound, Callback = function(V) CatstarState.Toggles.KillSound = V end}},
    {Type = "Button",   Module = "Train",        InitArg = "Component", Args = {Name = "Spawn Train", Callback = function() if Modules.Train then Modules.Train.Spawn() end end}},
    {Type = "Keybind",  Module = "Aimbot",       Args = {Name = "Aimbot Keybind", CurrentKeybind = "C", Callback = function() if Modules.Aimbot then Modules.Aimbot.Toggle(CatstarState) end end}},
    {Type = "Toggle",   Module = "Aimbot",       Args = {Name = "Team Check", CurrentValue = CatstarState.Toggles.TeamCheck, Callback = function(V) CatstarState.Toggles.TeamCheck = V end}},
    
    {Type = "Section",  Name = "Visuals"},
    {Type = "Toggle",   Module = "Aura",         Args = {Name = "Message Aura", CurrentValue = CatstarState.Toggles.MsgAura, Callback = function(V) CatstarState.Toggles.MsgAura = V end}},
    {Type = "Toggle",   Module = "ItemESP",      Args = {Name = "Item ESP", CurrentValue = CatstarState.Toggles.ItemEsp, Callback = function(V) CatstarState.Toggles.ItemEsp = V end}},
    {Type = "Toggle",   Module = "ESP",          Args = {Name = "Player ESP", CurrentValue = CatstarState.Toggles.Esp, Callback = function(V) CatstarState.Toggles.Esp = V end}},
    {Type = "Toggle",   Module = "DummyESP",     Args = {Name = "Dummy ESP", CurrentValue = CatstarState.Toggles.DummyESP, Callback = function(V) CatstarState.Toggles.DummyESP = V end}},
    
    {Type = "Section",  Name = "Targeting"},
    {Type = "Input",    Module = "Targeting",    InitName = "None", Args = {Name = "Search Player", PlaceholderText = "Enter name...", Callback = function(T) CatstarState.Variables.TargetIdentifier = T end}},
    {Type = "Button",   Module = "Targeting",    InitName = "None", Args = {Name = "Spectate", Callback = function() if Modules.Targeting then Modules.Targeting.Spectate(CatstarState) end end}}
}

local InitializedModules = {}

for _, Element in ipairs(UiLayout) do
    if Element.Type == "Section" then
        MainTab:CreateSection(Element.Name)
    else
        local Component = MainTab["Create" .. Element.Type](MainTab, Element.Args)
        
        task.spawn(function()
            local TargetModule = Element.Module
            
            local StartTime = os.clock()
            while ModuleStatus[TargetModule] == "Loading" and (os.clock() - StartTime) < 15 do
                task.wait()
            end
            
            local Mod = Modules[TargetModule]
            if Mod and not InitializedModules[TargetModule] then
                
                local runName = Element.InitName or "Init"
                
                if runName ~= "None" then
                    InitializedModules[TargetModule] = true
                    
                    if type(Mod) == "table" and type(Mod[runName]) == "function" then
                        local passArg = CatstarState
                        if Element.InitArg == "Component" then
                            passArg = Component
                        end
                        
                        Mod[runName](passArg)
                    else
                        warn(TargetModule .. " does not have a ." .. runName .. " function")
                    end
                end
            elseif ModuleStatus[TargetModule] == "Failed" or not Mod then
                warn("UI linked to failed module payload: " .. tostring(TargetModule))
            end
        end)
        
        task.wait()
    end
end

StarterGui:SetCore("SendNotification", {
    Title = "Catstar Pro",
    Text = "Successfully loaded!",
    Duration = 5
})
