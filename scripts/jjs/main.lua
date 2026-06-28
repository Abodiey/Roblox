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

local SettingsFolder = CoreGui:FindFirstChild("CatstarSettings")
if SettingsFolder then SettingsFolder:Destroy() end

SettingsFolder = Instance.new("Folder")
SettingsFolder.Name = "CatstarSettings"
SettingsFolder.Parent = CoreGui

local TogglesFolder = Instance.new("Folder")
TogglesFolder.Name = "Toggles"
TogglesFolder.Parent = SettingsFolder

local VariablesFolder = Instance.new("Folder")
VariablesFolder.Name = "Variables"
VariablesFolder.Parent = SettingsFolder

local function BindToFolder(folderInstance, valueClassMapping, defaultValues)
    local cache = {}
    return setmetatable(cache, {
        __index = function(_, key)
            local existing = folderInstance:FindFirstChild(key)
            if existing then return existing end

            local default = defaultValues[key]
            local className = valueClassMapping[type(default)] or "StringValue"
            if default == nil and (key == "LockedTarget" or key:find("Target")) then
                className = "ObjectValue"
            end

            local valObj = Instance.new(className)
            valObj.Name = key
            valObj.Value = default
            valObj.Parent = folderInstance
            return valObj
        end
    })
end

-- Alphabetically ordered default values
local ToggleDefaults = { 
    Aim = false, 
    AntiBlackhole = true,
    AntiVoid = false,
    AutoBurst = true,
    BlackFlash = false, 
    DiamondInTheSky = false,
    DomainNoclip = false,
    DummyESP = true, 
    Esp = true, 
    Gamepasses = true,
    InstantInteract = true,
    ItemEsp = false, 
    KillSound = true,
    MsgAura = true, 
    Noclip = true, 
    QTE = true,
    Ratio = false,
    TeamCheck = true
}

local VariableDefaults = {
    SpeedMultiplier = 15,
    LockedTarget = nil,
    TargetIdentifier = ""
}

local ClassMap = {
    ["boolean"] = "BoolValue",
    ["number"] = "NumberValue",
    ["string"] = "StringValue"
}

local StateStructure = {
    Connections = setmetatable({}, { __mode = "v" }),
    Toggles = BindToFolder(TogglesFolder, ClassMap, ToggleDefaults),
    Variables = BindToFolder(VariablesFolder, ClassMap, VariableDefaults)
}

getgenv().CatstarState = StateStructure
local CatstarState = StateStructure

local function Load(Name)
    local Url = BaseUrl .. Name .. ".lua"

    local ReqSuccess, Response = pcall(function()
        return request({
            Url = Url,
            Method = "GET"
        })
    end)
    
    local Success = ReqSuccess and type(Response) == "table" and Response.StatusCode == 200
    if not Success then
        local ErrorMsg = not ReqSuccess and tostring(Response) or (Response and "Status " .. tostring(Response.StatusCode) or "Unknown error")
        warn("Failed to fetch " .. Name .. ": " .. ErrorMsg) 
        return nil 
    end
    
    local Chunk, CompileError = loadstring(Response.Body, "=" .. Name)
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

local ModuleList = {"ESP", "Aimbot", "Noclip", "Gamepasses", "AutoBurst", "Aura", "AntiBlackhole", "InstantInteract", "QTE", "DomainNoclip", "AntiVoid", "ItemESP", "BlackFlash", "Ratio", "DummyESP", "Train", "Targeting", "KillSound", "DiamondInTheSky"}

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
    local RayUrl = "https://sirius.menu/rayfield"
    
    local ReqSuccess, Response = pcall(function()
        return request({
            Url = RayUrl,
            Method = "GET"
        })
    end)
    
    if ReqSuccess and type(Response) == "table" and Response.StatusCode == 200 and Response.Body then
        Content = Day .. "\n" .. Response.Body
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
    {Type = "Section",  Name = "Combat Modules"},
    {Type = "Toggle",   Module = "BlackFlash",   Args = {Name = "Auto BlackFlash", CurrentValue = CatstarState.Toggles.BlackFlash.Value, Callback = function(V) CatstarState.Toggles.BlackFlash.Value = V end}},
    {Type = "Toggle",   Module = "Ratio",        Args = {Name = "Auto Nanami Ratio", CurrentValue = CatstarState.Toggles.Ratio.Value, Callback = function(V) CatstarState.Toggles.Ratio.Value = V end}},
    {Type = "Toggle",   Module = "AutoBurst",    Args = {Name = "Auto Burst", CurrentValue = CatstarState.Toggles.AutoBurst.Value, Callback = function(V) CatstarState.Toggles.AutoBurst.Value = V end}},
    {Type = "Toggle",   Module = "QTE",          Args = {Name = "Auto QTE", CurrentValue = CatstarState.Toggles.QTE.Value, Callback = function(V) CatstarState.Toggles.QTE.Value = V end}},
    
    {Type = "Section",  Name = "Aimbot Settings"},
    {Type = "Keybind",  Module = "Aimbot",       Args = {Name = "Aimbot Keybind", CurrentKeybind = "C", Callback = function() if Modules.Aimbot then Modules.Aimbot.Toggle(CatstarState) end end}},
    {Type = "Toggle",   Module = "Aimbot",       Args = {Name = "Team Check", CurrentValue = CatstarState.Toggles.TeamCheck.Value, Callback = function(V) CatstarState.Toggles.TeamCheck.Value = V end}},

    {Type = "Section",  Name = "Movement & Protection"},
    {Type = "Toggle",   Module = "Noclip",       Args = {Name = "Noclip through Players", CurrentValue = CatstarState.Toggles.Noclip.Value, Callback = function(V) CatstarState.Toggles.Noclip.Value = V end}},
    {Type = "Toggle",   Module = "DomainNoclip", Args = {Name = "Noclip through Domains", CurrentValue = CatstarState.Toggles.DomainNoclip.Value, Callback = function(V) CatstarState.Toggles.DomainNoclip.Value = V end}},
    {Type = "Toggle",   Module = "AntiVoid",     Args = {Name = "Anti Void", CurrentValue = CatstarState.Toggles.AntiVoid.Value, Callback = function(V) CatstarState.Toggles.AntiVoid.Value = V end}},
    {Type = "Toggle",   Module = "AntiBlackhole",Args = {Name = "Anti Blackhole", CurrentValue = CatstarState.Toggles.AntiBlackhole.Value, Callback = function(V) CatstarState.Toggles.AntiBlackhole.Value = V end}},
    {Type = "Toggle",   Module = "InstantInteract",Args = {Name = "Instant Interact", CurrentValue = CatstarState.Toggles.InstantInteract.Value, Callback = function(V) CatstarState.Toggles.InstantInteract.Value = V end}},
    
    {Type = "Section",  Name = "Emote Exploits"},
    {Type = "Toggle",   Module = "DiamondInTheSky",Args = {Name = "Faster Diamond In The Sky", CurrentValue = CatstarState.Toggles.DiamondInTheSky.Value, Callback = function(V) CatstarState.Toggles.DiamondInTheSky.Value = V end}},
    {Type = "Slider",   Module = "DiamondInTheSky", Args = {Name = "Diamond In The Sky Speed", Range = {1, 50}, Increment = 1, CurrentValue = CatstarState.Variables.SpeedMultiplier.Value, Flag = "DiamondInTheSkySpeed", Callback = function(V) CatstarState.Variables.SpeedMultiplier.Value = V end}},
    {Type = "Section",  Name = "Utility Mechanics"},
    
    {Type = "Button",   Module = "Train",        InitArg = "Component", Args = {Name = "Spawn Train", Callback = function() if Modules.Train then Modules.Train.Spawn() end end}},

    {Type = "Section",  Name = "Visual Mechanics"},
    {Type = "Toggle",   Module = "ESP",          Args = {Name = "Player ESP", CurrentValue = CatstarState.Toggles.Esp.Value, Callback = function(V) CatstarState.Toggles.Esp.Value = V end}},
    {Type = "Toggle",   Module = "DummyESP",     Args = {Name = "Dummy ESP", CurrentValue = CatstarState.Toggles.DummyESP.Value, Callback = function(V) CatstarState.Toggles.DummyESP.Value = V end}},
    {Type = "Toggle",   Module = "ItemESP",      Args = {Name = "Item ESP", CurrentValue = CatstarState.Toggles.ItemEsp.Value, Callback = function(V) CatstarState.Toggles.ItemEsp.Value = V end}},
    {Type = "Toggle",   Module = "Aura",         Args = {Name = "Message Aura", CurrentValue = CatstarState.Toggles.MsgAura.Value, Callback = function(V) CatstarState.Toggles.MsgAura.Value = V end}},
    
    {Type = "Section",  Name = "Targeting & Spectating"},
    {Type = "Input",    Module = "Targeting",    InitName = "None", Args = {Name = "Search Player", PlaceholderText = "Enter name...", Callback = function(T) CatstarState.Variables.TargetIdentifier.Value = T end}},
    {Type = "Button",   Module = "Targeting",    InitName = "None", Args = {Name = "Spectate", Callback = function() if Modules.Targeting then Modules.Targeting.Spectate(CatstarState) end end}},

    {Type = "Section",  Name = "Unlocks"},
    {Type = "Toggle",   Module = "Gamepasses",   Args = {Name = "Free Gamepasses", CurrentValue = CatstarState.Toggles.Gamepasses.Value, Callback = function(V) CatstarState.Toggles.Gamepasses.Value = V end}},
    {Type = "Toggle",   Module = "KillSound",    Args = {Name = "Free Kill Sound", CurrentValue = CatstarState.Toggles.KillSound.Value, Callback = function(V) CatstarState.Toggles.KillSound.Value = V end}},
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
                        -- Safe multi-argument routing matching signature (Component, State)
                        if Element.InitArg == "Component" then
                            Mod[runName](Component, CatstarState)
                        else
                            Mod[runName](CatstarState)
                        end
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
