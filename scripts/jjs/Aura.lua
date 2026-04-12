local Aura = {}

-- Service Localization
local TextChatService = game:GetService("TextChatService")
local Chat = game:GetService("Chat")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Unicode Directional Marks
local LRM = "\226\128\142" -- Left-to-Right Mark
local RLM = "\226\128\143" -- Right-to-Left Mark

local lastMsg = {}
local localPlayer = Players.LocalPlayer
local CHECK_INTERVAL = 0.1
local lastCheck = 0

-- Helper to detect if a string contains RTL characters (Arabic/Hebrew range)
local function isRTL(text)
    for _, codePoint in utf8.codes(text) do
        -- FIXED: Removed the space in the hex literal (0xFB50)
        if (codePoint >= 0x0590 and codePoint <= 0x08FF) or (codePoint >= 0xFB50 and codePoint <= 0xFDFF) then
            return true
        end
    end
    return false
end

function Aura.Init(State)
    local conn = RunService.Heartbeat:Connect(function(deltaTime)
        lastCheck = lastCheck + deltaTime
        if lastCheck < CHECK_INTERVAL then return end
        lastCheck = 0

        local charFolder = workspace:FindFirstChild("Characters")
        if not State.Toggles.MsgAura or not charFolder then return end
        
        local currentLocalChar = localPlayer.Character
        local generalChannel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")

        if not generalChannel then return end

        for _, char in ipairs(charFolder:GetChildren()) do
            local board = char:FindFirstChild("Board")
            if char == currentLocalChar or not board then continue end
            
            local sGui = board:FindFirstChild("SurfaceGui")
            local label = sGui and sGui:FindFirstChild("TextLabel")
            if not label or label.Text == "" then continue end

            local rawMsg = label.Text
            local charName = char.Name
            
            if lastMsg[charName] == rawMsg then continue end
            lastMsg[charName] = rawMsg
            
            task.spawn(function()
                -- Determine directionality
                local directionalMsg = rawMsg
                if isRTL(rawMsg) then
                    -- Wrap RTL text in RLM and ensure the system tag stays LTR
                    directionalMsg = RLM .. rawMsg .. RLM
                end

                -- Format with LRM at the start to prevent the brackets from flipping
                local formattedChat = string.format("%s[<b>%s</b>]: %s", LRM, charName, directionalMsg)
                
                -- 1. Display in Chat Window
                generalChannel:DisplaySystemMessage(formattedChat)
                
                -- 2. Bubble Chat
                local head = char:FindFirstChild("Head")
                if head then
                    Chat:Chat(head, rawMsg, Enum.ChatColor.White)
                end
            end)
        end
    end)
    
    table.insert(State.Connections, conn)
end

return Aura
