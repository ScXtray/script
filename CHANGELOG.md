# CHANGELOG — Xtray Hub

Semua perubahan yang pernah dilakukan di project ini, dari awal hingga sekarang.

---

## [Session 1] — Setup & Migrasi dari Repo Lama

### Latar Belakang
Akun GitHub lama (`tlredz`) terkena suspend. Project dimulai ulang dengan akun baru `ScXtray`.

### Perubahan
- **Clone & push repo lama** — `tlredz/Scripts` → `ScXtray/script`
- **Buat `sync-github.sh`** — script otomatis untuk push perubahan dari Replit ke GitHub
- **Update URL di `main.luau`**
  - Sebelum: `https://raw.githubusercontent.com/tlredz/Scripts/...`
  - Sesudah: `https://raw.githubusercontent.com/ScXtray/script/...`
- **Update URL di `README.md`** — loadstring URL diperbarui ke repo baru

---

## [Session 2] — Rebuild Script BloxFruits

### Latar Belakang
`Games/BloxFruits.luau` ter-obfuscate (dikunci), tidak bisa dibaca atau diedit.

### Perubahan
- **Hapus** konten lama yang obfuscated dari `Games/BloxFruits.luau`
- **Buat ulang dari awal** `Games/BloxFruits.luau` — script bersih dan terbaca penuh
- Fitur yang diimplementasi: Auto Farm, Auto Quest, Silent Aim, Noclip, Bring Mobs, Server Hop, Chest Farm, Berry Farm, Buso Haki, WalkSpeed Bypass, Redeem Codes, Translator

---

## [Session 3] — Fix Folder Duplikat

### Latar Belakang
Saat sync pertama, folder terduplikat: `Games/Games/`, `Utils/Utils/`, `Library/Library/`, `Translator/Translator/`.

### Perubahan
- **Hapus** 15 file duplikat dari GitHub via GitHub API
- **Perbaiki `sync-github.sh`** — sekarang hapus folder lama di clone sebelum copy baru, mencegah duplikasi

---

## [Session 4] — Rebranding Redz → Xtray

### Latar Belakang
Semua nama yang mengandung "Redz" harus diganti ke "Xtray" sesuai identitas baru.

### File yang diubah
| File | Perubahan |
|------|-----------|
| `README.md` | `redz hub` → `xtray hub`, `REDZ HUB` → `XTRAY HUB` |
| `replit.md` | `Redz Hub Scripts` → `Xtray Hub Scripts` |
| `Games/BloxFruits.luau` | `REDZ HUB` → `XTRAY HUB` (3 tempat) |
| `Utils/BloxFruits/Module.luau` | `redz Hub` → `Xtray Hub` (2 tempat) |
| `Library/main.luau` | `redz-library-v5` → `xtray-library-v5` |

---

## [Session 5] — Audit & Cleanup Menyeluruh

### Perubahan

#### Fix referensi akun lama
- `Library/main.luau` baris 129: `GitHubOwner="tlredz"` → `GitHubOwner="ScXtray"`

#### Rename global variable prefix `rz_` → `xt_`
| File | Variable lama | Variable baru |
|------|--------------|--------------|
| `main.luau` | `_ENV.rz_execute_debounce` | `_ENV.xt_execute_debounce` |
| `main.luau` | `_ENV.rz_added_teleport_queue` | `_ENV.xt_added_teleport_queue` |
| `main.luau` | `_ENV.rz_error_message` | `_ENV.xt_error_message` |
| `Module.luau` | `f.rz_hook_manager` | `f.xt_hook_manager` |
| `Module.luau` | `f.rz_EnabledOptions` | `f.xt_EnabledOptions` |
| `Module.luau` | `f.rz_enabled_bypass` | `f.xt_enabled_bypass` |
| `Module.luau` | `f.rz_original_namecall` | `f.xt_original_namecall` |

#### Hapus file obfuscated (tidak bisa diedit/dibaca)
| File | Ukuran | Alasan |
|------|--------|--------|
| `Games/BLOX-FRUITS-BETA.lua` | 480 KB | Fully obfuscated |
| `Games/MemeSea.luau` | 117 KB | Fully obfuscated |
| `Utils/BloxFruits/Webhooks.lua` | 57 KB | Fully obfuscated |

#### Cleanup `main.luau`
- Hapus `BETA_VERSION` dan referensinya (tidak relevan setelah BLOX-FRUITS-BETA.lua dihapus)
- Hapus entry Meme Sea dari `Scripts` table (file game-nya sudah dihapus)

---

## Status Repo Saat Ini

```
✅ Semua file terbaca (tidak ada yang obfuscated)
✅ Tidak ada referensi ke akun lama (tlredz)
✅ Semua branding sudah "Xtray Hub"
✅ Global prefix sudah "xt_"
✅ Tidak ada folder duplikat
✅ Sync script berfungsi dengan baik
```

## File yang Ada di Repo Sekarang

| File | Kondisi | Keterangan |
|------|---------|-----------|
| `main.luau` | ✅ Bersih | Entry point, deteksi game |
| `Games/BloxFruits.luau` | ✅ Bersih | Script BF baru, lengkap |
| `Utils/BloxFruits/Module.luau` | ✅ Bersih | Logic utama BF |
| `Utils/BloxFruits/Codes.json` | ✅ Bersih | Redeem codes |
| `Utils/BloxFruits/GameModules/Quests.lua` | ✅ Bersih | Data quest |
| `Utils/BloxFruits/GameModules/GuideModule.lua` | ✅ Bersih | NPC data |
| `Utils/MemeSea/Module.luau` | ✅ Bersih | Module MS (terbaca) |
| `Library/main.luau` | ✅ Bersih | UI Library |
| `Library/Utils/Icons.lua` | ✅ Bersih | Icons |
| `Translator/BloxFruits/*.json` | ✅ Bersih | 3 bahasa |
| `Translator/MemeSea/*.json` | ✅ Bersih | 1 bahasa |
| `README.md` | ✅ Bersih | Readme publik |
| `CONTEXT.md` | ✅ Bersih | Panduan AI |
| `CHANGELOG.md` | ✅ Bersih | File ini |
