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
- 点击格子弹出该 Boss 掉落列表选择装备
- 标题栏 **导出 / 导入心愿**（仅心愿 Tab 显示）
- 心愿达成 / 拍卖语音提醒（可在设置中开关）
- 小地图悬停显示当前心愿摘要

### 角色总览

- 多角色团本完成度、货币、专业、声望等概览
- 独立 UI，可通过命令或快捷键打开
- 可自定义显示哪些团本 / 任务 / 专业 CD / 声望 / 货币
- 支持排序方式、布局、装等/等级过滤、备注、专精图标等

---

## 安装

1. 安装并启用 **BGLite**
2. 将 `BGLite_Plus` 文件夹放入  
   `World of Warcraft\_classic_titan_\Interface\AddOns\`
3. 登录后在插件列表勾选 **BGLite Plus**
4. 重载界面（`/reload`）

也可从 [CurseForge](https://authors.curseforge.com/#/projects/1672098/files) 下载正式版压缩包安装。

> 仅安装 BGLite Plus、不装 BGLite 时插件无法正常工作。  
> 若曾使用独立插件 **TitanCharOverview**，请禁用它，避免与 Plus 功能重复；设置请改用下方 BGLite 内页签。

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

打开游戏 **设置 → 插件 → BGLite-金团表格纯净版**，可见页签：

| 页签 | 内容 |
|------|------|
| **角色总览** | UI 缩放/透明度、快捷键、打开/删除角色；团本·任务·专业 CD·声望·货币勾选；排序与布局；等级/装等过滤；备注、专精、阵营等 |
| **心愿清单** | 心愿达成语音、拍卖语音等 |

---

## 常见问题

**心愿 Tab 没有 Boss 行或格子？**  
执行 `/bgp hope rebuild` 或 `/reload`；确认 BGLite 与 BGLite Plus 均为最新版。

**点格子后装备列表点不到 / 一闪就没？**  
请更新到最新版（列表抬层且失焦时不再误关列表）。

**切到心愿页报 `UpdateBiaoGeAllIsHaved` / `zhuangbei` 空引用？**  
请更新到 **v0.1.3+**（Plus 安全覆盖，不改 BGLite）。

**角色总览设置里只有缩放，没有团本勾选？**  
请更新到最新版并 `/reload`；完整配置在 **BGLite → 角色总览** 页签，不再使用 TitanCharOverview 独立设置页。

**设置列表里还有 TitanCharOverview？**  
那是旧独立插件。禁用即可；Plus 已接管角色总览与心愿相关能力。

**CurseForge 上是 Alpha 而不是正式版？**  
自 **v0.1.4** 起改为仅 `v*` tag 发版，应为绿色 Release。请下载最新正式文件。

**和 BGLite 冲突吗？**  
不会修改 BGLite 文件，仅在运行时扩展 `BG.*` 行为；只装 BGLite 时行为与原版一致。

---

## 开发 / 发版

需要本机已安装 **Python 3** 与 **git**，并配置 GitHub Secret `CF_API_KEY`。

```powershell
cd D:\dev\github\wow_interface\BGLite_Plus

# 正式版：自动递增 toc 最小版本段（如 0.1.7 → 0.1.8）
.\release.cmd

# 或指定版本
.\release.cmd 0.2.0
```

流程：改 `## Version` → commit → 打 annotated tag `v{版本}` → push 分支与 tag → GitHub Actions（BigWigs packager）上传 CurseForge **Release**。

注意：

- 同一版本号 / 同一 tag **不可复用**
- tag 名不要包含 `alpha` / `beta`
- 若本机 git 配置了 `http.proxy`（如 Clash `127.0.0.1:7890`），发版时请保持代理可用
- CurseForge 网页「详细介绍」需在作者后台手动粘贴（不会随 README 自动同步）
- 详细变更见 [CHANGELOG.md](CHANGELOG.md)

---

## 链接

- 源码：https://github.com/odinGitGmail/BGLite_Plus
- 更新日志：[CHANGELOG.md](CHANGELOG.md)
- CurseForge：https://authors.curseforge.com/#/projects/1672098/files
