local Aimbot = {}

local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local GuiService = cloneref(game:GetService("GuiService"))

local Player = Players.LocalPlayer
local workspace = cloneref(game:GetService("Workspace"))
local Camera = workspace.CurrentCamera

while not Player or not Player.Parent or not CoreGui or not Camera do
    task.wait()
end

while CoreGui:FindFirstChild("AimbotHighlight") do 
    CoreGui.AimbotHighlight:Destroy() 
    task.wait() 
end

local Highlight = Instance.new("Highlight")
Highlight.Name = "AimbotHighlight"
Highlight.Parent = CoreGui

-- Performance Trackers
local CurrentTargetPart = nil
local FrameCounter = 0
local FRAME_SKIP_INTERVAL = 2 -- Runs the heavy scan every X frames

function Aimbot.Toggle(State)
    if not State.Toggles.Aim then return end
    
    State.Toggles.Aim = false
    State.LockedTarget = nil
    CurrentTargetPart = nil
    Highlight.Adornee = nil
end

function Aimbot.Init(State)
    Camera = workspace.CurrentCamera
    State.Connections = State.Connections or {}
    
    if State.Toggles.TeamCheck == nil then
        State.Toggles.TeamCheck = true
    end

    local removeConn = Players.PlayerRemoving:Connect(function(p)
        if not State.LockedTarget then return end
        if State.LockedTarget.Name ~= p.Name then return end
        
        State.LockedTarget = nil
        CurrentTargetPart = nil
        Highlight.Adornee = nil
    end)
    table.insert(State.Connections, removeConn)

    -- Connection: Handles both fast camera tracking and frame-skipped target acquisition
    local mainConn = RunService.Heartbeat:Connect(function()
        if not State.Toggles.Aim then 
            Highlight.Adornee = nil 
            return 
        end

        FrameCounter = FrameCounter + 1

        ---------------------------------------------------------
        -- SECTION 1: THROTTLED LOOP (Runs every X frames)
        ---------------------------------------------------------
        if FrameCounter >= FRAME_SKIP_INTERVAL then
            FrameCounter = 0 -- Reset counter
            local currentTarget = State.LockedTarget

            -- Sub-Routine: Validate current target lock status
            if currentTarget then
                if not currentTarget.Parent or currentTarget:GetAttribute("Dead") then
                    State.LockedTarget = nil
                    CurrentTargetPart = nil
                else
                    local hrp = currentTarget:FindFirstChild("HumanoidRootPart")
                    if not hrp then
                        State.LockedTarget = nil
                        CurrentTargetPart = nil
                    else
                        CurrentTargetPart = hrp
                    end
                end
            end

            -- Sub-Routine: Find new target if currently idle
            if not State.LockedTarget then
                local nearest, targetPart, dist = nil, nil, math.huge
                local inset = GuiService:GetGuiInset()
                local mousePos = UserInputService:GetMouseLocation() - inset
                local myTeam = Player.Team
                local characterFolder = workspace:FindFirstChild("Characters") or workspace
                Camera = workspace.CurrentCamera

                for _, obj in ipairs(characterFolder:GetChildren()) do
                    if obj == Player.Character then continue end
                    if obj:GetAttribute("Dead") then continue end
                    
                    local hrp = obj:FindFirstChild("HumanoidRootPart")
                    if not hrp then continue end
                    
                    local targetPlayer = Players:GetPlayerFromCharacter(obj)
                    if State.Toggles.TeamCheck and myTeam and targetPlayer and targetPlayer.Team == myTeam then 
                        continue 
                    end

                    local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if not onScreen then continue end

                    local mDist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if mDist >= dist then continue end

                    dist = mDist
                    nearest = obj 
                    targetPart = hrp
                end

                if nearest then
                    State.LockedTarget = nearest
                    CurrentTargetPart = targetPart
                end
            end
        end

        ---------------------------------------------------------
        -- SECTION 2: FAST LOOP (Runs every single frame)
        ---------------------------------------------------------
        local target = State.LockedTarget
        local targetPart = CurrentTargetPart
        
        if not target or not targetPart then 
            Highlight.Adornee = nil 
            return 
        end

        Highlight.Adornee = target
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
    end)
    table.insert(State.Connections, mainConn)
end

return Aimbot
