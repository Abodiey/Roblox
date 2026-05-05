local RunService = game:GetService("RunService")
local domains = workspace:WaitForChild("Domains")

local DomainNoclip = {}

function DomainNoclip.Init(State)
    local connection
    connection = RunService.Stepped:Connect(function()
        if not State.Toggles.DomainNoclip then
            for _, v in pairs(domains:GetChildren()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
            connection:Disconnect()
            return 
        end

        -- Apply noclip
        for _, v in pairs(domains:GetChildren()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end)

    table.insert(State.Connections, connection)
end

return DomainNoclip
