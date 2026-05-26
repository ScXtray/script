# XTRAY HUB — Project Context (Baca ini sebelum mulai!)

> File ini dibuat untuk membantu AI Agent memahami project secara cepat tanpa perlu membaca semua file satu per satu.

---

## Apa itu project ini?

**Xtray Hub** adalah kumpulan Roblox Luau script untuk automasi game — gratis, keyless, untuk Blox Fruits (game lain bisa ditambahkan nanti).

- GitHub Repo  : https://github.com/ScXtray/script
- Owner GitHub : `ScXtray`
- Bahasa komunikasi dengan user: **Indonesia**

---

## Cara sync ke GitHub

Setelah edit file di Replit, jalankan di Shell:

```bash
bash sync-github.sh "pesan commit"
```

Script ini otomatis:
1. Clone repo terbaru
2. Hapus folder lama di clone (mencegah duplikasi)
3. Copy file terbaru dari workspace
4. Commit & push ke `main`

Secret yang dibutuhkan: `GITHUB_TOKEN` (sudah ada di Replit Secrets)

> **JANGAN** pakai `cp -r Games "$WORK_DIR/Games"` — akan buat `Games/Games/` duplikat.
> Sync script sudah diperbaiki untuk menghindari ini.

---

## Struktur Folder (terkini)

```
/
├── Games/
│   └── BloxFruits.luau         ← Script utama Blox Fruits (bersih, terbaca)
│
├── Utils/
│   ├── BloxFruits/
│   │   ├── Module.luau          ← Logic utama BF (farm, aim, hop, inventory, dll)
│   │   ├── Codes.json           ← Daftar redeem codes Blox Fruits
│   │   └── GameModules/
│   │       ├── Quests.lua       ← Data quest per area (level req, enemy, dll)
│   │       └── GuideModule.lua  ← Nama NPC quest giver per quest key
│   └── MemeSea/
│       └── Module.luau          ← Module Meme Sea (bersih, terbaca, 410 baris)
│
├── Library/
│   ├── main.luau                ← Library UI utama (ScreenGui, theme, toggle)
│   └── Utils/
│       └── Icons.lua            ← Icon assets
│
├── Translator/
│   ├── BloxFruits/
│   │   ├── Portuguese.json
│   │   ├── Thai.json
│   │   └── Vietnamese.json
│   └── MemeSea/
│       └── Portuguese.json
│
├── main.luau                    ← Entry point (loadstring dari Roblox)
├── README.md                    ← Readme publik
├── CONTEXT.md                   ← File ini
├── CHANGELOG.md                 ← Log semua perubahan
└── sync-github.sh               ← Script sync ke GitHub (hanya di Replit lokal)
```

---

## Entry Point (`main.luau`)

User load script di Roblox dengan:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScXtray/script/refs/heads/main/main.luau"))()
```

`main.luau` mendeteksi `game.GameId` lalu load script yang sesuai:
- GameId `994732206` → load `Games/BloxFruits.luau`

URL base:
```lua
urls.Owner      = "https://raw.githubusercontent.com/ScXtray/"
urls.Repository = urls.Owner .. "script/refs/heads/main/"
urls.Translator = urls.Repository .. "Translator/"
urls.Utils      = urls.Repository .. "Utils/"
```

Global variable debounce menggunakan prefix `xt_` (bukan `rz_` lagi):
- `xt_execute_debounce`
- `xt_added_teleport_queue`
- `xt_error_message`

---

## Script Blox Fruits (`Games/BloxFruits.luau`)

Script ini **bersih dan terbaca** — dibuat ulang dari awal karena yang lama ter-obfuscate.

Fitur yang ada (semua bisa toggle via Config di atas file):
| Fitur | Config Key |
|-------|-----------|
| Auto Farm (kill + quest) | `AutoFarm`, `AutoQuest` |
| Auto Attack | `AutoAttack` |
| Auto Shoot | `AutoShoot` |
| Silent Aim | `SilentAim`, `AimBotGun` |
| Noclip | `Noclip` |
| Bring Mobs | `BringMobs`, `BringDistance` |
| Server Hop | `AutoServerHop`, `ServerHopMinPlayers` |
| Chest Farm | `AutoChest` |
| Berry Farm | `AutoBerry` |
| Buso Haki auto | `AutoBuso` |
| WalkSpeed Bypass | `WalkSpeedBypass` |
| Redeem Codes | otomatis saat load |
| Translator | `Translator` |

---

## Module Utama (`Utils/BloxFruits/Module.luau`)

Tidak ter-obfuscate. Berisi:
- `Services.Network` — InvokeCommF, RemoteFunction, RemoteEvent
- `Services.Enemies` — tracking musuh, boss spawns, bring mobs
- `Services.Inventory` — item, mastery, unlock
- `Services.Hooking` — silent aim, walkspeed bypass (`xt_` prefix)
- `Services.FastAttack` — auto attack logic
- `Services.ToolService` — equip tool, buso haki
- `Services.PlayerManager` — posisi player

---

## Library UI (`Library/main.luau`)

- Versi: `v2.0.1`
- `GitHubOwner = "ScXtray"` ✅
- Internal cache key: `"xtray-library-v5"`
- Berisi ScreenGui, tema (Darker default), toggle system

---

## Branding

- Nama resmi: **Xtray Hub**
- Semua referensi "Redz Hub" sudah diganti ke "Xtray Hub"
- Global prefix: `xt_` (sebelumnya `rz_`)
- Library key: `xtray-library-v5`

---

## Yang Belum Dibuat / TODO

- [ ] GUI in-game (ScreenGui toggle untuk aktifkan/matikan fitur)
- [ ] Script Meme Sea baru yang bersih (Games/MemeSea.luau dihapus karena obfuscated)
- [ ] Support game lain selain Blox Fruits

---

## Tips untuk AI Agent

1. **Baca CHANGELOG.md** untuk tahu semua yang sudah pernah diubah.
2. **Jangan baca semua file** — pakai file ini sebagai panduan, baca file spesifik sesuai kebutuhan.
3. **Selalu push setelah edit:** `bash sync-github.sh "pesan"`.
4. **`GITHUB_TOKEN`** sudah ada di Replit Secrets.
5. **Jangan obfuscate** `Games/BloxFruits.luau` — user minta script yang terbaca.
6. **Prefix global vars = `xt_`** (bukan `rz_`).
7. **Bahasa dengan user: Indonesia**.
