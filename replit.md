# Xtray Script

Script hub Roblox gratis tanpa key, mendukung Blox Fruits, Meme Sea, dan Vox Seas.

## Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/XtrayScript/XtrayScript/refs/heads/main/main.luau"))()
```

Dengan settings (Blox Fruits):
```lua
local Settings = {
  JoinTeam = "Pirates"; -- Pirates/Marines
  Translator = true;    -- true/false
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/XtrayScript/XtrayScript/refs/heads/main/main.luau"))(Settings)
```

## Struktur File

```
main.luau                  — Entry point, deteksi game & routing
Games/
  BloxFruits.luau          — Script Blox Fruits (file utama, ~2961 baris)
  MemeSea.luau             — Script Meme Sea
  VoxSeas.luau             — Script Vox Seas
Library/
  main.luau                — UI Library utama
Utils/Module/
  Movement.luau            — Modul gerakan karakter
  FullBright.luau          — Fullbright toggle
  AntiReset.luau           — Anti reset / anti death
  BloxFruitsESP.luau       — ESP untuk Blox Fruits
  FastAttack.luau          — Fast attack module
  BloxFruitsAimBotModule.luau — AimBot module
```

## Game yang Didukung

- **Blox Fruits** — Sea 1, 2, 3 (PlaceId lama & baru)
- **Meme Sea**
- **Vox Seas**

## Status Pengembangan

### Selesai
- Script bisa dijalankan di PC dan Mobile
- Kill Aura (tab Farm)
- Utilitas Farm (Walk in Water, Disable Damage Counter, Remove VFX)
- AimBot, ESP, Auto Stats, Auto Quest, Auto Boss, Auto Fishing, Mastery Farm, Sea Event Farm, Extras, Teleport

### Dalam Pengembangan / Dihapus Sementara
- Auto Farm (loop & error — dihapus dari tab)
- Auto Farm Level (dihapus)
- Fast Attack (dihapus dari tab Farm)
- Super Clique (dihapus dari tab Farm)
- Main Farm / Farm Settings (dihapus)

### Tab Farm Saat Ini (BloxFruits.luau)
- **Kill Aura** — otomatis membunuh musuh dalam radius
- **Utilitas** — Walk in Water, Disable Damage Counter, Remove Effects (VFX)

## Stack / Bahasa

- Luau (Roblox scripting language)
- Tidak ada backend, tidak ada database

## User Preferences

- Tab Farm hanya berisi: Kill Aura dan Utilitas Farm
- Fitur Auto Farm dihapus sementara karena masalah stuck loop dan crash
