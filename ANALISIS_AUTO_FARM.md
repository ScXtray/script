# Analisis Auto Farm — Studi 3 Referensi

> Dokumen ini merangkum semua pola, teknik, dan data yang dipelajari dari 3 repo referensi
> sebelum membangun ulang fitur Auto Farm di BloxFruits.luau.

---

## Referensi yang Dipelajari

| # | Repo | File |
|---|------|------|
| 1 | MUXHUB169/BloxFruits-Auto-farm | `README.md` (berisi script lengkap) |
| 2 | nvb201112/the_real_Panda-Hub | `redz.luau` (~3900+ baris) |
| 3 | newredzv3/Scripts | `Utils/Module/Tween-Module.luau` |

---

## 1. Struktur Loop Auto Farm (Pola Utama)

### Pola dari MUXHUB + Panda-Hub (Sangat Mirip)

```
while task.wait() do
    if AutoFarm aktif then
        pcall(function()
            CheckQuest()  -- update variabel quest berdasarkan level

            if Quest.Visible == FALSE then
                -- Belum ada quest → pergi ke NPC quest, ambil quest
                TP ke CFrameQuest
                tunggu sampai dekat (magnitude <= 20)
                CommF_:InvokeServer("StartQuest", QuestName, QuestNumber)

            elseif Quest.Visible == TRUE then
                -- Quest aktif → cari musuh, serang
                if Enemies:FindFirstChild(MonsterName) then
                    for i, v in pairs(Enemies:GetChildren()) do
                        if v.Name == Mon dan v.Humanoid.Health > 0 then
                            repeat
                                TP ke atas musuh (CFrame * CFrame.new(0, 30, 0))
                                v.HumanoidRootPart.Size = Vector3.new(70, 70, 70)  -- hitbox besar
                                v.Humanoid.WalkSpeed = 0  -- freeze musuh
                                v.HumanoidRootPart.CanCollide = false
                                VirtualUser:Button1Down(...)  -- klik/serang
                            until musuh mati / quest selesai / AutoFarm off
                        end
                    end
                else
                    TP ke CFrameMon  -- pergi ke area spawn musuh
                end
            end
        end)
    end
end
```

### Perbedaan MUXHUB vs Panda-Hub:

| Aspek | MUXHUB | Panda-Hub |
|-------|--------|-----------|
| Movement | `TweenService` (smooth) | `TweenService` (smooth) |
| Hitbox size | `Vector3.new(50,50,50)` | `Vector3.new(70,70,70)` |
| Quest check | `Quest.Visible` | `Quest.Visible` |
| Quest struct | `QuestName, QuestNumber` | `NameQuest, LevelQuest` |
| VirtualUser | `Button1Down(1280,672)` | `Button1Down(1280,672)` |
| AbandonQuest | `CommF_:InvokeServer("AbandonQuest")` | `CommF_:InvokeServer("AbandonQuest")` |
| Range level | 1–2150 | 1–2650+ |

---

## 2. Remote Server — CommF_

```lua
-- Path standar:
local CommF_ = game:GetService("ReplicatedStorage").Remotes.CommF_

-- Ambil quest:
CommF_:InvokeServer("StartQuest", QuestName, QuestNumber)

-- Batalkan quest:
CommF_:InvokeServer("AbandonQuest")

-- Set spawn point:
CommF_:InvokeServer("SetSpawnPoint")

-- Masuk area tertutup (Fishman Island, Sky Island atas):
CommF_:InvokeServer("requestEntrance", Vector3.new(x, y, z))
```

---

## 3. Fungsi CheckQuest()

Fungsi ini membaca level pemain (`Character:FindFirstChildOfClass("Humanoid").MaxHealth` atau `leaderstats.Level`) lalu mengisi variabel global:

```lua
local MyLevel        -- level pemain
local QuestName      -- nama string quest (e.g. "BanditQuest1")
local QuestNumber    -- nomor quest (1 atau 2)
local NameMon        -- nama monster (e.g. "Bandit")
local CFrameQuest    -- CFrame NPC pemberi quest
local CFrameMon      -- CFrame area spawn monster
```

### Cara baca level pemain (dua cara yang dipakai referensi):
```lua
-- Cara 1 (MUXHUB):
local MyLevel = game.Players.LocalPlayer.leaderstats.Level.Value

-- Cara 2 (Panda-Hub):
local MyLevel = game.Players.LocalPlayer.Data.Level.Value
```

### Contoh entri CheckQuest Sea 1:
```lua
if MyLevel >= 1 and MyLevel <= 14 then
    QuestName = "BanditQuest1"
    QuestNumber = 1
    NameMon = "Bandit"
    CFrameQuest = CFrame.new(1060.93, 16.45, 1547.78)
    CFrameMon   = CFrame.new(1000, 16, 1500)
```

---

## 4. Sistem Teleport / Movement

### Cara MUXHUB (TweenService langsung):
```lua
function totarget(CFgo)
    local ts = game:GetService("TweenService")
    local dist = (Player.Character.HumanoidRootPart.Position - CFgo.Position).Magnitude
    local info = TweenInfo.new(dist / 300, Enum.EasingStyle.Linear)
    local tw = ts:Create(Player.Character.HumanoidRootPart, info, {CFrame = CFgo})
    tw:Play()
end
```
- Kecepatan: **300 studs/detik**
- Tidak ada NoClip built-in → bisa stuck di dinding

### Cara Panda-Hub (function TP1 / topos):
```lua
function TP1(cf)
    -- ada mode BypassTP (TweenService) dan direct teleport
    if BypassTP then
        TweenService:Create(HRP, TweenInfo.new(dist / TweenSpeed, Linear), {CFrame = cf}):Play()
    else
        HRP.CFrame = cf  -- langsung teleport
    end
end
```

### Cara Tween-Module (newredzv3 — sudah di repo kita):
```lua
-- API:
TweenModule:Teleport(TargetCFrame)  -- mulai bergerak smooth
TweenModule:Stop()                   -- berhenti
TweenModule:SetSpeed(n)              -- set kecepatan (default ~50)
TweenModule:IsTweening()             -- cek apakah sedang bergerak

-- Cara kerja internal:
-- Pakai BodyVelocity ("KAHover") + task.wait() loop
-- Otomatis berhenti kalau magnitude < 5 dari target
-- Ada NoClip via PhysicsService collision group
```

**→ Rekomendasi untuk kita: pakai TweenModule yang sudah ada, karena punya NoClip dan lebih smooth.**

---

## 5. Sistem Serangan (VirtualUser)

Semua referensi pakai `VirtualUser` untuk auto-attack:

```lua
local VU = game:GetService("VirtualUser")

-- Di dalam loop kill monster:
VU:CaptureController()
VU:Button1Down(Vector2.new(1280, 672))  -- koordinat tengah layar (1920x1080 / 1.5)
```

Dipanggil **di dalam repeat...until** setiap `task.wait()`, bukan sekali.

---

## 6. Pola requestEntrance (Area Khusus)

Beberapa area butuh "requestEntrance" sebelum bisa masuk:

```lua
-- Fishman Island (Sea 1):
if magnitude > 10000 then
    CommF_:InvokeServer("requestEntrance", Vector3.new(61163.85, 11.68, 1819.78))
end

-- Sky Island atas (Sea 1):
CommF_:InvokeServer("requestEntrance", Vector3.new(-4607.82, 872.54, -1667.55))  -- Upper Skylands
CommF_:InvokeServer("requestEntrance", Vector3.new(-7894.61, 5547.14, -380.29))  -- Sky Exp 2

-- Ship area (Sea 2):
CommF_:InvokeServer("requestEntrance", Vector3.new(923.21, 126.97, 32852.83))
```

Cara deteksi: kalau `CFrameQuest.Position - HRP.Position).Magnitude > 10000` berarti butuh entrance.

---

## 7. Database Quest Level (Sea 1, 2, 3)

### Sea 1 (Level 1–700):
| Level | Monster | Quest | CFrameQuest | CFrameMon |
|-------|---------|-------|-------------|-----------|
| 1–14 | Bandit | BanditQuest1 Q1 | 1060, 16, 1547 | ~1000, 16, 1500 |
| 15–29 | Pirate | BanditQuest1 Q2 | 1060, 16, 1547 | ... |
| 30–59 | Monkey | JungleQuest Q1 | -1604, 36, 154 | ... |
| 60–89 | Gorilla | JungleQuest Q2 | -1604, 36, 154 | ... |
| 90–119 | Bera... | BuggyQuest1 Q1 | -1140, 4, 3827 | ... |
| 120–149 | Crab | BuggyQuest1 Q2 | -1140, 4, 3827 | ... |
| 150–174 | Bandit Desert | DesertQuest Q1 | 896, 6, 4390 | ... |
| 175–199 | Desert Officer | DesertQuest Q2 | 896, 6, 4390 | ... |
| 200–249 | Snow Bandit | SnowQuest Q1 | 1386, 87, -1298 | ... |
| 250–299 | Snowman | SnowQuest Q2 | 1386, 87, -1298 | ... |
| 300–374 | Marine | MarineQuest2 | -5035, 28, 4324 | ... |
| 375–449 | Angel | SkyQuest Q1/Q2 | -4841, 717, -2623 | ... |
| 450–524 | Gladiator | ColosseumQuest | -1576, 7, -2983 | ... |
| 525–624 | Magma | MagmaQuest | -5316, 12, 8517 | ... |
| 625–699 | Fishman | FishmanQuest | 61122, 18, 1568 | ... |
> → Data CFrame lengkap ada di redz.luau baris 97–350 dan MUXHUB README baris 152–450

### Sea 2 (Level 700–1500):
| Level | Monster | Quest |
|-------|---------|-------|
| 700–724 | Raider | Area1Quest Q1 |
| 725–774 | Mercenary | Area1Quest Q2 |
| 775–799 | Swan Pirate | Area2Quest Q1 |
| 800–874 | Factory Staff | Area2Quest Q2 |
| 875–899 | Marine Lieutenant | MarineQuest3 Q1 |
| 900–949 | Marine Captain | MarineQuest3 Q2 |
| 950–974 | Zombie | ZombieQuest Q1 |
| 975–999 | Vampire | ZombieQuest Q2 |
| 1000–1049 | Snow Trooper | SnowMountainQuest Q1 |
| 1050–1099 | Winter Warrior | SnowMountainQuest Q2 |
| 1100–1124 | Lab Subordinate | IceSideQuest Q1 |
| 1125–1174 | Horned Warrior | IceSideQuest Q2 |
| 1175–1199 | Magma Ninja | FireSideQuest Q1 |
| 1200–1349 | Lava Pirate | FireSideQuest Q2 |
| 1350–1374 | Arctic Warrior | FrostQuest Q1 |
| 1375–1424 | Snow Lurker | FrostQuest Q2 |
| 1425–1449 | Sea Soldier | ForgottenQuest Q1 |
| 1450–1499 | Water Fighter | ForgottenQuest Q2 |

### Sea 3 (Level 1500–2650+):
| Level | Monster | Quest |
|-------|---------|-------|
| 1500–1524 | Pirate Millionaire | PiratePortQuest Q1 |
| 1525–1574 | Pistol Billionaire | PiratePortQuest Q2 |
| 1575–1599 | Dragon Crew Warrior | AmazonQuest Q1 |
| 1600–1624 | Dragon Crew Archer | AmazonQuest Q2 |
| 1625–1649 | Female Islander | AmazonQuest2 Q1 |
| 1650–1699 | Giant Islander | AmazonQuest2 Q2 |
| 1700–1724 | Marine Commodore | MarineTreeIsland Q1 |
| 1725–1774 | Marine Rear Admiral | MarineTreeIsland Q2 |
| 1775–1799 | Fishman Raider | DeepForestIsland3 Q1 |
| 1800–1824 | Fishman Captain | DeepForestIsland3 Q2 |
| 1825–1849 | Forest Pirate | DeepForestIsland Q1 |
| 1850–1899 | Mythological Pirate | DeepForestIsland Q2 |
| 1900–1924 | Jungle Pirate | DeepForestIsland2 Q1 |
| 1925–1974 | Musketeer Pirate | DeepForestIsland2 Q2 |
| 1975–1999 | Reborn Skeleton | HauntedQuest1 Q1 |
| 2000–2024 | Living Zombie | HauntedQuest1 Q2 |
| 2025–2049 | Demonic Soul | HauntedQuest2 Q1 |
| 2050–2074 | Posessed Mummy | HauntedQuest2 Q2 |
| 2075–2099 | Peanut Scout | NutsIslandQuest Q1 |
| 2100–2124 | Peanut President | NutsIslandQuest Q2 |
| 2125–2149 | Ice Cream Chef | IceCreamIslandQuest Q1 |
| 2150+ | Ice Cream Commander | IceCreamIslandQuest Q2 |
> Panda-Hub lanjut sampai 2650+ (Cake, Choco, Candy, Tiki islands)

---

## 8. Anti-Stuck Patterns

### Masalah stuck loop di implementasi lama kita:
- `repeat...until` tanpa timeout → infinite loop kalau musuh hilang/reset
- Tidak ada `pcall()` → error putuskan seluruh coroutine

### Solusi yang dipakai referensi:

**1. Selalu pcall:**
```lua
spawn(function()
    while task.wait() do
        if AutoFarm then
            pcall(function()
                -- semua logic di sini
            end)
        end
    end
end)
```

**2. Multi-condition repeat:**
```lua
repeat
    task.wait()
    -- logic serang
until not AutoFarm
    or v.Humanoid.Health <= 0
    or not v.Parent           -- musuh di-destroy
    or Quest.Visible == false  -- quest selesai
```

**3. CheckQuest() di tiap iterasi:**
```lua
repeat
    task.wait()
    CheckQuest()  -- update info musuh setiap tick
    ...
until ...
```

**4. AbandonQuest kalau quest title tidak match:**
```lua
if not string.find(QuestTitle.Text, NameMon) then
    CommF_:InvokeServer("AbandonQuest")
    -- akan ambil quest baru di iterasi berikutnya
end
```

---

## 9. Teknik Hitbox Expansion (Magnet)

```lua
-- Di dalam loop saat musuh ditemukan:
v.HumanoidRootPart.Size = Vector3.new(70, 70, 70)  -- MUXHUB: 50x50x50
v.Humanoid.WalkSpeed = 0          -- freeze musuh
v.HumanoidRootPart.CanCollide = false
v.Head.CanCollide = false
```

Efek: musuh seolah "menarik" semua hit ke arahnya dari radius jauh.

---

## 10. Equip Weapon

```lua
function EquipWeapon(ToolName)
    local char = game.Players.LocalPlayer.Character
    local bp   = game.Players.LocalPlayer.Backpack
    local tool = bp:FindFirstChild(ToolName) or char:FindFirstChild(ToolName)
    if tool then
        char.Humanoid:EquipTool(tool)
    end
end
```

Dipanggil setiap tick di dalam loop kill.

---

## 11. Rekomendasi Implementasi untuk BloxFruits.luau

Berdasarkan studi 3 referensi, ini rencana implementasi yang bersih dan anti-stuck:

### A. Variabel State (tambahkan ke State table):
```lua
State.AutoFarm       = false
State.AutoFarmMon    = ""    -- nama monster aktif
State.AutoFarmQuest  = ""    -- nama quest aktif
```

### B. Data Quest — pisahkan ke tabel bersih:
```lua
local QuestData = {
    -- { level_min, level_max, monster, quest_name, quest_num, cframe_quest, cframe_mon, entrance? }
    { 1,   14,  "Bandit",       "BanditQuest1",  1, CF_Quest, CF_Mon },
    { 15,  29,  "Pirate",       "BanditQuest1",  2, CF_Quest, CF_Mon },
    -- ...sampai 2650
}
```

### C. CheckQuest() bersih:
```lua
local function CheckQuest()
    local level = Player.leaderstats.Level.Value
    for _, data in ipairs(QuestData) do
        if level >= data.min and level <= data.max then
            ActiveQuest = data
            return
        end
    end
end
```

### D. Loop utama (pakai task.spawn, bukan spawn):
```lua
task.spawn(function()
    while task.wait(0.1) do
        if not State.AutoFarm then continue end
        pcall(function()
            CheckQuest()
            local questVisible = Player.PlayerGui.Main.Quest.Visible
            if not questVisible then
                -- pergi ambil quest
                TweenModule:Teleport(ActiveQuest.cframe_quest)
                TweenModule:Wait() -- tunggu sampai sampai
                CommF_:InvokeServer("StartQuest", ActiveQuest.quest, ActiveQuest.num)
            else
                -- cari & bunuh musuh
                local found = false
                for _, v in pairs(Workspace.Enemies:GetChildren()) do
                    if v.Name == ActiveQuest.monster
                    and v:FindFirstChild("Humanoid")
                    and v.Humanoid.Health > 0 then
                        found = true
                        repeat
                            task.wait()
                            CheckQuest()
                            TweenModule:Teleport(v.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
                            v.HumanoidRootPart.Size = Vector3.new(60,60,60)
                            v.Humanoid.WalkSpeed = 0
                            v.HumanoidRootPart.CanCollide = false
                            EquipWeapon(State.SelectedWeapon)
                            VU:CaptureController()
                            VU:Button1Down(Vector2.new(1280, 672))
                        until not State.AutoFarm
                            or v.Humanoid.Health <= 0
                            or not v.Parent
                            or not Player.PlayerGui.Main.Quest.Visible
                        break
                    end
                end
                if not found then
                    TweenModule:Teleport(ActiveQuest.cframe_mon)
                end
            end
        end)
    end
end)
```

---

## 12. Checklist Sebelum Implementasi

- [x] Pahami pola loop utama (✓)
- [x] Pahami CommF_ remote calls (✓)
- [x] Pahami CheckQuest() pattern (✓)
- [x] Pahami hitbox expansion (✓)
- [x] Pahami movement/teleport (✓)
- [x] Pahami anti-stuck patterns (✓)
- [x] Pahami VirtualUser attack (✓)
- [x] Database quest Sea 1 (✓ — ada di kedua referensi)
- [x] Database quest Sea 2 (✓)
- [x] Database quest Sea 3 (✓ — lengkap di Panda-Hub)
- [ ] Implementasi aktual di BloxFruits.luau
- [ ] Test Anti-Stuck
- [ ] Push ke GitHub

---

## 13. Sumber Data CFrame Lengkap

Untuk implementasi, copy CFrame dari:
- **Sea 1–2**: `MUXHUB README` baris 152–450 (format bersih)
- **Sea 3 extended**: `redz.luau` baris 380–700 (lebih lengkap, sampai 2650)
- **requestEntrance vectors**: `redz.luau` baris 157–760 (untuk area khusus)

File-file ini sudah disimpan di `/tmp/muxhub_ref.lua` dan `/tmp/redz_ref.luau`.
