local Aura = {}

local TextChatService = cloneref(game:GetService("TextChatService"))
local Chat = cloneref(game:GetService("Chat"))
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))
local HttpService = cloneref(game:GetService("HttpService"))

local LRI = "\u{2066}" 
local RLI = "\u{2067}" 
local PDI = "\u{2069}" 

local lastMsg = {}
local localPlayer = Players.LocalPlayer
local CHECK_INTERVAL = 0.1
local lastCheck = 0

local function isRTL(text)
    for _, codePoint in utf8.codes(text) do
        if (codePoint >= 0x0590 and codePoint <= 0x08FF) or (codePoint >= 0xFB50 and codePoint <= 0xFDFF) then
            return true
        end
    end
    return false
end

local function isProbablyEnglish(text)
    local stripped = string.gsub(text, "[%s%d%p]", "")
    if #stripped == 0 then return true end 
    
    local englishChars = string.match(stripped, "^[a-zA-Z]+$")
    return englishChars ~= nil
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
        if not State.Toggles.MsgAura.Value or not charFolder then return end
        
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
                local displayMsg = rawMsg
                
                if type(request) == "function" and not isProbablyEnglish(rawMsg) then
                    local apiUrl = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=en&dt=t&q=" .. HttpService:UrlEncode(rawMsg)
                    local responseSuccess, response = pcall(request, {
                        Url = apiUrl,
                        Method = "GET"
                    })
                    
                    if responseSuccess and response and response.StatusCode == 200 then
                        local decodeSuccess, decoded = pcall(function() return HttpService:JSONDecode(response.Body) end)
                        if decodeSuccess and decoded and decoded[1] and decoded[1][1] and decoded[1][1][1] then
                            local translatedText = decoded[1][1][1]
                            local detectedLang = decoded[3]
                            
                            if detectedLang ~= "en" and string.lower(translatedText) ~= string.lower(rawMsg) then
                                displayMsg = string.format("%s\n[Translation]: %s", rawMsg, translatedText)
                            end
                        end
                    end
                end

                local directionMarker = isRTL(rawMsg) and RLI or LRI
                local isolatedMsg = directionMarker .. displayMsg .. PDI

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
