local DomainNoclip = {}

local RunService = cloneref(game:GetService("RunService"))
local Domains = workspace:WaitForChild("Domains")

function DomainNoclip.Init(State)
    local Connection = RunService.Stepped:Connect(function()
        local Enabled = State.Toggles.DomainNoclip
        
        for _, v in ipairs(Domains:GetChildren()) do
            if v:IsA("BasePart") then 
                v.CanCollide = not Enabled 
            end
        end
    end)
    table.insert(State.Connections, Connection)
end

return DomainNoclip
