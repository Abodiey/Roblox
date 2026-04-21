if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Utility: CloneRef for service obfuscation
local cloneref = cloneref or function(obj) return obj end

-- Services
local CoreGui = cloneref(game:GetService("CoreGui"))
local GuiService = cloneref(game:GetService("GuiService"))
local VIM = cloneref(game:GetService("VirtualInputManager"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local Players = cloneref(game:GetService("Players"))
local VirtualUser = cloneref(game:GetService("VirtualUser"))
local HttpService = cloneref(game:GetService("HttpService"))

-- Configuration
local RECONNECT_TIME = 15*2
local SAME_SERVER_TIME = 20*2
local NEW_SERVER_TIME = 30*2
local INTERNET_CHECK_DELAY = 3

-- Variables
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    repeat task.wait() until Players.LocalPlayer
    LocalPlayer = Players.LocalPlayer
end

local PlaceId = game.PlaceId
local JobId = game.JobId

----------------------------------------------------------------                
-- SECTION 1: ANTI-AFK LOGIC
----------------------------------------------------------------

if getconnections then
    print("Anti-AFK: Attempting to disable connections")
    for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
        if connection["Disable"] then
            connection["Disable"](connection)
            print("Anti-AFK: Connection disabled")
        elseif connection["Disconnect"] then
            connection["Disconnect"](connection)
            print("Anti-AFK: Connection disconnected")
        end
    end
end

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    print("Anti-AFK: Prevented kick via Idled signal at " .. os.date("%X"))
end)

task.spawn(function()
    while true do
        task.wait(60)
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(0.2)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
end)

----------------------------------------------------------------                
-- SECTION 2: AUTO-RECONNECT LOGIC
----------------------------------------------------------------

local function hasInternet()
    local success, _ = pcall(function()
        return game:HttpGet("https://google.com")
    end)
    return success
end

local function forceClick(button)
    if button and button.Visible then
        GuiService.SelectedObject = button
        VIM:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        GuiService.SelectedObject = nil
    end
end

local function handleDisconnection(child)
    local button = child:FindFirstChild("ReconnectButton", true)
    if not button then return end

    task.spawn(function()
        print("Disconnection detected. Starting 4-Stage Escalation...")

        -- STAGE 1: Click Reconnect Button
        local s1 = tick()
        while button.Parent and (tick() - s1) < RECONNECT_TIME do
            if hasInternet() then
                forceClick(button)
                task.wait(2)
            else
                task.wait(INTERNET_CHECK_DELAY); s1 = tick()
            end
        end

        -- STAGE 2: Same Server Teleport
        if button.Parent and JobId and JobId ~= "" then
            print("Stage 2: Same-server recovery...")
            local s2 = tick()
            while button.Parent and (tick() - s2) < SAME_SERVER_TIME do
                if hasInternet() then
                    pcall(function() TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer) end)
                    task.wait(5)
                else
                    task.wait(INTERNET_CHECK_DELAY); s2 = tick()
                end
            end
        end

        -- STAGE 3: New Server Teleport
        if button.Parent then
            print("Stage 3: New server search...")
            local s3 = tick()
            while button.Parent and (tick() - s3) < NEW_SERVER_TIME do
                if hasInternet() then
                    pcall(function() TeleportService:Teleport(PlaceId, LocalPlayer) end)
                    task.wait(10)
                else
                    task.wait(INTERNET_CHECK_DELAY); s3 = tick()
                end
            end
        end

        -- STAGE 4: Final Force-Loop
        if button.Parent then
            print("Stage 4: Aggressive Force-Join.")
            while button.Parent do
                if hasInternet() then
                    pcall(function() TeleportService:Teleport(PlaceId, LocalPlayer, nil, nil) end)
                    task.wait(15)
                else
                    task.wait(INTERNET_CHECK_DELAY)
                end
            end
        end
    end)
end

-- Initialize Monitoring
local robloxPromptGui = CoreGui:WaitForChild("RobloxPromptGui")
local promptOverlay = robloxPromptGui:WaitForChild("promptOverlay")

promptOverlay.ChildAdded:Connect(handleDisconnection)

-- Check if disconnected on launch
for _, child in ipairs(promptOverlay:GetChildren()) do
    handleDisconnection(child)
end

print("System Loaded: Anti-AFK + 4-Stage Escalation.")
