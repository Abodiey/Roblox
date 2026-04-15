if getgenv().sailorhub_running then
    return
end

getgenv().sailorhub_running = true

if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

if game["GameId"] ~= 9186719164 then return end

print("Sailor Hub running")

function missing(t, f, fallback)
	if type(f) == t then return f end
	return fallback
end

cloneref = missing("function", cloneref, function(...) return ... end)
httprequest =  missing("function", request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request))
waxwritefile, waxreadfile = writefile, readfile
everyClipboard = missing("function", setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set))
writefile = missing("function", waxwritefile) and function(file, data, safe)
	if safe == true then return pcall(waxwritefile, file, data) end
	waxwritefile(file, data)
end
readfile = missing("function", waxreadfile) and function(file, safe)
	if safe == true then return pcall(waxreadfile, file) end
	return waxreadfile(file)
end
isfile = missing("function", isfile, readfile and function(file)
	local success, result = pcall(function()
		return readfile(file)
	end)
	return success and result ~= nil and result ~= ""
end)
makefolder = missing("function", makefolder)
isfolder = missing("function", isfolder)
getconnections = missing("function", getconnections or get_signal_cons)

local S = setmetatable({}, {
    __index = function(t, k)
        local s = cloneref(game:GetService(k))
        t[k] = s
        return s
    end
})

local Players = S.Players
local Plr = Players.LocalPlayer
local PGui = cloneref(Plr:FindFirstChildWhichIsA("PlayerGui"))
local Lighting = game:GetService("Lighting")

local RS = S.ReplicatedStorage
local RunService = S.RunService
local Http = S.HttpService
local Gui = S.GuiService
local TP = S.TeleportService
local Tween = S.TweenService

local Marketplace = S.MarketplaceService

local UIS = S.UserInputService
local VIM = S.VirtualInputManager
local VU = S.VirtualUser

local RM = RS:WaitForChild("Remotes")
local RE = RS:WaitForChild("RemoteEvents")

local Env = {
    GameName = "sailor piece",
    Version = "rel-0.0.1",
    InviteCode = "vsEjjqvpK5",
    Executor = (identifyexecutor and identifyexecutor() or "Unknown"),
    IsBadExec = false,
	Support = {
		Webhook = type(httprequest) == "function",
		Clipboard = type(everyClipboard) == "function",
		FileIO = (typeof(writefile) == "function" and typeof(isfile) == "function"),
		Connections = type(getconnections) == "function",
		FPS = (typeof(setfpscap) == "function"),
		Proximity = type(fireproximityprompt) == "function",
}
}

local success, info = pcall(Marketplace.GetProductInfo, Marketplace, game.PlaceId)
if success and info then
    Env.GameName = info.Name
end

local lowerExec = Env.Executor:lower()
local LimitedList = {"xeno"}

for _, name in ipairs(LimitedList) do
    if lowerExec:find(name) then
        Env.IsBadExec = true
        break
    end
end

Env.IsXeno = lowerExec:find("xeno") ~= nil
Env.IsDelta = lowerExec:find("delta") ~= nil

local repo = Env.IsDelta and "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/" or "https://raw.githubusercontent.com/gix314/Obsidian/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = true
Library.ShowToggleFrameInKeybinds = true

local omg = {
    13820188365,
    13413231458,
    5638697306,
    16660143487,
    12669880433,
    121554255694758,
    14287111618,
    16119081646,
    15868464144,
    13699729039,
    10502160439,
    76020690430974,
    92696084646822,
}

local fire = {
    "https://i.pinimg.com/736x/9b/d2/5f/9bd25f7e1d6e95c6253ef5e5f075f643.jpg",
    "https://i.pinimg.com/736x/f8/4d/c7/f84dc705b8f23ecdb8c650ec931b43c3.jpg",
    "https://i.pinimg.com/736x/10/3e/c8/103ec8d6ae5b9b7b38cd2614777aae90.jpg",
    "https://i.pinimg.com/736x/94/30/21/94302144f136aca660829c6824ada44f.jpg",
    "https://i.pinimg.com/736x/44/20/95/4420957839b426f39a0f712d7fee41f5.jpg",
    "https://i.pinimg.com/736x/d4/3e/c1/d43ec166f5fa3bffb0eba74f80a485d3.jpg",
    "https://i.pinimg.com/736x/79/9d/0e/799d0e707b953c372553449d96bbb1f8.jpg",
    "https://i.pinimg.com/736x/ba/e2/b3/bae2b38b9353be080d8df7460e9a9a49.jpg",
    "https://i.pinimg.com/736x/4c/60/4a/4c604abf385acef014f56dc3244bd58c.jpg",
    "https://i.pinimg.com/736x/0d/4a/2d/0d4a2d3b6add65506932c2429935c074.jpg",
    "https://i.pinimg.com/736x/91/fb/f8/91fbf8588cf51349670177e0f289432d.jpg",
    "https://i.pinimg.com/736x/44/81/d5/4481d5741397085afbee3fe42096ce83.jpg",
    "https://i.pinimg.com/1200x/0a/f8/61/0af861dbeafdcfce6fde30ce2d24e355.jpg",
    "https://i.pinimg.com/736x/d5/67/49/d56749b3fdf8ab8253ad32965518d309.jpg",
    "https://i.pinimg.com/1200x/40/cb/c2/40cbc211cc86a1e131f25dd0fa339e65.jpg",
    "https://i.pinimg.com/736x/51/27/c5/5127c5c03c81b72fbd666ca0ee9c20f3.jpg"
}

local eh_success, err = pcall(function()

local randomIndex = math.random(1, #omg)
local theChosenOne = omg[randomIndex]

if not Env.Support.FileIO then
    Library:Notify("Recommended to use better executor.", 3)
end

local Status = {
	Priority = {
		Task = {"Boss", "Pity Boss", "Summon", "Level Farm", "All Mob Farm", "Mob", "Merchant", "Alt Help"},
		Default = {"Boss", "Pity Boss", "Summon", "Level Farm", "All Mob Farm", "Mob", "Merchant", "Alt Help"},
	},
	Main = {
		GlobalPrio = "FARM",
		Farm = true,
		Recovering = false,
		MovingIsland = false,
		Island = "",
		Target = nil,
		KillTick = 0,
		TargetValid = false,
        IsSummoning = false,

		QuestNPC = "",
		
		MobIdx = 1,
		AllMobIdx = 1,
		WeapRotationIdx = 1,
		ComboIdx = 1,
		ParsedCombo = {},
		RawWeapCache = { Sword = {}, Melee = {} },
		ActiveWeap = "",

		ArmHaki = false,

		BossTIMap = {},
        BossMap = {},
        SummonMap = {},
		
		InventorySynced = false,
		Stats = {},
		Settings = {},
		GemStats = {},
		SkillTree = { Nodes = {}, Points = 0 },
		Passives = {},
		SpecStatsSlider = {},
        PowerSliders = {},
		ArtifactSession = {
			Inventory = {},
			Dust = 0,
			InvCount = 0
		},
		UpBlacklist = {},

		MerchantBusy = false,
		LocalMerchantTime = 0,
		LastTimerTick = tick(),
		MerchantExecute = false,
		FirstMerchantSync = false,
		CurrentStock = {},
		
		LastM1 = 0,
		LastWRSwitch = 0,
		LastSwitch = { Title = "", Rune = "" },
		LastBuildSwitch = 0,
		LastDungeon = 0,
        LastSummon = 0,
		
		AltDamage = {},
		AltActive = false,
		TradeState = {},
	},
    Dungeon = {
        SafetyPoint = nil,
        hasStartedWave = false,
        CountedThisRun = false,
        Count = 0,
    },
    Cached = {
		StartTime = os.time(),
        activeTween = nil,
        Inv = {},
        NewItem = {},
        Accessories = {},
        RawWeapCache = { Sword = {}, Melee = {} },
        CharParts = {},
        BossRemote = {},
        BossConf = {},
    },
    Connections = {
        Player_General = nil,
        Idled = nil,
        Merchant = nil,
        Dash = nil,
        Knockback = {},
        Reconnect = nil,
    },
	Misc = {
		GroupId = 1002185259,
		Rank = {255, 254, 175, 150},
        Kicking = false,
	}
}

local StartStats = {
    Level = Plr.Data.Level.Value,
    Money = Plr.Data.Money.Value,
    Gems = Plr.Data.Gems.Value,
    Bounty = (Plr:FindFirstChild("leaderstats") and Plr.leaderstats:FindFirstChild("Bounty") and Plr.leaderstats.Bounty.Value) or 0
}

local function GetSessionTime()
    local seconds = os.time() - Status.Cached.StartTime
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    
    return string.format("%dh %02dm", hours, mins)
end

local function Module(parent, name)
    local obj = parent:FindFirstChild(name)
    if obj and obj:IsA("ModuleScript") then
        local success, result = pcall(require, obj)
        if success then return result end
    end
    return nil
end

local function Remote(parent, pathString)
    local current = parent
    for _, name in ipairs(pathString:split(".")) do
        if not current then return nil end
        current = current:FindFirstChild(name)
    end
    return current
end

local function LoadModule(name)
    local obj = RS:FindFirstChild(name)
    if not obj then obj = RS:FindFirstChild("Modules") and RS:FindFirstChild("Modules"):FindFirstChild(name) end
    
    if obj and obj:IsA("ModuleScript") then
        local success, result = pcall(require, obj)
        if success then return result end
        warn("Module failed to require: " .. name .. " - " .. tostring(result))
    else
        warn("Module not found: " .. name)
    end
    return nil
end

local Remotes = {}

local remotePaths = {
    _DR = {RE, "DashRemote"},

    SettingsToggle = {RE, "SettingsToggle"},
    SettingsSync = {RE, "SettingsSync"},
    UseCode = {RE, "CodeRedeem"},

    M1 = {RS, "CombatSystem.Remotes.RequestHit"},
    EquipWeapon = {RM, "EquipWeapon"},
    UseSkill = {RS, "AbilitySystem.Remotes.RequestAbility"},
    UseFruit = {RE, "FruitPowerRemote"},
    QuestAccept = {RE, "QuestAccept"},
    QuestAbandon = {RE, "QuestAbandon"},

    UseItem = {RM, "UseItem"},
    SlimeCraft = {RM, "RequestSlimeCraft"},
    GrailCraft = {RM, "RequestGrailCraft"},

    RerollSingleStat = {RM, "RerollSingleStat"},

    SkillTreeUpgrade = {RE, "SkillTreeUpgrade"},
    Enchant = {RM, "EnchantAccessory"},
    Blessing = {RM, "BlessWeapon"},

    ArtifactSync = {RE, "ArtifactDataSync"},
    ArtifactClaim = {RE, "ArtifactMilestoneClaimReward"},
    MassDelete = {RE, "ArtifactMassDeleteByUUIDs"},
    MassUpgrade = {RE, "ArtifactMassUpgrade"},
    ArtifactLock = {RE, "ArtifactLock"},
    ArtifactUnequip = {RE, "ArtifactUnequip"},
    ArtifactEquip = {RE, "ArtifactEquip"},

    Roll_Trait = {RE, "TraitReroll"},
    TraitAutoSkip = {RE, "TraitUpdateAutoSkip"},
    TraitConfirm = {RE, "TraitConfirm"},
    SpecPassiveReroll = {RE, "SpecPassiveReroll"},

    PowerRoll = {RE, "PowerReroll"},
    PowerSkip = {RE, "PowerUpdateAutoSkip"},
    UpPower = {RE, "PowerDataUpdate"},

    ArmHaki = {RE, "HakiRemote"},
    ObserHaki = {RE, "ObservationHakiRemote"},
    ConquerorHaki = {RM, "ConquerorHakiRemote"},

    TP_Portal = {RM, "TeleportToPortal"},
    OpenDungeon = {RM, "RequestDungeonPortal"},
    StartDungeon = {RM, "StartDungeonPortal"},

    EquipTitle = {RE, "TitleEquip"},
    TitleUnequip = {RE, "TitleUnequip"},
    EquipRune = {RM, "EquipRune"},
    LoadoutLoad = {RE, "LoadoutLoad"},
    AddStat = {RE, "AllocateStat"},

    OpenMerchant = {RM, "MerchantRemotes.OpenMerchantUI"},
    MerchantBuy = {RM, "MerchantRemotes.PurchaseMerchantItem"},
    ValentineBuy = {RM, "ValentineMerchantRemotes.PurchaseValentineMerchantItem"},
    StockUpdate = {RM, "MerchantRemotes.MerchantStockUpdate"},

    SummonBoss = {RM, "RequestSummonBoss"},
    JJKSummonBoss = {RM, "RequestSpawnStrongestBoss"},
    RimuruBoss = {RE, "RequestSpawnRimuru"},
    AnosBoss = {RM, "RequestSpawnAnosBoss"},
    TrueAizenBoss = {RE, "RequestSpawnTrueAizen"},
    AtomicBoss = {RE, "RequestSpawnAtomic"},

    ReqInventory = {RM, "RequestInventory"},
    Ascend = {RE, "RequestAscend"},
    ReqAscend = {RE, "GetAscendData"},
    CloseAscend = {RE, "CloseAscendUI"},

    TradeRespond = {RM, "TradeRemotes.RespondToRequest"},
    TradeSend = {RM, "TradeRemotes.SendTradeRequest"},
    TradeAddItem = {RM, "TradeRemotes.AddItemToTrade"},
    TradeReady = {RM, "TradeRemotes.SetReady"},
    TradeConfirm = {RM, "TradeRemotes.ConfirmTrade"},
    TradeUpdated = {RM, "TradeRemotes.TradeUpdated"},

    HakiStateUpdate = {RE, "HakiStateUpdate"},
    UpCurrency = {RE, "UpdateCurrency"},
    UpInventory = {RM, "UpdateInventory"},
    UpPlayerStats = {RE, "UpdatePlayerStats"},
    UpAscend = {RE, "AscendDataUpdate"},
    UpStatReroll = {RE, "StatRerollUpdate"},
    SpecPassiveUpdate = {RE, "SpecPassiveDataUpdate"},
    SpecPassiveSkip = {RE, "SpecPassiveUpdateAutoSkip"},
    UpSkillTree = {RE, "SkillTreeUpdate"},
    BossUIUpdate = {RM, "BossUIUpdate"},
    TitleSync = {RE, "TitleDataSync"},
}

for key, data in pairs(remotePaths) do
    Remotes[key] = Remote(data[1], data[2])
end

local Modules = {
    BossConfig = LoadModule("BossConfig", {Bosses = {},}),
    TimedConfig = LoadModule("TimedBossConfig"),
    SummonConfig = LoadModule("SummonableBossConfig"),

    Merchant = LoadModule("MerchantConfig", {ITEMS = {},}),
    Travel = LoadModule("TravelConfig"),
    DungeonConfig = LoadModule("DungeonConfig"),

    Title = LoadModule("TitlesConfig", {}),
    Quests = LoadModule("QuestConfig", {RepeatableQuests = {}, Questlines = {},}),

    WeaponClass = LoadModule("WeaponClassification", {Tools = {},}),
    Fruits = Module(RS:FindFirstChild("FruitPowerSystem") or RS, "FruitPowerConfig") or {Powers = {}},
    ArtifactConfig = LoadModule("ArtifactConfig"),

    LevelingConfig = LoadModule("LevelingConfig", {STATS = {}}),
    Stats = LoadModule("StatRerollConfig"),
    Codes = LoadModule("CodesConfig", {Codes = {},}),
    ItemRarity = LoadModule("ItemRarityConfig"),
    ItemDropConfig = LoadModule("ItemDropConfig"),
    ItemCapsConfig = LoadModule("ItemCapsConfig", {Caps = {}}),
    Trait = LoadModule("TraitConfig", {Traits = {},}),
    Race = LoadModule("RaceConfig", {Races = {},}),
    Clan = LoadModule("ClanConfig", {Clans = {},}),
    SpecPassive = LoadModule("SpecPassiveConfig"),
    Power = LoadModule("PowerConfig")
}

local PATH = {
    Mobs = workspace:WaitForChild('NPCs'),
    InteractNPCs = workspace:WaitForChild('ServiceNPCs'),
}

local function GetServiceNPC(name)
    return PATH.InteractNPCs:FindFirstChild(name)
end

local NPCs = {
    Merchant = {
        Regular = GetServiceNPC("MerchantNPC"),
        Dungeon = GetServiceNPC("DungeonMerchantNPC"),
        Valentine = GetServiceNPC("ValentineMerchantNPC"),
    }
}

local UI = {
    Merchant = {
        Regular = PGui:WaitForChild("MerchantUI"),
        Dungeon = PGui:WaitForChild("DungeonMerchantUI"),
        Valentine = PGui:FindFirstChild("ValentineMerchantUI"),
    }
}

local Tables = {
    AscendLabels = {},
    DiffList = {"Normal", "Medium", "Hard", "Extreme"},
    MobList = {},
    MiniBossList = {"ThiefBoss", "MonkeyBoss", "DesertBoss", "SnowBoss", "PandaMiniBoss"},
    BossList = {},
    AllBossList = {},
    AllNPCList = {},
    AllEntitiesList = {},
    SummonList = {},
    OtherSummonList = {},
--    OtherSummonList = {"StrongestHistory", "StrongestToday", "Rimuru", "Anos", "TrueAizen"},
    FullSummon = {},
    Weapon = {"Melee", "Sword", "Power"},
    ManualWeaponClass = {
        ["Invisible"] = "Power",
        ["Bomb"] = "Power",
        ["Quake"] = "Power",
    },

    MerchantList = {},
    ValentineMerchantList = {},

    Rarities = {"Common", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Aura Crate", "Cosmetic Crate"},
    CraftItemList = {"SlimeKey", "DivineGrail"},
    UnlockedTitle = {},
    TitleCategory = {"None", "Best EXP", "Best Money & Gem", "Best Luck", "Best DMG"},
    TitleList = {},
    SortedTitle = Modules.Title:GetSortedTitleIds(),
    BuildList = {"1", "2", "3", "4", "5", "None"},
    TraitList = {},
    RarityWeight = {
    ["Secret"] = 1,
    ["Mythical"] = 2,
    ["Legendary"] = 3,
    ["Epic"] = 4,
    ["Rare"] = 5,
    ["Uncommon"] = 6,
    ["Common"] = 7
    },
    ArtiSet = {},
    ArtiStat = {},
    RaceList = {},
    ClanList = {},
    RuneList = {"None"},
    SpecPassive = {},
    Power = {},
    GemStat = Modules.Stats.StatKeys,
    GemRank = Modules.Stats.RankOrder,
    OwnedWeapon = {},
    AllOwnedWeapons = {},
    OwnedAccessory = {},
    QuestlineList = {},

    ITEM_WEIGHTS = {
    Chests = {"Common", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Aura Crate", "Cosmetic Crate"},
    Materials = {["Wood"] = 1, ["Iron"] = 2, ["Obsidian"] = 3, ["Mythril"] = 4, ["Adamantite"] = 5},
    Rarities = {["Common"] = 1, ["Rare"] = 2, ["Epic"] = 3, ["Legendary"] = 4},
    Gears = {["Helmet"] = 1, ["Gloves"] = 2, ["Body"] = 3, ["Boots"] = 4}
    },

    OwnedItem = {},

    NPC_QuestList = {"DungeonUnlock", "SlimeKeyUnlock"},
    NPC_MiscList = {"Artifacts", "Blessing", "Enchant", "SkillTree", "Cupid", "ArmHaki", "Observation", "Conqueror"},
    DungeonList = {},

    NPC_MovesetList = {},
    NPC_MasteryList = {},

    IslandList = {},
    IslandCrystals = {},
    MobToIsland = {},
}

local TradePresets = {
    ["Madara Set"] = {
        ["Path Fragment"] = 3,
        ["Eternal Core"] = 8,
        ["Battle Sigil"] = 18,
        ["Power Remnant"] = 15,
    },
    ["Aizen Set"] = {
        ["Hyoguko Fragment"] = 1,
        ["Reiatsu Core"] = 3,
        ["Illusion Prism"] = 6,
        ["Mirage Pendant"] = 10,
    },
    ["True Aizen Set"] = {
        ["Evolution Fragment"] = 1,
        ["Transcendent Core"] = 3,
        ["Divinity Essence"] = 8,
        ["Fusion Ring"] = 15,
        ["Chrysalis Sigil"] = 75,
        ["Transmutation Shards"] = 5,
    },
    ["Atomic Set"] = {
        ["Atomic Omen"] = 1,
        ["Eminence Essence"] = 3,
        ["Shadow Remnant"] = 9,
        ["Magic Shard"] = 16,
        ["Abyss Sigil"] = 140,
    },
    ["Shadow Set"] = {
        ["Atomic Core"] = 1,
        ["Shadow Essence"] = 4,
        ["Void Seed"] = 8,
        ["Umbral Capsule"] = 20,
    },
    ["Saber Alter Set"] = {
        ["Dark Grail"] = 110,
        ["Morgan Remnant"] = 15,
        ["Alter Essence"] = 8,
        ["Corruption Core"] = 12,
        ["Corrupt Crown"] = 3,
    },
    ["Blessed Maiden Set"] = {
        ["Celestial Mark"] = 3,
        ["Aero Core"] = 1,
        ["Gale Essence"] = 8,
        ["Tide Remnant"] = 14,
        ["Tempest Relic"] = 100,
    },
    ["Yamato Set"] = {
        ["Azure Heart"] = 1,
        ["Silent Storm"] = 3,
        ["Yamato Essence"] = 7,
        ["Frozen Will"] = 14,
    },
    ["Gilgamesh Set"] = {
        ["Ancient Shards"] = 6,
        ["Throne Remnants"] = 12,
        ["Golden Essence"] = 8,
        ["Phantasm Cores"] = 3,
        ["Broken Swords"] = 100,
    },
    ["Kokushibo Set"] = {
        ["Moon Crest"] = 2,
        ["Crescent Shard"] = 14,
        ["Lunar Essence"] = 9,
        ["Demon Remnant"] = 16,
        ["Upper Seal"] = 110,
    },
    ["Esdeath Set"] = {
        ["Ice Core"] = 3,
        ["Frozen Brand"] = 14,
        ["Glaciar Remant"] = 9,
        ["Battle Shard"] = 17,
        ["Frost Relic"] = 110,
    }
}

local BossRemoteRegistry = {
    ["StrongestofTodayBoss"] = { Remote = Remotes.JJKSummonBoss, Args = {"StrongestToday"} },
    ["StrongestinHistoryBoss"] = { Remote = Remotes.JJKSummonBoss, Args = {"StrongestHistory"} },
    ["AnosBoss"] = { Remote = Remotes.AnosBoss, Args = {"Anos"} },
    ["Strongest of Today"] = { Remote = Remotes.JJKSummonBoss, Args = {"StrongestToday"} },
    ["Strongest in History"] = { Remote = Remotes.JJKSummonBoss, Args = {"StrongestHistory"} },
    ["Anos"] = { Remote = Remotes.AnosBoss, Args = {"Anos"} },
    ["Demon King"] = { Remote = Remotes.AnosBoss, Args = {"Anos"} }
}

local function GetOtherSummon()
    local modules = RS:FindFirstChild("Modules")
    if not modules then return end

    local manualBosses = {"Strongest in History", "Strongest of Today"}
    
    local ignoreList = {
        "SummonableBossConfig", "BossConfig", "TimedBossConfig", "StrongestBossConfig"
    }

    for _, name in ipairs(manualBosses) do
        if not table.find(Tables.OtherSummonList, name) then
            table.insert(Tables.OtherSummonList, name)
        end
    end

    -- Scanner
    for _, obj in pairs(modules:GetChildren()) do
        if table.find(ignoreList, obj.Name) then continue end
        
        local bossPrefix = obj.Name:match("^(.-)BossConfig$")
        if bossPrefix and bossPrefix ~= "" then
            local displayName = bossPrefix 
            if not table.find(Tables.OtherSummonList, displayName) then
                table.insert(Tables.OtherSummonList, displayName)
            end
        end
    end
    table.sort(Tables.OtherSummonList)
end

GetOtherSummon()

local function InitializeIslands()
    local TravelConfig = Modules.Travel
    if not TravelConfig or not TravelConfig.Zones then return end

    table.clear(Tables.IslandList)
    table.clear(Tables.IslandCrystals)

    -- Pre-scan workspace for models with the CheckpointName attribute
    local crystalCache = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        local attrValue = obj:GetAttribute("CheckpointName")
        if attrValue then
            crystalCache[attrValue] = obj
        end
    end

    for internalName, data in pairs(TravelConfig.Zones) do
        local baseName = internalName:gsub("Island", ""):gsub("Station", "")
        local displayName = data.DisplayName
        
        -- Match crystal via attribute
        local crystal = crystalCache[displayName]

        if crystal then
            Tables.IslandCrystals[baseName] = crystal
        end
        
        table.insert(Tables.IslandList, baseName)
    end
    table.sort(Tables.IslandList)

    if Options.SelectedIsland then
        Options.SelectedIsland:SetValues(Tables.IslandList)
    end
end

local function GetTPName(baseName)
    if baseName == "Hollow" then 
        return "HollowIsland" 
    end
    return baseName
end

InitializeIslands()

local function Fill(target, source, sortFunc)
    for k in pairs(source) do table.insert(target, k) end
    table.sort(target, sortFunc)
end

local function SortByRarity(dataTable, rarityKey)
    return function(a, b)
        local dataA = dataTable[a]
        local dataB = dataTable[b]
        if not dataA or not dataB then return false end

        local rA = dataA[rarityKey] or dataA["Rarity"] or dataA["rarity"] or "Common"
        local rB = dataB[rarityKey] or dataB["Rarity"] or dataB["rarity"] or "Common"

        local wA = Tables.RarityWeight[rA] or 99
        local wB = Tables.RarityWeight[rB] or 99

        if wA ~= wB then
            return wA < wB
        end
        return a < b
    end
end

if Modules.TimedConfig and Modules.TimedConfig.Bosses then
    table.clear(Tables.BossList)
    for internalId, data in pairs(Modules.TimedConfig.Bosses) do
        Status.Main.BossMap[data.displayName] = internalId
        table.insert(Tables.BossList, data.displayName)
        
        local tpName = data.spawnLocation:gsub(" Island", ""):gsub(" Station", "")
        if data.spawnLocation == "Judgement Island" then tpName = "Judgement" end
        Status.Main.BossTIMap[data.displayName] = tpName
    end
    table.sort(Tables.BossList)
end

if Modules.SummonConfig and Modules.SummonConfig.Bosses then
    table.clear(Tables.SummonList)
    for internalId, data in pairs(Modules.SummonConfig.Bosses) do
        Status.Main.BossMap[data.displayName] = internalId
        table.insert(Tables.SummonList, data.displayName)
        Status.Main.SummonMap[data.displayName] = data.bossId or internalId
    end
    table.sort(Tables.SummonList)
end

for _, v in ipairs(Tables.SummonList) do table.insert(Tables.FullSummon, v) end
for _, v in ipairs(Tables.OtherSummonList) do table.insert(Tables.FullSummon, v) end
table.sort(Tables.FullSummon)

if Modules.BossConfig and Modules.BossConfig.Bosses then
    for internalId, data in pairs(Modules.BossConfig.Bosses) do
        Status.Main.BossMap[data.displayName] = internalId
        table.insert(Tables.AllBossList, data.displayName)
    end
end

local DisplayToInternal = {}
if Modules.BossConfig and Modules.BossConfig.Bosses then
    for internalId, data in pairs(Modules.BossConfig.Bosses) do
        DisplayToInternal[data.displayName] = internalId
    end
end

local function GetBestOwnedTitle(category)
    if #Tables.UnlockedTitle == 0 then return nil end
    
    local bestTitleId = nil
    local highestValue = -1
    
    local statMap = {
        ["Best EXP"] = "XPPercent",
        ["Best Money & Gem"] = "MoneyPercent", 
        ["Best Luck"] = "LuckPercent",
        ["Best DMG"] = "DamagePercent"
    }
    
    local targetStat = statMap[category]
    if not targetStat then return nil end

    for _, titleId in ipairs(Tables.UnlockedTitle) do
        local data = Modules.Title.Titles[titleId]
        if data and data.statBonuses and data.statBonuses[targetStat] then
            local val = data.statBonuses[targetStat]
            if val > highestValue then
                highestValue = val
                bestTitleId = titleId
            end
        end
    end
    
    return bestTitleId
end

-- // Title
local CombinedTitleList = {}
for _, v in ipairs(Tables.TitleCategory) do table.insert(CombinedTitleList, v) end
for _, v in ipairs(Tables.SortedTitle) do
    table.insert(Tables.TitleList, v)
    table.insert(CombinedTitleList, v)
end

-- // Import
Fill(Tables.ArtiSet, Modules.ArtifactConfig.Sets)
Fill(Tables.ArtiStat, Modules.ArtifactConfig.Stats)
Fill(Tables.SpecPassive, Modules.SpecPassive.Passives)
Fill(Tables.Power, Modules.Power.Powers)
Fill(Tables.QuestlineList, Modules.Quests.Questlines)
Fill(Tables.MerchantList, Modules.Merchant.ITEMS)
Fill(Tables.DungeonList, Modules.DungeonConfig.Dungeons)
Fill(Tables.TraitList, Modules.Trait.Traits, SortByRarity(Modules.Trait.Traits, "rarity"))
Fill(Tables.RaceList, Modules.Race.Races, SortByRarity(Modules.Race.Races, "rarity"))
Fill(Tables.ClanList, Modules.Clan.Clans, SortByRarity(Modules.Clan.Clans, "rarity"))

for _, v in ipairs(PATH.InteractNPCs:GetChildren()) do
    table.insert(Tables.AllNPCList, v.Name)
end

local function Cleanup(tbl)
    for key, value in pairs(tbl) do
        if typeof(value) == "RBXScriptConnection" then
            value:Disconnect()
            tbl[key] = nil
        elseif typeof(value) == 'thread' then
            task.cancel(value)
            tbl[key] = nil
        elseif type(value) == 'table' then
            Cleanup(value)
        end
    end
end

local Flags = {}

function Thread(featurePath, featureFunc, isEnabled, ...)
    local pathParts = featurePath:split(".")
    local currentTable = Flags 

    for i = 1, #pathParts - 1 do
        local part = pathParts[i]
        if not currentTable[part] then currentTable[part] = {} end
        currentTable = currentTable[part]
    end

    local flagKey = pathParts[#pathParts]
    local activeThread = currentTable[flagKey]

    if isEnabled then
        if not activeThread or coroutine.status(activeThread) == "dead" then
            local newThread = task.spawn(featureFunc, ...)
            currentTable[flagKey] = newThread
        end
    else
        if activeThread and typeof(activeThread) == 'thread' then
            task.cancel(activeThread)
            currentTable[flagKey] = nil
        end
    end
end

local function SafeLoop(name, func)
    return function(...)
        local success, err = pcall(func, ...)
        if not success then
            Library:Notify("ERROR in ["..name.."]: Check console and send to script developer.", 10)
            warn("⚠️ ["..name.."] ERROR: " .. tostring(err))
        end
    end
end

local function SafeSetValues(id, list)
    local opt = Options[id]
    if opt and opt.SetValues then opt:SetValues(list) end
end

local function CommaFormat(n)
    local s = tostring(n)
    return s:reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

local function Abbreviate(n)
    local abbrev = {{1e12, "T"}, {1e9, "B"}, {1e6, "M"}, {1e3, "K"}}
    for _, v in ipairs(abbrev) do
        if n >= v[1] then return string.format("%.1f%s", n / v[1], v[2]) end
    end
    return tostring(n)
end

local function GetFormattedItemSections(itemSourceTable, isNewItems)
    local categories = {
        Chests = {}, Rerolls = {}, Keys = {},
        Materials = {}, Gears = {}, Accessories = {}, Runes = {}, Others = {}
    }

    local totalDust = 0

    for key, data in pairs(itemSourceTable) do
        local name = tostring(type(data) == "table" and data.name or key)
        local qty = tonumber(type(data) == "table" and data.quantity or data) or 1

        if name:find("Auto%-deleted") then
            local dustValue = name:match("%+(%d+) dust")
            if dustValue then totalDust = totalDust + (qty * tonumber(dustValue)) end
            continue
        end

        local totalInInv = 0
        if isNewItems then
            for _, item in pairs(Status.Cached.Inv or {}) do
                if item.name == name then totalInInv = item.quantity break end
            end
        end

        local entryText = isNewItems 
            and string.format("+ [%d] %s [Total: %s]", qty, name, CommaFormat(totalInInv)) 
            or string.format("- %s: %s", name, CommaFormat(qty))

        -- Categorization Logic
        if name:find("Chest") or name:find("Crate") then
            local weight = 99
            for i, v in ipairs(Tables.ITEM_WEIGHTS.Chests) do if name:find(v) then weight = i break end end
            table.insert(categories.Chests, {Text = entryText, Weight = weight})
        elseif name:find("Reroll") then table.insert(categories.Rerolls, entryText)
        elseif name:find("Key") then table.insert(categories.Keys, entryText)
        elseif Tables.ITEM_WEIGHTS.Materials[name] then
            table.insert(categories.Materials, {Text = entryText, Weight = Tables.ITEM_WEIGHTS.Materials[name]})
        elseif name:find("Helmet") or name:find("Gloves") or name:find("Body") or name:find("Boots") then
            local rWeight, tWeight = 99, 99
            for k, v in pairs(Tables.ITEM_WEIGHTS.Rarities) do if name:find(k) then rWeight = v break end end
            for k, v in pairs(Tables.ITEM_WEIGHTS.Gears) do if name:find(k) then tWeight = v break end end
            table.insert(categories.Gears, {Text = entryText, Rarity = rWeight, Type = tWeight})
        elseif name:find("Rune") then table.insert(categories.Runes, entryText)
        else table.insert(categories.Others, entryText) end
    end

    if totalDust > 0 then
        local dustText = isNewItems and string.format("+ [%d] Dust", totalDust) or string.format("- Dust: %s", CommaFormat(totalDust))
        table.insert(categories.Materials, 1, {Text = dustText, Weight = 0})
    end

    local result = ""
    local function process(title, tbl, sortFunc)
        if #tbl > 0 then
            if sortFunc then table.sort(tbl, sortFunc) end
            result = result .. "**< " .. title .. " >**\n```" 
            for _, v in ipairs(tbl) do result = result .. (type(v) == "table" and v.Text or v) .. "\n" end
            result = result .. "```\n" 
        end
    end

    process("Chests", categories.Chests, function(a,b) return a.Weight < b.Weight end)
    process("Rerolls", categories.Rerolls)
    process("Keys", categories.Keys)
    process("Materials", categories.Materials, function(a,b) return a.Weight < b.Weight end)
    process("Gears", categories.Gears, function(a,b) 
        return (a.Rarity ~= b.Rarity) and (a.Rarity < b.Rarity) or (a.Type < b.Type)
    end)
    process("Runes", categories.Runes)
    process("Others", categories.Others)

    return result
end

local function PostToWebhook()
    local url = Options.WebhookURL.Value
    if url == "" or not url:find("discord.com/api/webhooks/") then return end

    local selected = Options.SelectedData.Value
    local allowedRarity = Options.SelectedItemRarity.Value or {}
    
    local data = Plr.Data
    local lstats = Plr:FindFirstChild("leaderstats")
    local bounty = lstats and lstats:FindFirstChild("Bounty") and lstats.Bounty.Value or 0
    
    local desc = "### sailor piece\n"
    
    if selected["Name"] then
        desc = desc .. string.format("\n👤 **Player:** ||%s||\n", Plr.Name)
    end

    if selected["Stats"] then
        local gainedLvl = data.Level.Value - StartStats.Level
        local gainedMoney = data.Money.Value - StartStats.Money
        local gainedGems = data.Gems.Value - StartStats.Gems
        local gainedBounty = bounty - StartStats.Bounty

        desc = desc .. string.format("📈 **Level:** `%s` (+%d)\n", CommaFormat(data.Level.Value), gainedLvl)
        desc = desc .. string.format("💰 **Currency:** 💵 %s (+%s) | 💎 %s (+%s)\n", 
            Abbreviate(data.Money.Value), Abbreviate(gainedMoney),
            CommaFormat(data.Gems.Value), CommaFormat(gainedGems))
        desc = desc .. string.format("☠️ **Bounty:** %s (+%s)\n", Abbreviate(bounty), Abbreviate(gainedBounty))
    end
    
    desc = desc .. "\n"

    local function IsAllowed(itemName)
        local rarity = Modules.ItemRarity and Modules.ItemRarity.Items[itemName] or "Common"
        return allowedRarity[rarity] == true
    end

    if selected["New Items"] and next(Status.Cached.NewItem) then
        local filteredNew = {}
        for name, qty in pairs(Status.Cached.NewItem) do
            if IsAllowed(name) then filteredNew[name] = qty end
        end

        if next(filteredNew) then
            desc = desc .. "✨ **New Items**\n"
            desc = desc .. GetFormattedItemSections(filteredNew, true) .. "\n"
        end
    end

    if selected["All Items"] then
        local filteredInv = {}
        for _, item in pairs(Status.Cached.Inv or {}) do
            if IsAllowed(item.name) then table.insert(filteredInv, item) end
        end

        if #filteredInv > 0 then
            desc = desc .. "---"
            desc = desc .. "\n🎒 **Inventory**\n"
            desc = desc .. GetFormattedItemSections(filteredInv, false)
        end
    end

    local catLink = fire[math.random(1, #fire)] or ""

    local payload = {
        ["embeds"] = {{
            ["description"] = desc,
            ["color"] = tonumber("ffff77", 16),
            ["footer"] = { ["text"] = string.format("sailor hub • Session: %s • %s", GetSessionTime(), os.date("%x %X")) },
            ["thumbnail"] = { ["url"] = catLink }
        }}
    }
    
    if Toggles.PingUser.Value then payload["content"] = (Options.UID.Value ~= "" and "<@"..Options.UID.Value..">" or "@everyone") end

    task.spawn(function()
        pcall(function()
            httprequest({ Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = Http:JSONEncode(payload) })
            table.clear(Status.Cached.NewItem)
        end)
    end)
end

local function GetSortedUniqueNames(dataList)
    local unique = {}
    local result = {}
    for _, item in ipairs(dataList) do
        if not unique[item.name] then
            unique[item.name] = true
            table.insert(result, item.name)
        end
    end
    table.sort(result)
    return result
end

Remotes.UpInventory.OnClientEvent:Connect(function(category, data)
    Status.Main.InventorySynced = true
    local safeData = (type(data) == "table") and data or {}

    if category == "Items" then 
        Status.Cached.Inv = safeData
        table.clear(Tables.OwnedItem)
        
        for presetName, _ in pairs(TradePresets) do
            table.insert(Tables.OwnedItem, presetName)
        end

        for _, item in pairs(safeData) do
            if not table.find(Tables.OwnedItem, item.name) then
                table.insert(Tables.OwnedItem, item.name)
            end
        end
        table.sort(Tables.OwnedItem)
        SafeSetValues("SelectedTradeItems", Tables.OwnedItem)

    elseif category == "Runes" then
        table.clear(Tables.RuneList)
        table.insert(Tables.RuneList, "None")
        for name, _ in pairs(safeData) do table.insert(Tables.RuneList, name) end
        table.sort(Tables.RuneList)
        
        for _, dd in ipairs({"DefaultRune", "Rune_Mob", "Rune_Boss", "Rune_BossHP"}) do
            SafeSetValues(dd, Tables.RuneList)
        end

    elseif category == "Accessories" then
        table.clear(Status.Cached.Accessories)
        for _, accInfo in ipairs(safeData) do
            if accInfo.name and accInfo.quantity then
                Status.Cached.Accessories[accInfo.name] = accInfo.quantity
            end
        end
        
        table.clear(Tables.OwnedAccessory)
        local processed = {}
        for _, item in ipairs(safeData) do
            if (item.enchantLevel or 0) < 10 and not processed[item.name] then
                table.insert(Tables.OwnedAccessory, item.name)
                processed[item.name] = true
            end
        end
        table.sort(Tables.OwnedAccessory)
        SafeSetValues("SelectedEnchant", Tables.OwnedAccessory)
        
    elseif category == "Sword" or category == "Melee" then
        Status.Main.RawWeapCache[category] = safeData
        
        table.clear(Tables.OwnedWeapon)
        table.clear(Tables.AllOwnedWeapons)
        local processedUpgradeable = {}
        local processedAll = {}
        
        for _, cat in pairs({"Sword", "Melee"}) do
            local weapList = Status.Main.RawWeapCache[cat] or {}
            for _, item in ipairs(weapList) do
                if (item.blessingLevel or 0) < 10 and not processedUpgradeable[item.name] then
                    table.insert(Tables.OwnedWeapon, item.name)
                    processedUpgradeable[item.name] = true
                end

                if not processedAll[item.name] then
                    table.insert(Tables.AllOwnedWeapons, item.name)
                    processedAll[item.name] = true
                end
            end
        end
        
        table.sort(Tables.OwnedWeapon)
        table.sort(Tables.AllOwnedWeapons)
        
        SafeSetValues("SelectedBlessing", Tables.OwnedWeapon)
        SafeSetValues("SelectedPassive", Tables.AllOwnedWeapons)
    end
end)

Remotes.ArtifactSync.OnClientEvent:Connect(function(data)
    Status.Main.ArtifactSession.Inventory = data.Inventory
    Status.Main.ArtifactSession.Dust = data.Dust
    
    local counts = { Helmet = 0, Gloves = 0, Body = 0, Boots = 0 }
    for _, item in pairs(data.Inventory) do
        if counts[item.Category] then counts[item.Category] = counts[item.Category] + 1 end
    end

    if DustLabel then DustLabel:SetText("Dust: " .. CommaFormat(data.Dust)) end
    for cat, count in pairs(counts) do
        local label = _G["InvLabel_" .. cat]
        if label then label:SetText(cat .. ": " .. count .. "/500") end
    end
end)

Remotes.HakiStateUpdate.OnClientEvent:Connect(function(target, state)
    if target == false then Status.Main.ArmHaki = false
    elseif target == Plr then Status.Main.ArmHaki = state end
end)

if Remotes.BossUIUpdate then
    Remotes.BossUIUpdate.OnClientEvent:Connect(function(mode, data)
        if mode == "DamageStats" and data.stats then
            for _, info in pairs(data.stats) do
                if info.player then Status.Main.AltDamage[info.player.Name] = tonumber(info.percent) or 0 end
            end
        end
    end)
end

Remotes.UpPower.OnClientEvent:Connect(function(data)
    if data and data.Current then
        Status.Main.CurrentPower.Name = data.Current.Name or "None"
        Status.Main.CurrentPower.Buffs = data.Current.RolledBuffs or {}
        
        if data.Current.RolledMythical then
            Status.Main.CurrentPower.MythicalBuff = data.Current.RolledMythical.DebuffPercent 
                or data.Current.RolledMythical.BossDamagePercent 
                or 0
        end
        
        if PowerLabel then
            local text = string.format("<b>Current:</b> %s", Status.Main.CurrentPower.Name)
            PowerLabel:SetText(text)
        end
    end
end)

PATH.Mobs.ChildRemoved:Connect(function(child)
    if child.Name:lower():find("boss") then
        table.clear(Status.Main.AltDamage)
        Status.Main.AltActive = false
    end
end)

RS.Remotes.NotifyItemDrop.OnClientEvent:Connect(function(d) Status.Cached.NewItem[d.name] = (Status.Cached.NewItem[d.name] or 0) + (d.quantity or 1) end)
Remotes.StockUpdate.OnClientEvent:Connect(function(n, s) Status.Main.CurrentStock[n] = tonumber(s) end)
Remotes.UpSkillTree.OnClientEvent:Connect(function(d) Status.Main.SkillTree.Nodes = d.Nodes; Status.Main.SkillTree.Points = d.SkillPoints end)
Remotes.SettingsSync.OnClientEvent:Connect(function(d) Status.Main.Settings = d end)
Remotes.TitleSync.OnClientEvent:Connect(function(d) Tables.UnlockedTitle = d.unlocked or {} end)
Remotes.TradeUpdated.OnClientEvent:Connect(function(d) Status.Main.TradeState = d end)

function AddSliderToggle(Config)
    local Toggle = Config.Group:AddToggle(Config.Id, {
        Text = Config.Text,
        Default = Config.DefaultToggle or false
    })
    
    local Slider = Config.Group:AddSlider(Config.Id .. "Value", {
        Text = Config.Text,
        Default = Config.Default,
        Min = Config.Min,
        Max = Config.Max,
        Rounding = Config.Rounding or 0,
        Compact = true,
        Visible = false
    })

    Toggle:OnChanged(function()
        Slider:SetVisible(Toggle.Value)
    end)

    return Toggle, Slider
end

local function CreateSwitchGroup(tab, id, displayName, tableSource)
    local toggle = tab:AddToggle("Auto"..id, { Text = "Auto Switch "..displayName, Default = false })
    
    toggle:OnChanged(function(state)
        if not state then
            Status.Main.LastSwitch[id] = ""
        end
    end)

    local listToUse = (id == "Title") and CombinedTitleList or tableSource

    tab:AddDropdown("Default"..id, { Text = "Select Default "..displayName, Values = listToUse, Searchable = true })
    tab:AddDropdown(id.."_Mob", { Text = displayName.." [Mob]", Values = listToUse, Searchable = true })
    tab:AddDropdown(id.."_Boss", { Text = displayName.." [Boss]", Values = listToUse, Searchable = true })
    tab:AddDropdown(id.."_Combo", { Text = displayName.." [Combo F Move]", Values = listToUse, Searchable = true })
    tab:AddDropdown(id.."_BossHP", { Text = displayName.." [Boss HP%]", Values = listToUse, Searchable = true })
    
    tab:AddSlider(id.."_BossHPAmt", { Text = "Change Until Boss HP%", Default = 15, Min = 0, Max = 100, Rounding = 0 })
end

function gsc(guiObject)
    if not guiObject then return false end
    
    local success = false
    pcall(function()
        if Gui and VIM then
            Gui.SelectedObject = guiObject
            task.wait(0.05)
            
            local keys = {Enum.KeyCode.Return, Enum.KeyCode.KeypadEnter, Enum.KeyCode.ButtonA}
            for _, key in ipairs(keys) do
                VIM:SendKeyEvent(true, key, false, game); task.wait(0.03)
                VIM:SendKeyEvent(false, key, false, game); task.wait(0.03)
            end

            Gui.SelectedObject = nil
            success = true
        end
    end)
    
    return success
end

local function UpdateAscendUI(data)
    if data.isMaxed then
        Tables.AscendLabels[1]:SetText("⭐ Max Ascension Reached!")
        Tables.AscendLabels[1]:SetVisible(true)
        for i = 2, 10 do Tables.AscendLabels[i]:SetVisible(false) end
        return
    end

    local reqs = data.requirements or {}
    for i = 1, 10 do
        local req = reqs[i]
        local label = Tables.AscendLabels[i]
        
        if req then
            local displayText = req.display:gsub("<[^>]+>", "")
            local status = req.completed and " ✅" or " ❌"
            local progress = string.format(" (%s/%s)", CommaFormat(req.current), CommaFormat(req.needed))
            
            label:SetText("- " .. displayText .. progress .. status)
            label:SetVisible(true)
        else
            label:SetVisible(false)
        end
    end
end

local function UpdateStatsLabel()
    if not StatsLabel then return end
    local text = ""
    local hasData = false
    
    for _, statName in ipairs(Tables.GemStat) do
        local data = Status.Main.GemStats[statName]
        if data then
            hasData = true
            text = text .. string.format("<b>%s:</b> %s\n", statName, tostring(data.Rank))
        end
    end
    
    if not hasData then
        StatsLabel:SetText("<i>No data. Reroll once to sync.</i>")
    else
        StatsLabel:SetText(text)
    end
end

local function UpdateSpecPassiveLabel()
    if not SpecPassiveLabel then return end
    
    local text = ""
    local selectedWeapons = Options.SelectedPassive.Value or {}
    local hasAny = false

    if type(Status.Main.Passives) ~= "table" then 
        Status.Main.Passives = {} 
    end

    for weaponName, isEnabled in pairs(selectedWeapons) do
        if isEnabled then
            hasAny = true
            
            local data = Status.Main.Passives[weaponName]
            local displayName = "None"

            if type(data) == "table" then
                displayName = tostring(data.Name or "None")
            elseif type(data) == "string" then
                displayName = data
            end

            text = text .. string.format("<b>%s:</b> %s\n", tostring(weaponName), displayName)
        end
    end

    if not hasAny then
        SpecPassiveLabel:SetText("<i>No weapons selected.</i>")
    else
        SpecPassiveLabel:SetText(text)
    end
end

local function GetCharacter()
    local c = Plr.Character
    return (c and c:FindFirstChild("HumanoidRootPart") and c:FindFirstChildOfClass("Humanoid")) and c or nil
end

local function GetPlayerByName(name)
    name = name:lower()
    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p.Name:lower():find(name) or p.DisplayName:lower():find(name) then
            return p
        end
    end
    return nil
end

local function PanicStop()
    Status.Main.Farm = false
    Status.Main.AltActive = false
    Status.Main.GlobalPrio = "FARM"
    Status.Main.Target = nil
    Status.Main.MovingIsland = false
    
    for _, toggle in pairs(Toggles) do
        if toggle.SetValue then
            toggle:SetValue(false)
        end
    end
    
    local char = GetCharacter()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        
        root.CFrame = root.CFrame * CFrame.new(0, 2, 0)
    end
    
    task.delay(0.5, function()
        Status.Main.Farm = true
    end)

    Library:Notify("Stopped.", 5)
end

local function FuncTPW()
    while true do
        local delta = RunService.Heartbeat:Wait()
        local char = GetCharacter()
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if char and hum and hum.Health > 0 then
            if hum.MoveDirection.Magnitude > 0 then
                local speed = Options.TPWValue.Value
                char:TranslateBy(hum.MoveDirection * speed * delta * 10)
            end
        end
    end
end

local function FuncNoclip()
    while Toggles.Noclip.Value do
        RunService.Stepped:Wait()
        local char = GetCharacter()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then 
                    part.CanCollide = false 
                end
            end
        end
    end
end

local function Func_AntiKnockback()
    if type(Status.Connections.Knockback) == "table" then
        for _, conn in pairs(Status.Connections.Knockback) do 
            if conn then conn:Disconnect() end 
        end
        table.clear(Status.Connections.Knockback)
    else
        Status.Connections.Knockback = {}
    end

    local function ApplyAntiKB(character)
        if not character then return end
        local root = character:WaitForChild("HumanoidRootPart", 10)
        
        if root then
            local conn = root.ChildAdded:Connect(function(child)
                if not Toggles.AntiKnockback.Value then return end
                
                if child:IsA("BodyVelocity") and child.MaxForce == Vector3.new(40000, 40000, 40000) then
                    child:Destroy()
                end
            end)
            table.insert(Status.Connections.Knockback, conn)
        end
    end

    if Plr.Character then
        ApplyAntiKB(Plr.Character)
    end

    local charAddedConn = Plr.CharacterAdded:Connect(function(newChar)
        ApplyAntiKB(newChar)
    end)
    table.insert(Status.Connections.Knockback, charAddedConn)

    repeat task.wait(1) until not Toggles.AntiKnockback.Value

    for _, conn in pairs(Status.Connections.Knockback) do 
        if conn then conn:Disconnect() end 
    end
    table.clear(Status.Connections.Knockback)
end

local function DisableIdled()
    pcall(function()
        if getconnections then
            for _, v in pairs(getconnections(Plr.Idled)) do
                if v.Disable then v:Disable()
                elseif v.Disconnect then v:Disconnect() end
            end
        end
    end)
end

local function Func_AutoReconnect()
    if Status.Connections.Reconnect then Status.Connections.Reconnect:Disconnect() end

    Status.Connections.Reconnect = Gui.ErrorMessageChanged:Connect(function()
        if not Toggles.AutoReconnect.Value then return end

        task.delay(2, function()
            pcall(function()
                local promptOverlay = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
                if promptOverlay then
                    local errorPrompt = promptOverlay.promptOverlay:FindFirstChild("ErrorPrompt")
                    
                    if errorPrompt and errorPrompt.Visible then
                        local secondaryTimer = 5
                        
                        task.wait(secondaryTimer)
                        
                        TP:Teleport(game.PlaceId, Plr)
                    end
                end
            end)
        end)
    end)
end

local function Func_NoGameplayPaused()
    while Toggles.NoGameplayPaused.Value do
        local success, err = pcall(function()
            local pauseGui = game:GetService("CoreGui").RobloxGui:FindFirstChild("CoreScripts/NetworkPause")
            if pauseGui then
                pauseGui:Destroy()
            end
        end)
        task.wait(1)
    end
end

local function Func_MemoryMonitor()
    local StatsService = game:GetService("Stats")
    
    while Toggles.AutoRejoinMemory.Value do
        local currentMemory = StatsService:GetTotalMemoryUsageMb()
        local limit = Options.MemoryLimit.Value
        
        if currentMemory >= limit then
            Library:Notify(string.format("Memory Limit Reached: %.0fMB. Sending Webhook & Rejoining...", currentMemory), 5)
            
            local url = Options.WebhookURL.Value
            if url and url ~= "" and url:find("discord.com/api/webhooks/") then
                task.spawn(function()
                    pcall(function()
                        local payload = {
                            ["embeds"] = {{
                                ["title"] = "💾 Auto Rejoin",
                                ["description"] = "ROBLOX's memory reached set amount.",
                                ["color"] = 16753920,
                                ["fields"] = {
                                    { ["name"] = "Player", ["value"] = "`" .. Plr.Name .. "`", ["inline"] = true },
                                    { ["name"] = "Usage", ["value"] = string.format("`%.0f MB` / `%.0f MB`", currentMemory, limit), ["inline"] = true },
                                    { ["name"] = "JobId", ["value"] = "```" .. game.JobId .. "```", ["inline"] = false }
                                },
                                ["footer"] = { ["text"] = "sailor hub • " .. os.date("%x %X") }
                            }}
                        }
                        httprequest({ 
                            Url = url, 
                            Method = "POST", 
                            Headers = {["Content-Type"] = "application/json"}, 
                            Body = Http:JSONEncode(payload) 
                        })
                    end)
                end)
            end

            task.wait(3)
            
            if #game:GetService("Players"):GetPlayers() <= 1 then
                Plr:Kick("\n[sailor hub]\nRejoining (" .. math.floor(currentMemory) .. "MB)")
                task.wait(0.5)
                TP:Teleport(game.PlaceId, Plr)
            else
                TP:Teleport(game.PlaceId, Plr)
            end
        end
        
        task.wait(2)
    end
end

local function ApplyFPSBoost(state)
    if not state then return end
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostProcessEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then
                v.Enabled = false
            end
        end
        task.spawn(function()
            for i, v in pairs(workspace:GetDescendants()) do
                if Toggles.FPSBoost and not Toggles.FPSBoost.Value then break end
                pcall(function()
                    if v:IsA("BasePart") then
                        v.Material = Enum.Material.SmoothPlastic
                        v.CastShadow = false
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        v:Destroy()
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then
                        v.Enabled = false
                    end
                end)
                if i % 500 == 0 then task.wait() end
            end
        end)
    end)
end

local function ApplyIslandWipe()
    if not Toggles.FPSBoost_AF.Value then return end

    task.spawn(function()
        local TravelConfig = Modules.Travel
        if not TravelConfig then return end

        -- 1. Pause Farm to prevent conflicts
        local originalFarmState = Status.Main.Farm
        Status.Main.Farm = false
        Status.Main.Target = nil
        
        local char = GetCharacter()
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then Status.Main.Farm = originalFarmState return end

        local protectKeywords = {"SpawnPointCrystal_", "Portal_", "QuestNPC", "NPCs", "ServiceNPCs", "Main Temple"}
        local problemIslands = {
            {Internal = "JudgementIsland", Base = "Judgement"},
            {Internal = "SlimeIsland", Base = "Slime"}
        }

        local function shouldProtect(name)
            for _, kw in ipairs(protectKeywords) do
                if name:find(kw) then return true end
            end
            return false
        end

        local function PerformRecursiveWipe()
            -- Wipe Island Folders
            for _, obj in ipairs(workspace:GetChildren()) do
                local name = obj.Name:lower()
                if name:find("island") or name == "shibuyastation" or name == "huecomundo" then
                    local descendants = obj:GetDescendants()
                    for i = 1, #descendants do
                        local target = descendants[i]
                        if (target:IsA("BasePart") or target:IsA("Model") or target:IsA("MeshPart")) then
                            if not shouldProtect(target.Name) then
                                pcall(function() target:Destroy() end)
                            end
                        end
                    end
                end
            end

            -- Wipe loose parts in Workspace root (Crucial for Judgement/Slime)
            for _, v in ipairs(workspace:GetChildren()) do
                if (v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Model")) and not shouldProtect(v.Name) then
                    if v.Name ~= "Terrain" and v ~= char then 
                        pcall(function() v:Destroy() end) 
                    end
                end
            end
        end

        -- Save position and enable Noclip
        local originalCF = root.CFrame
        local oldNoclip = Toggles.Noclip.Value
        Toggles.Noclip:SetValue(true)

        for _, data in ipairs(problemIslands) do
            local zoneData = TravelConfig.Zones[data.Internal]
            local portal = Tables.IslandCrystals[data.Base]
            local islandFolder = workspace:FindFirstChild(data.Internal)

            if zoneData then
                -- Step A: Teleport to Portal/Crystal first
                if portal then
                    root.CFrame = portal:GetPivot() * CFrame.new(0, 10, 0)
                    task.wait(1.5)
                    PerformRecursiveWipe()
                end

                -- Step B: Teleport to Island Center (Forces full load of ungrouped parts)
                root.CFrame = CFrame.new(zoneData.Center) * CFrame.new(0, 50, 0)
                task.wait(2.5) -- Wait longer for the engine to load the center area

                -- Step C: Enforce cleanup until child count is < 10
                local attempts = 0
                repeat
                    PerformRecursiveWipe()
                    task.wait(1)
                    attempts = attempts + 1
                    
                    local currentChildren = islandFolder and #islandFolder:GetChildren() or 0
                until currentChildren <= 10 or attempts >= 4
            end
        end

        -- Final Root Cleanup while returning
        for _, v in ipairs(workspace:GetChildren()) do
            if (v:IsA("BasePart") or v:IsA("MeshPart")) and not shouldProtect(v.Name) then
                if v.Name ~= "Terrain" then pcall(function() v:Destroy() end) end
            end
        end

        -- Restore player
        root.CFrame = originalCF
        Toggles.Noclip:SetValue(oldNoclip)
        Status.Main.Farm = originalFarmState
    end)
end

local function SendSafetyWebhook(targetPlayer, reason)
    local url = Options.WebhookURL.Value
    if url == "" or not url:find("discord.com/api/webhooks/") then return end

    local payload = {
        ["embeds"] = {{
            ["title"] = "⚠️ Auto Kick",
            ["description"] = "Someone joined you blud",
            ["color"] = 16711680,
            ["fields"] = {
                { ["name"] = "Username", ["value"] = "`" .. targetPlayer.Name .. "`", ["inline"] = true },
                { ["name"] = "Type", ["value"] = reason, ["inline"] = true },
                { ["name"] = "ID", ["value"] = "```" .. game.JobId .. "```", ["inline"] = false }
            },
            ["footer"] = { ["text"] = "sailor hub • " .. os.date("%x %X") }
        }}
    }

    task.spawn(function()
        pcall(function()
            httprequest({ 
                Url = url, 
                Method = "POST", 
                Headers = {["Content-Type"] = "application/json"}, 
                Body = Http:JSONEncode(payload) 
            })
        end)
    end)
end

local function CheckServerTypeSafety()
    if not Toggles.AutoKick.Value then return end
    local kickTypes = Options.SelectedKickType.Value or {}

    if kickTypes["Public Server"] then
        local success, serverType = pcall(function()
            local remote = game:GetService("RobloxReplicatedStorage"):WaitForChild("GetServerType", 2)
            if remote then
                return remote:InvokeServer()
            end
            return "Unknown"
        end)

        if success and serverType ~= "VIPServer" then
            local url = Options.WebhookURL.Value
            if url ~= "" and url:find("discord.com/api/webhooks/") then
                local payload = {
                    ["embeds"] = {{
                        ["title"] = "⚠️ Auto Kick",
                        ["description"] = "Kicked because in Public server.",
                        ["color"] = 16753920,
                        ["fields"] = {
                            { ["name"] = "Username", ["value"] = "`" .. Plr.Name .. "`", ["inline"] = true },
                            { ["name"] = "JobId", ["value"] = "```" .. game.JobId .. "```", ["inline"] = false }
                        },
                        ["footer"] = { ["text"] = "sailor hub" }
                    }}
                }
                task.spawn(function()
                    pcall(function()
                        httprequest({ 
                            Url = url, 
                            Method = "POST", 
                            Headers = {["Content-Type"] = "application/json"}, 
                            Body = Http:JSONEncode(payload) 
                        })
                    end)
                end)
            end

            task.wait(0.8)
            Plr:Kick("\n[sailor hub]\nReason: You are in a public server.")
        end
    end
end

local function CheckPlayerForSafety(targetPlayer)
    if not Toggles.AutoKick.Value then return end
    if targetPlayer == Plr then return end
    
    local kickTypes = Options.SelectedKickType.Value or {}
    
    if kickTypes["Player Join"] then
        SendSafetyWebhook(targetPlayer, "Player Join Detection")
        
        task.wait(0.5) 
        Plr:Kick("\n[sailor hub]\nReason: A player joined the server (" .. targetPlayer.Name .. ")")
        return
    end

    if kickTypes["Mod"] then
        local success, rank = pcall(function() return targetPlayer:GetRankInGroup(Status.Misc.GroupId) end)
        if success and table.find(Status.Misc.Rank, rank) then
            SendSafetyWebhook(targetPlayer, "Moderator Detection (Rank: " .. tostring(rank) .. ")")
            
            task.wait(0.5)
            Plr:Kick("\n[sailor hub]\nReason: Moderator Detected (" .. targetPlayer.Name .. ")")
        end
    end
end

local function ACThing(state)
    if Status.Connections.Dash then Status.Connections.Dash:Disconnect() end
    if not (state and Remotes._DR) then return end

    Status.Connections.Dash = S.RunService.Heartbeat:Connect(function()
        local randDir = vector.create(0, 0, 0)
        local randPower = 0 
        task.spawn(function()
            Remotes._DR:FireServer(randDir, randPower, false)
        end)
    end)
end

local function InitAutoKick()
    CheckServerTypeSafety()

    for _, p in ipairs(Players:GetPlayers()) do
        CheckPlayerForSafety(p)
    end

    Players.PlayerAdded:Connect(CheckPlayerForSafety)
end

local function GetNearestIsland(targetPos, npcName)
    if npcName and Status.Main.BossTIMap[npcName] then
        return Status.Main.BossTIMap[npcName]
    end

    local nearestIsland = "Starter"
    local minDistance = math.huge

    for baseName, crystal in pairs(Tables.IslandCrystals) do
        if crystal then
            local dist = (targetPos - crystal:GetPivot().Position).Magnitude
            if dist < minDistance then
                minDistance = dist
                nearestIsland = baseName
            end
        end
    end
    
    return nearestIsland
end

local function UpdateNPCLists()
    local dropData = Modules.ItemDropConfig.Drops
    local uniqueMobs = {}
    
    for mobKey, _ in pairs(dropData) do
        if mobKey == "Default" then continue end

        local isBoss = mobKey:find("Boss") ~= nil
        local isMiniBoss = table.find(Tables.MiniBossList, mobKey) ~= nil
        
        if isBoss and not isMiniBoss then
            continue
        end

        local cleanName = mobKey:gsub("%d+$", "")
        
        if not uniqueMobs[cleanName] then
            uniqueMobs[cleanName] = true
        end
    end

    table.clear(Tables.MobList)
    for name, _ in pairs(uniqueMobs) do
        table.insert(Tables.MobList, name)
    end
    
    for _, name in ipairs(Tables.MobList) do
        for _, v in pairs(PATH.Mobs:GetChildren()) do
            if v.Name:match("^(.-)%d*$") == name then
                local npcPos = v:GetPivot().Position
                local closestIsland = "Unknown"
                local minDistance = math.huge
                
                for islandName, crystal in pairs(Tables.IslandCrystals) do
                    local dist = (npcPos - crystal:GetPivot().Position).Magnitude
                    if dist < minDistance then
                        minDistance = dist
                        closestIsland = islandName
                    end
                end
                Tables.MobToIsland[name] = closestIsland
                break
            end
        end
    end
    
    table.sort(Tables.MobList)
    Options.SelectedMob:SetValues(Tables.MobList)
end

local function UpdateAllEntities()
    table.clear(Tables.AllEntitiesList)
    local unique = {}
    for _, v in pairs(PATH.Mobs:GetChildren()) do
        local cleanName = v.Name:gsub("%d+$", "") 
        if not unique[cleanName] then
            unique[cleanName] = true
            table.insert(Tables.AllEntitiesList, cleanName)
        end
    end
    table.sort(Tables.AllEntitiesList)
    if Options.SelectedQuestline_DMGTaken then
        Options.SelectedQuestline_DMGTaken:SetValues(Tables.AllEntitiesList)
    end
end

local function PopulateNPCLists()
    for _, child in ipairs(workspace:GetChildren()) do
        if child.Name:match("^QuestNPC%d+$") then
            if not table.find(Tables.NPC_QuestList, child.Name) then
                table.insert(Tables.NPC_QuestList, child.Name)
            end
        end
    end

    for _, child in ipairs(PATH.InteractNPCs:GetChildren()) do
        if child.Name:match("^QuestNPC%d+$") then
            if not table.find(Tables.NPC_QuestList, child.Name) then
                table.insert(Tables.NPC_QuestList, child.Name)
            end
        end
    end

    table.sort(Tables.NPC_QuestList, function(a, b)
        local numA = tonumber(a:match("%d+$")) or 0
        local numB = tonumber(b:match("%d+$")) or 0
        return (numA == numB) and (a < b) or (numA < numB)
    end)

    local interactives = PATH.InteractNPCs:GetChildren()
    for _, v in pairs(interactives) do
        local name = v.Name
        if (name:find("Moveset") or name:find("Buyer")) and not name:find("Observation") then
            table.insert(Tables.NPC_MovesetList, name)
        end
        if (name:find("Mastery") or name:find("Questline") or name:find("Craft"))
        and not (name:find("Grail") or name:find("Slime")) then
            table.insert(Tables.NPC_MasteryList, name)
        end
    end
    table.sort(Tables.NPC_MovesetList)
    table.sort(Tables.NPC_MasteryList)
end

local function GetCurrentPity()
    local pityLabel = PGui:FindFirstChild("BossUI", true) and PGui:FindFirstChild("BossUI", true).MainFrame.BossHPBar.Pity
    if not pityLabel then return 0, 25 end -- Fallback if GUI isn't loaded
    
    -- Strip RichText tags (like <font>) just in case
    local rawText = pityLabel.Text:gsub("<[^>]+>", "")
    local current, max = rawText:match("Pity:%s*(%d+)/(%d+)")
    
    local curVal = tonumber(current) or 0
    local maxVal = tonumber(max) or 25
    
    -- Update your global label if it exists
    if PityLabel then
        PityLabel:SetText(string.format("<b>Pity:</b> %d/%d", curVal, maxVal))
    end
    
    return curVal, maxVal
end

local function IsSmartMatch(npcName, targetMobType)
    local n = npcName:gsub("%d+$", ""):lower()
    local t = targetMobType:lower()
    
    if n == t then return true end
    if t:find(n) == 1 then return true end 
    if n:find(t) == 1 then return true end
    
    return false
end

local function SafeTeleportToNPC(targetName, customMap)
    local character = GetCharacter()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local actualName = customMap and customMap[targetName] or targetName
    
    local target = workspace:FindFirstChild(actualName) or PATH.InteractNPCs:FindFirstChild(actualName)
    if not target then
        for _, v in pairs(PATH.InteractNPCs:GetChildren()) do
            if v.Name:find(actualName) then 
                target = v 
                break 
            end
        end
    end

    if target then
        local npcPivot = target:GetPivot()

        root.CFrame = npcPivot * CFrame.new(0, 3, 0)
        
        root.AssemblyLinearVelocity = Vector3.new(0, 0.01, 0)
        root.AssemblyAngularVelocity = Vector3.zero
    else
        Library:Notify("NPC not found: " .. tostring(actualName), 3)
    end
end

local function Clean(str)
    return str:gsub("%s+", ""):lower()
end

local function GetRealToolName(tool)
    if not tool or not tool:IsA("Tool") then return "" end
    return tool:GetAttribute("_ToolName") or tool.Name
end

local function GetToolTypeFromModule(toolName)
    local cleanedTarget = Clean(toolName)

    for manualName, toolType in pairs(Tables.ManualWeaponClass) do
        if Clean(manualName) == cleanedTarget then
            return toolType
        end
    end

    if Modules.WeaponClass and Modules.WeaponClass.Tools then
        for moduleName, toolType in pairs(Modules.WeaponClass.Tools) do
            if Clean(moduleName) == cleanedTarget then
                return toolType
            end
        end
    end

    if toolName:lower():find("fruit") then
        return "Power"
    end

    return "Melee"
end

local function GetWeaponsByType()
    local available = {}
    local enabledTypes = Options.SelectedWeaponType.Value or {}
    local char = GetCharacter()
    
    local containers = {Plr.Backpack}
    if char then table.insert(containers, char) end

    for _, container in ipairs(containers) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local realName = GetRealToolName(tool)
                local toolType = GetToolTypeFromModule(realName)
                
                if enabledTypes[toolType] then
                    if not table.find(available, realName) then
                        table.insert(available, realName)
                    end
                end
            end
        end
    end
    return available
end

local function UpdateWeaponRotation()
    local weaponList = GetWeaponsByType()
    
    if #weaponList == 0 then 
        Status.Main.ActiveWeap = "" 
        return 
    end

    local switchDelay = Options.SwitchWeaponCD.Value or 4
    if tick() - Status.Main.LastWRSwitch >= switchDelay then
        Status.Main.WeapRotationIdx = Status.Main.WeapRotationIdx + 1
        if Status.Main.WeapRotationIdx > #weaponList then Status.Main.WeapRotationIdx = 1 end
        
        Status.Main.ActiveWeap = weaponList[Status.Main.WeapRotationIdx]
        Status.Main.LastWRSwitch = tick()
    end

    local exists = false
    for _, name in ipairs(weaponList) do
        if name == Status.Main.ActiveWeap then exists = true break end
    end
    
    if not exists then
        Status.Main.ActiveWeap = weaponList[1]
    end
end

local function EquipWeapon()
    UpdateWeaponRotation()
    if Status.Main.ActiveWeap == "" then return end
    
    local char = GetCharacter()
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local alreadyEquipped = false
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") and GetRealToolName(obj) == Status.Main.ActiveWeap then
            alreadyEquipped = true
            break
        end
    end

    if alreadyEquipped then return end 
    
    local targetTool = nil
    for _, tool in ipairs(Plr.Backpack:GetChildren()) do
        if tool:IsA("Tool") and GetRealToolName(tool) == Status.Main.ActiveWeap then
            targetTool = tool
            break
        end
    end

    if targetTool then 
        hum:EquipTool(targetTool) 
    end
end

local function CheckObsHaki()
    local PlayerGui = Plr:FindFirstChild("PlayerGui")
    if PlayerGui then
        local DodgeUI = PlayerGui:FindFirstChild("DodgeCounterUI")
        if DodgeUI and DodgeUI:FindFirstChild("MainFrame") then
            return DodgeUI.MainFrame.Visible
        end
    end
    return false
end

local function CheckArmHaki()
    if Status.Main.ArmHaki == true then 
        return true 
    end

    local char = GetCharacter()
    if char then
        local leftArm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm")
        local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
        
        local hasVisual = (leftArm and leftArm:FindFirstChild("Lightning Strike")) or 
                          (rightArm and rightArm:FindFirstChild("Lightning Strike"))
        
        if hasVisual then
            Status.Main.ArmHaki = true
            return true
        end
    end

    return false
end

local function IsBusy()
    return Plr.Character and Plr.Character:FindFirstChildOfClass("ForceField") ~= nil
end

local function IsSkillReady(key)
    local char = GetCharacter()
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not tool then return true end

    local keyMap = {["Z"] = 1, ["X"] = 2, ["C"] = 3, ["V"] = 4, ["F"] = 5}
    local slotIdx = keyMap[key] or 1

    local newUI = PGui:FindFirstChild("CD Ability UI")
    if newUI and newUI.Enabled then
        local specInfo = newUI:FindFirstChild("SpecInfoFrame")
        if specInfo then
            local skillHolders = {}
            for _, child in pairs(specInfo:GetChildren()) do
                if child.Name == "SkillMainHolder" then
                    table.insert(skillHolders, child)
                end
            end
            
            local holder = skillHolders[slotIdx]
            if holder then
                local skillHolder = holder:FindFirstChild("SkillHolder")
                local skillName = skillHolder and skillHolder:FindFirstChild("SkillName")
                
                if skillName then
                    local statusText = skillName.Text
                    if skillName:GetAttribute("ContentText") then
                        statusText = skillName:GetAttribute("ContentText")
                    end
                    
                    return not statusText:find("Unready")
                end
            end
        end
    end
    local mainFrame = PGui:FindFirstChild("CooldownUI") and PGui.CooldownUI:FindFirstChild("MainFrame")
    if mainFrame then
        local realToolName = GetRealToolName(tool)
        local cleanTool = Clean(realToolName)
        
        for _, frame in pairs(mainFrame:GetChildren()) do
            if not frame:IsA("Frame") then continue end
            local fname = frame.Name:lower()
            if fname:find("cooldown") and (fname:find(cleanTool) or fname:find("skill")) then
                local mapped = "none"
                if fname:find("skill 1") or fname:find("_z") then mapped = "Z"
                elseif fname:find("skill 2") or fname:find("_x") then mapped = "X"
                elseif fname:find("skill 3") or fname:find("_c") then mapped = "C"
                elseif fname:find("skill 4") or fname:find("_v") then mapped = "V"
                elseif fname:find("skill 5") or fname:find("_f") then mapped = "F" end

                if mapped == key then
                    local cdLabel = frame:FindFirstChild("WeaponNameAndCooldown", true)
                    return (cdLabel and cdLabel.Text:find("Ready"))
                end
            end
        end
    end

    return true -- Default to true if no UI found
end

local function GetSecondsFromTimer(text)
    local min, sec = text:match("(%d+):(%d+)")
    if min and sec then
        return (tonumber(min) * 60) + tonumber(sec)
    end
    return nil
end

local function FormatSecondsToTimer(s)
    local minutes = math.floor(s / 60)
    local seconds = s % 60
    return string.format("<b>Refresh:</b> %02d:%02d", minutes, seconds)
end

local function OpenMerchantInterface()
    if Env.IsXeno then
        local npc = workspace:FindFirstChild("ServiceNPCs") and workspace.ServiceNPCs:FindFirstChild("MerchantNPC")
        local prompt = npc and npc:FindFirstChild("HumanoidRootPart") and npc.HumanoidRootPart:FindFirstChild("MerchantPrompt")
        
        if prompt then
            local char = GetCharacter()
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local oldCF = root.CFrame
                
                root.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                task.wait(0.2)
                
                if Env.Support.Proximity then
                    fireproximityprompt(prompt)
                else
                    prompt:InputHoldBegin()
                    task.wait(prompt.HoldDuration + 0.1)
                    prompt:InputHoldEnd()
                end
                
                task.wait(0.5)
                root.CFrame = oldCF
            end
        end
    else
        if firesignal then
            firesignal(Remotes.OpenMerchant.OnClientEvent)
        elseif getconnections then
            for _, v in pairs(getconnections(Remotes.OpenMerchant.OnClientEvent)) do
                if v.Function then task.spawn(v.Function) end
            end
        end
    end
end

local function SyncRaceSettings()
    if not Toggles.AutoRace.Value then return end

    pcall(function()
        local selected = Options.SelectedRace.Value or {}
        local hasEpic = false
        local hasLegendary = false
        
        for name, data in pairs(Modules.Race.Races) do
            local rarity = data.rarity or data.Rarity
            if rarity == "Mythical" then
                local shouldSkip = not selected[name]
                if Status.Main.Settings["SkipRace_" .. name] ~= shouldSkip then
                    Remotes.SettingsToggle:FireServer("SkipRace_" .. name, shouldSkip)
                end
            end
            if selected[name] then
                if rarity == "Epic" then hasEpic = true end
                if rarity == "Legendary" then hasLegendary = true end
            end
        end

        if Status.Main.Settings["SkipEpicReroll"] ~= not hasEpic then
            Remotes.SettingsToggle:FireServer("SkipEpicReroll", not hasEpic)
        end
        if Status.Main.Settings["SkipLegendaryReroll"] ~= not hasLegendary then
            Remotes.SettingsToggle:FireServer("SkipLegendaryReroll", not hasLegendary)
        end
    end)
end

local function SyncClanSettings()
    if not Toggles.AutoClan.Value then return end

    pcall(function()
        local selected = Options.SelectedClan.Value or {}
        local hasEpic = false
        local hasLegendary = false

        for name, data in pairs(Modules.Clan.Clans) do
            local rarity = data.rarity or data.Rarity
            
            if rarity == "Legendary" then
                local shouldSkip = not selected[name]
                if Status.Main.Settings["SkipClan_" .. name] ~= shouldSkip then
                    Remotes.SettingsToggle:FireServer("SkipClan_" .. name, shouldSkip)
                end
            end

            if selected[name] then
                if rarity == "Epic" then hasEpic = true end
                if rarity == "Legendary" then hasLegendary = true end
            end
        end

        if Status.Main.Settings["SkipEpicClan"] ~= not hasEpic then
            Remotes.SettingsToggle:FireServer("SkipEpicClan", not hasEpic)
        end
        if Status.Main.Settings["SkipLegendaryClan"] ~= not hasLegendary then
            Remotes.SettingsToggle:FireServer("SkipLegendaryClan", not hasLegendary)
        end
    end)
end

local function SyncSpecPassiveAutoSkip()
    local skipData = {
        ["Epic"] = true,
        ["Legendary"] = true,
        ["Mythical"] = true
    }
    pcall(function()
        local remote = Remotes.SpecPassiveSkip
        if remote then
            remote:FireServer(skipData)
        end
    end)
end

local function SyncPowerAutoSkip()
    local selected = Options.SelectedPower.Value or {}
    local rarities = { "Epic", "Legendary", "Mythical" }
    local skipData = { ["Epic"] = true, ["Legendary"] = true, ["Mythical"] = true }
    
    local lowestRarityValue = 99
    local rarityMap = { ["Epic"] = 1, ["Legendary"] = 2, ["Mythical"] = 3 }

    for name, enabled in pairs(selected) do
        if enabled then
            local data = Modules.Power.Powers[name]
            local val = rarityMap[data.Rarity] or 0
            if val > 0 and val < lowestRarityValue then lowestRarityValue = val end
        end
    end

    if lowestRarityValue ~= 99 then
        skipData["Epic"] = 1 < lowestRarityValue
        skipData["Legendary"] = 2 < lowestRarityValue
        skipData["Mythical"] = 3 < lowestRarityValue
        Remotes.PowerSkip:FireServer(skipData)
    end
end

local function SyncTraitAutoSkip()
    if not Toggles.AutoTrait.Value then return end

    pcall(function()
    local selected = Options.SelectedTrait.Value or {}
    local rarityHierarchy = { ["Epic"] = 1, ["Legendary"] = 2, ["Mythical"] = 3, ["Secret"] = 4 }
    local lowestTargetValue = 99

    for traitName, enabled in pairs(selected) do
        if enabled then
            local data = Modules.Trait.Traits[traitName]
            if data then
                local val = rarityHierarchy[data.Rarity] or 0
                if val > 0 and val < lowestTargetValue then
                    lowestTargetValue = val
                end
            end
        end
    end

    if lowestTargetValue == 99 then return end

    local skipData = {
        ["Epic"] = 1 < lowestTargetValue,
        ["Legendary"] = 2 < lowestTargetValue,
        ["Mythical"] = 3 < lowestTargetValue,
        ["Secret"] = 4 < lowestTargetValue
    }

    Remotes.TraitAutoSkip:FireServer(skipData)
    end)
end

local function GetMatches(data, subStatFilter)
    local count = 0
    for _, sub in pairs(data.Substats or {}) do
        if subStatFilter[sub.Stat] then
            count = count + 1
        end
    end
    return count
end

local function IsMainStatGood(data, mainStatFilter)
    if data.Category == "Helmet" or data.Category == "Gloves" then return true end
    return mainStatFilter[data.MainStat.Stat] == true
end

local function EvaluateArtifact2(uuid, data)
    local actions = { lock = false, delete = false, upgrade = false }
    
    -- Helper: Returns true if value is in filter. Returns nil if filter is empty.
    local function GetFilterStatus(filter, value)
        if not filter or next(filter) == nil then return nil end
        return filter[value] == true
    end

    -- Helper: Returns true if item is allowed (Whitelist)
    local function IsWhitelisted(filter, value)
        local status = GetFilterStatus(filter, value)
        if status == nil then return true end -- Empty = All allowed
        return status
    end

    -- 1. UPGRADE LOGIC (Whitelist)
    if Toggles.ArtifactUpgrade.Value and data.Level < Options.UpgradeLimit.Value then
        if IsWhitelisted(Options.Up_MS.Value, data.MainStat.Stat) then
            actions.upgrade = true
        end
    end

    -- 2. LOCK LOGIC (Whitelist)
    local lockMinSS = Options.Lock_MinSS.Value
    if Toggles.ArtifactLock.Value and not data.Locked and data.Level >= (lockMinSS * 3) then
        if IsWhitelisted(Options.Lock_MS.Value, data.MainStat.Stat) and
           IsWhitelisted(Options.Lock_Type.Value, data.Category) and
           IsWhitelisted(Options.Lock_Set.Value, data.Set) then
            if GetMatches(data, Options.Lock_SS.Value) >= lockMinSS then
                actions.lock = true
            end
        end
    end

    -- 3. DELETE LOGIC (Strict Intersection Blacklist)
    if not data.Locked and not actions.lock then
        if Toggles.DeleteUnlock.Value then
            actions.delete = true
        elseif Toggles.ArtifactDelete.Value then
            
            local typeMatch = GetFilterStatus(Options.Del_Type.Value, data.Category)
            local setMatch = GetFilterStatus(Options.Del_Set.Value, data.Set)

            -- Check type-specific Main Stat
            local msDropdownName = "Del_MS_" .. data.Category
            local specificMSFilter = Options[msDropdownName] and Options[msDropdownName].Value or {}
            local msMatch = GetFilterStatus(specificMSFilter, data.MainStat.Stat)

            -- DETERMINING IF ITEM IS A TARGET:
            -- Logic: Must match active filters. If a filter is empty (nil), it is ignored.
            local isTarget = true
            
            if typeMatch == false then isTarget = false end
            if setMatch == false then isTarget = false end
            
            -- Safety: If NO filters are selected (nothing to target), target = false
            if typeMatch == nil and setMatch == nil and msMatch == nil then
                isTarget = false
            end

            if isTarget then
                local trashCount = GetMatches(data, Options.Del_SS.Value)
                local minTrash = Options.Del_MinSS.Value
                local isMaxLevel = data.Level >= Options.UpgradeLimit.Value

                -- Scenario A: Blacklisted Main Stat (Delete immediately)
                if msMatch == true then
                    actions.delete = true
                -- Scenario B: The Gamble (Delete if reached max level but failed stats)
                elseif minTrash == 0 then
                    actions.delete = true -- No stat requirement set? Delete target type/set immediately.
                elseif isMaxLevel and trashCount >= minTrash then
                    actions.delete = true
                end
            end
        end
    end

    return actions
end

local function AutoEquipArtifacts()
    if not Toggles.ArtifactEquip.Value then return end
    
    local bestItems = { Helmet = nil, Gloves = nil, Body = nil, Boots = nil }
    local bestScores = { Helmet = -1, Gloves = -1, Body = -1, Boots = -1 }
    
    local targetTypes = Options.Eq_Type.Value or {}
    local targetMS = Options.Eq_MS.Value or {}
    local targetSS = Options.Eq_SS.Value or {}

    for uuid, data in pairs(Status.Main.ArtifactSession.Inventory) do
        if targetTypes[data.Category] and IsMainStatGood(data, targetMS) then
            local score = (GetMatches(data, targetSS) * 10) + data.Level
            
            if score > bestScores[data.Category] then
                bestScores[data.Category] = score
                bestItems[data.Category] = {UUID = uuid, Equipped = data.Equipped}
            end
        end
    end

    for category, item in pairs(bestItems) do
        if item and not item.Equipped then
            Remotes.ArtifactEquip:FireServer(item.UUID)
            task.wait(0.2)
        end
    end
end

local function IsStrictBossMatch(npcName, targetDisplayName)
    local internalId = Status.Main.BossMap[targetDisplayName]
    if not internalId then return false end
    
    local cleanNpcName = npcName:match("^([^_]+)") or npcName
    
    return cleanNpcName == internalId
end

local function AutoUpgradeLoop(mode)
    local toggle = Toggles["Auto"..mode]
    local allToggle = Toggles["Auto"..mode.."All"]
    local remote = (mode == "Enchant") and Remotes.Enchant or Remotes.Blessing
    local sourceTable = (mode == "Enchant") and Tables.OwnedAccessory or Tables.OwnedWeapon

    while toggle.Value or allToggle.Value do
        local selection = Options["Selected"..mode].Value or {}
        local workDone = false
        
        for _, itemName in ipairs(sourceTable) do
            if Status.Main.UpBlacklist[itemName] then continue end

            local isSelected = false
            if allToggle.Value then
                isSelected = true
            else
                isSelected = selection[itemName] or table.find(selection, itemName)
            end

            if isSelected then
                workDone = true
                pcall(function()
                    remote:FireServer(itemName)
                end)

                task.wait(1.5)
                break 
            end
        end

        if not workDone then
            Library:Notify("Stopping..", 5)
            toggle:SetValue(false)
            allToggle:SetValue(false)
            break
        end
        task.wait(0.1)
    end
end

local function FindRemoteDynamic(remoteName)
    local locations = {RS:FindFirstChild("Remotes"), RS:FindFirstChild("RemoteEvents")}
    for _, folder in pairs(locations) do
        if folder then
            local obj = folder:FindFirstChild(remoteName)
            if obj then return obj end
        end
    end
    return nil
end

local function FireBossRemote(bossDisplayName, diff)
    local internalId = Status.Main.BossMap[bossDisplayName] or bossDisplayName
    
    local registryData = BossRemoteRegistry[internalId] or BossRemoteRegistry[bossDisplayName]
    if registryData then
        local args = table.clone(registryData.Args)
        table.insert(args, diff)
        
        registryData.Remote:FireServer(unpack(args))
        return
    end

    local shortId = internalId:gsub("Boss$", "")
    local remoteNameWith = "RequestSpawn" .. internalId
    local remoteNameBoss = "RequestSpawn" .. shortId .. "Boss"
    local remoteNameWithout = "RequestSpawn" .. shortId
    
    if not Status.Cached.BossRemote[internalId] then
        Status.Cached.BossRemote[internalId] = FindRemoteDynamic(remoteNameWith) 
                                            or FindRemoteDynamic(remoteNameBoss) 
                                            or FindRemoteDynamic(remoteNameWithout)
    end

    local foundRemote = Status.Cached.BossRemote[internalId]
    if foundRemote then
        foundRemote:FireServer(diff)
        return
    end

    local summonId = Status.Main.SummonMap[bossDisplayName] or internalId
    Remotes.SummonBoss:FireServer(summonId, diff)
end

local function IsBossAlreadySpawned(displayName)
    local internalId = DisplayToInternal[displayName] or Status.Main.BossMap[displayName]
    if not internalId then return false end

    for _, npc in pairs(PATH.Mobs:GetChildren()) do
        if npc.Name:find(internalId) then
            local hum = npc:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                return true
            end
        end
    end
    return false
end

local function IsSummonable(displayName)
    -- 1. Check if it's a known summonable boss
    if table.find(Tables.SummonList, displayName) then return true end
    
    -- 2. Check your custom list
    if table.find(Tables.OtherSummonList, displayName) then return true end
    
    return false
end

local function HandleSummons()
    if tick() - Status.Main.LastSummon < 2 then return end
    
    if Status.Main.MerchantBusy then return end

    -- 1. Pity Summoning Logic
    if Toggles.PityBossFarm.Value then
        local current, max = GetCurrentPity()
        local buildOptions = Options.SelectedBuildPity and Options.SelectedBuildPity.Value or {}
        local useName = Options.SelectedUsePity and Options.SelectedUsePity.Value 
        
        if useName and next(buildOptions) then
            if current >= (max - 1) then
                local isSpawned = IsBossAlreadySpawned(useName)
                local isSummonable = IsSummonable(useName)
                
                if not isSpawned and isSummonable then
                    FireBossRemote(useName, Options.SelectedPityDiff.Value or "Normal")
                    Status.Main.LastSummon = tick()
                    return 
                end
            else
                -- Logic for normal summon when not at pity
                local anyBuildSpawned = false
                for bossName, enabled in pairs(buildOptions) do
                    if enabled and IsBossAlreadySpawned(bossName) then
                        anyBuildSpawned = true break
                    end
                end

                if not anyBuildSpawned then
                    for bossName, enabled in pairs(buildOptions) do
                        if enabled and IsSummonable(bossName) then
                            FireBossRemote(bossName, "Normal")
                            Status.Main.LastSummon = tick()
                            break
                        end
                    end
                end
            end
        end
    end
    
    -- 2. Consolidated Auto-Summon
    if Toggles.AutoSummon.Value then
        local selected = Options.SelectedSummon.Value
        if selected and not IsBossAlreadySpawned(selected) and IsSummonable(selected) then
            FireBossRemote(selected, Options.SelectedSummonDiff.Value or "Normal")
            Status.Main.LastSummon = tick()
        end
    end
end

local function UpdateSwitchState(target, farmType)
    if Status.Main.GlobalPrio == "COMBO" then return end

    local types = {
        { id = "Title", remote = Remotes.EquipTitle, method = function(val) return val end },
        { id = "Rune", remote = Remotes.EquipRune, method = function(val) return {"Equip", val} end },
        { id = "Build", remote = Remotes.LoadoutLoad, method = function(val) return tonumber(val) end }
    }

    for _, switch in ipairs(types) do
        local toggleObj = Toggles["Auto"..switch.id]
        if not (toggleObj and toggleObj.Value) then continue end

        if switch.id == "Build" and tick() - Status.Main.LastBuildSwitch < 3.1 then 
            continue 
        end

        local toEquip = ""
        local threshold = Options[switch.id.."_BossHPAmt"].Value
        local isLow = false
        
        if farmType == "Boss" and target then
            local hum = target:FindFirstChildOfClass("Humanoid")
            if hum and (hum.Health / hum.MaxHealth) * 100 <= threshold then
                isLow = true
            end
        end

        if farmType == "None" then toEquip = Options["Default"..switch.id].Value
        elseif farmType == "Mob" then toEquip = Options[switch.id.."_Mob"].Value
        elseif farmType == "Boss" then toEquip = isLow and Options[switch.id.."_BossHP"].Value or Options[switch.id.."_Boss"].Value end

        if not toEquip or toEquip == "" or toEquip == "None" then continue end

        local finalEquipValue = toEquip
        if switch.id == "Title" and toEquip:find("Best ") then
                local bestId = GetBestOwnedTitle(toEquip)
                if bestId then finalEquipValue = bestId else continue end
        end

        if finalEquipValue ~= Status.Main.LastSwitch[switch.id] then
            local args = switch.method(finalEquipValue)
            pcall(function()
                if type(args) == "table" then 
                    switch.remote:FireServer(unpack(args))
                else 
                    switch.remote:FireServer(args) 
                end
            end)
            
            Status.Main.LastSwitch[switch.id] = finalEquipValue
            
            if switch.id == "Build" then
                Status.Main.LastBuildSwitch = tick()
            end
        end
    end
end

local function UniversalPuzzleSolver(puzzleType)
    local moduleMap = {
        ["Dungeon"] = RS.Modules:FindFirstChild("DungeonConfig"),
        ["Slime"] = RS.Modules:FindFirstChild("SlimePuzzleConfig"),
        ["Demonite"] = RS.Modules:FindFirstChild("DemoniteCoreQuestConfig"),
        ["Hogyoku"] = RS.Modules:FindFirstChild("HogyokuQuestConfig")
    }
    
    local hogyokuIslands = {"Snow", "Shibuya", "HollowIsland", "Shinjuku", "Slime", "Judgement"}
    local targetModule = moduleMap[puzzleType]
    if not targetModule then return end
    
    local data = require(targetModule)
    local settings = data.PuzzleSettings or data.PieceSettings
    local piecesToCollect = data.Pieces or settings.IslandOrder
    local pieceModelName = settings and settings.PieceModelName or "DungeonPuzzlePiece"
    
    Library:Notify("Starting " .. puzzleType .. " Puzzle...", 5)

    for i, islandOrPiece in ipairs(piecesToCollect) do
        local piece = nil
        local tpTarget = nil
        
    if puzzleType == "Demonite" then 
        tpTarget = "Academy"
    elseif puzzleType == "Hogyoku" then 
        tpTarget = hogyokuIslands[i]
    else
        if islandOrPiece == "HollowIsland" then
            tpTarget = "HollowIsland"
        else
            tpTarget = islandOrPiece:gsub("Island", ""):gsub("Station", "")
        end
    end
        
        if tpTarget then
            Remotes.TP_Portal:FireServer(tpTarget)
            task.wait(1.5)
        end

        if puzzleType == "Slime" and i == #piecesToCollect then
            local char = GetCharacter()
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                Remotes.TP_Portal:FireServer("Shinjuku")
                task.wait(1.5)
                Remotes.TP_Portal:FireServer("Slime")
                task.wait(1.5)
                root.CFrame = CFrame.new(788, 68, -2309)
                task.wait(1.5)
            end
        end

        if puzzleType == "Demonite" or puzzleType == "Hogyoku" then
            piece = workspace:FindFirstChild(islandOrPiece, true)
        else
            local islandFolder = workspace:FindFirstChild(islandOrPiece)
            piece = islandFolder and islandFolder:FindFirstChild(pieceModelName, true) or workspace:FindFirstChild(pieceModelName, true)
        end
        
        if piece then
            local char = Plr.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = piece:GetPivot() * CFrame.new(0, 3, 0)
                root.AssemblyLinearVelocity = Vector3.zero
            end
            
            task.wait(0.5)

            local prompt = piece:FindFirstChildOfClass("ProximityPrompt") 
                or piece:FindFirstChild("PuzzlePrompt", true) 
                or piece:FindFirstChild("ProximityPrompt", true)
            
            if prompt then
                prompt.RequiresLineOfSight = false
                prompt.HoldDuration = 0
                
                fireproximityprompt(prompt)
                
                Library:Notify(string.format("Collected Piece %d/%d", i, #piecesToCollect), 2)
                task.wait(0.25)
            else
                Library:Notify("Found piece but no prompt was detected.", 3)
            end
        else
            Library:Notify("Failed to find piece " .. i .. " on " .. tostring(tpTarget or "Island"), 3)
        end
    end
    Library:Notify(puzzleType .. " Puzzle Completed!", 5)
end

local function GetCurrentQuestUI()
    local holder = PGui.QuestUI.Quest.Quest.Holder.Content
    local info = holder.QuestInfo
    return {
        Title = info.QuestTitle.QuestTitle.Text,
        Description = info.QuestDescription.Text,
        SwitchVisible = holder.QuestSwitchButton.Visible,
        SwitchBtn = holder.QuestSwitchButton,
        IsVisible = PGui.QuestUI.Quest.Visible
    }
end

local function AutoQuestlineLoop()
    while Toggles.AutoQuestline.Value do
        task.wait(0.1)
        
        local selectedId = Options.SelectedQuestline.Value
        if not selectedId then continue end
        
        local questData = Modules.Quests.Questlines[selectedId]
        if not questData then continue end

        local ui = GetCurrentQuestUI()
        local actualNPCName = questData.npcName 

        local isMatchingStage = false
        for _, stage in ipairs(questData.stages) do
            if stage.title == ui.Title then isMatchingStage = true break end
        end

        if not ui.IsVisible or not isMatchingStage then
            if ui.SwitchVisible and not isMatchingStage then
                gsc(ui.SwitchBtn)
                task.wait(1)
                ui = GetCurrentQuestUI()
            end
            if not isMatchingStage then
                Remotes.QuestAccept:FireServer(actualNPCName) 
                task.wait(1.5)
                continue
            end
        end

        local currentStage = nil
        for _, stage in ipairs(questData.stages) do
            if stage.title == ui.Title then currentStage = stage break end
        end

        if currentStage then
            local taskType = currentStage.trackingType
            
            if taskType == "CombatNPCKills" or taskType == "CombatPunches" or taskType == "GroundSmashUses" then
                local character = GetCharacter()
                local hasCombat = Plr.Backpack:FindFirstChild("Combat") or (character and character:FindFirstChild("Combat"))
                
                if not hasCombat then
                    Remotes.EquipWeapon:FireServer("Equip", "Combat")
                    
                    local timeout = 0
                    repeat
                        task.wait(0.2)
                        timeout = timeout + 1
                        hasCombat = Plr.Backpack:FindFirstChild("Combat") or (GetCharacter() and GetCharacter():FindFirstChild("Combat"))
                    until hasCombat or timeout > 15
                end

                Options.SelectedWeaponType:SetValue({["Melee"] = true})
                
                Options.SelectedMob:SetValue({["Thief"] = true})
                Toggles.MobFarm:SetValue(true)

                if taskType == "GroundSmashUses" then
                    Remotes.UseSkill:FireServer(1)
                    task.wait(1)
                elseif taskType == "CombatPunches" then
                    Remotes.M1:FireServer()
                    task.wait(0.2)
                end

            elseif taskType:find("Kills") and taskType ~= "PlayerKills" and not taskType:find("Boss") then
                local mobName = taskType:gsub("Kills", "")
                if mobName == "AnyNPC" then
                    Toggles.LevelFarm:SetValue(true)
                elseif mobName == "HakiNPC" then
                    Toggles.ArmHaki:SetValue(true) 
                    Toggles.LevelFarm:SetValue(true)
                else
                    Options.SelectedMob:SetValue({[mobName] = true})
                    Toggles.MobFarm:SetValue(true)
                end

            elseif taskType == "DamageTaken" then
                local targetName = Options.SelectedQuestline_DMGTaken.Value
                if targetName then
                    local targetEntity = nil
                    for _, v in pairs(PATH.Mobs:GetChildren()) do
                        if v.Name:find(targetName) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            targetEntity = v
                            break
                        end
                    end

                    if targetEntity then
                        local root = GetCharacter().HumanoidRootPart
                        root.CFrame = targetEntity:GetPivot() * CFrame.new(0, 0, 3)
                        root.AssemblyLinearVelocity = Vector3.zero 
                    else
                        local island = Tables.MobToIsland[targetName]
                        if island then Remotes.TP_Portal:FireServer(island) end
                    end
                end

            elseif taskType == "PlayerKills" then
                local targetName = Options.SelectedQuestline_Player.Value
                local targetPlayer = Players:FindFirstChild(targetName)
                
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local tRoot = targetPlayer.Character.HumanoidRootPart
                    local root = GetCharacter().HumanoidRootPart
                    
                    if targetPlayer.Character.Humanoid.Health > 0 then
                        root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
                        EquipWeapon()
                        Remotes.M1:FireServer()
                        Remotes.UseSkill:FireServer(math.random(1, 4))
                    end
                end

            elseif taskType:find("BossKills") or taskType == "AnyBossKills" then
                if taskType == "AnyBossKills" then
                    Toggles.AllBossesFarm:SetValue(true)
                else
                    local bossName = ""
                    local diff = "Normal"
                    for _, d in ipairs(Tables.DiffList) do
                        if taskType:find(d) then 
                            diff = d
                            bossName = taskType:gsub(d, ""):gsub("BossKills", "")
                            break 
                        end
                    end
                    if bossName == "" then bossName = taskType:gsub("BossKills", "") end

                    local lowerB = bossName:lower()
                    if lowerB:find("strongest") then
                        if lowerB:find("history") then bossName = "StrongestHistory"
                        elseif lowerB:find("today") then bossName = "StrongestToday" end
                    end

                    if table.find(Tables.MiniBossList, bossName) then
                        Options.SelectedMob:SetValue({[bossName] = true})
                        Toggles.MobFarm:SetValue(true)
                    else
                        local isRegular = table.find(Tables.SummonList, bossName)
                        local isOther = table.find(Tables.OtherSummonList, bossName)

                        if isRegular then
                            Options.SelectedSummon:SetValue(bossName)
                            Options.SelectedSummonDiff:SetValue(diff)
                            Toggles.AutoSummon:SetValue(true)
                            Toggles.SummonBossFarm:SetValue(true)
                        elseif isOther then
                            Options.SelectedOtherSummon:SetValue(bossName)
                            Options.SelectedOtherSummonDiff:SetValue(diff)
                            Toggles.AutoOtherSummon:SetValue(true)
                            Toggles.OtherSummonFarm:SetValue(true)
                        else
                            Options.SelectedBosses:SetValue({[bossName] = true})
                            Toggles.BossesFarm:SetValue(true)
                        end
                    end
                end

            elseif taskType:find("Piece") or taskType:find("Found") then
                local pType = taskType:find("Dungeon") and "Dungeon" or (taskType:find("Slime") and "Slime" or "Demonite" or "Hogyoku")
                UniversalPuzzleSolver(pType)

            elseif taskType:find("Has") and taskType:find("Race") then
                local race = taskType:gsub("Has", ""):gsub("Race", "")
                if Plr:GetAttribute("CurrentRace") ~= race then
                    Remotes.UseItem:FireServer("Use", "Race Reroll", 1)
                end
            elseif taskType == "MonarchClanCheck" then
                if Plr:GetAttribute("CurrentClan") ~= "Monarch" then
                    Remotes.UseItem:FireServer("Use", "Clan Reroll", 1)
                end
            elseif taskType == "DeemedWorthy" then
                Remotes.UseItem:FireServer("Use", "Worthiness Fragment", 1)
            end
        end
    end
end

local function IsValidTarget(npc)
    if not npc or not npc.Parent then return false end
    local hum = npc:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    if npc:GetAttribute("IK_Active") then
        return true
    end

    local minMaxHP = tonumber(Options.InstaKillMinHP.Value) or 0
    local isEligible = Toggles.InstaKill.Value and hum.MaxHealth >= minMaxHP

    if isEligible then
        return (hum.Health > 0) or (npc == Status.Main.Target)
    else
        return (hum.Health > 0)
    end
end

local function GetBestMobCluster(mobNamesDictionary)
    local allMobs = {}
    local clusterRadius = 35

    if type(mobNamesDictionary) ~= "table" then return nil end

    for _, npc in pairs(PATH.Mobs:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") then
            local cleanName = npc.Name:gsub("%d+$", "")
            if mobNamesDictionary[cleanName] and IsValidTarget(npc) then
                table.insert(allMobs, npc)
            end
        end
    end

    if #allMobs == 0 then return nil end

    local bestMob = allMobs[1]
    local maxNearby = 0

    for _, mobA in ipairs(allMobs) do
        local nearbyCount = 0
        local posA = mobA:GetPivot().Position
        
        for _, mobB in ipairs(allMobs) do
            if (posA - mobB:GetPivot().Position).Magnitude <= clusterRadius then
                nearbyCount = nearbyCount + 1
            end
        end

        if nearbyCount > maxNearby then
            maxNearby = nearbyCount
            bestMob = mobA
        end
    end

    return bestMob, maxNearby
end

local function EnsureQuestSettings()
    local settings = PGui.SettingsUI.MainFrame.Frame.Content.SettingsTabFrame
    
    local tog1 = settings:FindFirstChild("Toggle_EnableQuestRepeat", true)
    if tog1 and tog1.SettingsHolder.Off.Visible then
        Remotes.SettingsToggle:FireServer("EnableQuestRepeat", true)
        task.wait(0.3)
    end

    local tog2 = settings:FindFirstChild("Toggle_AutoQuestRepeat", true)
    if tog2 and tog2.SettingsHolder.Off.Visible then
        Remotes.SettingsToggle:FireServer("AutoQuestRepeat", true)
    end
end

local function GetBestQuestNPC()
    local QuestModule = Modules.Quests
    local playerLevel = Plr.Data.Level.Value
    local bestNPC = "QuestNPC1"
    local highestLevel = -1

    for npcId, questData in pairs(QuestModule.RepeatableQuests) do
        local reqLevel = questData.recommendedLevel or 0
        if playerLevel >= reqLevel and reqLevel > highestLevel then
            highestLevel = reqLevel
            bestNPC = npcId
        end
    end
    return bestNPC
end

local function UpdateQuest()
    if not Toggles.LevelFarm.Value then return end
    
    EnsureQuestSettings()
    local targetNPC = GetBestQuestNPC()
    local questUI = PGui.QuestUI.Quest
    
    if Status.Main.QuestNPC ~= targetNPC or not questUI.Visible then
        
        Remotes.QuestAbandon:FireServer("repeatable")
        
        local abandonTimeout = 0
        while questUI.Visible and abandonTimeout < 15 do
            task.wait(0.2)
            abandonTimeout = abandonTimeout + 1
        end

        Remotes.QuestAccept:FireServer(targetNPC)
        
        local acceptTimeout = 0
        while not questUI.Visible and acceptTimeout < 20 do
            task.wait(0.2)
            acceptTimeout = acceptTimeout + 1
            
            if acceptTimeout % 5 == 0 then
                Remotes.QuestAccept:FireServer(targetNPC)
            end
        end

        if questUI.Visible then
            Status.Main.QuestNPC = targetNPC
        end
    end
end

local function GetPityTarget()
    if not Toggles.PityBossFarm.Value then return nil end
    local current, max = GetCurrentPity()
    local buildBosses = Options.SelectedBuildPity.Value or {}
    local useName = Options.SelectedUsePity.Value
    if not useName then return nil end

    local isUseTurn = (current >= (max - 1))
    
    if isUseTurn then
        for _, npc in pairs(PATH.Mobs:GetChildren()) do
            if IsStrictBossMatch(npc.Name, useName) and IsValidTarget(npc) then
                local island = Status.Main.BossTIMap[useName] or "Boss"
                return npc, island, "Boss"
            end
        end
    else
        for bossName, enabled in pairs(buildBosses) do
            if enabled then
                for _, npc in pairs(PATH.Mobs:GetChildren()) do
                    if IsStrictBossMatch(npc.Name, bossName) and IsValidTarget(npc) then
                        local island = Status.Main.BossTIMap[bossName] or "Boss"
                        return npc, island, "Boss"
                    end
                end
            end
        end
    end
    return nil
end

local function GetAllMobTarget()
    if not Toggles.AllMobFarm.Value then 
        Status.Main.AllMobIdx = 1 
        return nil 
    end

    local rotateList = {}
    for _, mobName in ipairs(Tables.MobList) do
        if mobName ~= "TrainingDummy" then
            table.insert(rotateList, mobName)
        end
    end

    if #rotateList == 0 then return nil end

    if Status.Main.AllMobIdx > #rotateList then Status.Main.AllMobIdx = 1 end
    
    local targetMobName = rotateList[Status.Main.AllMobIdx]
    local target, count = GetBestMobCluster({[targetMobName] = true})

    if target then
        local island = GetNearestIsland(target:GetPivot().Position, target.Name)
        return target, island, "Mob"
    else
        Status.Main.AllMobIdx = Status.Main.AllMobIdx + 1
        if Status.Main.AllMobIdx > #rotateList then Status.Main.AllMobIdx = 1 end
        return nil
    end
end

local function GetLevelFarmTarget()
    if not Toggles.LevelFarm.Value then return nil end
    
    UpdateQuest()
    
    if not PGui.QuestUI.Quest.Visible then return nil end
    
    local questData = Modules.Quests.RepeatableQuests[Status.Main.QuestNPC]
    if not questData or not questData.requirements[1] then return nil end
    
    local targetMobType = questData.requirements[1].npcType
    local matches = {}

    for _, npc in pairs(PATH.Mobs:GetChildren()) do
        if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") then
            if IsSmartMatch(npc.Name, targetMobType) then
                local cleanName = npc.Name:gsub("%d+$", "")
                matches[cleanName] = true
            end
        end
    end

    local bestMob, count = GetBestMobCluster(matches)
    
    if bestMob then
        local island = GetNearestIsland(bestMob:GetPivot().Position, bestMob.Name)
        return bestMob, island, "Mob"
    end
    
    return nil
end

local function GetSummonTarget()
    if not Toggles.SummonBossFarm.Value then return nil end
    local selected = Options.SelectedSummon.Value
    if not selected then return nil end

    local workspaceName = Status.Main.SummonMap[selected] or (selected .. "Boss")

    for _, npc in pairs(PATH.Mobs:GetChildren()) do
        if npc.Name:lower():find(workspaceName:lower()) then
            if IsValidTarget(npc) then
                return npc, "Boss", "Boss"
            end
        end
    end
    return nil
end

local function GetWorldBossTarget()
    if Toggles.AllBossesFarm.Value then
        for _, npc in pairs(PATH.Mobs:GetChildren()) do
            local isBoss = npc.Name:find("Boss") and not table.find(Tables.MiniBossList, npc.Name)
            if isBoss and IsValidTarget(npc) then
                local island = "Boss"
                for dName, iId in pairs(Status.Main.BossMap) do
                    if npc.Name:find(iId) then
                        island = Status.Main.BossTIMap[dName] or "Boss"
                        break
                    end
                end
                return npc, island, "Boss"
            end
        end
    end

    if Toggles.BossesFarm.Value then
        local selected = Options.SelectedBosses.Value or {}
        for bossDisplayName, isEnabled in pairs(selected) do
            if isEnabled then
                local internalId = Status.Main.BossMap[bossDisplayName]
                for _, npc in pairs(PATH.Mobs:GetChildren()) do
                    if npc.Name:find(internalId) and IsValidTarget(npc) then
                        local island = Status.Main.BossTIMap[bossDisplayName] or "Boss"
                        return npc, island, "Boss"
                    end
                end
            end
        end
    end
    return nil
end

local function GetMobTarget()
    if not Toggles.MobFarm.Value then 
        Status.Main.MobIdx = 1 
        return nil 
    end

    local selectedDict = Options.SelectedMob and Options.SelectedMob.Value or {} -- NIL GUARD
    local enabledMobs = {}
    
    for mob, enabled in pairs(selectedDict) do
        if enabled then table.insert(enabledMobs, mob) end
    end
    table.sort(enabledMobs)

    if #enabledMobs == 0 then return nil end

    if Status.Main.MobIdx > #enabledMobs then Status.Main.MobIdx = 1 end
    
    local targetMobName = enabledMobs[Status.Main.MobIdx]
    local target, count = GetBestMobCluster({[targetMobName] = true})

    if target then
        local island = GetNearestIsland(target:GetPivot().Position, target.Name)
        return target, island, "Mob"
    else
        Status.Main.MobIdx = Status.Main.MobIdx + 1
        return nil
    end
end

local function ShouldMainWait()
    if not Toggles.AltBossFarm.Value then return false end
    
    local selectedAlts = {}
    for i = 1, 5 do
        local val = Options["SelectedAlt_" .. i].Value
        local name = (typeof(val) == "Instance" and val:IsA("Player")) and val.Name or tostring(val)
        
        if name and name ~= "" and name ~= "nil" and name ~= "None" then
            table.insert(selectedAlts, name)
        end
    end

    if #selectedAlts == 0 then return false end

    for _, altName in ipairs(selectedAlts) do
        local currentDmg = Status.Main.AltDamage[altName] or 0
        if currentDmg < 10 then
            return true 
        end
    end

    return false 
end

local function GetAltHelpTarget()
    if not Toggles.AltBossFarm.Value then return nil end
    
    local targetBossName = Options.SelectedAltBoss.Value
    if not targetBossName then return nil end

    local targetNPC = nil
    for _, npc in pairs(PATH.Mobs:GetChildren()) do
        if IsStrictBossMatch(npc.Name, targetBossName) then
            if IsValidTarget(npc) then
                targetNPC = npc
                break
            end
        end
    end

    if not targetNPC then
        FireBossRemote(targetBossName, Options.SelectedAltDiff.Value or "Normal")
        task.wait(0.5)
        return nil
    end

    Status.Main.AltActive = ShouldMainWait()
    
    local island = Status.Main.BossTIMap[targetBossName] or "Boss"
    return targetNPC, island, "Boss"
end

local function CheckTask(taskType)
    if taskType == "Merchant" then
        if Toggles.AutoMerchant.Value and Status.Main.MerchantBusy then
            return true, nil, "None"
        end
        return nil
    elseif taskType == "Pity Boss" then
        return GetPityTarget()
    elseif taskType == "Summon" then
        return GetSummonTarget()
    elseif taskType == "Boss" then
        return GetWorldBossTarget()
    elseif taskType == "Level Farm" then
        return GetLevelFarmTarget()
    elseif taskType == "All Mob Farm" then
        return GetAllMobTarget()
    elseif taskType == "Mob" then
        return GetMobTarget()
    elseif taskType == "Alt Help" then
        return GetAltHelpTarget()
    end
    return nil
end

local function GetNearestAuraTarget()
    local nearest = nil
    local maxRange = tonumber(Options.KillAuraRange.Value) or 200
    local lastDist = maxRange
    
    local char = Plr.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local myPos = root.Position
    local mobFolder = workspace:FindFirstChild("NPCs")
    if not mobFolder then return nil end

    for _, v in ipairs(mobFolder:GetChildren()) do
        if v:IsA("Model") then
            local npcPos = v:GetPivot().Position
            local dist = (myPos - npcPos).Magnitude
            
            if dist <= lastDist then
                local hum = v:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    nearest = v
                    lastDist = dist
                end
            end
        end
    end
    return nearest
end

local function Func_KillAura()
    while Toggles.KillAura.Value do
        if IsBusy() then 
            task.wait(0.1) 
            continue 
        end

        local target = GetNearestAuraTarget()
        
        if target then
            EquipWeapon()
            
            local targetPos = target:GetPivot().Position
            
            pcall(function()
                Remotes.M1:FireServer(targetPos)
            end)
        end
        
        task.wait(tonumber(Options.KillAuraCD.Value) or 0.12)
    end
end

local function ExecuteFarmLogic(target, island, farmType)
    local char = GetCharacter()
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not target or Status.Main.Recovering or not root or not hum then return end

    if Status.Main.MovingIsland then return end
    Status.Main.Target = target

    if Toggles.IslandTP.Value then
        if island and island ~= "" and island ~= Status.Main.Island then
            Status.Main.MovingIsland = true
            
            Remotes.TP_Portal:FireServer(island)
            
            task.wait(tonumber(Options.IslandTPCD.Value) or 0.8)
            Status.Main.Island = island
            Status.Main.MovingIsland = false
            return
        end
    end

    local targetPivot = target:GetPivot()
    local targetPos = targetPivot.Position
    local distVal = tonumber(Options.Distance.Value) or 10
    local posType = Options.SelectedFarmType.Value
    
    local finalPos

    if Status.Main.AltActive then
        finalPos = targetPos + Vector3.new(0, 120, 0)
    elseif posType == "Above" then
        finalPos = targetPos + Vector3.new(0, distVal, 0)
    elseif posType == "Below" then
        finalPos = targetPos + Vector3.new(0, -distVal, 0)
    else
        finalPos = (targetPivot * CFrame.new(0, 0, distVal)).Position
    end

    local finalDestination = CFrame.lookAt(finalPos, targetPos)

    if (root.Position - finalPos).Magnitude > 0.1 then
        if Options.SelectedMovementType.Value == "Teleport" then
    root.CFrame = finalDestination
    else
    if (root.Position - finalPos).Magnitude > 2 then
        local distance = (root.Position - finalPos).Magnitude
        local speed = tonumber(Options.TweenSpeed.Value) or 180
        
        if Status.Cached.activeTween then Status.Cached.activeTween:Cancel() end
        
        Status.Cached.activeTween = Tween:Create(root, TweenInfo.new(distance/speed, Enum.EasingStyle.Linear), {CFrame = finalDestination})
        Status.Cached.activeTween:Play()
        
        Status.Cached.activeTween.Completed:Connect(function()
            if Status.Cached.activeTween then
                Status.Cached.activeTween:Destroy()
                Status.Cached.activeTween = nil
            end
        end)
    else
        if Status.Cached.activeTween then Status.Cached.activeTween:Cancel() end
        root.CFrame = finalDestination
    end
end
end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

local function Func_WebhookLoop()
    while Toggles.SendWebhook.Value do
        PostToWebhook()
        local delay = math.max(Options.WebhookDelay.Value, 0.5) * 60
        task.wait(delay)
    end
end

local function Func_AutoHaki()
    while task.wait(0.5) do
        if Toggles.ObserHaki.Value and not CheckObsHaki() then
            Remotes.ObserHaki:FireServer("Toggle")
        end

        if Toggles.ArmHaki.Value and not CheckArmHaki() then
            Remotes.ArmHaki:FireServer("Toggle")
            task.wait(0.5) 
        end

        if Toggles.ConquerorHaki.Value then
            if Toggles.OnlyTarget.Value then
                if not Status.Main.Farm or not Status.Main.Target or not Status.Main.Target.Parent then
                    continue
                end
            end

            Remotes.ConquerorHaki:FireServer("Activate")
        end
    end
end

local function Func_AutoM1()
    while task.wait(Options.M1Speed.Value) do
        if Toggles.AutoM1.Value then
        Remotes.M1:FireServer()
        end
    end
end

local function Func_AutoSkill()
    local keyToEnum = { ["Z"] = Enum.KeyCode.Z, ["X"] = Enum.KeyCode.X, ["C"] = Enum.KeyCode.C, ["V"] = Enum.KeyCode.V, ["F"] = Enum.KeyCode.F }
    local keyToSlot = { ["Z"] = 1, ["X"] = 2, ["C"] = 3, ["V"] = 4, ["F"] = 5 }
    local priority = {"Z", "X", "C", "V", "F"}

    while task.wait() do
        if not Toggles.AutoSkill.Value then continue end

        local target = Status.Main.Target
        if Toggles.OnlyTarget.Value and (not Status.Main.Farm or not target or not target.Parent) then
            continue
        end

        local canExecute = true
        if Toggles.AutoSkill_BossOnly.Value then
            if not target or not target.Parent then
                canExecute = false
            else
                local npcHum = target:FindFirstChildOfClass("Humanoid")
                local isRealBoss = target.Name:find("Boss") and not table.find(Tables.MiniBossList, target.Name)
                local hpPercent = npcHum and (npcHum.Health / npcHum.MaxHealth * 100) or 101
                local threshold = tonumber(Options.AutoSkill_BossHP.Value) or 100

                if not isRealBoss or hpPercent > threshold then
                    canExecute = false
                end
            end
        end

        if canExecute and target and target.Parent then
            if target:FindFirstChild("IK_Active") and Options.InstaKillType.Value == "V1" then
                canExecute = false
            end
        end

        if not canExecute then continue end

        local char = GetCharacter()
        local tool = char and char:FindFirstChildOfClass("Tool")
        if not tool then continue end

        local toolName = tool.Name
        local toolType = GetToolTypeFromModule(toolName)
        local useMode = Options.AutoSkillType.Value
        local selected = Options.SelectedSkills.Value or {}

        if useMode == "Instant" then
            for _, key in ipairs(priority) do
                if selected[key] then
                    if toolType == "Power" then
                        Remotes.UseFruit:FireServer("UseAbility", {
                            ["FruitPower"] = toolName:gsub(" Fruit", ""), 
                            ["KeyCode"] = keyToEnum[key]
                        })
                    else
                        Remotes.UseSkill:FireServer(keyToSlot[key])
                    end
                end
            end
            task.wait(.01)
        else
            local mainFrame = PGui:FindFirstChild("CooldownUI") and PGui.CooldownUI:FindFirstChild("MainFrame")
            if not mainFrame then continue end

            for _, key in ipairs(priority) do
                if selected[key] then
                    if IsSkillReady(key) then
                        if toolType == "Power" then
                            Remotes.UseFruit:FireServer("UseAbility", {
                                ["FruitPower"] = toolName:gsub(" Fruit", ""), 
                                ["KeyCode"] = keyToEnum[key]
                            })
                        else
                            Remotes.UseSkill:FireServer(keyToSlot[key])
                        end
                        task.wait(0.1)
                        break
                    end
                end
            end
        end
    end
end

local function Func_AutoCombo()
    Status.Main.ComboIdx = 1
    
    while Toggles.AutoCombo.Value do
        task.wait(0.1)
        
        local rawPattern = Options.ComboPattern.Value
        if not rawPattern or rawPattern == "" then continue end
        Status.Main.ParsedCombo = {}
        for item in string.gmatch(rawPattern:upper():gsub("%s+", ""), "([^,>]+)") do
            table.insert(Status.Main.ParsedCombo, item)
        end
        if #Status.Main.ParsedCombo == 0 then continue end
        if Status.Main.ComboIdx > #Status.Main.ParsedCombo then Status.Main.ComboIdx = 1 end

        if IsBusy() then
            local waitStart = tick()
            repeat task.wait(0.1) until not IsBusy() or (tick() - waitStart > 8)
        end
        task.wait(0.4) 

        if Toggles.ComboBossOnly.Value then
            if not Status.Main.Target or not Status.Main.Target.Parent or not Status.Main.Target.Name:lower():find("boss") then
                Status.Main.ComboIdx = 1
                task.wait(0.5)
                continue
            end
        end

        local currentAction = Status.Main.ParsedCombo[Status.Main.ComboIdx]
        
        local waitTime = tonumber(currentAction)
        if waitTime then
            if Options.ComboMode.Value == "Normal" then task.wait(waitTime) end
            Status.Main.ComboIdx = Status.Main.ComboIdx + 1
            continue
        end

        if IsSkillReady(currentAction) then
            local isF = (currentAction == "F")

            if isF then
                Status.Main.GlobalPrio = "COMBO" 
                
                local cTitle = Options.Title_Combo.Value
                local cRune = Options.Rune_Combo.Value
                if cTitle and cTitle ~= "None" then Remotes.EquipTitle:FireServer(cTitle) end
                if cRune and cRune ~= "None" then Remotes.EquipRune:FireServer("Equip", cRune) end
                
                Status.Main.LastSwitch.Title = cTitle
                Status.Main.LastSwitch.Rune = cRune
                task.wait(0.7) 

                local uiConfirmed = false
                repeat
                    EquipWeapon()
                    Remotes.UseSkill:FireServer(5)
                    local check = tick()
                    repeat
                        task.wait(0.1)
                        if not IsSkillReady("F") then uiConfirmed = true end
                    until uiConfirmed or (tick() - check > 1.0)
                until uiConfirmed or not Toggles.AutoCombo.Value

                local ffStarted = false
                local catchTimer = tick()
                repeat
                    task.wait()
                    if IsBusy() then ffStarted = true end
                until ffStarted or (tick() - catchTimer > 2.0)

                if ffStarted then
                    local holdStart = tick()
                    repeat task.wait(0.1) until not IsBusy() or (tick() - holdStart > 15)
                else
                    task.wait(2.5) 
                end

                Status.Main.GlobalPrio = "FARM" 
                Status.Main.LastSwitch.Title = "" 
                Status.Main.LastSwitch.Rune = ""
                Status.Main.ComboIdx = Status.Main.ComboIdx + 1
                task.wait(0.3)

            else
                local slot = ({["Z"]=1, ["X"]=2, ["C"]=3, ["V"]=4})[currentAction] or 1
                
                local stepDone = false
                repeat
                    Remotes.UseSkill:FireServer(slot)
                    local check = tick()
                    repeat
                        task.wait(0.1)
                        if not IsSkillReady(currentAction) or IsBusy() then stepDone = true end
                    until stepDone or (tick() - check > 1.2)
                until stepDone or not Toggles.AutoCombo.Value

                if stepDone then
                    Status.Main.ComboIdx = Status.Main.ComboIdx + 1
                    task.wait(0.2)
                end
            end
        else
            task.wait(0.2)
        end
    end
end

local function Func_AutoStats()
    local pointsPath = Plr:WaitForChild("Data"):WaitForChild("StatPoints")

    while task.wait(1) do
        if not Toggles.AutoStats.Value then break end
        
        local availablePoints = pointsPath.Value
        if availablePoints > 0 then
            local selectedStats = Options.SelectedStats.Value or {}
            local activeStats = {}
            
            for statName, enabled in pairs(selectedStats) do
                if enabled then
                    local currentLevel = Status.Main.Stats[statName] or 0
                    
                    local statConfig = Modules.LevelingConfig.STATS[statName]
                    local maxPoints = statConfig and statConfig.maxPoints or 13000
                    
                    if currentLevel < maxPoints then
                        table.insert(activeStats, statName)
                    end
                end
            end
            
            local statCount = #activeStats
            if statCount > 0 then
                local pointsPerStat = math.floor(availablePoints / statCount)
                
                if pointsPerStat > 0 then
                    for _, stat in ipairs(activeStats) do
                        Remotes.AddStat:FireServer(stat, pointsPerStat)
                    end
                else
                    Remotes.AddStat:FireServer(activeStats[1], availablePoints)
                end
            end
        end
    end
end

local function AutoRollStatsLoop()
    local selectedStats = Options.SelectedGemStats.Value or {}
    local selectedRanks = Options.SelectedRank.Value or {}
    
    local hasStat = false; for _ in pairs(selectedStats) do hasStat = true break end
    local hasRank = false; for _ in pairs(selectedRanks) do hasRank = true break end

    if not hasStat or not hasRank then
        Library:Notify("Error: Select at least one Stat and one Rank first!", 5)
        Toggles.AutoRollStats:SetValue(false)
        return
    end

    while Toggles.AutoRollStats.Value do
        if not next(Status.Main.GemStats) then
            task.wait(0.1)
            continue
        end

        local workDone = true
        
        for _, statName in ipairs(Tables.GemStat) do
            if selectedStats[statName] then
                local currentData = Status.Main.GemStats[statName]
                
                if currentData then
                    local currentRank = currentData.Rank
                    
                    if not selectedRanks[currentRank] then
                        workDone = false
                        
                        local success, err = pcall(function()
                            Remotes.RerollSingleStat:InvokeServer(statName)
                        end)
                        
                        if not success then
                            Library:Notify("ERROR: " .. tostring(err):gsub("<", "["), 5)
                        end
                        
                        task.wait(tonumber(Options.StatsRollCD.Value) or 0.1)
                        
                        break 
                    end
                end
            end
        end

        if workDone then
            Library:Notify("Successfully rolled selected stats.", 5)
            Toggles.AutoRollStats:SetValue(false)
            break
        end
        
        task.wait()
    end
end

local function Func_UnifiedRollManager()
    while task.wait() do
        -- Priority 1: Traits
        if Toggles.AutoTrait.Value then
            local traitUI = PGui:WaitForChild("TraitRerollUI").MainFrame.Frame.Content.TraitPage.TraitGottenFrame.Holder.Trait.TraitGotten
            local confirmFrame = PGui.TraitRerollUI.MainFrame.Frame.Content:FindFirstChild("AreYouSureYouWantToRerollFrame")
            local currentTrait = traitUI.Text
            local selected = Options.SelectedTrait.Value or {}

            if selected[currentTrait] then
                Library:Notify("Success! Got Trait: " .. currentTrait, 5)
                Toggles.AutoTrait:SetValue(false)
            else
                pcall(SyncTraitAutoSkip)
                if confirmFrame and confirmFrame.Visible then
                    Remotes.TraitConfirm:FireServer(true)
                    task.wait(0.1)
                end
                Remotes.Roll_Trait:FireServer()
                task.wait(Options.RollCD.Value)
            end
            continue -- Jump to next loop cycle to ensure 1-by-1
        end

        -- Priority 2: Race
        if Toggles.AutoRace.Value then
            local currentRace = Plr:GetAttribute("CurrentRace")
            local selected = Options.SelectedRace.Value or {}

            if selected[currentRace] then
                Library:Notify("Success! Got Race: " .. currentRace, 5)
                Toggles.AutoRace:SetValue(false)
            else
                pcall(SyncRaceSettings)
                Remotes.UseItem:FireServer("Use", "Race Reroll", 1)
                task.wait(Options.RollCD.Value)
            end
            continue
        end

        -- Priority 3: Clan
        if Toggles.AutoClan.Value then
            local currentClan = Plr:GetAttribute("CurrentClan")
            local selected = Options.SelectedClan.Value or {}

            if selected[currentClan] then
                Library:Notify("Success! Got Clan: " .. currentClan, 5)
                Toggles.AutoClan:SetValue(false)
            else
                pcall(SyncClanSettings)
                Remotes.UseItem:FireServer("Use", "Clan Reroll", 1)
                task.wait(Options.RollCD.Value)
            end
            continue
        end

        -- If nothing is enabled, wait a bit longer to save CPU
        task.wait(0.4)
    end
end

local function EnsureRollManager()
    Thread("UnifiedRollManager", Func_UnifiedRollManager, 
        Toggles.AutoTrait.Value or Toggles.AutoRace.Value or Toggles.AutoClan.Value
    )
end

local function AutoSpecPassiveLoop()
    pcall(SyncSpecPassiveAutoSkip)
    task.wait(Options.SpecRollCD.Value)

    while Toggles.AutoSpec.Value do
        local targetWeapons = Options.SelectedPassive.Value or {}
        local targetPassives = Options.SelectedSpec.Value or {}
        local workDone = false

        if type(Status.Main.Passives) ~= "table" then Status.Main.Passives = {} end

        for weaponName, isWeaponEnabled in pairs(targetWeapons) do
            if not isWeaponEnabled then continue end

            local currentData = Status.Main.Passives[weaponName] 
            
            local currentName = "None"
            local currentBuffs = {}
            
            if type(currentData) == "table" then
                currentName = currentData.Name or "None"
                currentBuffs = currentData.RolledBuffs or {}
            elseif type(currentData) == "string" then
                currentName = currentData
            end

            local isCorrectName = targetPassives[currentName]
            local meetsAllStats = true

            if isCorrectName then
                if type(currentBuffs) == "table" then
                    for statKey, rolledValue in pairs(currentBuffs) do
                        local sliderId = "Min_" .. currentName:gsub("%s+", "") .. "_" .. statKey
                        local minRequired = Options[sliderId] and Options[sliderId].Value or 0
                        
                        if tonumber(rolledValue) and rolledValue < minRequired then
                            meetsAllStats = false
                            break
                        end
                    end
                end
            else
                meetsAllStats = false
            end

            if not isCorrectName or not meetsAllStats then
                workDone = true
                Remotes.SpecPassiveReroll:FireServer(weaponName)
                
                local startWait = tick()
                repeat 
                    task.wait()
                    local checkData = Status.Main.Passives[weaponName]
                    local checkName = (type(checkData) == "table" and checkData.Name) or (type(checkData) == "string" and checkData) or ""
                until (checkName ~= currentName) or (tick() - startWait > 1.5)
                break 
            end
        end

        if not workDone then
            Library:Notify("Done", 5)
            Toggles.AutoSpec:SetValue(false)
            break
        end
        task.wait()
    end
end

local function AutoPowerLoop()
    while Toggles.AutoPower.Value do
        local targets = Options.SelectedPower.Value or {}
        local cur = Status.Main.CurrentPower
        
        local isTargetName = targets[cur.Name]
        local statsSatisfied = true

        if isTargetName then
            -- Check Regular Buffs
            for statKey, val in pairs(cur.Buffs) do
                local sliderId = "MinPower_" .. cur.Name:gsub("%s+", "") .. "_" .. statKey
                if Options[sliderId] and val < Options[sliderId].Value then
                    statsSatisfied = false break
                end
            end
            
            -- Check Mythical Buffs
            if statsSatisfied then
                local mythStatKey = (cur.Name == "Cursebrand" and "DebuffPercent") or (cur.Name == "Colossus" and "BossDamagePercent")
                if mythStatKey then
                    local sliderId = "MinPower_" .. cur.Name .. "_" .. mythStatKey
                    if Options[sliderId] and cur.MythicalBuff < Options[sliderId].Value then
                        statsSatisfied = false
                    end
                end
            end
        else
            statsSatisfied = false
        end

        if not statsSatisfied then
            SyncPowerAutoSkip()
            Remotes.PowerRoll:FireServer()
            task.wait(Options.RollCD.Value + 0.1)
        else
            Library:Notify("Got: " .. cur.Name, 5)
            Toggles.AutoPower:SetValue(false)
            break
        end
        task.wait()
    end
end

local function AutoSkillTreeLoop()
    while Toggles.AutoSkillTree.Value do
        task.wait(0.5) 
        
        if not next(Status.Main.SkillTree.Nodes) and Status.Main.SkillTree.SkillPoints == 0 then
            continue
        end

        local points = Status.Main.SkillTree.SkillPoints
        if points <= 0 then continue end

        for _, branch in pairs(Modules.SkillTree.Branches) do
            for _, node in ipairs(branch.Nodes) do
                local nodeId = node.Id
                local cost = node.Cost

                if not Status.Main.SkillTree.Nodes[nodeId] then
                    if points >= cost then
                        local success, err = pcall(function()
                            Remotes.SkillTreeUpgrade:FireServer(nodeId)
                        end)
                        
                        if success then
                            Status.Main.SkillTree.SkillPoints = Status.Main.SkillTree.SkillPoints - cost
                            task.wait(0.3)
                        end
                    end
                    
                    break 
                end
            end
        end
    end
end

local function Func_ArtifactMilestone()
    local currentMilestone = 1
    while Toggles.ArtifactMilestone.Value do
        Remotes.ArtifactClaim:FireServer(currentMilestone)
        
        currentMilestone = currentMilestone + 1
        if currentMilestone > 40 then currentMilestone = 1 end
        
        task.wait(1)
    end
end

local function Func_AutoDungeon()
    while Toggles.AutoDungeon.Value do
        task.wait(1)
        
        local selected = Options.SelectedDungeon.Value
        if not selected then continue end

        if PGui.DungeonPortalJoinUI.LeaveButton.Visible then
            continue
        end

        local targetIsland = "Dungeon"
        if selected == "BossRush" then
            targetIsland = "Sailor"
        end

        if tick() - Status.Main.LastDungeon > 15 then
            Remotes.OpenDungeon:FireServer(tostring(selected))
            Status.Main.LastDungeon = tick()
            task.wait(1)
            Remotes.StartDungeon:FireServer()
        end

        if not PGui.DungeonPortalJoinUI.LeaveButton.Visible then
            local portal = workspace:FindFirstChild("ActiveDungeonPortal")

            if not portal then
                if Status.Main.Island ~= targetIsland then
                    Remotes.TP_Portal:FireServer(targetIsland)
                    Status.Main.Island = targetIsland
                    task.wait(2.5)
                end
            else
                local root = GetCharacter():FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = portal.CFrame
                    task.wait(0.2)
                    
                    local prompt = portal:FindFirstChild("JoinPrompt")
                    if prompt then
                        fireproximityprompt(prompt)
                        task.wait(1)
                    end
                end
            end
        end
    end
end

local function Func_AutoMerchant()
    local MerchantUI = UI.Merchant.Regular
    local Holder = MerchantUI:FindFirstChild("Holder", true)
    local LastTimerText = ""

    local function StartPurchaseSequence()
        if Status.Main.MerchantExecute then return end
        Status.Main.MerchantExecute = true
        
        if Status.Main.FirstMerchantSync then
            MerchantUI.Enabled = true
            MerchantUI.MainFrame.Visible = true
            task.wait(0.5)
            
            local closeBtn = MerchantUI:FindFirstChild("CloseButton", true)
            if closeBtn then
                gsc(closeBtn)
                task.wait(1.8) 
            end
        end

        OpenMerchantInterface() 
        task.wait(2) 

        local itemsWithStock = {}
        for _, child in pairs(Holder:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "Item" then
                local stockLabel = child:FindFirstChild("StockAmountForThatItem", true)
                local currentStock = 0
                if stockLabel then
                    currentStock = tonumber(stockLabel.Text:match("%d+")) or 0
                end
                
                Status.Main.CurrentStock[child.Name] = currentStock
                if currentStock > 0 then
                    table.insert(itemsWithStock, {Name = child.Name, Stock = currentStock})
                end
            end
        end

        if #itemsWithStock > 0 then
            local selectedItems = Options.SelectedMerchantItems.Value
            for _, item in ipairs(itemsWithStock) do
                if selectedItems[item.Name] then
                    pcall(function()
                        Remotes.MerchantBuy:InvokeServer(item.Name, 99)
                    end)
                    task.wait(math.random(11, 17) / 10)
                end
            end
        end

        if MerchantUI.MainFrame then MerchantUI.MainFrame.Visible = false end
        Status.Main.FirstMerchantSync = true
        Status.Main.MerchantExecute = false
    end

    local function SyncClock()
        OpenMerchantInterface()
        task.wait(1)
        
        local Label = MerchantUI and MerchantUI:FindFirstChild("RefreshTimerLabel", true)
        if Label and Label.Text:find(":") then
            local serverSecs = GetSecondsFromTimer(Label.Text)
            if serverSecs then Status.Main.LocalMerchantTime = serverSecs end
        end
        if MerchantUI.MainFrame then MerchantUI.MainFrame.Visible = false end
    end

    SyncClock()

    while Toggles.AutoMerchant.Value do
        local Label = MerchantUI:FindFirstChild("RefreshTimerLabel", true)
        
        if Label and Label.Text ~= "" then
            local currentText = Label.Text
            local s = GetSecondsFromTimer(currentText)
            if s then
                Status.Main.LocalMerchantTime = s
                if currentText ~= LastTimerText then
                    LastTimerText = currentText
                    Status.Main.LastTimerTick = tick()
                end
            else
                Status.Main.LocalMerchantTime = math.max(0, Status.Main.LocalMerchantTime - 1)
            end
        else
            Status.Main.LocalMerchantTime = math.max(0, Status.Main.LocalMerchantTime - 1)
        end

        local isRefresh = (Status.Main.LocalMerchantTime <= 1) or (Status.Main.LocalMerchantTime >= 1799)
        if not Status.Main.FirstMerchantSync or isRefresh then
            task.spawn(StartPurchaseSequence)
        end

        if tick() - Status.Main.LastTimerTick > 30 then
            task.spawn(SyncClock)
            Status.Main.LastTimerTick = tick()
        end

        if MerchantTimerLabel then
            MerchantTimerLabel:SetText(FormatSecondsToTimer(Status.Main.LocalMerchantTime))
        end

        task.wait(1)
    end
end

local function Func_AutoTrade()
    local function GetInvQty(name)
        for _, item in pairs(Status.Cached.Inv or {}) do
            if item.name == name then return item.quantity end
        end
        return 0
    end

    local function IsAlreadyInTrade(name)
        if not Status.Main.TradeState.myItems then return false end
        for _, tradeItem in pairs(Status.Main.TradeState.myItems) do
            if tradeItem.name == name then return true end
        end
        return false
    end

    while task.wait(0.5) do
        local inTradeUI = PGui:FindFirstChild("InTradingUI") and PGui.InTradingUI.MainFrame.Visible
        local requestUI = PGui:FindFirstChild("TradeRequestUI") and PGui.TradeRequestUI.TradeRequest.Visible
        
        if Toggles.ReqTradeAccept.Value and requestUI then
            Remotes.TradeRespond:FireServer(true)
            task.wait(1)
        end

    if Toggles.ReqTrade.Value and not inTradeUI and not requestUI then
        local rawName = Options.SelectedTradePlr.Value
        if rawName and rawName ~= "" then
            local target = GetPlayerByName(rawName)
            
            if target and target ~= Plr then
                Library:Notify("Trading with: " .. target.Name, 2)
                
                Remotes.TradeSend:FireServer(target.UserId)
                task.wait(3)
            end
        end
    end

        if inTradeUI and Toggles.AutoAccept.Value then
            local selection = Options.SelectedTradeItems.Value or {}
            local itemsToProcess = {}

            for name, enabled in pairs(selection) do
                if enabled then
                    if TradePresets[name] then
                        for itemName, amount in pairs(TradePresets[name]) do
                            itemsToProcess[itemName] = amount
                        end
                    else
                        itemsToProcess[name] = GetInvQty(name)
                    end
                end
            end

            -- Step 2: Add items to trade
            local addedAny = false
            for itemName, amountNeeded in pairs(itemsToProcess) do
                if not IsAlreadyInTrade(itemName) then
                    local available = GetInvQty(itemName)
                    if available > 0 then
                        local finalAmount = math.min(available, amountNeeded)
                        Remotes.TradeAddItem:FireServer("Items", itemName, finalAmount)
                        addedAny = true
                        task.wait(0.3)
                    end
                end
            end

            if not addedAny then
                if not Status.Main.TradeState.myReady then
                    Remotes.TradeReady:FireServer(true)
                elseif Status.Main.TradeState.myReady and Status.Main.TradeState.theirReady then
                    if Status.Main.TradeState.phase == "confirming" and not Status.Main.TradeState.myConfirm then
                        Remotes.TradeConfirm:FireServer()
                    end
                end
            end
        end
    end
end

local function Func_AutoChest()
    while task.wait(2) do
        if not Toggles.AutoChest.Value then break end

        local selected = Options.SelectedChests.Value
        if type(selected) ~= "table" then continue end

        for _, rarityName in ipairs(Tables.Rarities or {}) do
            if selected[rarityName] == true then
                local fullName = (rarityName == "Aura Crate") and "Aura Crate" or (rarityName .. " Chest")

                pcall(function()
                    Remotes.UseItem:FireServer("Use", fullName, 10000)
                end)

                task.wait(1)
            end
        end
    end
end

local function Func_AutoCraft()
    while task.wait(1) do
        if Toggles.AutoCraftItem.Value then
            local selected = Options.SelectedCraftItems.Value
            
            for _, item in pairs(Status.Cached.Inv) do
                if selected["DivineGrail"] and item.name == "Broken Sword" and item.quantity >= 3 then
                    local totalPossible = math.floor(item.quantity / 3)
                    local craftAmount = math.min(totalPossible, 99)
                    
                    pcall(function()
                        Remotes.GrailCraft:InvokeServer("DivineGrail", craftAmount)
                    end)
                    task.wait(0.5)
                end
                
                if selected["SlimeKey"] and item.name == "Slime Shard" and item.quantity >= 2 then
                    local totalPossible = math.floor(item.quantity / 2)
                    local craftAmount = math.min(totalPossible, 99)
                    
                    pcall(function()
                        Remotes.SlimeCraft:InvokeServer("SlimeKey", craftAmount)
                    end)
                end
            end
        end
        
        if not Toggles.AutoCraftItem.Value then break end
    end
end

local function Func_ArtifactAutomation()
    while task.wait(5) do
        -- If inventory is empty, force a sync and wait
        if not Status.Main.ArtifactSession.Inventory or not next(Status.Main.ArtifactSession.Inventory) then 
            Remotes.ArtifactUnequip:FireServer("")
            task.wait(2)
            continue
        end

        local lockQueue = {}
        local deleteQueue = {}
        local upgradeQueue = {}

        for uuid, data in pairs(Status.Main.ArtifactSession.Inventory) do
            local res = EvaluateArtifact2(uuid, data)
            if res.lock then table.insert(lockQueue, uuid) end
            if res.delete then table.insert(deleteQueue, uuid) end
            if res.upgrade then
                local targetLvl = Options.UpgradeLimit.Value
                if Toggles.UpgradeStage.Value then
                    targetLvl = math.min(math.floor(data.Level / 3) * 3 + 3, Options.UpgradeLimit.Value)
                end
                table.insert(upgradeQueue, {["UUID"] = uuid, ["Levels"] = targetLvl})
            end
        end

        -- Processing
        for _, uuid in ipairs(lockQueue) do
            Remotes.ArtifactLock:FireServer(uuid, true)
            task.wait(0.1)
        end

        if #deleteQueue > 0 then
            -- Chunks of 50 to prevent remote lag
            for i = 1, #deleteQueue, 50 do
                local chunk = {}
                for j = i, math.min(i + 49, #deleteQueue) do table.insert(chunk, deleteQueue[j]) end
                Remotes.MassDelete:FireServer(chunk)
                task.wait(0.6)
            end
            -- Request sync after a mass delete to refresh Shared table
            Remotes.ArtifactUnequip:FireServer("")
        end

        if #upgradeQueue > 0 then
            for i = 1, #upgradeQueue, 50 do
                local chunk = {}
                for j = i, math.min(i + 49, #upgradeQueue) do table.insert(chunk, upgradeQueue[j]) end
                Remotes.MassUpgrade:FireServer(chunk)
                task.wait(0.6)
            end
        end

        if Toggles.ArtifactEquip.Value then AutoEquipArtifacts() end
    end
end

local Window = Library:CreateWindow({
	Title = "sailor hub",
	Footer = "" .. Env.GameName .. " | ".. Env.Version,
	NotifySide = "Right",
    Icon = tostring(theChosenOne),
	ShowCustomCursor = false,
	AutoShow = true,
	Center = true,
    Font = Enum.Font.RobotoMono,

    EnableSidebarResize = true,
    SidebarCompacted = true,
})

if not Env.IsDelta then
    Window:SetCornerRadius(16)
end

local Tabs = {
    Information = Window:AddTab("Information", "info"),
    Priority = Window:AddTab("Priority", "arrow-up-down"),
	Main = Window:AddTab("Main", "box"),
    Automation = Window:AddTab("Automation", "repeat-2"),
    Artifact = Window:AddTab("Artifact", "martini"),
    Dungeon = Window:AddTab("Dungeon", "door-open"),
    Player = Window:AddTab("Player", "user"),
    Teleport = Window:AddTab("Teleport", "map-pin"),
    Webhook = Window:AddTab("Webhook", "send"),
    Misc = Window:AddTab("Misc", "apple"),
    Config = Window:AddTab("Config", "cog"),
}

local GB = {}

if Env.IsDelta then
    GB = {
        Information = {
            Left = {
                User = Tabs.Information:AddLeftGroupbox("User", "user"),
                Game = Tabs.Information:AddLeftGroupbox("Game", "gamepad"),
            },
            Right = {
                Others = Tabs.Information:AddRightGroupbox("Others", "boxes"),
            },
        },
        Priority = {
            Left = {
                Config = Tabs.Priority:AddLeftGroupbox("Config", "wrench"),
            },
        },
        Artifact = {
            Left = {
                Status = Tabs.Artifact:AddLeftGroupbox("Status", "info"),
                Equip = Tabs.Artifact:AddLeftGroupbox("Auto-Equip", "kayak"),
                Upgrade = Tabs.Artifact:AddLeftGroupbox("Upgrade", "hammer"),
            },
            Right = {
                Lock = Tabs.Artifact:AddRightGroupbox("Lock", "lock"),
                Delete = Tabs.Artifact:AddRightGroupbox("Delete", "trash"),
            },
        },
        Player = {
            Left = {
                General = Tabs.Player:AddLeftGroupbox("General", "user-cog"),
                Server = Tabs.Player:AddLeftGroupbox("Server", "server"),
            },
            Right = {
                Game = Tabs.Player:AddRightGroupbox("Game", "earth"),
                Safety = Tabs.Player:AddRightGroupbox("Safety", "shield"),
            },
        },
        Webhook = {
            Left = {
                Config = Tabs.Webhook:AddLeftGroupbox("Config", "wrench"),
            },
        }
    }
else
    GB = {
        Information = {
            Left = {
                User = Tabs.Information:AddLeftGroupbox("User", "user", true),
                Game = Tabs.Information:AddLeftGroupbox("Game", "gamepad", true),
            },
            Right = {
                Others = Tabs.Information:AddRightGroupbox("Others", "boxes", true),
            },
        },
        Priority = {
            Left = {
                Config = Tabs.Priority:AddLeftGroupbox("Config", "wrench", true),
            },
        },
        Artifact = {
            Left = {
                Status = Tabs.Artifact:AddLeftGroupbox("Status", "info", true),
                Equip = Tabs.Artifact:AddLeftGroupbox("Auto-Equip", "kayak", true),
                Upgrade = Tabs.Artifact:AddLeftGroupbox("Upgrade", "hammer", true),
            },
            Right = {
                Lock = Tabs.Artifact:AddRightGroupbox("Lock", "lock", true),
                Delete = Tabs.Artifact:AddRightGroupbox("Delete", "trash", true),
            },
        },
        Player = {
            Left = {
                General = Tabs.Player:AddLeftGroupbox("General", "user-cog", true),
                Server = Tabs.Player:AddLeftGroupbox("Server", "server", true),
            },
            Right = {
                Game = Tabs.Player:AddRightGroupbox("Game", "earth", true),
                Safety = Tabs.Player:AddRightGroupbox("Safety", "shield", true),
            },
        },
        Webhook = {
            Left = {
                Config = Tabs.Webhook:AddLeftGroupbox("Config", "wrench", true),
            },
        }
    }
end

local TB = {
    Main = {
        Left = {
            Autofarm = Tabs.Main:AddLeftTabbox(),
            MiscAuto = Tabs.Main:AddLeftTabbox(),
        },
        Right = {
            Switch = Tabs.Main:AddRightTabbox(),
            MiscAuto = Tabs.Main.AddRightTabbox(),
        },
    },
    Automation = {
        Left = {
            Misc1 = Tabs.Automation:AddLeftTabbox(),
            Stats1 = Tabs.Automation:AddLeftTabbox(),
            Merchant = Tabs.Automation:AddLeftTabbox(),
        },
        Right = {
            Enchant = Tabs.Automation:AddRightTabbox(),
            Misc1 = Tabs.Automation:AddRightTabbox(),
        },
    },
    Teleport = {
        Left = {
            Waypoint = Tabs.Teleport:AddLeftTabbox(),
        },
        Right = {
            NPCs = Tabs.Teleport:AddRightTabbox(),
        },
    },
    Dungeon = {
        Left = {
            Autojoin = Tabs.Dungeon:AddLeftTabbox(),
        },
        Right = {

        },
    },
    Misc = {
        Left = {
--            Merchant = Tabs.Misc:AddLeftTabbox(),
        },
        Right = {
            Quests = Tabs.Misc:AddRightTabbox(),
        },
    },
}

local TB_Tabs = {
    Autofarm = {
        T1 = TB.Main.Left.Autofarm:AddTab("Autofarm"),
        T2 = TB.Main.Left.Autofarm:AddTab("Boss"),
        T3 = TB.Main.Left.Autofarm:AddTab("Misc"),
        T4 = TB.Main.Left.Autofarm:AddTab("Config"),
    },
    MiscAuto = {
        T1 = TB.Main.Left.MiscAuto:AddTab("Haki"),
        T2 = TB.Main.Left.MiscAuto:AddTab("Skill"),
        T3 = TB.Main.Left.MiscAuto:AddTab("Combo"),
    },
    Switch = {
        T1 = TB.Main.Right.Switch:AddTab("Title"),
        T2 = TB.Main.Right.Switch:AddTab("Rune"),
        T3 = TB.Main.Right.Switch:AddTab("Build"),
    },
    MiscAuto_Left = {
        T1 = TB.Automation.Left.Misc1:AddTab("Ascend"),
        T2 = TB.Automation.Left.Misc1:AddTab("Rolls"),
        T3 = TB.Automation.Left.Misc1:AddTab("Trade"),
        T4 = TB.Automation.Left.Misc1:AddTab("Config"),
    },
    Stats1 = {
        T1 = TB.Automation.Left.Stats1:AddTab("Level"),
        T2 = TB.Automation.Left.Stats1:AddTab("Gem"),
        T3 = TB.Automation.Left.Stats1:AddTab("Misc"),
    },
    Enchant = {
        T1 = TB.Automation.Right.Enchant:AddTab("Enchant"),
        T2 = TB.Automation.Right.Enchant:AddTab("Passive"),
        T3 = TB.Automation.Right.Enchant:AddTab("Config"),
    },
    Dungeon = {
        T1 = TB.Dungeon.Left.Autojoin:AddTab("Autojoin"),
        T2 = TB.Dungeon.Left.Autojoin:AddTab("Config"),
    },
    Waypoint = {
        T1 = TB.Teleport.Left.Waypoint:AddTab("Island"),
        T2 = TB.Teleport.Left.Waypoint:AddTab("Quest"),
        T3 = TB.Teleport.Left.Waypoint:AddTab("Misc"),
    },
    NPCs = {
        T1 = TB.Teleport.Right.NPCs:AddTab("Moveset"),
        T2 = TB.Teleport.Right.NPCs:AddTab("Mastery"),
    },
    Merchant = {
        T1 = TB.Automation.Left.Merchant:AddTab("Merchant"),
        T2 = TB.Automation.Left.Merchant:AddTab("Dungeon"),
        T3 = TB.Automation.Left.Merchant:AddTab("Valentine"),
    },
    Misc1 = {
        T1 = TB.Automation.Right.Misc1:AddTab("Chests"),
        T2 = TB.Automation.Right.Misc1:AddTab("Craft"),
    },
    Puzzle = {
        T1 = TB.Misc.Right.Quests:AddTab("Puzzles"),
        T2 = TB.Misc.Right.Quests:AddTab("Questlines"),
    },
}

local statusText = Env.IsBadExec and "<font color='#FFA500'>Semi-Working</font>" or "<font color='#00FF00'>Working</font>"
local extraNote = Env.IsBadExec and "<b>NOTE:</b> May experience bugs for some features!" or "All features should work properly!"

GB.Information.Left.User:AddLabel("<b>Executor:</b> " .. Env.Executor .. "\n<b>Status:</b> " .. statusText .. "\n" .. extraNote, true)

GB.Information.Left.Game:AddButton("Redeem All Codes", function()
    local allCodes = Modules.Codes.Codes
    local playerLevel = StartStats.Level
    
    for codeName, data in pairs(allCodes) do
        local levelReq = data.LevelReq or 0
        if playerLevel >= levelReq then
            Library:Notify("Attempting to redeem code: " .. codeName, 5)
            Remotes.UseCode:InvokeServer(codeName)
            task.wait(2)
        else
            Library:Notify(string.format("Not enough requirement for: %s (Req. Lvl %d)", codeName, levelReq), 4)
        end
    end
end)

GB.Information.Right.Others:AddLabel("- ⚠️ If some features are disabled, it is because your executor lacks the required functions.", true)

for i = 1, #Status.Priority.Task do
    GB.Priority.Left.Config:AddDropdown("SelectedPriority_" .. i, {
        Text = "Priority " .. i,
        Values = Status.Priority.Task,
        Default = Status.Priority.Default[i],
        Multi = false,
        AllowNull = true,
        Searchable = true,
    })
end

GB.Webhook.Left.Config:AddInput("WebhookURL", {
	Default = "",
	Numeric = false,
	Finished = false,
	ClearTextOnFocus = true,
	Text = "Webhook URL",
	Placeholder = "Enter Webhook URL...",
})

GB.Webhook.Left.Config:AddInput("UID", {
	Default = "",
	Numeric = false,
	Finished = false,
	ClearTextOnFocus = true,
	Text = "User ID",
	Placeholder = "Enter UID...",
})

GB.Webhook.Left.Config:AddDropdown("SelectedData", {
    Text = "Select Data (s)",
    Values = {"Name", "Stats", "New Items", "All Items"},
    Default = nil,
    Multi = true,
    Searchable = true,
})

GB.Webhook.Left.Config:AddDropdown("SelectedItemRarity", {
    Text = "Select Rarity To Send",
    Values = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret"},
    Default = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret"},
    Multi = true,
    Searchable = true,
})

GB.Webhook.Left.Config:AddToggle("PingUser", {
    Text = "Ping User",
    Default = false,
})

GB.Webhook.Left.Config:AddToggle("SendWebhook", {
    Text = "Send Webhook",
    Default = false,
    Disabled = not Env.Support.Webhook,
})

GB.Webhook.Left.Config:AddSlider("WebhookDelay", {
    Text = "Send every [x] minutes",
    Default = 5,
    Min = 1,
    Max = 300,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

GB.Webhook.Left.Config:AddButton("Test Webhook", function()
    PostToWebhook()
end)

TB_Tabs.Autofarm.T1:AddDropdown("SelectedMob", {
    Text = "Select Mob (s)",
    Values = Tables.MobList,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Autofarm.T1:AddToggle("MobFarm", {
    Text = "Autofarm Selected Mob",
    Default = false,
})

TB_Tabs.Autofarm.T1:AddToggle("AllMobFarm", {
    Text = "Autofarm All Mobs",
    Default = false,
})

TB_Tabs.Autofarm.T1:AddDropdown("AllMobType", {
    Text = "Select Type [All Mob]",
    Values = {"Normal", "Fast"},
    Default = "Normal",
    Multi = false,
    Searchable = true,
})

TB_Tabs.Autofarm.T1:AddToggle("LevelFarm", {
    Text = "Autofarm Level",
    Default = false,
})

TB_Tabs.Autofarm.T2:AddDropdown("SelectedBosses", {
    Text = "Select Bosses",
    Values = Tables.BossList,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Autofarm.T2:AddToggle("BossesFarm", {
    Text = "Autofarm Selected Boss",
    Default = false,
})

TB_Tabs.Autofarm.T2:AddToggle("AllBossesFarm", {
    Text = "Autofarm All Bosses",
    Default = false,
})

TB_Tabs.Autofarm.T2:AddDivider()

TB_Tabs.Autofarm.T2:AddDropdown("SelectedSummon", {
    Text = "Select Boss to Auto-Summon",
    Values = Tables.FullSummon,
    Default = nil,
    Multi = false,
    Searchable = true,
})

TB_Tabs.Autofarm.T2:AddDropdown("SelectedSummonDiff", {
    Text = "Summon Difficulty",
    Values = Tables.DiffList,
    Default = "Normal",
    Multi = false,
})

TB_Tabs.Autofarm.T2:AddToggle("AutoSummon", {
    Text = "Enable Auto Summon",
    Default = false,
})

TB_Tabs.Autofarm.T2:AddToggle("SummonBossFarm", {
    Text = "Autofarm Summon Boss",
    Default = false,
})

TB_Tabs.Autofarm.T2:AddDivider()

PityLabel = TB_Tabs.Autofarm.T2:AddLabel("<b>Pity:</b> 0/25")

TB_Tabs.Autofarm.T2:AddDropdown("SelectedBuildPity", {
    Text = "Select Boss [Build Pity]",
    Values = Tables.AllBossList,
    Default = nil,
    Multi = true,
    AllowNull = true,
    Searchable = true,
})

TB_Tabs.Autofarm.T2:AddDropdown("SelectedUsePity", {
    Text = "Select Boss [Use Pity]",
    Values = Tables.AllBossList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
})

TB_Tabs.Autofarm.T2:AddDropdown("SelectedPityDiff", {
    Text = "Select Difficulty [Use Pity]",
    Values = Tables.DiffList,
    Default = nil,
    Multi = false,
    Searchable = true,
})

TB_Tabs.Autofarm.T2:AddToggle("PityBossFarm", {
    Text = "Autofarm Pity Boss",
    Default = false,
})

TB_Tabs.Autofarm.T3:AddDropdown("SelectedAltBoss", {
    Text = "Select Boss",
    Values = Tables.AllBossList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
})

TB_Tabs.Autofarm.T3:AddDropdown("SelectedAltDiff", {
    Text = "Select Difficulty",
    Values = Tables.DiffList,
    Default = nil,
    Multi = false,
    Searchable = true,
})

for i = 1, 5 do
    TB_Tabs.Autofarm.T3:AddDropdown("SelectedAlt_" .. i, {
        Text = "Select Alt #" .. i,
        SpecialType = "Player",
        ExcludeLocalPlayer = true,
        Default = nil,
        Multi = false,
        AllowNull = true,
        Searchable = true,
    })
end

TB_Tabs.Autofarm.T3:AddToggle("AltBossFarm", {
    Text = "Auto Help Alt",
    Default = false,
})

TB_Tabs.Autofarm.T4:AddDropdown("SelectedWeaponType", {
    Text = "Select Weapon Type",
    Values = Tables.Weapon,
    Default = nil,
    Multi = true,
})

TB_Tabs.Autofarm.T4:AddSlider("SwitchWeaponCD", {
    Text = "Switch Weapon Delay",
    Default = 4,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T4:AddToggle("IslandTP", {
    Text = "Island TP [Autofarm]",
    Default = true,
})

TB_Tabs.Autofarm.T4:AddSlider("IslandTPCD", {
    Text = "Island TP CD",
    Default = 0.67,
    Min = 0,
    Max = 2.5,
    Rounding = 2,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T4:AddSlider("TargetTPCD", {
    Text = "Target TP CD",
    Default = 0,
    Min = 0,
    Max = 5,
    Rounding = 2,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T4:AddSlider("TargetDistTP", {
    Text = "Target Distance TP [Tween]",
    Default = 0,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T4:AddSlider("M1Speed", {
    Text = "M1 Attack Cooldown",
    Default = 0.2,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T4:AddDropdown("SelectedMovementType", {
    Text = "Select Movement Type",
    Values = {"Teleport", "Tween"},
    Default = "Tween",
    Multi = false,
    Searchable = true,
})

TB_Tabs.Autofarm.T4:AddDropdown("SelectedFarmType", {
    Text = "Select Farm Type",
    Values = {"Behind", "Above", "Below"},
    Default = "Behind",
    Multi = false,
    Searchable = true,
})

TB_Tabs.Autofarm.T4:AddSlider("Distance", {
    Text = "Farm Distance",
    Default = 12,
    Min = 0,
    Max = 200,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T4:AddSlider("TweenSpeed", {
    Text = "Tween Speed",
    Default = 160,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T4:AddToggle("InstaKill", {
    Text = "Instant Kill",
    Default = false,
})

TB_Tabs.Autofarm.T4:AddDropdown("InstaKillType", {
    Text = "Select Type",
    Values = {"V1", "V2"},
    Default = "V1",
    Multi = false,
    Searchable = true,
})

TB_Tabs.Autofarm.T4:AddSlider("InstaKillHP", {
    Text = "HP% For Insta-Kill",
    Default = 90,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Autofarm.T4:AddInput("InstaKillMinHP", {
    Text = "Min MaxHP for Insta-Kill",
    Default = "100000",
    Numeric = true,
    Finished = true,
    Placeholder = "Number..",
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.MiscAuto.T1:AddToggle("ObserHaki", {
    Text = "Auto Observation Haki",
    Default = false,
})

TB_Tabs.MiscAuto.T1:AddToggle("ArmHaki", {
    Text = "Auto Armament Haki",
    Default = false,
})

TB_Tabs.MiscAuto.T1:AddToggle("ConquerorHaki", {
    Text = "Auto Conqueror Haki",
    Default = false,
})

TB_Tabs.MiscAuto.T2:AddLabel("Autofarm already has <b>auto-M1 built in</b>.\nYou do not need to enable this separately unless you have <b>any issues with the autofarm M1.</b>", true)

TB_Tabs.MiscAuto.T2:AddToggle("AutoM1", {
    Text = "Auto Attack",
    Default = false,
})

TB_Tabs.MiscAuto.T2:AddToggle("KillAura", {
    Text = "Kill Aura",
    Default = false,
})

TB_Tabs.MiscAuto.T2:AddSlider("KillAuraCD", {
    Text = "CD",
    Default = 0.1,
    Min = 0.1,
    Max = 1,
    Rounding = 2,
})

TB_Tabs.MiscAuto.T2:AddSlider("KillAuraRange", {
    Text = "Range",
    Default = 200,
    Min = 0,
    Max = 200,
    Rounding = 0,
})

TB_Tabs.MiscAuto.T2:AddLabel("Mode:\n- <b>Normal:</b> Check skill cooldowns\n- <b>Instant:</b> No check (may affect performance when use in long time.)", true)

TB_Tabs.MiscAuto.T2:AddDropdown("SelectedSkills", {
    Text = "Select Skills",
    Values = {"Z", "X", "C", "V", "F"},
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.MiscAuto.T2:AddDropdown("AutoSkillType", {
    Text = "Select Mode",
    Values = {"Normal", "Instant"},
    Default = "Normal",
    Multi = false,
    Searchable = true,
})

TB_Tabs.MiscAuto.T2:AddToggle("OnlyTarget", {
    Text = "Target Only",
    Default = false,
})

TB_Tabs.MiscAuto.T2:AddToggle("AutoSkill_BossOnly", {
    Text = "Use On Boss Only",
    Default = false,
})

TB_Tabs.MiscAuto.T2:AddSlider("AutoSkill_BossHP", {
    Text = "Boss HP%",
    Default = 100,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.MiscAuto.T2:AddToggle("AutoSkill", {
    Text = "Auto Use Skills",
    Default = false,
})

TB_Tabs.MiscAuto.T3:AddLabel("Example:\n- Z > X > C > 0.5 > V\n- Z, X, C, 0.5, V", true)
TB_Tabs.MiscAuto.T3:AddLabel("Mode:\n- Normal: Wait for input CD (ex: Z > 0.5)\n- Instant: Ignore input CD", true)

TB_Tabs.MiscAuto.T3:AddInput("ComboPattern", {
    Text = "Combo Pattern",
    Default = "Z > X > C > V > F",
    Placeholder = "combo..",
})

TB_Tabs.MiscAuto.T3:AddDropdown("ComboMode", {
    Text = "Select Mode",
    Values = {"Normal", "Instant"},
    Default = "Normal",
})

TB_Tabs.MiscAuto.T3:AddToggle("ComboBossOnly", {
    Text = "Boss Only",
    Default = false,
})

TB_Tabs.MiscAuto.T3:AddToggle("AutoCombo", {
    Text = "Auto Skill Combo",
    Default = false,
    Callback = function(state)
        if state and Toggles.AutoSkill.Value then
            Toggles.AutoSkill:SetValue(false)
            Library:Notify("NOTICE: Auto Skill disabled for this to works properly.", 3)
        end
    end
})

CreateSwitchGroup(TB_Tabs.Switch.T1, "Title", "Title", CombinedTitleList)
CreateSwitchGroup(TB_Tabs.Switch.T2, "Rune", "Rune", Tables.RuneList)
CreateSwitchGroup(TB_Tabs.Switch.T3, "Build", "Build", Tables.BuildList)

TB_Tabs.MiscAuto_Left.T1:AddToggle("AutoAscend", {
    Text = "Auto Ascend",
    Default = false,
})

for i = 1, 10 do
    Tables.AscendLabels[i] = TB_Tabs.MiscAuto_Left.T1:AddLabel("", true)
    Tables.AscendLabels[i]:SetVisible(false)
end

TB_Tabs.MiscAuto_Left.T2:AddLabel("- ⚠️ Increase delay based on your ping/internet speed.\n- ⚠️ Low delay settings are not recommended.", true)

TB_Tabs.MiscAuto_Left.T2:AddSlider("RollCD", {
    Text = "Roll Delay",
    Default = 0.3,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.MiscAuto_Left.T2:AddDropdown("SelectedTrait", {
    Text = "Select Trait (s)",
    Values = Tables.TraitList,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.MiscAuto_Left.T2:AddToggle("AutoTrait", {
    Text = "Auto Roll Trait",
    Default = false,
})

TB_Tabs.MiscAuto_Left.T2:AddDropdown("SelectedRace", {
    Text = "Select Race (s)",
    Values = Tables.RaceList,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.MiscAuto_Left.T2:AddToggle("AutoRace", {
    Text = "Auto Roll Race",
    Default = false,
})

TB_Tabs.MiscAuto_Left.T2:AddDropdown("SelectedClan", {
    Text = "Select Clan (s)",
    Values = Tables.ClanList,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.MiscAuto_Left.T2:AddToggle("AutoClan", {
    Text = "Auto Roll Clan",
    Default = false,
})

PowerLabel = TB_Tabs.MiscAuto_Left.T2:AddLabel("Current: N/A", true)

TB_Tabs.MiscAuto_Left.T2:AddDropdown("SelectedPower", {
    Text = "Select Power (s)",
    Values = Tables.Power,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.MiscAuto_Left.T2:AddToggle("AutoPower", {
    Text = "Auto Roll Power",
    Default = false,
})

local function UpdatePowerSliders()
    local selected = Options.SelectedPower.Value or {}
    for _, slider in pairs(Status.Main.PowerSliders) do slider:SetVisible(false) end

    for name, isSelected in pairs(selected) do
        if isSelected then
            local data = Modules.Power.Powers[name]
            if data and data.Buffs then
                -- 1. Regular Buffs
                for statKey, range in pairs(data.Buffs) do
                    local id = "MinPower_" .. name:gsub("%s+", "") .. "_" .. statKey
                    local label = string.format("%s [%s]", name, statKey:gsub("Percent", "%%"))
                    
                    if not Options[id] then
                        Status.Main.PowerSliders[id] = TB_Tabs.MiscAuto_Left.T4:AddSlider(id, {
                            Text = label, Default = range[1], Min = range[1], Max = range[2],
                            Rounding = 1, Compact = true
                        })
                    else
                        Status.Main.PowerSliders[id]:SetVisible(true)
                    end
                end
                -- 2. Mythical Config Buffs
                if data.MythicalConfig then
                    for statKey, range in pairs(data.MythicalConfig) do
                        if type(range) == "table" then
                            local id = "MinPower_" .. name .. "_" .. statKey
                            local label = string.format("%s [%s]", name, statKey:gsub("Percent", "%%"))
                            if not Options[id] then
                                Status.Main.PowerSliders[id] = TB_Tabs.MiscAuto_Left.T4:AddSlider(id, {
                                    Text = label, Default = range[1], Min = range[1], Max = range[2],
                                    Rounding = 1, Compact = true
                                })
                            else
                                Status.Main.PowerSliders[id]:SetVisible(true)
                            end
                        end
                    end
                end
            end
        end
    end
end

TB_Tabs.MiscAuto_Left.T3:AddInput("SelectedTradePlr", {
	Default = nil,
	Numeric = false,
	Finished = false,
	ClearTextOnFocus = true,
	Text = "Type Player Name",
	Placeholder = "@username...",
})

TB_Tabs.MiscAuto_Left.T3:AddDropdown("SelectedTradeItems", {
    Text = "Select Item (s)",
    Values = Tables.OwnedItem,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.MiscAuto_Left.T3:AddToggle("ReqTrade", {
    Text = "Auto Send Request",
    Default = false,
})

TB_Tabs.MiscAuto_Left.T3:AddToggle("ReqTradeAccept", {
    Text = "Auto Accept Request",
    Default = false,
})

TB_Tabs.MiscAuto_Left.T3:AddToggle("AutoAccept", {
    Text = "Auto Accept Trade",
    Default = false,
})

TB_Tabs.Stats1.T1:AddDropdown("SelectedStats", {
    Text = "Select Stat (s)",
    Values = {"Melee", "Defense", "Sword", "Power"},
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Stats1.T1:AddToggle("AutoStats", {
    Text = "Auto UP Stats",
    Default = false,
})

TB_Tabs.Stats1.T2:AddLabel("- ⚠️ Increase delay based on your ping/internet speed.\n- ⚠️ Low delay settings are not recommended.\n- Reroll once for this to work.", true)

StatsLabel = TB_Tabs.Stats1.T2:AddLabel("N/A", true)

TB_Tabs.Stats1.T2:AddDropdown("SelectedGemStats", {
    Text = "Select Stat (s)",
    Values = Tables.GemStat,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Stats1.T2:AddDropdown("SelectedRank", {
    Text = "Select Rank (s)",
    Values = Tables.GemRank,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Stats1.T2:AddSlider("StatsRollCD", {
    Text = "Roll Delay",
    Default = 0.1,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Stats1.T2:AddToggle("AutoRollStats", {
    Text = "Auto Roll Stats",
    Default = false,
})

TB_Tabs.Stats1.T3:AddToggle("AutoSkillTree", {
    Text = "Auto Skill Tree",
    Default = false,
})

TB_Tabs.Stats1.T3:AddToggle("ArtifactMilestone", {
    Text = "Auto Artifact Milestone",
    Default = false,
})

TB_Tabs.Enchant.T1:AddDropdown("SelectedEnchant", {
    Text = "Select Enchant",
    Values = Tables.OwnedAccessory,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Enchant.T1:AddToggle("AutoEnchant", {
    Text = "Auto Enchant",
    Default = false,
})

TB_Tabs.Enchant.T1:AddToggle("AutoEnchantAll", {
    Text = "Auto Enchant All",
    Default = false,
})

TB_Tabs.Enchant.T1:AddDivider()

TB_Tabs.Enchant.T1:AddDropdown("SelectedBlessing", {
    Text = "Select Blessing",
    Values = Tables.OwnedWeapon,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Enchant.T1:AddToggle("AutoBlessing", {
    Text = "Auto Blessing",
    Default = false,
})

TB_Tabs.Enchant.T1:AddToggle("AutoBlessingAll", {
    Text = "Auto Blessing All",
    Default = false,
})

SpecPassiveLabel = TB_Tabs.Enchant.T2:AddLabel("N/A", true)

TB_Tabs.Enchant.T2:AddDropdown("SelectedPassive", {
    Text = "Select Weapon (s)",
    Values = Tables.AllOwnedWeapons,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Enchant.T2:AddDropdown("SelectedSpec", {
    Text = "Target Passives",
    Values = Tables.SpecPassive,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Enchant.T2:AddSlider("SpecRollCD", {
    Text = "Roll Delay",
    Default = 0.1,
    Min = 0.01,
    Max = 1,
    Rounding = 2,
    Callback = function(a)
        tonumber(a)
    end
})

TB_Tabs.Enchant.T2:AddToggle("AutoSpec", {
    Text = "Auto Reroll Passive",
    Default = false,
})

TB_Tabs.Enchant.T3:AddLabel("- ⚠️ <b>Only adjust these values if you are an advanced user.\nWill stop once the selected passive reaches your set minimum value.</b>", true)

local ShortMap = {
    ["DamagePercent"] = "DMG%",
    ["CritChance"] = "CC%",
    ["CritDamage"] = "CD%",
    ["BonusDropChance"] = "Drop%",
    ["ExecuteBonus"] = "BonusDMG%",
    ["ExecuteThreshold"] = "Exec%",
    
    ["Damage"] = "DMG",
    ["Crit Chance"] = "CC",
    ["Crit Damage"] = "CD",
    ["Luck"] = "Luck"
}

local SortedShortKeys = {}
for k in pairs(ShortMap) do table.insert(SortedShortKeys, k) end
table.sort(SortedShortKeys, function(a, b) return #a > #b end)

local function Shorten(text)
    for _, long in ipairs(SortedShortKeys) do
        local short = ShortMap[long]
        local safeShort = short:gsub("%%", "%%%%")
        text = text:gsub(long, safeShort)
    end
    return text
end

local function UpdatePassiveSliders()
    local selectedPassives = Options.SelectedSpec.Value or {}
    
    for _, slider in pairs(Status.Main.SpecStatsSlider) do
        slider:SetVisible(false)
    end

    for passiveName, isSelected in pairs(selectedPassives) do
        if isSelected then
            local data = Modules.SpecPassive.Passives[passiveName]
            if data and data.Buffs then
                for statKey, range in pairs(data.Buffs) do
                    local sliderId = "Min_" .. passiveName:gsub("%s+", "") .. "_" .. statKey
                    
                    local shortName = Shorten(passiveName)
                    local shortStat = Shorten(statKey)
                    local label = string.format("%s [%s]", shortName, shortStat)

                    if not Options[sliderId] then
                        local minVal, maxVal = range[1], range[2]

                        Status.Main.SpecStatsSlider[sliderId] = TB_Tabs.Enchant.T3:AddSlider(sliderId, {
                            Text = label,
                            Default = minVal,
                            Min = minVal,
                            Max = maxVal,
                            Rounding = 1,
                            Compact = true,
                            Visible = true
                        })
                    else
                        Options[sliderId]:SetText(label)
                        Status.Main.SpecStatsSlider[sliderId]:SetVisible(true)
                    end
                end
            end
        end
    end
end

ArtifactLabel = GB.Artifact.Left.Status:AddLabel("Status: N/A", true)
DustLabel = GB.Artifact.Left.Status:AddLabel("Dust: N/A", true)

InvLabel_Helmet = GB.Artifact.Left.Status:AddLabel("Helmet: 0/500")
InvLabel_Gloves = GB.Artifact.Left.Status:AddLabel("Gloves: 0/500")
InvLabel_Body = GB.Artifact.Left.Status:AddLabel("Body: 0/500")
InvLabel_Boots = GB.Artifact.Left.Status:AddLabel("Boots: 0/500")


GB.Artifact.Right.Lock:AddDropdown("Lock_Type", {
    Text = "Artifact Type",
    Values = {},
    Default = nil,
    Multi = true,
    Searchable = true,
})

GB.Artifact.Right.Lock:AddDropdown("Lock_Set", {
    Text = "Artifact Set",
    Values = {},
    Default = nil,
    Multi = true,
    Searchable = true,
})

GB.Artifact.Right.Lock:AddDropdown("Lock_MS", {
    Text = "Main Stat Filter",
    Values = {},
    Default = nil,
    Multi = true,
    Searchable = true,
})

GB.Artifact.Right.Lock:AddDropdown("Lock_SS", {
    Text = "Sub Stat Filter",
    Values = {},
    Default = nil,
    Multi = true,
    Searchable = true,
})

GB.Artifact.Right.Lock:AddSlider("Lock_MinSS", {
    Text = "Min Sub-Stats",
    Default = 0,
    Min = 0,
    Max = 4,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

GB.Artifact.Right.Lock:AddToggle("ArtifactLock", {
    Text = "Auto Lock",
    Default = false,
})

GB.Artifact.Right.Delete:AddDropdown("Del_Type", {
    Text = "Artifact Type",
    Values = {},
    Default = nil,
    Multi = true,
    Searchable = true,
})

GB.Artifact.Right.Delete:AddDropdown("Del_Set", {
    Text = "Artifact Set",
    Values = {},
    Default = nil,
    Multi = true,
    Searchable = true,
})

GB.Artifact.Right.Delete:AddDropdown("Del_MS_Helmet", {
    Text = "Main Stat [Helmet]",
    Values = {"FlatDefense", "Defense"},
    Default = nil,
    Multi = true,
    Searchable = true,
})

GB.Artifact.Right.Delete:AddDropdown("Del_MS_Gloves", {
    Text = "Main Stat [Gloves]",
    Values = {"Damage"},
    Default = nil,
    Multi = true,
    Searchable = true,
})

GB.Artifact.Right.Delete:AddDropdown("Del_MS_Body", {
    Text = "Main Stat [Body]",
    Values = {},
    Default = nil,
    Multi = true,
    Searchable = true,
})

GB.Artifact.Right.Delete:AddDropdown("Del_MS_Boots", {
    Text = "Main Stat [Boots]",
    Values = {},
    Default = nil,
    Multi = true,
    Searchable = true,
})

GB.Artifact.Right.Delete:AddDropdown("Del_SS", {
    Text = "Sub Stat Filter",
    Values = {},
    Default = nil,
    Multi = true,
    Searchable = true,
})

GB.Artifact.Right.Delete:AddSlider("Del_MinSS", {
    Text = "Min Sub-Stats",
    Default = 0,
    Min = 0,
    Max = 4,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

GB.Artifact.Right.Delete:AddToggle("ArtifactDelete", {
    Text = "Auto Delete",
    Default = false,
})

GB.Artifact.Right.Delete:AddToggle("DeleteUnlock", {
    Text = "Auto Delete Unlocked",
    Default = false,
})

GB.Artifact.Left.Upgrade:AddSlider("UpgradeLimit", {
    Text = "Upgrade Limit",
    Default = 0,
    Min = 0,
    Max = 15,
    Rounding = 0,
    Callback = function(a)
        tonumber(a)
    end
})

GB.Artifact.Left.Upgrade:AddDropdown("Up_MS", {
    Text = "Main Stat Filter",
    Values = {},
    Default = nil,
    Multi = true,
    Searchable = true,
})

GB.Artifact.Left.Upgrade:AddToggle("ArtifactUpgrade", {
    Text = "Auto Upgrade",
    Default = false,
})

GB.Artifact.Left.Upgrade:AddToggle("UpgradeStage", {
    Text = "Upgrade in Stages",
    Default = false,
})

GB.Artifact.Left.Equip:AddDropdown("Eq_Type", {
    Text = "Artifact Type",
    Values = {},
    Default = nil,
    Multi = true,
    Searchable = true,
})

GB.Artifact.Left.Equip:AddDropdown("Eq_MS", {
    Text = "Main Stat Filter",
    Values = {},
    Default = nil,
    Multi = true,
    Searchable = true,
})

GB.Artifact.Left.Equip:AddDropdown("Eq_SS", {
    Text = "Sub Stat Filter",
    Values = {},
    Default = nil,
    Multi = true,
    Searchable = true,
})

GB.Artifact.Left.Equip:AddToggle("ArtifactEquip", {
    Text = "Auto Equip",
    Default = false,
})

Tabs.Artifact:UpdateWarningBox({
    Title = "⚠️ WARNING ⚠️",
    Text = "These features below are in heavy development. Use at your own risk. I am NOT responsible for any resulting artifacts or issues.",
    IsNormal = false,
    Visible = true,
    LockSize = true,
})

TB_Tabs.Dungeon.T1:AddLabel("BossRush Supported.", true)

TB_Tabs.Dungeon.T1:AddDropdown("SelectedDungeon", {
    Text = "Select Dungeon",
    Values = Tables.DungeonList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
})

TB_Tabs.Dungeon.T1:AddToggle("AutoDungeon", {
    Text = "Auto Join Dungeon",
    Default = false,
})

DungeonCount = TB_Tabs.Dungeon.T2:AddLabel("Dungeon Completed: N/A")

TB_Tabs.Dungeon.T2:AddDropdown("SelectedDiff", {
    Text = "Select Difficulty",
    Values = {"Easy", "Medium", "Hard", "Extreme"},
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
})

TB_Tabs.Dungeon.T2:AddToggle("AutoDiff", {
    Text = "Auto Select Difficulty",
    Default = false,
})

TB_Tabs.Dungeon.T2:AddToggle("AutoReplay", {
    Text = "Auto Replay",
    Default = false,
})

TB_Tabs.Dungeon.T2:AddToggle("DungeonAutofarm", {
    Text = "Autofarm Dungeon",
    Default = false,
})

    AddSliderToggle({ Group = GB.Player.Left.General, Id = "WS", Text = "WalkSpeed", Default = 16, Min = 16, Max = 250 })
    local TPW_T, TPW_S = AddSliderToggle({ Group = GB.Player.Left.General, Id = "TPW", Text = "TPWalk", Default = 1, Min = 1, Max = 10, Rounding = 1 })
    AddSliderToggle({ Group = GB.Player.Left.General, Id = "JP", Text = "JumpPower", Default = 50, Min = 0, Max = 500 })
    AddSliderToggle({ Group = GB.Player.Left.General, Id = "HH", Text = "HipHeight", Default = 2, Min = 0, Max = 10, Rounding = 1 })
    GB.Player.Left.General:AddToggle("Noclip", { Text = "Noclip" })
    GB.Player.Left.General:AddToggle("AntiKnockback", {
    Text = "Anti Knockback",
    Default = false,
    })
    GB.Player.Left.General:AddToggle("Disable3DRender", { Text = "Disable 3D Rendering" })
    AddSliderToggle({ Group = GB.Player.Left.General, Id = "Grav", Text = "Gravity", Default = 196, Min = 0, Max = 500, Rounding = 1})
    AddSliderToggle({ Group = GB.Player.Left.General, Id = "Zoom", Text = "Camera Zoom", Default = 128, Min = 128, Max = 10000 })
    AddSliderToggle({ Group = GB.Player.Left.General, Id = "FOV", Text = "Field of View", Default = 70, Min = 30, Max = 120 })
    local FPS_T, FPS_S = AddSliderToggle({ Group = GB.Player.Left.General, Id = "LimitFPS", Text = "Set Max FPS", Disabled = not Env.Support.FPS, Default = 60, Min = 5, Max = 360 })
    GB.Player.Left.General:AddToggle("FPSBoost", { Text = "FPS Boost" })
    GB.Player.Left.General:AddToggle("FPSBoost_AF", { Text = "FPS Boost [Autofarm]" })

    GB.Player.Left.Server:AddToggle("AntiAFK", {
        Text = "Anti AFK",
        Default = true,
        Disabled = not Env.Support.Connections,
    })
    GB.Player.Left.Server:AddToggle("AntiKick", { Text = "Anti Kick (Client)" })
    GB.Player.Left.Server:AddToggle("AutoReconnect", { Text = "Auto Reconnect" })
    GB.Player.Left.Server:AddToggle("NoGameplayPaused", { Text = "No Gameplay Paused"})

    GB.Player.Left.Server:AddButton({ Text = "Serverhop", Func = function() 
        local Servers = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    end})
    GB.Player.Left.Server:AddButton({ Text = "Rejoin", Func = function() TP:Teleport(game.PlaceId, Plr) end })

    GB.Player.Left.Server:AddToggle("AutoServerhop", { Text = "Auto Serverhop" })
    GB.Player.Left.Server:AddSlider("AutoHopMins", { Text = "Minutes", Default = 30, Min = 0, Max = 300, Compact = true })

    GB.Player.Left.Server:AddToggle("AutoRejoinMemory", { 
        Text = "Auto Rejoin (Memory)", 
        Default = false 
    })

    GB.Player.Left.Server:AddSlider("MemoryLimit", { 
        Text = "Memory Limit (MB)", 
        Default = 3000, 
        Min = 1000, 
        Max = 20000, 
        Rounding = 0,
        Compact = true 
    })

    GB.Player.Right.Game:AddToggle("InstantPP", { Text = "Instant Prompt" })
    GB.Player.Right.Game:AddToggle("Fullbright", { Text = "Fullbright" })
    GB.Player.Right.Game:AddToggle("NoFog", { Text = "No Fog" })

    AddSliderToggle({ Group = GB.Player.Right.Game, Id = "OverrideTime", Text = "Time Of Day", Default = 12, Min = 0, Max = 24, Rounding = 1 })

    GB.Player.Right.Safety:AddLabel("Panic")
    :AddKeyPicker("PanicKeybind", { Default = "P", Text = "Panic" })
    GB.Player.Right.Safety:AddToggle("AutoKick", { Text = "Auto Kick", Default = true})
    GB.Player.Right.Safety:AddDropdown("SelectedKickType", {
    Text = "Select Type",
    Values = {"Mod", "Player Join", "Public Server"},
    Default = {"Mod"},
    Multi = true,
    Searchable = true,})

TB_Tabs.Waypoint.T1:AddDropdown("SelectedIsland", {
    Text = "Select Island",
    Values = Tables.IslandList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
    Callback = function(a)
    if a ~= nil then
        Remotes.TP_Portal:FireServer(GetTPName(a))
    else
        Library:Notify("Please select a island to teleport.", 2)
    end
    end
})

TB_Tabs.Waypoint.T2:AddDropdown("SelectedQuestNPC", {
    Text = "Select NPC",
    Values = Tables.NPC_QuestList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
    Callback = function(a)

    local questMap = {
        ["DungeonUnlock"] = "DungeonPortalsNPC",
        ["SlimeKeyUnlock"] = "SlimeCraftNPC"
    }

    SafeTeleportToNPC(a, questMap)
    end
})

TB_Tabs.Waypoint.T3:AddDropdown("SelectedMiscNPC", {
    Text = "Select NPC [Misc]",
    Values = Tables.NPC_MiscList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
    Callback = function(a)

    local miscMap = {
        ["ArmHaki"] = "HakiQuest",
        ["Observation"] = "ObservationBuyer"
    }

    SafeTeleportToNPC(tostring(a), miscMap)
    end
})

TB_Tabs.Waypoint.T3:AddDropdown("SelectedMiscAllNPC", {
    Text = "Select NPC [All NPCs]",
    Values = Tables.AllNPCList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
    Callback = function(a)
        if a then SafeTeleportToNPC(tostring(a)) end
    end
})

TB_Tabs.NPCs.T1:AddDropdown("SelectedMovesetNPC", {
    Text = "Select NPC",
    Values = Tables.NPC_MovesetList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
    Callback = function(a)
        if a then SafeTeleportToNPC(tostring(a)) end
    end
})

TB_Tabs.NPCs.T2:AddDropdown("SelectedMasteryNPC", {
    Text = "Select NPC",
    Values = Tables.NPC_MasteryList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
    Callback = function(a)
        if a then SafeTeleportToNPC(tostring(a)) end
    end
})

MerchantTimerLabel = TB_Tabs.Merchant.T1:AddLabel("Refresh: N/A")

TB_Tabs.Merchant.T1:AddDropdown("SelectedMerchantItems", {
    Text = "Select Item (s)",
    Values = Tables.MerchantList,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Merchant.T1:AddToggle("AutoMerchant", {
    Text = "Auto Buy Selected Items",
    Default = false,
})

TB_Tabs.Merchant.T2:AddLabel("Soon...")

TB_Tabs.Merchant.T3:AddLabel("Able to causing performance issues.", true)

ValentineLabel = TB_Tabs.Merchant.T3:AddLabel("Hearts: N/A")

TB_Tabs.Merchant.T3:AddDropdown("SelectedValentineMerchantItems", {
    Text = "Select Item (s)",
    Values = Tables.ValentineMerchantList,
    Default = nil,
    Multi = true,
    Searchable = true,
})

ValentinePriceLabel = TB_Tabs.Merchant.T3:AddLabel("Price: N/A")

TB_Tabs.Merchant.T3:AddToggle("AutoValentineMerchant", {
    Text = "Auto Buy Selected Items",
    Default = false,
})

TB_Tabs.Misc1.T1:AddDropdown("SelectedChests", {
    Text = "Select Chest (s)",
    Values = Tables.Rarities,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Misc1.T1:AddToggle("AutoChest", {
    Text = "Auto Open Chest",
    Default = false,
})

TB_Tabs.Misc1.T2:AddDropdown("SelectedCraftItems", {
    Text = "Select Item (s) To Craft",
    Values = Tables.CraftItemList,
    Default = nil,
    Multi = true,
    Searchable = true,
})

TB_Tabs.Misc1.T2:AddToggle("AutoCraftItem", {
    Text = "Auto Craft Item",
    Default = false,
})

TB_Tabs.Puzzle.T1:AddButton({
    Text = "Complete Dungeon Puzzle",
    Disabled = not Env.Support.Proximity,
    Func = function()
        local currentLevel = Plr.Data.Level.Value
        if currentLevel >= 5000 then
            UniversalPuzzleSolver("Dungeon")
        else
            Library:Notify("Level 5000 required! Current: " .. currentLevel, 3)
        end
    end
})

TB_Tabs.Puzzle.T1:AddButton({
    Text = "Complete Slime Key Puzzle",
    Disabled = not Env.Support.Proximity,
    Func = function()
        UniversalPuzzleSolver("Slime")
    end
})

TB_Tabs.Puzzle.T1:AddButton({
    Text = "Complete Demonite Puzzle",
    Disabled = not Env.Support.Proximity,
    Func = function()
        UniversalPuzzleSolver("Demonite")
    end
})

TB_Tabs.Puzzle.T1:AddButton({
    Text = "Complete Hogyoku Puzzle",
    Disabled = not Env.Support.Proximity,
    Func = function()
        local currentLevel = Plr.Data.Level.Value
        if currentLevel >= 8500 then
            UniversalPuzzleSolver("Hogyoku")
        else
            Library:Notify("Level 8500 required! Current: " .. currentLevel, 4)
        end
    end
})

TB_Tabs.Puzzle.T2:AddLabel({
    Text = "- ⚠️: Experimental feature. Deep testing required!\n- ⚠️: Make sure to store your race & clan before using this.\n- Dungeon tasks only make you join dungeon.\n- Feature will change some other features settings.",
    DoesWrap = true,
})

TB_Tabs.Puzzle.T2:AddDropdown("SelectedQuestline", {
    Text = "Select Questline",
    Values = Tables.QuestlineList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
})

TB_Tabs.Puzzle.T2:AddDropdown("SelectedQuestline_Player", {
    Text = "Select Player",
    SpecialType = "Player",
    ExcludeLocalPlayer = true,
    AllowNull = true,
    Default = nil,
    Multi = false,
    Searchable = true,
})

TB_Tabs.Puzzle.T2:AddDropdown("SelectedQuestline_DMGTaken", {
    Text = "Select Mob [Take Damage]",
    Values = Tables.AllEntitiesList,
    Default = nil,
    Multi = false,
    AllowNull = true,
    Searchable = true,
})

TB_Tabs.Puzzle.T2:AddButton("Refresh", function()
    UpdateAllEntities()
    Options.SelectedQuestline_DMGTaken:SetValues(Tables.AllEntitiesList)
end)

TB_Tabs.Puzzle.T2:AddToggle("AutoQuestline", {
    Text = "Auto Questline [BETA]",
    Default = false,
})

Toggles.SendWebhook:OnChanged(function(state)
    Thread("WebhookLoop", Func_WebhookLoop, state)
end)

Toggles.LevelFarm:OnChanged(function(state)
    if not state then Status.Main.QuestNPC = "" end
end)

Toggles.AutoTitle:OnChanged(function(state)
    if state and #Tables.UnlockedTitle == 0 then
        Remotes.TitleUnequip:FireServer()
    end
end)

Toggles.ObserHaki:OnChanged(function(state)
    Thread("AutoHaki", Func_AutoHaki, state)
end)

Toggles.ArmHaki:OnChanged(function(state)
    Thread("AutoHaki", Func_AutoHaki, state)
end)

Toggles.ConquerorHaki:OnChanged(function(state)
    Thread("AutoHaki", Func_AutoHaki, state)
end)

Toggles.AutoM1:OnChanged(function(state)
    Thread("AutoM1", SafeLoop("Auto M1", Func_AutoM1), state)
end)

Toggles.KillAura:OnChanged(function(state)
    Thread("KillAura", Func_KillAura, state)
end)

Toggles.AutoSkill:OnChanged(function(state)
    Thread("AutoSkill", SafeLoop("Auto Skill", Func_AutoSkill), state)
end)

Toggles.AutoStats:OnChanged(function(state)
    Thread("AutoStats", SafeLoop("Auto Stats", Func_AutoStats), state)
end)

Toggles.AutoCombo:OnChanged(function(state)
    if not state then Status.Main.ComboIdx = 1 end
    Thread("AutoCombo", SafeLoop("Skill Combo", Func_AutoCombo), state)
end)

Toggles.AutoAscend:OnChanged(function(state)
    if state then
        Remotes.ReqAscend:InvokeServer()
    else
        Remotes.CloseAscend:FireServer()
        for i = 1, 10 do Tables.AscendLabels[i]:SetVisible(false) end
    end
end)

Toggles.AutoTrait:OnChanged(EnsureRollManager)
Toggles.AutoRace:OnChanged(EnsureRollManager)
Toggles.AutoClan:OnChanged(EnsureRollManager)

Options.SelectedTrait:OnChanged(function()
    SyncTraitAutoSkip()
end)

Options.SelectedRace:OnChanged(function()
    SyncRaceSettings()
end)

Options.SelectedClan:OnChanged(function()
    SyncClanSettings()
end)

Options.SelectedSpec:OnChanged(function()
    SyncSpecPassiveAutoSkip()
end)

Options.SelectedPassive:OnChanged(function()
    UpdateSpecPassiveLabel()
end)

Options.SelectedSpec:OnChanged(UpdatePassiveSliders)
Options.SelectedPower:OnChanged(UpdatePowerSliders)

Options.SelectedKickType:OnChanged(function()
    CheckServerTypeSafety()
end)

task.spawn(Func_AutoTrade)

Toggles.AutoSpec:OnChanged(function(state)
    Thread("AutoSpecPassive", SafeLoop("Spec Passive", AutoSpecPassiveLoop), state)
end)

Toggles.AutoPower:OnChanged(function(state)
    Thread("AutoPower", SafeLoop("PowerRoll", AutoPowerLoop), state)
end)


Toggles.AutoRollStats:OnChanged(function(state)
    Thread("AutoRollStats", SafeLoop("Stat Roll", AutoRollStatsLoop), state)
end)

Toggles.AutoSkillTree:OnChanged(function(state)
    Thread("AutoSkillTree", SafeLoop("Skill Tree", AutoSkillTreeLoop), state)
end)

Toggles.ArtifactMilestone:OnChanged(function(state)
    Thread("ArtifactMilestone", Func_ArtifactMilestone, state)
end)

Toggles.AutoEnchant:OnChanged(function(s) Thread("AutoEnchant", SafeLoop("Enchant", function() AutoUpgradeLoop("Enchant") end), s) end)
Toggles.AutoEnchantAll:OnChanged(function(s) Thread("AutoEnchantAll", SafeLoop("EnchantAll", function() AutoUpgradeLoop("Enchant") end), s) end)
Toggles.AutoBlessing:OnChanged(function(s) Thread("AutoBlessing", SafeLoop("Blessing", function() AutoUpgradeLoop("Blessing") end), s) end)
Toggles.AutoBlessingAll:OnChanged(function(s) Thread("AutoBlessingAll", SafeLoop("BlessingAll", function() AutoUpgradeLoop("Blessing") end), s) end)

Toggles.ArtifactLock:OnChanged(function(state)
    Thread("Artifact.Lock", SafeLoop("ArtifactLogic", Func_ArtifactAutomation), state)
end)

Toggles.ArtifactDelete:OnChanged(function(state)
    Thread("Artifact.Delete", SafeLoop("ArtifactLogic", Func_ArtifactAutomation), state)
end)

Toggles.ArtifactUpgrade:OnChanged(function(state)
    Thread("Artifact.Upgrade", SafeLoop("ArtifactLogic", Func_ArtifactAutomation), state)
end)

Toggles.AutoDungeon:OnChanged(function(state)
    Thread("AutoDungeon", Func_AutoDungeon, state)
end)

Toggles.AutoMerchant:OnChanged(function(state)
    Thread("AutoMerchant", SafeLoop("Merchant", Func_AutoMerchant), state)
end)

Toggles.AutoChest:OnChanged(function(state)
    Thread("AutoChest", SafeLoop("Chest", Func_AutoChest), state)
end)

Toggles.AutoCraftItem:OnChanged(function(state)
    Thread("AutoCraft", SafeLoop("Craft", Func_AutoCraft), state)
end)

Toggles.AutoQuestline:OnChanged(function(state)
    Thread("AutoQuestline", SafeLoop("Questline", AutoQuestlineLoop), state)
end)

Toggles.AntiKnockback:OnChanged(function(state)
    Thread("AntiKnockback", Func_AntiKnockback, state)
end)

Toggles.TPW:OnChanged(function(v)
    TPW_S:SetVisible(TPW_T.Value)
    Thread("TPW", FuncTPW, v)
end)
Toggles.Noclip:OnChanged(function(v)
    Thread("Noclip", FuncNoclip, v)
end)

Status.Connections.Player_General = RunService.Stepped:Connect(function()
    local Hum = Plr.Character and Plr.Character:FindFirstChildOfClass("Humanoid")
    if Hum then
        if Toggles.WS.Value then Hum.WalkSpeed = Options.WSValue.Value end
        if Toggles.JP.Value then Hum.JumpPower = Options.JPValue.Value Hum.UseJumpPower = true end
        if Toggles.HH.Value then Hum.HipHeight = Options.HHValue.Value end
    end
        workspace.Gravity = Toggles.Grav.Value and Options.GravValue.Value or 192
        if Toggles.FOV.Value then workspace.CurrentCamera.FieldOfView = Options.FOVValue.Value end
        if Toggles.Zoom.Value then Plr.CameraMaxZoomDistance = Options.ZoomValue.Value end
end)

task.spawn(function()
    while task.wait() do
        if Toggles.Fullbright.Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
        elseif Toggles.OverrideTime.Value then
            Lighting.ClockTime = Options.OverrideTimeValue.Value
        end
        if Toggles.NoFog.Value then Lighting.FogEnd = 9e9 end
        if Library.Unloaded then break end
    end
end)

Options.LimitFPSValue:OnChanged(function()
    if FPS_T.Value then
        setfpscap(FPS_S.Value)
    end
end)

Toggles.LimitFPS:OnChanged(function(v)
    FPS_S:SetVisible(FPS_T.Value)
    if not v then
        setfpscap(60)
    end
end)

RunService.Stepped:Connect(function()
    if Status.Main.Farm and Status.Main.Target then
        local char = Plr.Character
        if char then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not Toggles.SendWebhook.Value and #Status.Cached.NewItem > 100 then
            table.clear(Status.Cached.NewItem)
        end
    end
end)

Toggles.Disable3DRender:OnChanged(function(v) RunService:Set3dRenderingEnabled(not v) end)

Toggles.FPSBoost:OnChanged(function(state)
    ApplyFPSBoost(state)
end)

Toggles.FPSBoost_AF:OnChanged(function(state)
    if state then
        ApplyIslandWipe()
    end
end)

Toggles.AutoReconnect:OnChanged(function(state)
    if state then Func_AutoReconnect() end
end)

Toggles.NoGameplayPaused:OnChanged(function(state)
    Thread("NoGameplayPaused", SafeLoop("Anti-Pause", Func_NoGameplayPaused), state)
end)

Toggles.AutoRejoinMemory:OnChanged(function(state)
    Thread("AutoRejoinMemory", SafeLoop("AutoRejoinMemory", Func_MemoryMonitor), state)
end)

game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
    if Toggles.InstantPP and Toggles.InstantPP.Value then
        prompt.HoldDuration = 0
    end
end)

Options.PanicKeybind:OnClick(function()
    PanicStop()
end)

Remotes.SpecPassiveUpdate.OnClientEvent:Connect(function(data)
    if type(Status.Main.Passives) ~= "table" then Status.Main.Passives = {} end
    
    if data and data.Passives then
        for weaponName, info in pairs(data.Passives) do
            if type(info) == "table" then
                Status.Main.Passives[weaponName] = info
            else
                Status.Main.Passives[weaponName] = { Name = tostring(info), RolledBuffs = {} }
            end
        end
        pcall(UpdateSpecPassiveLabel)
    end
end)

Remotes.UpStatReroll.OnClientEvent:Connect(function(data)
    if data and data.Stats then
        Status.Main.GemStats = data.Stats
        task.spawn(UpdateStatsLabel)
    end
end)

Remotes.UpPlayerStats.OnClientEvent:Connect(function(data)
    if data and data.Stats then
        Status.Main.Stats = data.Stats
        UpdateStatsLabel()
    end
end)

Remotes.UpAscend.OnClientEvent:Connect(function(data)
    if not Toggles.AutoAscend.Value then return end
    
    UpdateAscendUI(data)

    if data.isMaxed then 
        Toggles.AutoAscend:SetValue(false) 
        return 
    end

    if data.allMet then
        Library:Notify("All requirements met! Attempt to ascend into: " .. data.nextRankName, 5)
        Remotes.Ascend:FireServer()
        task.wait(1)
    end
end)

task.spawn(function()
    while getgenv().sailorhub_running do
        if Remotes.ReqInventory then
            Remotes.ReqInventory:FireServer()
        end
        task.wait(60)
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not getgenv().sailorhub_running then break end
        
        pcall(function()
            if PityLabel then
                local current, max = GetCurrentPity()
                PityLabel:SetText(string.format("<b>Pity:</b> %d/%d", current or 0, max or 25))
            end
        end)
    end
end)

task.spawn(function()
    DisableIdled()

    while true do
        task.wait(60)
        
        if Toggles.AntiAFK and Toggles.AntiAFK.Value then
            pcall(function()
                VU:CaptureController()
                VU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(0.2)
                VU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait()
        if Status.Main.AltActive then continue end
            if not Status.Main.Farm or Status.Main.MerchantBusy or not Status.Main.Target then continue end
        
        local success, err = pcall(function()
            local char = GetCharacter()
            local target = Status.Main.Target
            if not target or not char then return end
            
            local npcHum = target:FindFirstChildOfClass("Humanoid")
            local npcRoot = target:FindFirstChild("HumanoidRootPart")
            local root = char:FindFirstChild("HumanoidRootPart")
            
            if npcHum and npcRoot and root then
                local currentDist = (root.Position - npcRoot.Position).Magnitude
                local hpPercent = (npcHum.Health / npcHum.MaxHealth) * 100
                local minMaxHP = tonumber(Options.InstaKillMinHP.Value) or 0
                local ikThreshold = tonumber(Options.InstaKillHP.Value) or 90

            if Toggles.InstaKill.Value and npcHum.MaxHealth >= minMaxHP and hpPercent < ikThreshold then
                npcHum.Health = 0 
                if not target:GetAttribute("IK_Active") then
                    target:SetAttribute("IK_Active", true)
                    target:SetAttribute("TriggerTime", tick())
                end
            end

                if currentDist < 35 then
                    if math.abs(root.Position.Y - npcRoot.Position.Y) > 50 then
                        root.Velocity = Vector3.new(0, -100, 0)
                    end

                    local m1Delay = tonumber(Options.M1Speed.Value) or 0.2
                    if tick() - Status.Main.LastM1 >= m1Delay then
                        EquipWeapon() 
                        Remotes.M1:FireServer()
                        Status.Main.LastM1 = tick()
                    end
                end
            end
        end)
        
        if not success then
            Library:Notify("ERROR: " .. tostring(err), 10)
        end
    end
end)

task.spawn(function()
    while task.wait() do
        if not Status.Main.Farm or Status.Main.MerchantBusy then 
            Status.Main.Target = nil 
            continue 
        end

        local char = GetCharacter()
        if not char or Status.Main.Recovering then continue end

        if Status.Main.TargetValid and (not Status.Main.Target or not Status.Main.Target.Parent or Status.Main.Target.Humanoid.Health <= 0) then
            Status.Main.KillTick = tick()
            Status.Main.TargetValid = false
        end

        if tick() - Status.Main.KillTick < (tonumber(Options.TargetTPCD.Value) or 0) then continue end

        HandleSummons()

        local currentPity, maxPity = GetCurrentPity()
        local isPityReady = Toggles.PityBossFarm.Value and currentPity >= (maxPity - 1)
        
        local foundTask = false
        
        for i = 1, #Status.Priority.Task do
            local taskName = Options["SelectedPriority_" .. i].Value
            if not taskName then continue end

            local isBossRelated = (taskName == "Boss" or taskName == "Summon" or taskName == "Alt Help" or taskName == "Pity Boss")

            if isPityReady and isBossRelated then
                local t, isl, fType = GetPityTarget()
                if t then
                    foundTask = true
                    Status.Main.Target = t
                    Status.Main.TargetValid = true
                    UpdateSwitchState(t, fType)
                    ExecuteFarmLogic(t, isl, fType)
                    break 
                end
            else
                local t, isl, fType = CheckTask(taskName)
                if t then
                    foundTask = true
                    Status.Main.Target = t
                    Status.Main.TargetValid = true
                    UpdateSwitchState(t, fType)
                    if taskName ~= "Merchant" then 
                        ExecuteFarmLogic(t, isl, fType) 
                    end
                    break 
                end
            end
        end

        if not foundTask then
            Status.Main.Target = nil
            UpdateSwitchState(nil, "None")
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not getgenv().sailorhub_running then break end
        
        local char = GetCharacter()
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if root and not Status.Main.MovingIsland then
            local pos = root.Position
            
            if pos.Y > 5000 or math.abs(pos.X) > 10000 or math.abs(pos.Z) > 10000 then
                Status.Main.Recovering = true
                Library:Notify("Something wrong, attempt to reset..", 5)
                
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                
                if Tables.IslandCrystals["Starter"] then
                    root.CFrame = Tables.IslandCrystals["Starter"]:GetPivot() * CFrame.new(0, 5, 0)
                    task.wait(1)
                end
                
                Status.Main.Recovering = false
            end
        end
    end
end)

local MenuGroup = Tabs.Config:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("AutoShowUI", {
    Text = "Auto Show UI",
    Default = true,
})

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = false,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",

	Text = "Notification Side",

	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})

MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",

	Text = "DPI Scale",

	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)

		Library:SetDPIScale(DPI)
	end,
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "U", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
    getgenv().sailorhub_running = false
    Status.Main.Farm = false
    Cleanup(Status.Connections)
    Cleanup(Flags)
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ "SelectedIsland" })
SaveManager:SetIgnoreIndexes({ "SelectedQuestNPC" })
SaveManager:SetIgnoreIndexes({ "SelectedMiscNPC" })
SaveManager:SetIgnoreIndexes({ "SelectedMiscAllNPC" })
SaveManager:SetIgnoreIndexes({ "SelectedMovesetNPC" })
SaveManager:SetIgnoreIndexes({ "SelectedMasteryNPC" })

ThemeManager:SetFolder("sailorhub")
SaveManager:SetFolder("sailorhub/sailorpiece")

SaveManager:BuildConfigSection(Tabs.Config)

ThemeManager:ApplyToTab(Tabs.Config)

Options.Lock_Type:SetValues(Modules.ArtifactConfig.Categories)
Options.Lock_Set:SetValues(Tables.ArtiSet)
Options.Lock_MS:SetValues(Tables.ArtiStat)
Options.Lock_SS:SetValues(Tables.ArtiStat)

Options.Del_Type:SetValues(Modules.ArtifactConfig.Categories)
Options.Del_Set:SetValues(Tables.ArtiSet)
Options.Del_MS_Body:SetValues(Tables.ArtiStat)
Options.Del_MS_Boots:SetValues(Tables.ArtiStat)
Options.Del_SS:SetValues(Tables.ArtiStat)

Options.Up_MS:SetValues(Tables.ArtiStat)

Options.Eq_Type:SetValues(Modules.ArtifactConfig.Categories)
Options.Eq_MS:SetValues(Tables.ArtiStat)
Options.Eq_SS:SetValues(Tables.ArtiStat)

UpdateNPCLists()
PopulateNPCLists()
UpdateAllEntities()
InitAutoKick()
ACThing(true)

task.spawn(function()
    if Remotes.ReqInventory then Remotes.ReqInventory:FireServer() end

    local timeout = 0
    while not Status.Main.InventorySynced and timeout < 5 do
        task.wait(0.15)
        timeout = timeout + 0.15
        
        if timeout == 1.5 then Remotes.ReqInventory:FireServer() end
    end

    SaveManager:LoadAutoloadConfig()
    task.wait(0.25)

    if Toggles.AutoRune.Value then
        Status.Main.LastSwitch.Rune = "REFRESHING"
        Toggles.AutoRune:SetValue(false)
        task.wait(.01)
        Toggles.AutoRune:SetValue(true)
    end
    
    Status.Main.LastSwitch.Title = "REFRESHING"
    
    if Remotes.ReqInventory then Remotes.ReqInventory:FireServer() end
end)

task.spawn(function()
    task.wait(0.1)
    if Toggles.AutoTitle and Toggles.AutoTitle.Value then
        Remotes.TitleUnequip:FireServer()
    end
end)

pcall(function()
    local screen = workspace.CurrentCamera.ViewportSize
    if screen.X > 0 and screen.Y > 0 then
        if UIS.TouchEnabled and not UIS.KeyboardEnabled then
            local scale = (screen.X < 500) and 50 or 75
            Library:SetDPIScale(scale)
        else
            Library:SetDPIScale(100)
        end
    end
end)

ThemeManager:LoadDefault()

task.spawn(function()
    task.wait(0.1)
    if Toggles.AutoShowUI.Value == false then
        Library:Toggle()
    end
end)

Library:Notify("Script loaded.", 2)
Library:Notify("Report bug and give suggestion in Discord!", 5)

end)

if not eh_success then
    Library:Notify("ERROR: " .. tostring(err), 4)
end
