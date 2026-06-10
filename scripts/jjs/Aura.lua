local Aura = {}

local TextChatService = cloneref(game:GetService("TextChatService"))
local Chat = cloneref(game:GetService("Chat"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))

-- Using modern Luau Unicode escapes for directional formatting
local LRI = "\u{2066}" -- Left-to-Right Isolate
local RLI = "\u{2067}" -- Right-to-Left Isolate
local PDI = "\u{2069}" -- Pop Directional Isolate

local lastMsg = {}
local localPlayer = Players.LocalPlayer
local CHECK_INTERVAL = 0.1
local lastCheck = 0

local function isRTL(text)
    for _, codePoint in utf8.codes(text) do
        -- Captures Arabic, Hebrew, Persian, Syriac, Thaana, etc.
        if (codePoint >= 0x0590 and codePoint <= 0x08FF) or (codePoint >= 0xFB50 and codePoint <= 0xFDFF) then
            return true
        end
    end
    return false
end

function Aura.Init(State)
    local BubbleConfig = TextChatService.BubbleChatConfiguration
    BubbleConfig.MaxDistance = 500 
    BubbleConfig.MinimizeDistance = 400
    BubbleConfig.TextSize = 20
    
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
                -- Isolate the specific direction of the message content
                local directionMarker = isRTL(rawMsg) and RLI or LRI
                local isolatedMsg = directionMarker .. rawMsg .. PDI

                -- Force the structural wrapper ([Name]: ) to always read Left-to-Right
                local formattedChat = string.format("%s[<b>%s</b>]: %s%s", LRI, charName, isolatedMsg, PDI)
                
                generalChannel:DisplaySystemMessage(formattedChat)
                
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
