--[[
    Catstar Pro
]]--
while not game.GameId or game.GameId == 0 do task.wait() end
if game.GameId ~= 3508322461 then return end
print("Catstar Running")

local WindUI
local File = "WindUI_Cache.lua"
local Day = "--" .. os.date("%d")
local Content = nil

-- Check if file exists and read it
if writefile and readfile and isfile and isfile(File) then
    Content = readfile(File)
end

-- Validate cached content
if not Content or Content:sub(1, #Day) ~= Day then
    local WindUrl = "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
    
    local Success, Response = pcall(function()
        return request({
            Url = WindUrl,
            Method = "GET"
        })
    end)
    
    if Success and type(Response) == "table" and Response.StatusCode == 200 and Response.Body and type(Response.Body) == "string" then
        Content = Day .. "\n" .. Response.Body
        if writefile then
            writefile(File, Content)
        end
    else
        Content = nil
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

--Custom Notifications
local loaded
task.defer(function()
    while not game.Players.LocalPlayer do task.wait() end

    local viewport = workspace.CurrentCamera.ViewportSize
    local w, h = 280, 70
    local x, y = viewport.X/2 - w/2, 60

    local function notif(titleText, bodyText, isLoaded)
        local bg = Drawing.new("Square")
        bg.Visible = true
        bg.Color = Color3.fromRGB(20, 20, 20)
        bg.Filled = true
        bg.Thickness = 0
        bg.Position = Vector2.new(x, y)
        bg.Size = Vector2.new(w, h)
        bg.Transparency = 0.5

        local border = Drawing.new("Square")
        border.Visible = true
        border.Color = isLoaded and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(80, 80, 80)
        border.Filled = false
        border.Thickness = isLoaded and 2 or 1
        border.Position = Vector2.new(x - 1, y - 1)
        border.Size = Vector2.new(w + 2, h + 2)
        border.Transparency = 0.7

        local title = Drawing.new("Text")
        title.Visible = true
        title.Color = Color3.fromRGB(255, 255, 255)
        title.Font = 1
        title.Size = 20
        title.Position = Vector2.new(x + w/2, y + 16)
        title.Text = titleText
        title.Transparency = 0.9
        title.Center = true

        local body = Drawing.new("Text")
        body.Visible = true
        body.Color = isLoaded and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(180, 180, 180)
        body.Font = 0
        body.Size = 16
        body.Position = Vector2.new(x + w/2, y + 44)
        body.Text = bodyText
        body.Transparency = 0.8
        body.Center = true

        return {bg = bg, border = border, title = title, body = body}
    end

    -- Loading notification with dots
    local n = notif("Catstar Pro", "Loading")
    local dots = 0
    while not loaded do
        task.wait(0.3)
        dots = (dots % 3) + 1
        n.body.Text = "Loading" .. string.rep(".", dots)
    end
    for _, v in pairs(n) do v:Remove() end

    -- Loaded notification
    local n2 = notif("Catstar Pro", "Loaded!", true)
    task.wait(2)
    for _, v in pairs(n2) do v:Remove() end
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
    DomainESP = true,
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
    Reach = true,
    TeamCheck = true,
}

local VariableDefaults = {
    SpeedMultiplier = 15,
    Reach = 15,
    LockedTarget = nil,
    TargetIdentifier = "",
}

local ClassMap = {
    ["boolean"] = "BoolValue",
    ["number"] = "NumberValue",
    ["string"] = "StringValue",
}

local StateStructure = {
    Connections = setmetatable({}, { __mode = "v" }),
    Toggles = BindToFolder(TogglesFolder, ClassMap, ToggleDefaults),
    Variables = BindToFolder(VariablesFolder, ClassMap, VariableDefaults),
}

getgenv().CatstarState = StateStructure
local CatstarState = StateStructure

local function Load(Name)
    local Url = BaseUrl .. Name .. ".lua"
    local MaxRetries = 5
    local DelayTime = 2 + math.random()
    local Response = nil
    local Success = false

    for Attempt = 1, MaxRetries do
        local ReqSuccess, ReqResponse = pcall(function()
            return request({
                Url = Url,
                Method = "GET"
            })
        end)

        if ReqSuccess and type(ReqResponse) == "table" and ReqResponse.StatusCode == 200 then
            Response = ReqResponse
            Success = true
            break
        end

        local ErrorMsg = not ReqSuccess and tostring(ReqResponse) or (ReqResponse and "Status " .. tostring(ReqResponse.StatusCode) or "Unknown error")
        warn(string.format("Attempt %d/%d failed for %s: %s", Attempt, MaxRetries, Name, ErrorMsg))

        if Attempt < MaxRetries then
            task.wait(DelayTime)
            DelayTime = DelayTime * 2 -- Exponential backoff (1s, 2s, 4s...)
        end
    end

    if not Success or not Response then
        warn("Failed to fetch " .. Name .. " after max retries.")
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

local ModuleList = {"ESP", "Aimbot", "Noclip", "Gamepasses", "AutoBurst", "Aura", "AntiBlackhole", "InstantInteract", "QTE", "DomainESP", "Reach", "AntiVoid", "ItemESP", "BlackFlash", "Ratio", "DummyESP", "Rejoin", "Train", "Targeting", "KillSound", "DiamondInTheSky"}

task.spawn(function()
    while not Players.LocalPlayer do task.wait() end
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

while not Players.LocalPlayer do task.wait() end --WINDUI NEEDS LOCALPLAYER FIRST
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
    {Type = "Toggle",   Module = "Reach",             Args = {Title = "Front Dash Reach", Value = CatstarState.Toggles.Reach.Value, Callback = function(V) CatstarState.Toggles.Reach.Value = V end}},
    {Type = "Slider",   Module = "Reach",             Args = {Title = "Reach Distance", Step = 1, Value = {Min = 1, Max = 15, Default = CatstarState.Variables.Reach.Value}, Callback = function(V) CatstarState.Variables.Reach.Value = V end}},
    
    {Type = "Section",  Args = {Title = "Aimbot Settings"}},
    {Type = "Keybind",  Module = "Aimbot",            Args = {Title = "Aimbot Keybind", Value = "C", Callback = function() if Modules.Aimbot then Modules.Aimbot.Toggle(CatstarState) end end}},
    {Type = "Toggle",   Module = "Aimbot",            Args = {Title = "Team Check", Value = CatstarState.Toggles.TeamCheck.Value, Callback = function(V) CatstarState.Toggles.TeamCheck.Value = V end}},

    {Type = "Section",  Args = {Title = "Movement & Protection"}},
    {Type = "Toggle",   Module = "Noclip",            Args = {Title = "Noclip through Players", Value = CatstarState.Toggles.Noclip.Value, Callback = function(V) CatstarState.Toggles.Noclip.Value = V end}},
    {Type = "Toggle",   Module = "AntiVoid",          Args = {Title = "Anti Void", Value = CatstarState.Toggles.AntiVoid.Value, Callback = function(V) CatstarState.Toggles.AntiVoid.Value = V end}},
    {Type = "Toggle",   Module = "AntiBlackhole",     Args = {Title = "Anti Blackhole", Value = CatstarState.Toggles.AntiBlackhole.Value, Callback = function(V) CatstarState.Toggles.AntiBlackhole.Value = V end}},
    {Type = "Toggle",   Module = "InstantInteract",   Args = {Title = "Instant Interact", Value = CatstarState.Toggles.InstantInteract.Value, Callback = function(V) CatstarState.Toggles.InstantInteract.Value = V end}},
    
    {Type = "Section",  Args = {Title = "Emote Exploits"}},
    {Type = "Toggle",   Module = "DiamondInTheSky",   Args = {Title = "Faster Diamond In The Sky", Value = CatstarState.Toggles.DiamondInTheSky.Value, Callback = function(V) CatstarState.Toggles.DiamondInTheSky.Value = V end}},
    {Type = "Slider",   Module = "DiamondInTheSky",   Args = {Title = "Diamond In The Sky Speed", Step = 1, Value = {Min = 1, Max = 50, Default = CatstarState.Variables.SpeedMultiplier.Value}, Callback = function(V) CatstarState.Variables.SpeedMultiplier.Value = V end}},
    
    {Type = "Section",  Args = {Title = "Utility Mechanics"}},
    {Type = "Button",   Module = "Train",            InitArg = "Component", Args = {Title = "Spawn Train", Callback = function() if Modules.Train then Modules.Train.Clicked() end end}},
    {Type = "Button",   Module = "Rejoin",           InitName = "None", Args = {Title = "Rejoin Server", Callback = function() if Modules.Rejoin then Modules.Rejoin.Clicked() end end}},

    {Type = "Section",  Args = {Title = "Visual Mechanics"}},
    {Type = "Toggle",   Module = "ESP",               Args = {Title = "Player ESP", Value = CatstarState.Toggles.ESP.Value, Callback = function(V) CatstarState.Toggles.ESP.Value = V end}},
    {Type = "Toggle",   Module = "DomainESP",         Args = {Title = "Domain ESP", Value = CatstarState.Toggles.DomainESP.Value, Callback = function(V) CatstarState.Toggles.DomainESP.Value = V end}},
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

loaded = true
