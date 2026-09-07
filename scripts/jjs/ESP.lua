local ESP = {}

local cloneReference = cloneref or function(object) return object end
local Players = cloneReference(game:GetService("Players"))
local RunService = cloneReference(game:GetService("RunService"))

local Cache = {}
local ActiveMarks = {}

local SPECIAL_COOLDOWNS = {
    Itadori = { Name = "Feint", Duration = 2 },
    Hakari = { Name = "Counter", Duration = 16 },
}

local function awaitDependency(State, name)
    local modules = State.Modules
    local failed = State.ModuleFailed
    local started = os.clock()

    while modules and not modules[name] and not (failed and failed[name]) and os.clock() - started < 45 do
        task.wait()
    end

    return modules and modules[name]
end

function ESP.Init(State)
    local Assets = awaitDependency(State, "ESPAssets")
    local TrackingModule = awaitDependency(State, "ESPTracking")
    local Effects = awaitDependency(State, "ESPEffects")
    local Renderer = awaitDependency(State, "ESPRenderer")
    local BarsModule = awaitDependency(State, "ESPBars")
    local MovesetModule = awaitDependency(State, "ESPMoveset")
    local PlayerInfoModule = awaitDependency(State, "ESPPlayerInfo")
    local TracersModule = awaitDependency(State, "ESPTracers")

    if not Assets
        or not TrackingModule
        or not Effects
        or not Renderer
        or not BarsModule
        or not MovesetModule
        or not PlayerInfoModule
        or not TracersModule
    then
        warn("ESP dependencies failed to load")
        return
    end

    local Tracking = TrackingModule.new(Assets)
    local toggle = State.Toggles.ESP

    local function cleanupCacheEntry(player, assets)
        Assets.Destroy(assets)
        Cache[player] = nil
    end

    local function cleanupAll()
        for player, assets in pairs(Cache) do
            cleanupCacheEntry(player, assets)
        end
        table.clear(ActiveMarks)
    end

    local function handleToggleChange()
        if not toggle.Value then
            for _, assets in pairs(Cache) do
                Assets.Hide(assets)
            end
        end
    end

    Effects.Init(State, Cache, ActiveMarks, SPECIAL_COOLDOWNS)

    local playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
        if player == Players.LocalPlayer then
            cleanupAll()
        end
    end)
    table.insert(State.Connections, playerRemovingConnection)

    local renderFrame = Renderer.new({
        State = State,
        Assets = Assets,
        Tracking = Tracking,
        Cache = Cache,
        ActiveMarks = ActiveMarks,
        SpecialCooldowns = SPECIAL_COOLDOWNS,
        Toggle = toggle,
        CleanupCacheEntry = cleanupCacheEntry,
        BarsModule = BarsModule,
        MovesetModule = MovesetModule,
        PlayerInfoModule = PlayerInfoModule,
        TracersModule = TracersModule,
    })

    local renderConnection = RunService.RenderStepped:Connect(renderFrame)
    table.insert(State.Connections, renderConnection)

    local toggleConnection = toggle:GetPropertyChangedSignal("Value"):Connect(handleToggleChange)
    table.insert(State.Connections, toggleConnection)

    handleToggleChange()
end

return ESP

