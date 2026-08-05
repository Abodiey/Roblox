--[[
    Catstar Pro
]]--
while not game.GameId or game.GameId == 0 do task.wait() end
if game.GameId ~= 3508322461 then return end
print("Catstar Running")

local WindUI
local File, Day = "WindUI_Cache.lua", "--" .. os.date("%d")
local Content = writefile and readfile and isfile and isfile(File) and readfile(File)

if not Content or Content:sub(1, #Day) ~= Day then
    local WindUrl = "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
    
    local Success, Response = pcall(function()
        return request({
            Url = WindUrl,
            Method = "GET"
        })
    end)
    
    if Success and type(Response) == "table" and Response.StatusCode == 200 and Response.Body and type(Response.Body) == "string" then
        Content = Response.Body
        if writefile then
            Content = Day .. "\n" .. Response.Body
            writefile(File, Content)
        end
    end
end

if not Content or Content == "" then 
    warn("Could not load WindUI") 
    return 
end

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
        Duration = 15
    })
end)

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
            if default == nil then
                if key == "LockedTarget" or key:find("Target") then
                    className = "ObjectValue"
                else
                    default = false
                    className = "StringValue"
                end
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
    DiamondInTheSky = true,
    DomainNoclip = false,
    DummyESP = true, 
    ESP = true, 
    Gamepasses = true,
    InstantInteract = true,
    ItemESP = true, 
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
local ModuleFailed = {}

local ModuleList = {"ESP", "Aimbot", "Noclip", "Gamepasses", "AutoBurst", "Aura", "AntiBlackhole", "InstantInteract", "QTE", "DomainNoclip", "AntiVoid", "ItemESP", "BlackFlash", "Ratio", "DummyESP", "Rejoin", "Train", "Targeting", "KillSound", "DiamondInTheSky"}

task.spawn(function()
    if not Players.LocalPlayer then
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    end
    for _, Name in ipairs(ModuleList) do
        task.spawn(function()
            local Result = Load(Name)
            if Result then
                Modules[Name] = Result
            else
                ModuleFailed[Name] = true
            end
        end)
    end
end)

WindUI = loadstring(Content)()

-- Window Setup
local Window = WindUI:CreateWindow({
    Title = "CATSTAR PRO V6.2",
    Icon = "rbxassetid://4483362458",
    Folder = "CatstarPro",
    Size = UDim2.fromOffset(580, 460)
})

-- UI Toggle Keybind
Window:SetToggleKey(Enum.KeyCode.K)

local MainTab = Window:Tab({
    Title = "Main",
    Icon = "rbxassetid://4483362458"
})

-- Automatically select Main Tab
MainTab:Select()

local UiLayout = {
    {Type = "Section",  Args = {Title = "Combat Modules"}},
    {Type = "Toggle",   Module = "BlackFlash",        Args = {Title = "Auto BlackFlash", Value = CatstarState.Toggles.BlackFlash.Value, Callback = function(V) CatstarState.Toggles.BlackFlash.Value = V end}},
    {Type = "Toggle",   Module = "Ratio",             Args = {Title = "Auto Nanami Ratio", Value = CatstarState.Toggles.Ratio.Value, Callback = function(V) CatstarState.Toggles.Ratio.Value = V end}},
    {Type = "Toggle",   Module = "AutoBurst",         Args = {Title = "Auto Burst", Value = CatstarState.Toggles.AutoBurst.Value, Callback = function(V) CatstarState.Toggles.AutoBurst.Value = V end}},
    {Type = "Toggle",   Module = "QTE",               Args = {Title = "Auto QTE", Value = CatstarState.Toggles.QTE.Value, Callback = function(V) CatstarState.Toggles.QTE.Value = V end}},
    
    {Type = "Section",  Args = {Title = "Aimbot Settings"}},
    {Type = "Keybind",  Module = "Aimbot",            Args = {Title = "Aimbot Keybind", Value = "C", Callback = function() if Modules.Aimbot then Modules.Aimbot.Toggle(CatstarState) end end}},
    {Type = "Toggle",   Module = "Aimbot",            Args = {Title = "Team Check", Value = CatstarState.Toggles.TeamCheck.Value, Callback = function(V) CatstarState.Toggles.TeamCheck.Value = V end}},

    {Type = "Section",  Args = {Title = "Movement & Protection"}},
    {Type = "Toggle",   Module = "Noclip",            Args = {Title = "Noclip through Players", Value = CatstarState.Toggles.Noclip.Value, Callback = function(V) CatstarState.Toggles.Noclip.Value = V end}},
    {Type = "Toggle",   Module = "DomainNoclip",      Args = {Title = "Noclip through Domains", Value = CatstarState.Toggles.DomainNoclip.Value, Callback = function(V) CatstarState.Toggles.DomainNoclip.Value = V end}},
    {Type = "Toggle",   Module = "AntiVoid",          Args = {Title = "Anti Void", Value = CatstarState.Toggles.AntiVoid.Value, Callback = function(V) CatstarState.Toggles.AntiVoid.Value = V end}},
    {Type = "Toggle",   Module = "AntiBlackhole",     Args = {Title = "Anti Blackhole", Value = CatstarState.Toggles.AntiBlackhole.Value, Callback = function(V) CatstarState.Toggles.AntiBlackhole.Value = V end}},
    {Type = "Toggle",   Module = "InstantInteract",   Args = {Title = "Instant Interact", Value = CatstarState.Toggles.InstantInteract.Value, Callback = function(V) CatstarState.Toggles.InstantInteract.Value = V end}},
    
    {Type = "Section",  Args = {Title = "Emote Exploits"}},
    {Type = "Toggle",   Module = "DiamondInTheSky",   Args = {Title = "Faster Diamond In The Sky", Value = CatstarState.Toggles.DiamondInTheSky.Value, Callback = function(V) CatstarState.Toggles.DiamondInTheSky.Value = V end}},
    {Type = "Slider",   Module = "DiamondInTheSky",   Args = {
        Title = "Diamond In The Sky Speed", 
        Step = 1, 
        Value = {
            Min = 1, 
            Max = 50, 
            Default = CatstarState.Variables.SpeedMultiplier.Value
        }, 
        Callback = function(V) CatstarState.Variables.SpeedMultiplier.Value = V end
    }},
    
    {Type = "Section",  Args = {Title = "Utility Mechanics"}},
    {Type = "Button",   Module = "Train",            InitArg = "Component", Args = {Title = "Spawn Train", Callback = function() if Modules.Train then Modules.Train.Clicked() end end}},
    {Type = "Button",   Module = "Rejoin",           InitName = "None", Args = {Title = "Rejoin Server", Callback = function() if Modules.Rejoin then Modules.Rejoin.Clicked() end end}},

    {Type = "Section",  Args = {Title = "Visual Mechanics"}},
    {Type = "Toggle",   Module = "ESP",               Args = {Title = "Player ESP", Value = CatstarState.Toggles.ESP.Value, Callback = function(V) CatstarState.Toggles.ESP.Value = V end}},
    {Type = "Toggle",   Module = "DummyESP",          Args = {Title = "Dummy ESP", Value = CatstarState.Toggles.DummyESP.Value, Callback = function(V) CatstarState.Toggles.DummyESP.Value = V end}},
    {Type = "Toggle",   Module = "ItemESP",           Args = {Title = "Item ESP", Value = CatstarState.Toggles.ItemESP.Value, Callback = function(V) CatstarState.Toggles.ItemESP.Value = V end}},
    {Type = "Toggle",   Module = "Aura",              Args = {Title = "Message Aura", Value = CatstarState.Toggles.MsgAura.Value, Callback = function(V) CatstarState.Toggles.MsgAura.Value = V end}},
    
    {Type = "Section",  Args = {Title = "Targeting & Spectating"}},
    {Type = "Input",    Module = "Targeting",        InitName = "None", Args = {Title = "Search Player", Placeholder = "Enter name...", Value = CatstarState.Variables.TargetIdentifier.Value, Callback = function(T) CatstarState.Variables.TargetIdentifier.Value = T end}},
    {Type = "Button",   Module = "Targeting",        InitName = "None", Args = {Title = "Spectate", Callback = function() if Modules.Targeting then Modules.Targeting.Clicked(CatstarState) end end}},

    {Type = "Section",  Args = {Title = "Unlocks"}},
    {Type = "Toggle",   Module = "Gamepasses",        Args = {Title = "Free Gamepasses", Value = CatstarState.Toggles.Gamepasses.Value, Callback = function(V) CatstarState.Toggles.Gamepasses.Value = V end}},
    {Type = "Toggle",   Module = "KillSound",         Args = {Title = "Free Kill Sound", Value = CatstarState.Toggles.KillSound.Value, Callback = function(V) CatstarState.Toggles.KillSound.Value = V end}},
}

local InitializedModules = {}

for _, Element in ipairs(UiLayout) do
    local Component = MainTab[Element.Type](MainTab, Element.Args)
    
    if Element.Module then
        task.spawn(function()
            local TargetModule = Element.Module
            
            local StartTime = os.clock()
            while not Modules[TargetModule] and not ModuleFailed[TargetModule] and (os.clock() - StartTime) < 15 do
                task.wait()
            end
            
            local Mod = Modules[TargetModule]
            if Mod and not InitializedModules[TargetModule] then
                
                local runName = Element.InitName or "Init"
                
                if runName ~= "None" then
                    InitializedModules[TargetModule] = true
                    
                    if type(Mod) == "table" and type(Mod[runName]) == "function" then
                        if Element.InitArg == "Component" then
                            Mod[runName](Component, CatstarState)
                        else
                            Mod[runName](CatstarState)
                        end
                    else
                        warn(TargetModule .. " does not have a ." .. runName .. " function")
                    end
                end
            elseif ModuleFailed[TargetModule] or not Mod then
                warn("UI linked to failed module payload: " .. tostring(TargetModule))
            end
        end)
    end
    
    task.wait()
end

StarterGui:SetCore("SendNotification", {
    Title = "Catstar Pro",
    Text = "Successfully loaded!",
    Duration = 5
})
