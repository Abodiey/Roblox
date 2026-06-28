local Targeting = {}

-- Localize Services & Core API
local cloneref = cloneref
local game = game
local workspace = cloneref(game:GetService("Workspace"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))

-- Localize Global Engine Functions
local ipairs = ipairs
local string = string
local s_lower = string.lower
local table = table
local table_insert = table.insert

local LocalPlayer = Players.LocalPlayer

-- Connection trackers
local loopConn = nil
local toggleConn = nil

-- Safely resets the camera subject back to the local character's humanoid
local function resetCamera()
    if loopConn then
        loopConn:Disconnect()
        loopConn = nil
    end

    local camera = workspace.CurrentCamera
    if not camera then return end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        camera.CameraSubject = hum
    end
end

-- Helper to find player via partial Name or DisplayName match
local function findTargetPlayer(searchTerm)
    if not searchTerm or searchTerm == "" then return nil end
    local cleanTerm = s_lower(searchTerm)

    local allPlayers = Players:GetPlayers()
    for i = 1, #allPlayers do
        local pl = allPlayers[i]
        if pl ~= LocalPlayer then
            if s_lower(pl.Name):find(cleanTerm, 1, true) or s_lower(pl.DisplayName):find(cleanTerm, 1, true) then
                return pl
            end
        end
    end
    return nil
end

function Targeting.Init(State)
    local toggleObject = State.Toggles.Spectate

    local function handleToggleChange()
        local isEnabled = toggleObject.Value

        if isEnabled then
            -- Fallback safety check for state variable
            if not State.Variables or not State.Variables.TargetIdentifier then 
                toggleObject.Value = false
                return 
            end

            local targetPlayer = findTargetPlayer(State.Variables.TargetIdentifier)
            if not targetPlayer then
                toggleObject.Value = false
                return
            end

            -- Connect updating camera alignment loop only while spectating is enabled
            if not loopConn then
                loopConn = RunService.RenderStepped:Connect(function()
                    local camera = workspace.CurrentCamera
                    if not camera then return end

                    local targetChar = targetPlayer.Character
                    local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")

                    if targetHum and targetHum.Health > 0 then
                        if camera.CameraSubject ~= targetHum then
                            camera.CameraSubject = targetHum
                        end
                    else
                        -- Target died, left, or went invalid; auto-disable spectate asset safely
                        toggleObject.Value = false
                    end
                end)
            end
        else
            resetCamera()
        end
    end

    toggleConn = toggleObject:GetPropertyChangedSignal("Value"):Connect(handleToggleChange)
    table_insert(State.Connections, toggleConn)

    handleToggleChange()
end

return Targeting
