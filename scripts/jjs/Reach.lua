local Reach = {}

-- Services & References
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer

-- Workspace & Tracking setup
local CharactersFolder = workspace:WaitForChild("Characters", 999)
local trackedRemotes = setmetatable({}, { __mode = "k" })

local character = LocalPlayer.Character
local localRoot = character and character:WaitForChild("HumanoidRootPart", 9999)
local oldNamecall = nil

-- Character Setup
local function setupCharacter(newChar)
    character = newChar
    localRoot = newChar:WaitForChild("HumanoidRootPart", 9999)

    newChar.ChildAdded:Connect(function(child)
        if child.Name == "RemoteEvent" then
            trackedRemotes[child] = true
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)
if character then 
    setupCharacter(character) 
end

-- Module Variables
local maxDistance = 15
local isEnabled = false

-- Helper Functions
local function getClosestCharacter()
    if not character or not localRoot then return nil end

    local closest, shortest = nil, maxDistance

    for _, char in ipairs(CharactersFolder:GetChildren()) do
        if char ~= character then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local d = (root.Position - localRoot.Position).Magnitude
                if d <= shortest then
                    shortest = d
                    closest = char
                end
            end
        end
    end

    return closest
end

-- Hook Initialization
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()

    if method == "FireServer" and not checkcaller() and isEnabled and trackedRemotes[self] then
        local Args = table.pack(...)

        if Args.n == 2 and Args[1] == nil and typeof(Args[2]) == "CFrame" then
            local target = getClosestCharacter()

            if target then
                -- Pass modified arguments directly into oldNamecall instead of re-firing
                setnamecallmethod(method)
                return oldNamecall(self, {target}, Args[2])
            end
        end
    end

    setnamecallmethod(method)
    return oldNamecall(self, ...)
end))

-- Module Core Initialization
function Reach.Init(State)
    local toggleObject = State.Toggles.Reach
    local reachVariable = State.Variables.Reach

    local function handleToggleChange()
        isEnabled = toggleObject.Value
    end

    local function handleReachChange()
        maxDistance = reachVariable.Value
    end

    -- Toggle setup
    local toggleConn = toggleObject:GetPropertyChangedSignal("Value"):Connect(handleToggleChange)
    table.insert(State.Connections, toggleConn)
    handleToggleChange()

    -- Reach variable setup
    local reachConn = reachVariable:GetPropertyChangedSignal("Value"):Connect(handleReachChange)
    table.insert(State.Connections, reachConn)
    handleReachChange()
end

return Reach
