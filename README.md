# BGLite Plus

An enhancement addon for **[BGLite](https://github.com/)** that adds **Wishlist** and **Character Overview** without modifying BGLite source code.

| | |
|---|---|
| **Game** | World of Warcraft · Titan (Classic+) |
| **Requires** | **BGLite** must be installed and enabled |
| **Author** | 丷杠上开花丷 |
| **License** | [MIT](LICENSE) |

[中文说明](README.zh-CN.md) · [CurseForge](https://authors.curseforge.com/#/projects/1672098/files) · [GitHub](https://github.com/odinGitGmail/BGLite_Plus)

---

## Features

### Wishlist

- Adds a **Wishlist** tab to the BGLite main window
- Manage desired loot per boss row and item slot
- **Export / Import** buttons on the title bar (visible on the Wishlist tab only)
- Voice alerts when wishlist items are looted or auctioned (configurable)
- Minimap tooltip shows your current wishes

### Character Overview

- Multi-character raid progress, gear, and bag summary
- Standalone UI opened via slash command or keybind
- Options for UI scale, background opacity, and more

---

## Installation

1. Install and enable **BGLite**
2. Copy the `BGLite_Plus` folder into  
   `World of Warcraft\_classic_titan_\Interface\AddOns\`
3. Enable **BGLite Plus** in the AddOns list at login
4. Reload UI (`/reload`)

> BGLite Plus alone is not sufficient — BGLite is required.

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

In the BGLite options panel:

- **Character Overview** — scale, opacity, keybind, etc.
- **Wishlist** — loot/auction voice alerts, etc.

---

## FAQ

**Wishlist tab shows no boss rows or slots?**  
Run `/bgp hope rebuild` or `/reload`; ensure both addons are up to date.

**Loot picker lists stacking on top of each other?**  
Fixed in v0.1.x — update to the latest release.

**Does it change BGLite?**  
No files in BGLite are modified; integration is runtime-only via `BG.*` hooks.

---

## Development

```powershell
# Release (bumps toc version → commit → auto push → CurseForge)
.\release.cmd 0.1.4
```

Release is triggered when `## Version` in `BGLite_Plus.toc` changes.

---

## Links

- Source: https://github.com/odinGitGmail/BGLite_Plus
- Changelog: [CHANGELOG.md](CHANGELOG.md)
