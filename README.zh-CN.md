# BGLite Plus

**BGLite 增强插件** — 在 [BGLite](https://github.com/) 基础上增加**心愿清单**与**角色总览**，不修改 BGLite 源码。

| | |
|---|---|
| **游戏** | 魔兽世界 · 时光服（Titan） |
| **依赖** | 必须先安装并启用 **BGLite** |
| **作者** | 丷杠上开花丷 |
| **许可** | [MIT](LICENSE) |
| **当前版本** | 见 `BGLite_Plus.toc` 中 `## Version` |

[English](README.md) · [CurseForge](https://authors.curseforge.com/#/projects/1672098/files) · [GitHub](https://github.com/odinGitGmail/BGLite_Plus)

---

## 功能

### 心愿清单

- 在 BGLite 主界面新增 **心愿** Tab
- 按 Boss 行 + 装备格子管理心愿装备
- **按服务器 + 角色分别保存**（切角色互不影响）
- 标题栏 **导出 / 导入心愿**（仅心愿 Tab 显示）
- 心愿达成 / 拍卖语音提醒（可在设置中开关）
- 小地图悬停显示当前心愿摘要

### 角色总览

- 多角色团本完成度、装备与背包概览
- 独立 UI，可通过命令或快捷键打开
- 支持 UI 缩放、背景透明度等选项

---

## 安装

1. 安装并启用 **BGLite**
2. 将 `BGLite_Plus` 文件夹放入  
   `World of Warcraft\_classic_titan_\Interface\AddOns\`
3. 登录后在插件列表勾选 **BGLite Plus**
4. 重载界面（`/reload`）

也可从 [CurseForge](https://authors.curseforge.com/#/projects/1672098/files) 下载正式版压缩包安装。

> 仅安装 BGLite Plus、不装 BGLite 时插件无法正常工作。

---

## 命令

| 命令 | 说明 |
|------|------|
| `/bgp hope` 或 `/bgph hope` | 打开 BGLite 并切到心愿 Tab |
| `/bgp ro` | 打开角色总览 |
| `/bgp hope debug` | 心愿 UI 调试信息 |
| `/bgp hope rebuild` | 强制重建心愿界面 |

---

## 设置

打开 BGLite 设置界面，可找到：

- **角色总览**：UI 缩放、背景透明度、快捷键等
- **心愿清单**：达成语音、拍卖语音等

---

## 常见问题

**心愿 Tab 没有 Boss 行或格子？**  
执行 `/bgp hope rebuild` 或 `/reload`；确认 BGLite 与 BGLite Plus 均为最新版。

**点格子后装备列表在下层、点不到？**  
请更新到 **v0.1.3+**（列表会提到 TOOLTIP 层）。

**切到心愿页报 `UpdateBiaoGeAllIsHaved` / `zhuangbei` 空引用？**  
请更新到 **v0.1.3+**（Plus 安全覆盖，不改 BGLite）。

**CurseForge 上是 Alpha 而不是正式版？**  
自 **v0.1.4** 起改为仅 `v*` tag 发版，应为绿色 Release。请下载最新正式文件。

**和 BGLite 冲突吗？**  
不会修改 BGLite 文件，仅在运行时扩展 `BG.*` 行为；只装 BGLite 时行为与原版一致。

---

## 开发 / 发版

需要本机已安装 **Python 3** 与 **git**，并配置 GitHub Secret `CF_API_KEY`。

```powershell
cd D:\dev\github\wow_interface\BGLite_Plus

# 正式版：自动递增 toc 最小版本段（如 0.1.6 → 0.1.7）
.\release.cmd

# 或指定版本
.\release.cmd 0.2.0
```

流程：改 `## Version` → commit → 打 annotated tag `v{版本}` → push 分支与 tag → GitHub Actions（BigWigs packager）上传 CurseForge **Release**。

注意：

- 同一版本号 / 同一 tag **不可复用**
- tag 名不要包含 `alpha` / `beta`
- 若本机 git 配置了 `http.proxy`（如 Clash `127.0.0.1:7890`），发版时请保持代理可用
- 详细变更见 [CHANGELOG.md](CHANGELOG.md)

---

## 链接

- 源码：https://github.com/odinGitGmail/BGLite_Plus
- 更新日志：[CHANGELOG.md](CHANGELOG.md)
- CurseForge：https://authors.curseforge.com/#/projects/1672098/files
