--[[
    REDZ HUB - Blox Fruits Script
    Repo: https://github.com/ScXtray/script
    Keyless & Free
--]]

local fetcher, Settings = ...

-- ============================================================
-- SETTINGS (bisa diubah sesuai kebutuhan)
-- ============================================================
local Config = {
    -- Auto Farm
    AutoFarm         = true,
    AutoQuest        = true,
    AutoAttack       = true,
    AutoShoot        = false,
    SmoothMode       = false,
    NoAimMobs        = false,

    -- Farm Tool (nama tool yang dipakai farm, kosongkan = otomatis)
    FarmTool         = "",

    -- Silent Aim
    SilentAim        = true,
    AimBotGun        = true,

    -- Noclip
    Noclip           = true,

    -- Bring Mobs (tarik musuh ke posisi player)
    BringMobs        = true,
    BringDistance    = 15,

    -- Server Hop
    AutoServerHop    = false,
    ServerHopMinPlayers = 8,

    -- Chest Farm
    AutoChest        = false,
    AutoBerry        = false,

    -- Buso Haki
    AutoBuso         = true,

    -- WalkSpeed bypass
    WalkSpeedBypass  = 24,

    -- Team (Pirates / Marines)
    JoinTeam         = Settings and Settings.JoinTeam or "Pirates",

    -- Translator
    Translator       = Settings and Settings.Translator or false,
}

-- ============================================================
-- SERVICES
-- ============================================================
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer    = Players.LocalPlayer
local Character      = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid       = Character:WaitForChild("Humanoid")
local RootPart       = Character:WaitForChild("HumanoidRootPart")

-- ============================================================
-- REMOTES
-- ============================================================
local Remotes        = ReplicatedStorage:WaitForChild("Remotes")
local CommF          = Remotes:WaitForChild("CommF_")
local CommE          = Remotes:WaitForChild("CommE")

-- ============================================================
-- WORLD REFERENCES
-- ============================================================
local WorldOrigin    = workspace:WaitForChild("_WorldOrigin")
local EnemySpawns   = WorldOrigin:WaitForChild("EnemySpawns")
local Locations      = WorldOrigin:WaitForChild("Locations")
local EnemiesFolder = workspace:WaitForChild("Enemies")
local CharactersFolder = workspace:WaitForChild("Characters")
local ChestsFolder  = workspace:WaitForChild("ChestModels")
local MapFolder     = workspace:WaitForChild("Map")

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
        Character  = LocalPlayer.Character
        Humanoid   = Character:WaitForChild("Humanoid")
        RootPart   = Character:WaitForChild("HumanoidRootPart")
    end
end

local function Notify(text)
    local msg = Instance.new("Message", workspace)
    msg.Text   = "[REDZ HUB] " .. text
    game:GetService("Debris"):AddItem(msg, 3)
end

-- ============================================================
-- NOCLIP
-- ============================================================

if Config.Noclip then
    RunService.Stepped:Connect(function()
        if not IsAlive(Character) then return end
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

-- ============================================================
-- WALKSPEED BYPASS
-- ============================================================

local function ApplyWalkSpeedBypass()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if Config.WalkSpeedBypass and hum.WalkSpeed < Config.WalkSpeedBypass then
                hum.WalkSpeed = Config.WalkSpeedBypass
            end
        end)
    end
end

ApplyWalkSpeedBypass()
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid  = char:WaitForChild("Humanoid")
    RootPart  = char:WaitForChild("HumanoidRootPart")
    task.wait(1)
    ApplyWalkSpeedBypass()
end)

-- ============================================================
-- BUSO HAKI
-- ============================================================

if Config.AutoBuso then
    task.spawn(function()
        while task.wait(5) do
            if IsAlive(Character) and not Character:FindFirstChild("HasBuso") then
                pcall(function()
                    if Character:HasTag("Buso") then
                        InvokeCommF("Buso")
                    end
                end)
            end
        end
    end)
end

-- ============================================================
-- SILENT AIM
-- ============================================================

local AimTarget = nil

local function GetClosestEnemy(range)
    range = range or 900
    local closest, dist = nil, range
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, enemy in ipairs(EnemiesFolder:GetChildren()) do
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        local eRoot = enemy:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 and eRoot then
            local d = (eRoot.Position - root.Position).Magnitude
            if d < dist then
                closest = eRoot
                dist = d
            end
        end
    end

    return closest
end

if Config.SilentAim then
    local originalNamecall
    originalNamecall = hookmetamethod and hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args   = {...}

        if method:lower() == "fireserver" then
            local name = originalNamecall(self, "Name")

            if name == "ShootGunEvent" and Config.AimBotGun then
                local target = GetClosestEnemy(250)
                if target and typeof(args[1]) == "Vector3" then
                    args[1] = target.Position
                    if type(args[2]) == "table" then
                        args[2] = {target}
                    end
                end
            elseif name == "RemoteEvent" and typeof(args[1]) == "Vector3" then
                local target = GetClosestEnemy()
                if target then
                    args[1] = target.Position
                end
            end
        end

        return originalNamecall(self, table.unpack(args))
    end) or nil
end

-- ============================================================
-- AUTO CHEST FARM
-- ============================================================

if Config.AutoChest then
    task.spawn(function()
        while task.wait(1) do
            if not IsAlive(Character) then WaitForRespawn() continue end

            local closest, dist = nil, math.huge
            for _, chest in ipairs(ChestsFolder:GetChildren()) do
                if not chest:GetAttribute("IsDisabled") then
                    local pos = chest:GetPivot().Position
                    local d = GetDistance(pos)
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
end

-- ============================================================
-- AUTO BERRY FARM
-- ============================================================

if Config.AutoBerry then
    task.spawn(function()
        while task.wait(1) do
            if not IsAlive(Character) then WaitForRespawn() continue end

            for _, berry in ipairs(CollectionService:GetTagged("BerryBush")) do
                if berry.Parent and next(berry:GetAttributes()) ~= nil then
                    local pivot = berry.Parent:GetPivot()
                    Teleport(pivot)
                    task.wait(0.5)
                end
            end
        end
    end)
end

-- ============================================================
-- SERVER HOP
-- ============================================================

local function ServerHop()
    local ServerBrowser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
    if not ServerBrowser then return end

    local minPlayers = Config.ServerHopMinPlayers
    local currentJobId = game.JobId
    local page = 1

    for _ = 1, 100 do
        task.delay(_ / 50, function()
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

-- ============================================================
-- QUEST SYSTEM
-- ============================================================

local QuestData   = fetcher.get("{Utils}BloxFruits/GameModules/Quests.lua")
local QuestModule = loadstring(QuestData)()

local GuideData   = fetcher.get("{Utils}BloxFruits/GameModules/GuideModule.lua")
local GuideModule = loadstring(GuideData)()

local function GetCurrentLevel()
    local data = LocalPlayer:WaitForChild("Data")
    return data:WaitForChild("Level").Value
end

local function FindQuestForLevel(level)
    for questKey, questList in pairs(QuestModule) do
        for _, quest in ipairs(questList) do
            if level >= quest.LevelReq then
                local npcName = GuideModule.Data.NPCs[questKey]
                if npcName then
                    return {
                        Key    = questKey,
                        Name   = quest.Name,
                        Task   = quest.Task,
                        NPC    = npcName,
                        Level  = quest.LevelReq,
                    }
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

local farming  = Config.AutoFarm
local killList = {}

local function GetQuestEnemies()
    local quest = GetActiveQuest()
    if not quest or not quest.Task then return {} end
    local enemies = {}
    for name, _ in pairs(quest.Task) do
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

    -- Gerak ke musuh
    if Config.BringMobs then
        root.CFrame = CFrame.new(eRoot.Position + Vector3.new(0, 3, 3))
    else
        Teleport(CFrame.new(eRoot.Position + Vector3.new(0, 0, 4)))
    end

    -- Auto Attack pakai tool
    if Config.AutoAttack then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local leftClick = tool:FindFirstChild("LeftClickRemote")
            if leftClick then
                leftClick:FireServer(eRoot.Position)
            end
        end
    end

    -- Auto Shoot
    if Config.AutoShoot then
        local shootEvent = ReplicatedStorage:FindFirstChild("Remotes")
        if shootEvent then
            local gunEvent = Remotes:FindFirstChild("ShootGunEvent")
            if gunEvent then
                gunEvent:FireServer(eRoot.Position, {eRoot})
            end
        end
    end
end

-- Main farm loop
if Config.AutoFarm then
    task.spawn(function()
        while task.wait(0.1) do
            if not farming then task.wait(1) continue end

            local char = LocalPlayer.Character
            if not IsAlive(char) then
                WaitForRespawn()
                continue
            end

            -- Auto Quest
            if Config.AutoQuest then
                local quest = GetActiveQuest()
                if not quest then
                    local level      = GetCurrentLevel()
                    local questInfo  = FindQuestForLevel(level)
                    if questInfo then
                        Notify("Mengambil quest: " .. questInfo.Name)
                        AcceptQuest(questInfo.NPC)
                        task.wait(1)
                    end
                end
            end

            -- Cari dan serang musuh
            local targets = GetQuestEnemies()
            local enemy   = FindEnemy(targets)

            if enemy then
                AttackEnemy(enemy)
            end

            -- Server hop jika enabled dan quest selesai
            if Config.AutoServerHop then
                local players = #Players:GetPlayers()
                if players >= Config.ServerHopMinPlayers then
                    Notify("Server hop...")
                    ServerHop()
                end
            end
        end
    end)
end

-- ============================================================
-- REDEEM CODES
-- ============================================================

task.spawn(function()
    local ok, codesRaw = pcall(function()
        return fetcher.get("{Utils}BloxFruits/Codes.json")
    end)

    if ok and codesRaw then
        local HttpService = game:GetService("HttpService")
        local codes = HttpService:JSONDecode(codesRaw)

        for _, code in ipairs(codes) do
            pcall(function()
                InvokeCommF("ReedemCode", code)
            end)
            task.wait(0.2)
        end

        Notify("Redeem codes selesai!")
    end
end)

-- ============================================================
-- TRANSLATOR
-- ============================================================

if Config.Translator then
    task.spawn(function()
        local lang     = "Portuguese"
        local ok, data = pcall(function()
            return fetcher.get("{Translator}BloxFruits/" .. lang .. ".json")
        end)

        if ok and data then
            Notify("Translator loaded: " .. lang)
        end
    end)
end

-- ============================================================
-- FERTIG
-- ============================================================

Notify("REDZ HUB loaded! Auto Farm: " .. tostring(Config.AutoFarm))

return {
    Config    = Config,
    farming   = farming,
    ServerHop = ServerHop,
}
