# BGLite Plus

An enhancement addon for **[BGLite](https://github.com/)** that adds **Wishlist** and **Character Overview** without modifying BGLite source code.

| | |
|---|---|
| **Game** | World of Warcraft · Titan (Classic+) |
| **Requires** | **BGLite** must be installed and enabled |
| **Author** | 丷杠上开花丷 |
| **License** | [MIT](LICENSE) |
| **Version** | See `## Version` in `BGLite_Plus.toc` |

[中文说明](README.zh-CN.md) · [CurseForge](https://authors.curseforge.com/#/projects/1672098/files) · [GitHub](https://github.com/odinGitGmail/BGLite_Plus)

---

## Features

### Wishlist

- Adds a **Wishlist** tab to the BGLite main window
- Manage desired loot per boss row and item slot
- Saved **per realm + character**
- Click a cell to pick from that boss’s loot list
- **Export / Import** on the title bar (Wishlist tab only)
- Optional voice alerts for loot / auction matches
- Minimap tooltip shows current wishes

### Character Overview

- Multi-character raid progress, currencies, professions, reputation, and more
- Standalone UI via slash command or keybind
- Choose which raids / quests / profession CDs / factions / currencies to show
- Sorting, layout, level/ilvl filters, notes, talent icons, and more

---

## Installation

1. Install and enable **BGLite**
2. Copy the `BGLite_Plus` folder into  
   `World of Warcraft\_classic_titan_\Interface\AddOns\`
3. Enable **BGLite Plus** in the AddOns list at login
4. Reload UI (`/reload`)

Or install the Release zip from [CurseForge](https://authors.curseforge.com/#/projects/1672098/files).

> BGLite Plus alone is not sufficient — BGLite is required.  
> If you previously used the standalone **TitanCharOverview** addon, disable it to avoid duplicate features; use the BGLite option tabs below instead.

---

## Slash Commands

| Command | Description |
|---------|-------------|
| `/bgp hope` or `/bgph hope` | Open BGLite and switch to Wishlist tab |
| `/bgp ro` | Open Character Overview |
| `/bgp hope debug` | Print wishlist UI debug info |
| `/bgp hope rebuild` | Force rebuild wishlist UI |

---

## Settings

Open **Options → AddOns → BGLite** (金团表格纯净版). Tabs added by Plus:

| Tab | Contents |
|-----|----------|
| **Character Overview** | Scale/opacity, keybind, open/delete character; raid/quest/profession CD/faction/currency toggles; sort & layout; level/ilvl filters; notes, talents, faction coloring, etc. |
| **Wishlist** | Loot / auction voice alerts, etc. |

---

## FAQ

**Wishlist tab shows no boss rows or slots?**  
Run `/bgp hope rebuild` or `/reload`; keep both addons updated.

**Loot picker unclickable or disappears immediately?**  
Update to the latest build (list layering + focus-lost no longer closes the picker).

**Crash on Wishlist with `UpdateBiaoGeAllIsHaved`?**  
Update to **v0.1.3+** (safe override in Plus; BGLite files untouched).

**Character Overview settings only show scale sliders?**  
Update to the latest build and `/reload`. Full toggles live under **BGLite → Character Overview**, not the old TitanCharOverview page.

**TitanCharOverview still appears in the AddOns settings list?**  
That is the old standalone addon — disable it. Plus owns overview/wishlist settings now.

**CurseForge file shows Alpha instead of Release?**  
From **v0.1.4**, publishes are tag-triggered Releases. Download the latest Release build.

**Does it change BGLite?**  
No. Runtime hooks only via `BG.*`.

---

## Development / Release

Requires **Python 3**, **git**, and GitHub secret `CF_API_KEY`.

```powershell
cd D:\dev\github\wow_interface\BGLite_Plus

# Release: auto-bump last toc version segment (e.g. 0.1.7 -> 0.1.8)
.\release.cmd

# Or set an explicit version
.\release.cmd 0.2.0
```

Flow: bump `## Version` → commit → annotated tag `v{version}` → push branch + tag → GitHub Actions (BigWigs packager) uploads a CurseForge **Release**.

Notes:

- Do not reuse a version / tag
- Tag names must not contain `alpha` / `beta`
- If git uses `http.proxy` (e.g. Clash on `127.0.0.1:7890`), keep the proxy running during release
- CurseForge project description must be pasted in the Authors UI (not auto-synced from README)
- See [CHANGELOG.md](CHANGELOG.md)

---

## Links

- Source: https://github.com/odinGitGmail/BGLite_Plus
- Changelog: [CHANGELOG.md](CHANGELOG.md)
- CurseForge: https://authors.curseforge.com/#/projects/1672098/files
