# XTRAY HUB — Project Context (Baca ini sebelum mulai!)

> File ini dibuat untuk membantu AI Agent memahami project secara cepat tanpa perlu membaca semua file satu per satu.

---

## Apa itu project ini?

**Xtray Hub** adalah kumpulan Roblox Luau script untuk automasi game — gratis, keyless, untuk Blox Fruits dan Meme Sea.

- GitHub Repo: https://github.com/ScXtray/script
- Owner GitHub: `ScXtray`
- Bahasa komunikasi dengan user: **Indonesia**

---

## Cara sync ke GitHub

Setelah edit file di Replit, jalankan di Shell:

```bash
bash sync-github.sh "pesan commit"
```

Script ini otomatis:
1. Clone repo terbaru
2. Hapus folder lama di clone
3. Copy file terbaru dari workspace
4. Commit & push ke `main`

> **PENTING:** Jangan pakai `cp -r Games "$WORK_DIR/Games"` — ini akan buat `Games/Games/` (duplikat). Script sudah diperbaiki untuk menghindari ini.

Secret yang dibutuhkan: `GITHUB_TOKEN` (GitHub Classic Token milik ScXtray, sudah ada di Replit Secrets)

---

## Struktur Folder

```
/
├── Games/
│   ├── BloxFruits.luau       ← Script utama Blox Fruits (CLEAN, bisa dibaca)
│   ├── BLOX-FRUITS-BETA.lua  ← Script beta (ter-obfuscate, jangan diedit)
│   └── MemeSea.luau          ← Script Meme Sea
│
├── Utils/
│   ├── BloxFruits/
│   │   ├── Module.luau       ← Module utama BF (logic lengkap: farm, aim, hop)
│   │   ├── Codes.json        ← Daftar redeem codes BF
│   │   └── GameModules/
│   │       ├── Quests.lua    ← Data quest per area (level req, enemy, dll)
│   │       └── GuideModule.lua ← Nama NPC quest giver per quest key
│   └── MemeSea/
│       └── Module.luau
│
├── Library/
│   ├── main.luau             ← Library UI utama (ScreenGui, toggle, dll)
│   └── Utils/
│       └── Icons.lua
│
├── Translator/
│   ├── BloxFruits/
│   │   ├── Portuguese.json
│   │   ├── Thai.json
│   │   └── Vietnamese.json
│   └── MemeSea/
│       └── Portuguese.json
│
├── main.luau                 ← Entry point (loadstring dari Roblox)
├── README.md                 ← Readme publik di GitHub
├── sync-github.sh            ← Script sync ke GitHub
└── CONTEXT.md                ← File ini
```

---

## Entry Point (`main.luau`)

User load script di Roblox dengan:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ScXtray/script/refs/heads/main/main.luau"))()
```

`main.luau` mendeteksi `game.PlaceId` lalu load script yang sesuai:
- PlaceId Blox Fruits → load `Games/BloxFruits.luau`
- PlaceId Meme Sea → load `Games/MemeSea.luau`

URL base di `main.luau`:
```lua
urls.Owner = "https://raw.githubusercontent.com/ScXtray/"
urls.Repository = urls.Owner .. "script/refs/heads/main/"
```

---

## Script Blox Fruits (`Games/BloxFruits.luau`)

Script ini **bersih dan terbaca** (dibuat ulang dari awal karena yang lama ter-obfuscate).

Fitur yang ada:
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

Config ada di bagian atas file, mudah diubah.

---

## Module Utama (`Utils/BloxFruits/Module.luau`)

File ini **tidak ter-obfuscate** dan berisi logic lengkap:
- `Services.Network` — InvokeCommF, RemoteFunction, RemoteEvent
- `Services.Enemies` — tracking musuh, boss spawns, bring mobs
- `Services.Inventory` — item, mastery, unlock status
- `Services.Hooking` — silent aim, walkspeed bypass
- `Services.FastAttack` — auto attack logic
- `Services.ToolService` — equip tool, buso haki
- `Services.PlayerManager` — posisi player
- `ServerHop`, `GetRaidIsland`, `Shop` data, dll

---

## Branding

- Nama: **Xtray Hub**
- Semua file sudah di-rebrand dari "Redz Hub" → "Xtray Hub"
- Internal string: `[XTRAY HUB]`, `Xtray Hub Error`, `xtray-library-v5`

---

## Yang Belum Dibuat / TODO

- [ ] GUI in-game (ScreenGui toggle untuk fitur)
- [ ] Script Meme Sea (`Games/MemeSea.luau`) — masih pakai yang lama
- [ ] Support game baru selain BF dan Meme Sea

---

## Tips untuk AI Agent

1. **Jangan baca semua file sekaligus** — gunakan file ini sebagai panduan, lalu baca file spesifik yang dibutuhkan saja.
2. **Selalu push ke GitHub setelah edit** dengan `bash sync-github.sh "pesan"`.
3. **`GITHUB_TOKEN`** sudah ada di Replit Secrets — langsung bisa dipakai.
4. **Jangan obfuscate/lock** file `Games/BloxFruits.luau` — user minta script yang terbaca.
5. **Sync script sudah diperbaiki** — tidak akan buat folder duplikat lagi.
6. **Bahasa dengan user: Indonesia**.
