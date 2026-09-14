print("[My_Script] v" .. tostring(os.date("%Y-%m-%d %H:%M:%S")) .. " executing...")
--=====================================================================
-- My_Script — WindUI + Game Framework (consolidated)
--=====================================================================
print("[My_Script] executing...")

--=====================================================================
-- 1. UI Library
--=====================================================================
local WindUI = loadstring(game:HttpGet(
    "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()

--=====================================================================
-- 2. Game Framework
--=====================================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Framework = ReplicatedStorage:WaitForChild("Framework", 30)
if not Framework then
    warn("[My_Script] Framework not found — is this the right game?")
    return
end
local Library = require(Framework:WaitForChild("Library"))

local AutoService      = Library:GetService("AutoService")
local InventoryService = Library:GetService("InventoryService")
local GachaService     = Library:GetService("GachaService")
local StatsService     = Library:GetService("StatsService")
local UnlockService    = Library:GetService("UnlockService")
local UpgradeService   = Library:GetService("UpgradeService")
local DailyRewardSvc   = Library:GetService("DailyRewardService")

local Remote = Library.Remote
local LP     = Library.LocalPlayer
print("[My_Script] services OK")

--=====================================================================
-- 3. State (forward declarations)
--=====================================================================
local Selected = "None"
local DropdownWorld, DropdownEnem

--=====================================================================
-- 4. Tutorial gate + safe firing
--=====================================================================
local function tutorialDone()
    local d = Library.PlayerData
    if not d or not next(d) then return true end
    return d.Tutorial == nil or d.Tutorial.Completed == true
end

local function safeFire(...)
    if not tutorialDone() then
        WindUI:Notify({
            Title = "Blocked",
            Content = "Finish the tutorial before using auto features.",
            Duration = 3, Icon = "alert-triangle",
        })
        return false
    end
    local ok, err = pcall(function() Remote:Fire(...) end)
    if not ok then
        warn("[My_Script] Remote error:", err)
        return false
    end
    return true
end

--=====================================================================
-- 5. Window
--=====================================================================
local Window = WindUI:CreateWindow({
    Title = "My_Script",
    Icon = "house",
    Author = "by Me",
    Folder = "MySuperHub",
    Topbar = { Height = 52, ButtonsType = "Default" },
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    ToggleKey = Enum.KeyCode.LeftShift,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    HideSearchBar = true,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            setclipboard(game.GameId)
            WindUI:Notify({
                Title = "Notification",
                Content = "Game Id Copied !",
                Duration = 3, Icon = "info",
            })
        end,
    },
})

Window:EditOpenButton({
    Title = "Show / Hide", Icon = "house",
    CornerRadius = UDim.new(0, 16), StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("FF0F7B"), Color3.fromHex("F89B29")),
    OnlyMobile = false, Enabled = true, Draggable = true,
})

print("[My_Script] window OK")

--=====================================================================
-- 6. Helpers
--=====================================================================
local enemiesFolder, serverFolder

local function toast(title, content, icon)
    WindUI:Notify({
        Title = title or "Notification",
        Content = content or "",
        Duration = 3,
        Icon = icon or "info",
    })
end

local function getWorlds()
    local list = {}
    if not serverFolder then return list end
    for _, c in ipairs(serverFolder:GetChildren()) do
        table.insert(list, c.Name)
    end
    return list
end

local function getEnemiesOf(worldName)
    local list = {}
    if not serverFolder then return list end
    local world = serverFolder:FindFirstChild(worldName)
    if not world then return list end
    for _, c in ipairs(world:GetChildren()) do
        table.insert(list, c:GetAttribute("Name") or c.Name)
    end
    return list
end

local function getEnemiesInRange()
    local list = {}
    local folder = workspace._ENEMIES and workspace._ENEMIES:FindFirstChild("InRange")
    if not folder then return list end
    for _, v in ipairs(folder:GetChildren()) do
        if v:IsA("Model") then table.insert(list, v) end
    end
    return list
end

local function enemyNamesInRange()
    local names = {}
    for _, e in ipairs(getEnemiesInRange()) do
        if e and e.Parent then table.insert(names, e.Name) end
    end
    return names
end

--=====================================================================
-- 7. Async setup of _ENEMIES folder (does not block)
--=====================================================================
task.spawn(function()
    enemiesFolder = workspace:WaitForChild("_ENEMIES", 60)
    if not enemiesFolder then
        warn("[My_Script] _ENEMIES never appeared")
        return
    end
    serverFolder = enemiesFolder:WaitForChild("Server", 60)
    if not serverFolder then
        warn("[My_Script] _ENEMIES.Server never appeared")
        return
    end
    print("[My_Script] _ENEMIES ready")
    -- Populate world dropdown once data is available
    local w = getWorlds()
    if #w > 0 and DropdownWorld then
        Selected = w[1]
        DropdownWorld:Refresh(w)
        if DropdownEnem then
            DropdownEnem:Refresh(getEnemiesOf(Selected))
        end
    end
end)

--=====================================================================
-- 8. TAB: Main
--=====================================================================
local TabMain = Window:Tab({ Title = "Main", Icon = "bird" })

DropdownWorld = TabMain:Dropdown({
    Title = "Select World",
    Values = getWorlds(), Value = Selected,
    Multi = false, MenuWidth = 180, AllowNone = false,
    SearchBarEnabled = true,
    Callback = function(option)
        Selected = option
        toast("Notification", "World: " .. tostring(Selected))
        if DropdownEnem then
            DropdownEnem:Refresh(getEnemiesOf(Selected))
        end
    end,
})

DropdownEnem = TabMain:Dropdown({
    Title = "Enemies",
    Desc = "Enemies of the world selected",
    Values = getEnemiesOf(Selected), Value = {},
    Multi = true, MenuWidth = 180, AllowNone = true,
    SearchBarEnabled = true,
    Callback = function() end,
})

TabMain:Button({
    Title = "Refresh Enemies", Icon = "refresh-cw",
    Color = Color3.fromHex("#a2ff30"), Justify = "Center",
    Callback = function()
        DropdownEnem:Refresh(getEnemiesOf(Selected))
        toast("Notification", "Refreshed Enemies !")
    end,
})

--=====================================================================
-- 9. TAB: Combat
--=====================================================================
local TabCombat = Window:Tab({ Title = "Combat", Icon = "swords" })

local autoAttackOn, autoAttackToken = false, 0
TabCombat:Toggle({
    Title = "Auto Attack",
    Desc = "Sends ClickSystem.Execute for every enemy in range",
    Value = false, Type = "Toggle", Icon = "zap",
    Callback = function(state)
        autoAttackOn = state
        if not autoAttackOn then autoAttackToken += 1 return end
        autoAttackToken += 1
        local myToken = autoAttackToken
        task.spawn(function()
            while autoAttackOn and autoAttackToken == myToken do
                local names = enemyNamesInRange()
                if #names > 0 then
                    safeFire("ClickSystem", "Execute", names)
                end
                task.wait(0.1)
            end
        end)
    end,
})

local autoCastOn, autoCastToken = false, 0
TabCombat:Toggle({
    Title = "Auto Cast Skill",
    Desc = "Fires ClickSystem.CastSkill on enemies in range",
    Value = false, Type = "Toggle", Icon = "sparkles",
    Callback = function(state)
        autoCastOn = state
        if not autoCastOn then autoCastToken += 1 return end
        autoCastToken += 1
        local myToken = autoCastToken
        task.spawn(function()
            while autoCastOn and autoCastToken == myToken do
                safeFire("ClickSystem", "CastSkill", enemyNamesInRange())
                task.wait(0.3)
            end
        end)
    end,
})

local autoWarriorOn, autoWarriorToken = false, 0
TabCombat:Toggle({
    Title = "Auto Warrior Closest",
    Desc = "Fires WarriorSystem.Closest for each of your active warriors",
    Value = false, Type = "Toggle", Icon = "sword",
    Callback = function(state)
        autoWarriorOn = state
        if not autoWarriorOn then autoWarriorToken += 1 return end
        autoWarriorToken += 1
        local myToken = autoWarriorToken
        task.spawn(function()
            while autoWarriorOn and autoWarriorToken == myToken do
                local myWarriors = workspace._ENEMIES:FindFirstChild("Client")
                if myWarriors then
                    for _, folder in ipairs(myWarriors:GetDescendants()) do
                        if folder:IsA("Folder") and folder:GetAttribute("Target") ~= nil then
                            safeFire("WarriorSystem", "Closest", folder.Name)
                        end
                    end
                end
                task.wait(0.15)
            end
        end)
    end,
})

TabCombat:Button({
    Title = "Dash", Icon = "wind", Justify = "Center",
    Callback = function()
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not (hum and hrp) then return end
        local dir = hum.MoveDirection
        if dir.Magnitude == 0 then return end

        local speed = math.clamp(hum.WalkSpeed, 26, 200) / 26 * 20 + 130
        local att = Instance.new("Attachment", hrp)
        local ao = Instance.new("AlignOrientation")
        ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
        ao.MaxTorque = math.huge
        ao.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + dir * 3)
        ao.Attachment0 = att
        ao.RigidityEnabled = true
        ao.Parent = hrp
        local lv = Instance.new("LinearVelocity")
        lv.Attachment0 = att
        lv.MaxForce = math.huge
        lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        lv.VectorVelocity = dir * speed
        lv.Parent = hrp
        task.delay(0.2, function()
            ao:Destroy(); lv:Destroy(); att:Destroy()
        end)
    end,
})

--=====================================================================
-- 10. TAB: Auto (via game's own AutoSystem)
--=====================================================================
local TabAuto = Window:Tab({ Title = "Auto", Icon = "cog" })

local AutoData = Library:GetData("AutoData")
local autoToggles = {}
local pendingClick = {}

for key, cfg in pairs(AutoData) do
    if cfg.Kind == "Toggle" and not cfg.Group and not cfg.Page then
        autoToggles[key] = TabAuto:Toggle({
            Title = cfg.Name or key,
            Desc = cfg.Desc,
            Value = false,
            Type = "Toggle",
            Callback = function(_)
                if pendingClick[key] then return end
                pendingClick[key] = true
                safeFire("AutoSystem", "Toggle", key)
                task.delay(0.4, function() pendingClick[key] = nil end)
            end,
        })
    end
end

Library.Signal.DataChanged:Connect(function()
    local s = Library.PlayerData and Library.PlayerData.AutoSettings
    if not s then return end
    for key, obj in pairs(autoToggles) do
        local want = s[key] == true
        pcall(function() obj:Set(want) end)
    end
end)

local function toggleAllByPrefix(prefix)
    for key in pairs(AutoData) do
        if key:sub(1, #prefix) == prefix then
            safeFire("AutoSystem", "Toggle", key)
            task.wait(0.15)
        end
    end
end

TabAuto:Button({
    Title = "Toggle All Claim Autos", Icon = "gift", Justify = "Center",
    Callback = function()
        toggleAllByPrefix("AutoClaim")
        toast("Auto", "Toggled claim autos")
    end,
})

TabAuto:Button({
    Title = "Toggle Upgrade + RankUp", Icon = "arrow-up-circle",
    Justify = "Center",
    Callback = function()
        safeFire("AutoSystem", "Toggle", "AutoUpgrade")
        task.wait(0.15)
        safeFire("AutoSystem", "Toggle", "AutoRankUp")
        toast("Auto", "Toggled upgrade + rebirth")
    end,
})

TabAuto:Button({
    Title = "Unlock All Systems", Icon = "unlock",
    Justify = "Center", Color = Color3.fromHex("#5cc9ff"),
    Callback = function()
        local unlocked, attempted = 0, 0
        local UnlockData = Library:GetData("UnlockData")
        for id in pairs(UnlockData) do
            attempted += 1
            if UnlockService:Check(LP, id) then
                unlocked += 1
            else
                safeFire("UnlockSystem", "Validate", id)
            end
            task.wait(0.15)
        end
        toast("Unlock", ("Tried %d, had %d"):format(attempted, unlocked), "unlock")
    end,
})

--=====================================================================
-- 11. TAB: Stats
--=====================================================================
local TabStats = Window:Tab({ Title = "Stats", Icon = "bar-chart-3" })

local STATS_ID, STATS_TYPE = "Stats", "Default"
local targetLevels = {}

TabStats:Input({
    Title = "Stat Id", Value = STATS_ID,
    Callback = function(t) STATS_ID = t end,
})
TabStats:Input({
    Title = "Stat Type", Value = STATS_TYPE,
    Callback = function(t) STATS_TYPE = t end,
})

local autoStatsOn, autoStatsToken = false, 0
TabStats:Toggle({
    Title = "Auto Reroll Stats",
    Desc = "Spins stats until each target level is met, then locks it",
    Value = false, Type = "Toggle", Icon = "dice-5",
    Callback = function(state)
        autoStatsOn = state
        if not autoStatsOn then autoStatsToken += 1 return end
        autoStatsToken += 1
        local myToken = autoStatsToken

        task.spawn(function()
            while autoStatsOn and autoStatsToken == myToken do
                local data = Library.PlayerData
                local StatsData = Library:GetData("StatsData")
                local entry = StatsData[STATS_ID] and StatsData[STATS_ID][STATS_TYPE]
                if data and entry then
                    local cost = StatsService:GetCost(LP, STATS_ID, STATS_TYPE)
                    local currency = entry.Currency
                    local have = data.Items and (data.Items[currency] or 0) or 0

                    if have < cost then
                        autoStatsOn = false
                        toast("Auto Stats", "Not enough " .. tostring(currency), "alert-triangle")
                        break
                    end

                    local targets = {}
                    local allLocked = true
                    local statKey = ("%s_%s"):format(STATS_ID, STATS_TYPE)
                    local current = data.Stats[statKey]

                    for statName, maxLevel in pairs(StatsService.Targets[("%s%s"):format(STATS_ID, STATS_TYPE)] or {}) do
                        local target = targetLevels[statName] or maxLevel
                        targets[statName] = target
                        local cur = current[statName]
                        if cur then
                            if cur.Level >= target and not cur.Locked then
                                safeFire("StatsSystem", "Lock", STATS_ID, STATS_TYPE, statName)
                                task.wait(0.1)
                            elseif not cur.Locked then
                                allLocked = false
                            end
                        end
                    end

                    if allLocked then
                        autoStatsOn = false
                        toast("Auto Stats", "All targets reached", "check-circle")
                        break
                    end

                    safeFire("StatsSystem", "Spin", STATS_ID, STATS_TYPE, targets)
                end
                task.wait(0.35)
            end
        end)
    end,
})

TabStats:Button({
    Title = "Set Targets to Max", Icon = "target", Justify = "Center",
    Callback = function()
        local StatsData = Library:GetData("StatsData")
        local entry = StatsData[STATS_ID] and StatsData[STATS_ID][STATS_TYPE]
        if not entry then
            return toast("Stats", "Unknown Id/Type", "alert-triangle")
        end
        targetLevels = {}
        for statName, info in pairs(entry.List) do
            targetLevels[statName] = info.MaxLevel
        end
        toast("Stats", "Targets set to Max", "check")
    end,
})

--=====================================================================
-- 12. TAB: Gacha
--=====================================================================
local TabGacha = Window:Tab({ Title = "Gacha", Icon = "dice-5" })

local GACHA_ID, GACHA_TYPE = "Powers", "Standard"

TabGacha:Input({
    Title = "Gacha Id", Value = GACHA_ID,
    Callback = function(t) GACHA_ID = t end,
})
TabGacha:Input({
    Title = "Gacha Type", Value = GACHA_TYPE,
    Callback = function(t) GACHA_TYPE = t end,
})

TabGacha:Dropdown({
    Title = "Stop On Rarities",
    Desc = "Auto-spin stops when one of these rarities is obtained",
    Values = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythical", "Secret" },
    Value = { "Legendary", "Mythical", "Secret" },
    Multi = true, AllowNone = true, SearchBarEnabled = false,
    Callback = function(option)
        local targets = {}
        for _, r in ipairs(option) do targets[r] = true end
        GachaService.Targets[GACHA_ID] = targets
    end,
})

local autoSpinOn, autoSpinToken = false, 0
TabGacha:Toggle({
    Title = "Auto Spin",
    Value = false, Type = "Toggle", Icon = "refresh-cw",
    Callback = function(state)
        autoSpinOn = state
        if not autoSpinOn then autoSpinToken += 1 return end
        autoSpinToken += 1
        local myToken = autoSpinToken
        task.spawn(function()
            while autoSpinOn and autoSpinToken == myToken do
                local targets = GachaService.Targets[GACHA_ID] or {}
                safeFire("GachaSystem", "Spin", GACHA_ID, GACHA_TYPE, targets, nil)
                task.wait(0.35)
            end
        end)
    end,
})

--=====================================================================
-- 13. TAB: Movement
--=====================================================================
local TabMove = Window:Tab({ Title = "Movement", Icon = "wind" })

TabMove:Button({
    Title = "Toggle Mount", Icon = "rocket", Justify = "Center",
    Callback = function()
        if LP:GetAttribute("OnMount") then
            safeFire("MountSystem", "Remove")
        else
            safeFire("MountSystem", "Add")
        end
    end,
})

TabMove:Toggle({
    Title = "Fly",
    Desc = "Works when you have a flying mount equipped",
    Value = false, Type = "Toggle", Icon = "plane",
    Callback = function(state)
        LP:SetAttribute("Fly", state or nil)
    end,
})

local MapData = Library:GetData("MapData")
local mapIds = {}
for id in pairs(MapData) do table.insert(mapIds, id) end
table.sort(mapIds)

local teleportTarget = mapIds[1] or "None"
TabMove:Dropdown({
    Title = "Teleport Map",
    Values = mapIds, Value = teleportTarget,
    Multi = false, AllowNone = false, SearchBarEnabled = true,
    Callback = function(option) teleportTarget = option end,
})

TabMove:Button({
    Title = "Teleport", Icon = "map-pin",
    Color = Color3.fromHex("#a2ff30"), Justify = "Center",
    Callback = function()
        safeFire("TeleportSystem", "To", teleportTarget)
        toast("Teleport", "Sent to " .. tostring(teleportTarget))
    end,
})

TabMove:Button({
    Title = "Buy Map", Icon = "shopping-cart", Justify = "Center",
    Callback = function()
        safeFire("TeleportSystem", "Buy", teleportTarget)
        toast("Buy Map", "Sent request for " .. tostring(teleportTarget))
    end,
})

local gamemodeIds = AutoService:GetModes()
local gamemodeTarget = gamemodeIds[1] or "None"
TabMove:Dropdown({
    Title = "Gamemode",
    Values = gamemodeIds, Value = gamemodeTarget,
    Multi = false, AllowNone = false, SearchBarEnabled = false,
    Callback = function(option) gamemodeTarget = option end,
})

TabMove:Button({
    Title = "Create Gamemode", Icon = "gamepad-2", Justify = "Center",
    Callback = function()
        local data = Library.PlayerData
        if not data then return end
        local mode, map, diff = AutoService:Resolve(data)
        local useMode = gamemodeTarget or mode
        safeFire("GamemodeSystem", "Create", useMode, map, diff, false)
        toast("Gamemode", "Creating " .. tostring(useMode))
    end,
})

TabMove:Button({
    Title = "Leave Gamemode", Icon = "log-out", Justify = "Center",
    Callback = function()
        safeFire("GamemodeSystem", "Quit")
    end,
})

--=====================================================================
-- 14. TAB: Game UIs
--=====================================================================
local TabGameUI = Window:Tab({ Title = "Game UIs", Icon = "layout-grid" })

local function openGameGui(name)
    Library.Signal.Tell:Fire({ "UIController", "UpdateGui", name })
end

for _, name in ipairs({
    "Upgrade", "Rebirth", "Inventory", "Gacha",
    "Battlepass", "DailyRewards", "Achievements",
    "Leaderboard", "StockShop", "Stats",
}) do
    TabGameUI:Button({
        Title = name, Icon = "external-link", Justify = "Center",
        Callback = function() openGameGui(name) end,
    })
end

--=====================================================================
-- 15. TAB: Player
--=====================================================================
local TabPlayer = Window:Tab({ Title = "Player", Icon = "user" })

local statsLabel = TabPlayer:Paragraph({
    Title = "Live Stats", Desc = "Loading...",
})

local function refreshPlayerInfo()
    local data = Library.PlayerData
    if not data or not next(data) then
        statsLabel:SetDesc("Player data not loaded yet")
        return
    end
    local lines = {}
    lines[#lines + 1] = "Energy: " .. tostring(data.Energy or 0)
    lines[#lines + 1] = "Damage: " .. tostring(data.Damage or 0)
    if data.Items then
        lines[#lines + 1] = "Coins: " .. tostring(data.Items.Coins or 0)
        lines[#lines + 1] = "Gems: "  .. tostring(data.Items.Gems  or 0)
    end
    if data.UnlockedMap then
        local c = 0
        for _ in pairs(data.UnlockedMap) do c += 1 end
        lines[#lines + 1] = "Maps: " .. c
            .. " (progress " .. Library.Utils.GetMapProgress(data) .. ")"
    end
    if data.AutoSettings then
        local on, total = 0, 0
        for _, v in pairs(data.AutoSettings) do
            if typeof(v) == "boolean" then
                total += 1
                if v then on += 1 end
            end
        end
        lines[#lines + 1] = ("Auto: %d/%d on"):format(on, total)
    end
    statsLabel:SetDesc(table.concat(lines, "\n"))
end

TabPlayer:Button({
    Title = "Refresh", Icon = "refresh-cw",
    Callback = refreshPlayerInfo,
})

Library.Signal.DataChanged:Connect(function() pcall(refreshPlayerInfo) end)
pcall(refreshPlayerInfo)
task.spawn(function()
    while task.wait(5) do pcall(refreshPlayerInfo) end
end)

--=====================================================================
-- 16. TAB: Info
--=====================================================================
local TabInfo = Window:Tab({ Title = "Info", Icon = "info" })

-- ---- Player Summary ----
local playerInfo = TabInfo:Paragraph({
    Title = "Player", Desc = "Loading...",
})

local function refreshInfoPlayer()
    local d = Library.PlayerData
    if not d or not next(d) then
        playerInfo:SetDesc("Player data not loaded yet")
        return
    end
    local lines = {}
    lines[#lines + 1] = ("Energy: %s"):format(tostring(d.Energy or 0))
    lines[#lines + 1] = ("Damage: %s"):format(tostring(d.Damage or 0))
    lines[#lines + 1] = ("Map Progress: %d"):format(Library.Utils.GetMapProgress(d))
    lines[#lines + 1] = ("Current Map: %s"):format(tostring(d.CurrentMap or "?"))
    if d.Items then
        local items = {}
        for k, v in pairs(d.Items) do
            if typeof(v) == "number" and v > 0 then
                table.insert(items, ("%s=%s"):format(k, tostring(v)))
            end
        end
        table.sort(items)
        if #items > 0 then
            lines[#lines + 1] = "Items: " .. table.concat(items, ", ")
        end
    end
    playerInfo:SetDesc(table.concat(lines, "\n"))
end

TabInfo:Button({
    Title = "Refresh Player Info", Icon = "refresh-cw",
    Callback = refreshInfoPlayer,
})
Library.Signal.DataChanged:Connect(function() pcall(refreshInfoPlayer) end)
pcall(refreshInfoPlayer)

-- ---- Enemy Browser ----
local enemyData = Library:GetData("EnemyData")
local enemySummary = TabInfo:Paragraph({
    Title = "Enemy Browser", Desc = "Pick an enemy below",
})
local enemyPickWorld = (getWorlds()[1] or "None")

TabInfo:Dropdown({
    Title = "World",
    Values = getWorlds(), Value = enemyPickWorld,
    Multi = false, AllowNone = false, SearchBarEnabled = true,
    Callback = function(opt) enemyPickWorld = opt end,
})

TabInfo:Dropdown({
    Title = "Enemy",
    Values = getEnemiesOf(enemyPickWorld), Value = nil,
    Multi = false, AllowNone = true, SearchBarEnabled = true,
    Callback = function(opt)
        if not opt then
            enemySummary:SetDesc("No enemy selected")
            return
        end
        local info = enemyData[opt]
        if not info then
            enemySummary:SetDesc(("No EnemyData entry for %q"):format(opt))
            return
        end
        local lines = {}
        lines[#lines + 1] = ("Name: %s"):format(info.Name or opt)
        if info.HP then lines[#lines + 1] = ("Base HP: %s"):format(tostring(info.HP)) end
        if info.Rarity then lines[#lines + 1] = ("Rarity: %s"):format(info.Rarity) end
        if info.Boost then
            for k, v in pairs(info.Boost) do
                lines[#lines + 1] = ("  %s: %s"):format(k, tostring(v))
            end
        end
        if info.Drops then
            lines[#lines + 1] = "Drops:"
            for _, drop in ipairs(info.Drops) do
                lines[#lines + 1] = ("  • %s (%s%%)"):format(
                    tostring(drop.Id or drop.Type),
                    tostring(drop.Chance or "?")
                )
            end
        end
        enemySummary:SetDesc(table.concat(lines, "\n"))
    end,
})

-- ---- Data Browser ----
local ItemSystems = {
    Pet = "PetData",
    Weapon = "WeaponData",
    Avatar = "AvatarData",
    Accessory = "AccessoryData",
    Mount = "MountData",
    Amulet = "AmuletData",
    Warrior = "WarriorData",
    Item = "ItemData",
}

local browserSystem = "Pet"
local browserQuery = ""

local browserOutput = TabInfo:Paragraph({
    Title = "Data Browser", Desc = "Choose a system and search",
})

local function runBrowser()
    local dataName = ItemSystems[browserSystem]
    local ok, data = pcall(function() return Library:GetData(dataName) end)
    if not ok or not data then
        browserOutput:SetDesc(("Could not load %s"):format(tostring(dataName)))
        return
    end

    local q = browserQuery:lower()
    local matches = {}
    for id, entry in pairs(data) do
        if typeof(entry) == "table" then
            local name = tostring(entry.Name or id)
            local hit = q == ""
                or name:lower():find(q, 1, true)
                or tostring(id):lower():find(q, 1, true)
            if hit then
                table.insert(matches, { Id = id, Name = name, Rarity = entry.Rarity })
            end
        end
    end
    table.sort(matches, function(a, b) return tostring(a.Name) < tostring(b.Name) end)

    local shown = 0
    local lines = { ("Matches: %d"):format(#matches) }
    for _, m in ipairs(matches) do
        shown += 1
        if shown > 40 then
            lines[#lines + 1] = ("  ... and %d more"):format(#matches - 40)
            break
        end
        lines[#lines + 1] = ("  • %s [%s]%s"):format(
            m.Name, tostring(m.Id),
            m.Rarity and (" — " .. m.Rarity) or ""
        )
    end
    browserOutput:SetDesc(table.concat(lines, "\n"))
end

TabInfo:Dropdown({
    Title = "System",
    Values = (function()
        local t = {}
        for k in pairs(ItemSystems) do table.insert(t, k) end
        table.sort(t)
        return t
    end)(),
    Value = browserSystem,
    Multi = false, AllowNone = false, SearchBarEnabled = false,
    Callback = function(opt) browserSystem = opt; runBrowser() end,
})

TabInfo:Input({
    Title = "Search",
    Placeholder = "type to filter by name or id",
    Value = "",
    Callback = function(t) browserQuery = t; runBrowser() end,
})

TabInfo:Button({
    Title = "Search", Icon = "search", Justify = "Center",
    Callback = runBrowser,
})

pcall(runBrowser)

-- ---- Maps & Unlocks ----
local mapInfo = TabInfo:Paragraph({
    Title = "Maps", Desc = "Loading...",
})

local function refreshMaps()
    local d = Library.PlayerData
    local MapData = Library:GetData("MapData")
    if not (d and MapData) then
        mapInfo:SetDesc("Not ready")
        return
    end
    local lines = {}
    local maps = {}
    for id, info in pairs(MapData) do
        table.insert(maps, {
            Id = id,
            Order = info.Order or 0,
            Name = info.Name or id,
        })
    end
    table.sort(maps, function(a, b) return a.Order < b.Order end)
    for _, m in ipairs(maps) do
        local unlocked = d.UnlockedMap and d.UnlockedMap[m.Id] and "✔" or "✖"
        lines[#lines + 1] = ("  [%s] %s"):format(unlocked, m.Name)
    end
    mapInfo:SetDesc(table.concat(lines, "\n"))
end

TabInfo:Button({
    Title = "Refresh Maps", Icon = "map", Justify = "Center",
    Callback = refreshMaps,
})
Library.Signal.DataChanged:Connect(function() pcall(refreshMaps) end)
pcall(refreshMaps)

-- ---- Equipped ----
local equippedInfo = TabInfo:Paragraph({
    Title = "Equipped", Desc = "Loading...",
})

local function refreshEquipped()
    local d = Library.PlayerData
    if not d then return end
    local lines = {}
    local function add(label, list)
        if not list then return end
        local ids = {}
        for _, v in ipairs(list) do
            local id = typeof(v) == "table" and v.Id or v
            table.insert(ids, tostring(id))
        end
        lines[#lines + 1] = ("%s: %s"):format(
            label,
            #ids > 0 and table.concat(ids, ", ") or "none"
        )
    end
    add("Pets",        d.PetsEquipped)
    add("Weapons",     d.WeaponsEquipped)
    add("Avatars",     d.AvatarsEquipped)
    add("Accessories", d.AccessoriesEquipped)
    add("Mounts",      d.MountsEquipped)
    add("Amulets",     d.AmuletsEquipped)
    equippedInfo:SetDesc(table.concat(lines, "\n"))
end

TabInfo:Button({
    Title = "Refresh Equipped", Icon = "refresh-cw", Justify = "Center",
    Callback = refreshEquipped,
})
Library.Signal.DataChanged:Connect(function() pcall(refreshEquipped) end)
pcall(refreshEquipped)

-- ---- Multipliers ----
local multiplierInfo = TabInfo:Paragraph({
    Title = "Multipliers", Desc = "Loading...",
})

local function refreshMultipliers()
    local BoostData = Library:GetData("BoostData")
    if not BoostData then return end
    local MultiplierSvc = Library:GetService("MultiplierService")
    local lines = {}
    for id, info in pairs(BoostData) do
        if not info.Hide then
            local ok, v = pcall(function() return MultiplierSvc[id](LP) end)
            if ok and v then
                lines[#lines + 1] = ("  %s: %s"):format(info.Name or id, tostring(v))
            end
        end
    end
    table.sort(lines)
    multiplierInfo:SetDesc(table.concat(lines, "\n"))
end

TabInfo:Button({
    Title = "Refresh Multipliers", Icon = "trending-up", Justify = "Center",
    Callback = refreshMultipliers,
})
pcall(refreshMultipliers)
task.spawn(function()
    while task.wait(10) do pcall(refreshMultipliers) end
end)

--=====================================================================
-- 17. Notify
--=====================================================================
toast("Notification", "Script Loaded successfully !")

--=====================================================================
-- 18. Safety — disable running toggles if tutorial resets
--=====================================================================
task.spawn(function()
    while task.wait(5) do
        if not tutorialDone() then
            if autoAttackOn then  autoAttackOn = false;  autoAttackToken += 1 end
            if autoCastOn then    autoCastOn = false;    autoCastToken += 1   end
            if autoWarriorOn then autoWarriorOn = false; autoWarriorToken += 1 end
            if autoStatsOn then   autoStatsOn = false;   autoStatsToken += 1  end
            if autoSpinOn then    autoSpinOn = false;    autoSpinToken += 1   end
        end
    end
end)
