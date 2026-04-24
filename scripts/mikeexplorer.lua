--loadstring(game:HttpGet("https://raw.githubusercontent.com/Abodiey/Roblox/refs/heads/main/scripts/mikeexplorer.lua"))()
if not game:IsLoaded() then game.Loaded:Wait() end

if safe_mode == nil then 
    getgenv().safe_mode = true 
end

local whitelist = {
    ["Workspace"] = true,
    ["RunService"] = true,
    ["GuiService"] = true,
    ["Players"] = true,
    ["ReplicatedStorage"] = true,
    ["Debris"] = true,
    ["SoundService"] = true,
    ["StarterGui"] = true,
    ["CoreGui"] = true,
    ["Lighting"] = true,
    ["Teams"] = true,
}

if safe_mode then
    for _,v in pairs({"RunService", "GuiService", "Debris", "SoundService"}) do
        whitelist[v] = nil
    end
end

getgenv().cloneref = getgenv().cloneref or cloneref or function(o) 
    return o 
end 

getgenv().game = workspace.Parent

getgenv().service = setmetatable({}, {
    __mode = "v", 
    __index = function(self, name)
        local success, s = pcall(game.GetService, game, name)
        if success and s then
            local ref = cloneref(s)
            rawset(self, name, ref)
            return ref
        end
    end
})

getgenv().GetService = function(name)
    return service[name]
end

local success, IrisSource = pcall(function() 
    return game:HttpGet("https://raw.githubusercontent.com/x0581/Iris-Exploit-Bundle/main/bundle.lua") 
end)

local Iris
if success then
    IrisSource = string.gsub(IrisSource, "game:GetService", "GetService")
    Iris = loadstring(IrisSource)().Init()
else
    warn("Failed to load Iris dependency.")
    return
end

local PropertyAPIDump = service.HttpService:JSONDecode(game:HttpGet("https://anaminus.github.io/rbx/json/api/latest.json"))

local function GetPropertiesForInstance(Instance)
    local Properties = {}
    for i,v in next, PropertyAPIDump do
        if v.Class == Instance.ClassName and v.type == "Property" then
            pcall(function()
                Properties[v.Name] = {
                    Value = Instance[v.Name],
                    Type = v.ValueType,
                }
            end)
        end
        v = nil
    end
    Instance = nil
    return Properties
end

local ScriptContent = [[]]
local SelectedInstance = nil
local Properties = {}

local getChildren = game.GetChildren
local isA = game.IsA
local irisEnd = Iris.End
local irisSameLine = Iris.SameLine
local irisSmallButton = Iris.SmallButton
local irisCheckBox = Iris.Checkbox

local function CrawlInstances(Inst)
    local children = getChildren(Inst)
    local isGame = (Inst == game)
    for i = 1, #children do
        local obj = children[i]
        local objName = obj.Name
        if isGame and not whitelist[objName] then 
            continue
        end
        local InstTree = Iris.Tree({objName})
        
        irisSameLine()
        local isScript = isA(obj, "LuaSourceContainer") -- Matches LocalScript & ModuleScript

        if isScript then
            if irisSmallButton({"View Script"}).clicked then
                ScriptContent = decompile(obj)
            end
        end

        if irisSmallButton({"View Properties"}).clicked then
            SelectedInstance = obj
            Properties = GetPropertiesForInstance(obj)
        end
        
        irisEnd() -- Ends SameLine

        if InstTree.state.isUncollapsed.value then
            CrawlInstances(obj)
        end
        
        irisEnd() -- Ends Tree
    end
end

Iris:Connect(function()
    local InstanceViewer = Iris.State(false)
    local PropertyViewer = Iris.State(false)
    local ScriptViewer = Iris.State(false)

    Iris.Window({"MikeExplorer Settings", [Iris.Args.Window.NoResize] = true}, {size = Iris.State(Vector2.new(400, 75)), position = Iris.State(Vector2.new(0, 0))}) do
        irisSameLine() do
            irisCheckBox({"Instance Viewer"}, {isChecked = InstanceViewer})
            irisCheckBox({"Property Viewer"}, {isChecked = PropertyViewer})
            irisCheckBox({"Script Viewer"}, {isChecked = ScriptViewer})
            irisEnd()
        end
        irisEnd()
    end

    if InstanceViewer.value then
        Iris.Window({"MikeExplorer Instance Viewer", [Iris.Args.Window.NoClose] = true}, {size = Iris.State(Vector2.new(400, 300)), position = Iris.State(Vector2.new(0, 75))}) do
            CrawlInstances(game)
            irisEnd()
        end
    end

    if PropertyViewer.value then
        Iris.Window({"MikeExplorer Property Viewer", [Iris.Args.Window.NoClose] = true}, {size = Iris.State(Vector2.new(400, 200)), position = Iris.State(Vector2.new(0, 375))}) do
            Iris.Text({("Viewing Properties For: %s"):format(
                SelectedInstance and SelectedInstance:GetFullName() or "UNKNOWN INSTNACE"
            )})
            Iris.Table({3, [Iris.Args.Table.RowBg] = true}) do
                for PropertyName, PropDetails in next, Properties do
                    Iris.Text({PropertyName})
                    Iris.NextColumn()
                    Iris.Text({PropDetails.Type})
                    Iris.NextColumn()
                    Iris.Text({tostring(PropDetails.Value)})
                    Iris.NextColumn()
                end
                irisEnd()
            end
        end
        irisEnd()
    end

    if ScriptViewer.value then
        Iris.Window({"MikeExplorer Script Viewer", [Iris.Args.Window.NoClose] = true}, {size = Iris.State(Vector2.new(600, 575)), position = Iris.State(Vector2.new(400, 0))}) do
            if Iris.Button({"Copy To Clipboard"}).clicked then
                setclipboard(ScriptContent)
            end
            local Lines = ScriptContent:split("\n")
            for I, Line in next, Lines do
                Iris.Text({Line})
            end
            irisEnd()
        end
    end
end)
