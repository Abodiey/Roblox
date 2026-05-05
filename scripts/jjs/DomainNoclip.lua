local domains = workspace:WaitForChild("Domains")
local RunService = cloneref(game:GetService("RunService"))

local DomainNoclip = {}

function DomainNoclip.Init(State)
    local connection = RunService.Stepped:Connect(function()
        local enabled = State.Toggles.DomainNoclip
        if not enabled then return end
            
        for _, v in pairs(domains:GetChildren()) do
            if v:IsA("BasePart") then 
                v.CanCollide = not enabled 
            end
        end
    end)

    table.insert(State.Connections, connection)
end

return DomainNoclip
