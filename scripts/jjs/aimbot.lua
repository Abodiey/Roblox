-- File: aimbot.lua
local Camera = workspace.CurrentCamera
local LocalPlayer = game:GetService("Players").LocalPlayer

return function(getAimActive, getLockedTarget, setAimActive)
    return game:GetService("RunService").Heartbeat:Connect(function()
        if getAimActive() and getLockedTarget() and getLockedTarget():FindFirstChild("HumanoidRootPart") then
            local hum = getLockedTarget():FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, getLockedTarget().HumanoidRootPart.Position)
            else
                setAimActive(false)
            end
        end
    end)
end
