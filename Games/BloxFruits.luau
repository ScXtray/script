--[[
    XTRAY HUB - Blox Fruits Script
    Repo: https://github.com/ScXtray/script
    Keyless & Free
--]]

local fetcher, Settings = ...

-- ============================================================
-- CONFIG (semua default false — diubah via GUI toggle)
-- ============================================================
local Config = {
    AutoFarm         = false,
    AutoQuest        = false,
    AutoAttack       = false,
    AutoShoot        = false,
    SilentAim        = false,
    AimBotGun        = false,
    Noclip           = false,
    BringMobs        = false,
    BringDistance    = 15,
    AutoServerHop    = false,
    ServerHopMinPlayers = 8,
    AutoChest        = false,
    AutoBerry        = false,
    AutoBuso         = false,
    WalkSpeedBypass  = false,
    WalkSpeed        = 24,
    JoinTeam         = Settings and Settings.JoinTeam or "Pirates",
    Translator       = Settings and Settings.Translator or false,
}

-- ============================================================
-- SERVICES
-- ============================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TeleportService   = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local UserInputService  = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character   = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid    = Character:WaitForChild("Humanoid")
local RootPart    = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid  = char:WaitForChild("Humanoid")
    RootPart  = char:WaitForChild("HumanoidRootPart")
    task.wait(1)
    if Config.WalkSpeedBypass then
        ApplyWalkSpeed()
    end
end)

-- ============================================================
-- REMOTES
-- ============================================================
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CommF   = Remotes:WaitForChild("CommF_")
local CommE   = Remotes:WaitForChild("CommE")

-- ============================================================
-- WORLD REFERENCES
-- ============================================================
local WorldOrigin    = workspace:WaitForChild("_WorldOrigin")
local EnemySpawns    = WorldOrigin:WaitForChild("EnemySpawns")
local Locations      = WorldOrigin:WaitForChild("Locations")
local EnemiesFolder  = workspace:WaitForChild("Enemies")
local ChestsFolder   = workspace:WaitForChild("ChestModels")

-- ============================================================
-- UTILITIES
-- ============================================================

local function IsAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function GetDistance(pos)
    if typeof(pos) ~= "Vector3" then pos = pos.Position end
    return LocalPlayer:DistanceFromCharacter(pos)
end

local function InvokeCommF(...)
    return CommF:InvokeServer(...)
end

local function Teleport(cframe)
    if not IsAlive(Character) then return end
    RootPart.CFrame = cframe
end

local function WaitForRespawn()
    if not IsAlive(Character) then
        LocalPlayer.CharacterAdded:Wait()
        task.wait(2)
        Character = LocalPlayer.Character
        Humanoid  = Character:WaitForChild("Humanoid")
        RootPart  = Character:WaitForChild("HumanoidRootPart")
    end
end

-- ============================================================
-- LOAD LIBRARY (UI)
-- ============================================================

local Library = fetcher.load("{Repository}Library/main.luau")()

local Window = Library:MakeWindow({
    Title       = "Xtray Hub",
    SubTitle    = "Blox Fruits",
    ScriptFolder = "XtrayHub",
})

-- ============================================================
-- TAB: FARM
-- ============================================================

local FarmTab = Window:MakeTab({ Title = "Farm", Icon = "rbxassetid://10709791437" })

FarmTab:AddSection("Auto Farm")

FarmTab:AddToggle({
    Title    = "Auto Farm",
    Default  = false,
    Callback = function(v) Config.AutoFarm = v end,
    Flag     = "AutoFarm",
})

FarmTab:AddToggle({
    Title    = "Auto Quest",
    Default  = false,
    Callback = function(v) Config.AutoQuest = v end,
    Flag     = "AutoQuest",
})

FarmTab:AddToggle({
    Title    = "Auto Attack",
    Default  = false,
    Callback = function(v) Config.AutoAttack = v end,
    Flag     = "AutoAttack",
})

FarmTab:AddToggle({
    Title    = "Auto Shoot (Gun)",
    Default  = false,
    Callback = function(v) Config.AutoShoot = v end,
    Flag     = "AutoShoot",
})

FarmTab:AddSection("Farming Tools")

FarmTab:AddToggle({
    Title    = "Bring Mobs",
    Default  = false,
    Callback = function(v) Config.BringMobs = v end,
    Flag     = "BringMobs",
})

FarmTab:AddSlider({
    Title    = "Bring Distance",
    Min      = 5,
    Max      = 60,
    Increment = 1,
    Default  = 15,
    Callback = function(v) Config.BringDistance = v end,
    Flag     = "BringDistance",
})

FarmTab:AddSection("Chest & Berry")

FarmTab:AddToggle({
    Title    = "Auto Chest Farm",
    Default  = false,
    Callback = function(v) Config.AutoChest = v end,
    Flag     = "AutoChest",
})

FarmTab:AddToggle({
    Title    = "Auto Berry Farm",
    Default  = false,
    Callback = function(v) Config.AutoBerry = v end,
    Flag     = "AutoBerry",
})

-- ============================================================
-- TAB: COMBAT
-- ============================================================

local CombatTab = Window:MakeTab({ Title = "Combat", Icon = "rbxassetid://10709791437" })

CombatTab:AddSection("Aim")

CombatTab:AddToggle({
    Title    = "Silent Aim",
    Default  = false,
    Callback = function(v)
        Config.SilentAim = v
    end,
    Flag     = "SilentAim",
})

CombatTab:AddToggle({
    Title    = "Aimbot Gun",
    Default  = false,
    Callback = function(v) Config.AimBotGun = v end,
    Flag     = "AimBotGun",
})

CombatTab:AddSection("Haki")

CombatTab:AddToggle({
    Title    = "Auto Buso Haki",
    Default  = false,
    Callback = function(v) Config.AutoBuso = v end,
    Flag     = "AutoBuso",
})

-- ============================================================
-- TAB: PLAYER
-- ============================================================

local PlayerTab = Window:MakeTab({ Title = "Player", Icon = "rbxassetid://10709791437" })

PlayerTab:AddSection("Movement")

PlayerTab:AddToggle({
    Title    = "Noclip",
    Default  = false,
    Callback = function(v) Config.Noclip = v end,
    Flag     = "Noclip",
})

PlayerTab:AddToggle({
    Title    = "WalkSpeed Bypass",
    Default  = false,
    Callback = function(v)
        Config.WalkSpeedBypass = v
        if v then
            ApplyWalkSpeed()
        end
    end,
    Flag     = "WalkSpeedBypass",
})

PlayerTab:AddSlider({
    Title     = "WalkSpeed",
    Min       = 16,
    Max       = 150,
    Increment = 1,
    Default   = 24,
    Callback  = function(v)
        Config.WalkSpeed = v
        if Config.WalkSpeedBypass then
            ApplyWalkSpeed()
        end
    end,
    Flag      = "WalkSpeed",
})

-- ============================================================
-- TAB: MISC
-- ============================================================

local MiscTab = Window:MakeTab({ Title = "Misc", Icon = "rbxassetid://10709791437" })

MiscTab:AddSection("Server")

MiscTab:AddToggle({
    Title    = "Auto Server Hop",
    Default  = false,
    Callback = function(v) Config.AutoServerHop = v end,
    Flag     = "AutoServerHop",
})

MiscTab:AddSlider({
    Title     = "Min Players (Hop)",
    Min       = 1,
    Max       = 20,
    Increment = 1,
    Default   = 8,
    Callback  = function(v) Config.ServerHopMinPlayers = v end,
    Flag      = "ServerHopMinPlayers",
})

MiscTab:AddButton({
    Title    = "Server Hop Sekarang",
    Callback = function() ServerHop() end,
    Debounce = 5,
})

MiscTab:AddSection("Codes")

MiscTab:AddButton({
    Title    = "Redeem Semua Code",
    Callback = function() RedeemCodes() end,
    Debounce = 10,
})

-- Notify setelah GUI terbuka
Window:Notify({
    Title   = "Xtray Hub",
    Content = "Script berhasil dimuat! Aktifkan fitur via toggle.",
    Time    = 5,
})

-- ============================================================
-- WALKSPEED BYPASS
-- ============================================================

function ApplyWalkSpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Config.WalkSpeed
        hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if Config.WalkSpeedBypass and hum.WalkSpeed < Config.WalkSpeed then
                hum.WalkSpeed = Config.WalkSpeed
            end
        end)
    end
end

-- ============================================================
-- NOCLIP LOOP
-- ============================================================

RunService.Stepped:Connect(function()
    if not Config.Noclip then return end
    if not IsAlive(Character) then return end
    for _, part in ipairs(Character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end)

-- ============================================================
-- BUSO HAKI LOOP
-- ============================================================

task.spawn(function()
    while task.wait(5) do
        if not Config.AutoBuso then continue end
        if not IsAlive(Character) then continue end
        pcall(function()
            if Character:HasTag("Buso") then
                InvokeCommF("Buso")
            end
        end)
    end
end)

-- ============================================================
-- SILENT AIM
-- ============================================================

local function GetClosestEnemy(range)
    range = range or 900
    local closest, dist = nil, range
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, enemy in ipairs(EnemiesFolder:GetChildren()) do
        local hum   = enemy:FindFirstChildOfClass("Humanoid")
        local eRoot = enemy:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 and eRoot then
            local d = (eRoot.Position - root.Position).Magnitude
            if d < dist then
                closest = eRoot
                dist    = d
            end
        end
    end
    return closest
end

local originalNamecall
if hookmetamethod then
    originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args   = {...}

        if method:lower() == "fireserver" and Config.SilentAim then
            local name = originalNamecall(self, "Name")

            if name == "ShootGunEvent" and Config.AimBotGun then
                local target = GetClosestEnemy(250)
                if target and typeof(args[1]) == "Vector3" then
                    args[1] = target.Position
                    if type(args[2]) == "table" then
                        args[2] = {target}
                    end
                end
            elseif typeof(args[1]) == "Vector3" then
                local target = GetClosestEnemy()
                if target then
                    args[1] = target.Position
                end
            end
        end

        return originalNamecall(self, table.unpack(args))
    end)
end

-- ============================================================
-- AUTO CHEST FARM LOOP
-- ============================================================

task.spawn(function()
    while task.wait(1) do
        if not Config.AutoChest then continue end
        if not IsAlive(Character) then WaitForRespawn() continue end

        local closest, dist = nil, math.huge
        for _, chest in ipairs(ChestsFolder:GetChildren()) do
            if not chest:GetAttribute("IsDisabled") then
                local pos = chest:GetPivot().Position
                local d   = GetDistance(pos)
                if d < dist then
                    closest = chest
                    dist    = d
                end
            end
        end

        if closest then
            Teleport(closest:GetPivot())
            task.wait(0.5)
        end
    end
end)

-- ============================================================
-- AUTO BERRY FARM LOOP
-- ============================================================

task.spawn(function()
    while task.wait(1) do
        if not Config.AutoBerry then continue end
        if not IsAlive(Character) then WaitForRespawn() continue end

        for _, berry in ipairs(CollectionService:GetTagged("BerryBush")) do
            if berry.Parent and next(berry:GetAttributes()) ~= nil then
                Teleport(berry.Parent:GetPivot())
                task.wait(0.5)
            end
        end
    end
end)

-- ============================================================
-- SERVER HOP
-- ============================================================

function ServerHop()
    local ServerBrowser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
    if not ServerBrowser then
        Window:Notify({ Title = "Server Hop", Content = "Server Browser tidak tersedia.", Time = 3 })
        return
    end

    local minPlayers   = Config.ServerHopMinPlayers
    local currentJobId = game.JobId
    local page         = 1

    for i = 1, 100 do
        task.delay(i / 50, function()
            local ok, result = pcall(function()
                return ServerBrowser:InvokeServer(page)
            end)
            page += 1

            if ok and type(result) == "table" then
                local bestCount, bestJob = minPlayers, nil
                for jobId, data in pairs(result) do
                    if jobId ~= currentJobId and data.Count <= bestCount then
                        bestCount = data.Count
                        bestJob   = jobId
                    end
                end
                if bestJob then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, bestJob, LocalPlayer)
                end
            end
        end)
    end
end

task.spawn(function()
    while task.wait(30) do
        if not Config.AutoServerHop then continue end
        local players = #Players:GetPlayers()
        if players >= Config.ServerHopMinPlayers then
            ServerHop()
        end
    end
end)

-- ============================================================
-- QUEST SYSTEM
-- ============================================================

local QuestModule = loadstring(fetcher.get("{Utils}BloxFruits/GameModules/Quests.lua"))()
local GuideModule = loadstring(fetcher.get("{Utils}BloxFruits/GameModules/GuideModule.lua"))()

local function GetCurrentLevel()
    local data = LocalPlayer:WaitForChild("Data")
    return data:WaitForChild("Level").Value
end

local function FindQuestForLevel(level)
    for questKey, questList in pairs(QuestModule) do
        for _, quest in ipairs(questList) do
            if level >= quest.LevelReq then
                local npcName = GuideModule.Data and GuideModule.Data.NPCs and GuideModule.Data.NPCs[questKey]
                if npcName then
                    return { Key = questKey, Name = quest.Name, Task = quest.Task, NPC = npcName }
                end
            end
        end
    end
    return nil
end

local function AcceptQuest(npcName)
    for _, npc in ipairs(workspace:GetDescendants()) do
        if npc.Name == npcName and npc:IsA("Model") then
            local root = npc:FindFirstChild("HumanoidRootPart")
            if root then
                Teleport(CFrame.new(root.Position + Vector3.new(0, 0, 3)))
                task.wait(0.5)
                InvokeCommF("StartQuest", npcName)
                return true
            end
        end
    end
    return false
end

local function GetActiveQuest()
    local ok, result = pcall(function()
        return InvokeCommF("getCurrentQuest")
    end)
    return ok and result or nil
end

-- ============================================================
-- AUTO FARM LOOP
-- ============================================================

local function GetQuestEnemies()
    local quest = GetActiveQuest()
    if not quest or not quest.Task then return {} end
    local enemies = {}
    for name in pairs(quest.Task) do
        table.insert(enemies, name)
    end
    return enemies
end

local function FindEnemy(targetNames)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local closest, dist = nil, math.huge

    for _, enemy in ipairs(EnemiesFolder:GetChildren()) do
        if not targetNames or #targetNames == 0 or table.find(targetNames, enemy.Name) then
            local hum   = enemy:FindFirstChildOfClass("Humanoid")
            local eRoot = enemy:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and eRoot then
                local d = (eRoot.Position - root.Position).Magnitude
                if d < dist then
                    closest = enemy
                    dist    = d
                end
            end
        end
    end
    return closest
end

local function AttackEnemy(enemy)
    if not enemy then return end
    local eRoot = enemy:FindFirstChild("HumanoidRootPart")
    if not eRoot then return end

    local char = LocalPlayer.Character
    if not IsAlive(char) then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if Config.BringMobs then
        root.CFrame = CFrame.new(eRoot.Position + Vector3.new(0, 3, 3))
    else
        Teleport(CFrame.new(eRoot.Position + Vector3.new(0, 0, 4)))
    end

    if Config.AutoAttack then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local leftClick = tool:FindFirstChild("LeftClickRemote")
            if leftClick then
                leftClick:FireServer(eRoot.Position)
            end
        end
    end

    if Config.AutoShoot then
        local gunEvent = Remotes:FindFirstChild("ShootGunEvent")
        if gunEvent then
            gunEvent:FireServer(eRoot.Position, {eRoot})
        end
    end
end

task.spawn(function()
    while task.wait(0.1) do
        if not Config.AutoFarm then continue end

        local char = LocalPlayer.Character
        if not IsAlive(char) then
            WaitForRespawn()
            continue
        end

        if Config.AutoQuest then
            local quest = GetActiveQuest()
            if not quest then
                local level     = GetCurrentLevel()
                local questInfo = FindQuestForLevel(level)
                if questInfo then
                    AcceptQuest(questInfo.NPC)
                    task.wait(1)
                end
            end
        end

        local targets = GetQuestEnemies()
        local enemy   = FindEnemy(targets)
        if enemy then
            AttackEnemy(enemy)
        end
    end
end)

-- ============================================================
-- REDEEM CODES
-- ============================================================

function RedeemCodes()
    task.spawn(function()
        local ok, codesRaw = pcall(function()
            return fetcher.get("{Utils}BloxFruits/Codes.json")
        end)

        if ok and codesRaw then
            local HttpService = game:GetService("HttpService")
            local codes = HttpService:JSONDecode(codesRaw)
            local count = 0

            for _, code in ipairs(codes) do
                pcall(function()
                    InvokeCommF("ReedemCode", code)
                    count += 1
                end)
                task.wait(0.2)
            end

            Window:Notify({
                Title   = "Redeem Codes",
                Content = "Berhasil redeem " .. count .. " code!",
                Time    = 4,
            })
        end
    end)
end

-- Auto redeem sekali saat load
RedeemCodes()

-- ============================================================
-- SELESAI
-- ============================================================

return {
    Config    = Config,
    ServerHop = ServerHop,
    Redeem    = RedeemCodes,
    Window    = Window,
}
