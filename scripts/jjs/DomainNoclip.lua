local DomainNoclip = {}

local domains = workspace:WaitForChild("Domains")

function DomainNoclip.Init(State)
    task.spawn(function()
        while State.Toggles.DomainNoclip do
            for _, v in pairs(domains:GetChildren()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
            task.wait(0.1)
        end

        -- Reset collisions when toggled off
        for _, v in pairs(domains:GetChildren()) do
            if v:IsA("BasePart") then
                v.CanCollide = true
            end
        end
    end)
end

return DomainNoclip
