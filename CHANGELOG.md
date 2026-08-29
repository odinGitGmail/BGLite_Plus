# 更新日志

本文档记录 **BGLite Plus** 的重要变更。  
版本号与 `BGLite_Plus.toc` 中的 `## Version` 一致。

格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)。

---

## [0.1.7] - 2026-08-30

### 变更
- `release.py` 发版推送保留本机 git `http.proxy`（不再清空代理导致 push 失败）

---

## [0.1.6] - 2026-08-30

### 变更
- `release.cmd` 优先调用 Python 发版脚本，避免 Windows PowerShell 编码/解析错误

---

## [0.1.5] - 2026-08-30

### 变更
- 发版提交自动包含流水线与文档相关文件，确保 tag 对应提交可触发正式版 Actions

---

## [0.1.4] - 2026-08-30

### 变更
- 发版流水线改为仅推送 `v*` tag 时打包；CurseForge 上传为 **正式版（Release）**，不再因 master 推送变成 Alpha
- `release.cmd` 支持无参数自动递增 toc 最小版本段；有参数则使用指定版本

### 修复
- （继承 0.1.3）心愿页空引用崩溃、装备选择列表层级

---

## [0.1.3] - 2026-08-29

### 新增
- 配置 CurseForge 项目（`X-Curse-Project-ID: 1672098`）
- 首次通过 GitHub Actions + BigWigs packager 自动上传 CurseForge

### 修复
- 心愿页切换时 `UpdateBiaoGeAllIsHaved` 按 `Maxb` 越界访问导致报错（Plus 安全覆盖，不改 BGLite）
- 心愿装备选择列表被格子挡住无法点击（弹出后提升到 TOOLTIP 层）

---

## [0.1.2] - 2026-08-28

### 新增
- `release.cmd` 一键发版脚本（绕过 PowerShell 执行策略限制）
- post-commit 钩子：commit 后自动 push 并同步到游戏 AddOns 目录

### 变更
- CI 工作流支持 `CF_API_KEY`、手动强制发布、toc 项目 ID 校验

---

## [0.1.1] - 2026-08-28

### 新增
- GitHub Actions 自动发布流水线
- 版本号变更时自动生成 GitHub Release 附件
- `.pkgmeta` 打包配置（BigWigs packager）

---

## [0.1.0] - 2026-08-28

### 新增
- **心愿清单 Tab** 集成到 BGLite 主界面（Boss 行 + 装备格子）
- 标题栏 **导出 / 导入心愿**（仅心愿 Tab 显示）
- **角色总览**（多角色团本 / 装备概览）
- 斜杠命令：`/bgp`、`/bgph`（`hope`、`ro`、`hope debug`、`hope rebuild`）
- 运行时扩展 BGLite（`HopeOverrides`、`HopeTab`、`WishlistHope` 等）
- 角色总览缩放/透明度、心愿语音提醒等设置项
- 小地图悬停显示心愿摘要

### 修复
- 心愿 UI 被主窗背景遮挡（帧层级）
- 编辑心愿格时装备列表重复叠加、无法关闭
- `HopeOverrides` Lua 报错（WoW Lua 不支持给函数挂字段）

---

[0.1.7]: https://github.com/odinGitGmail/BGLite_Plus/compare/v0.1.6...v0.1.7
[0.1.6]: https://github.com/odinGitGmail/BGLite_Plus/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/odinGitGmail/BGLite_Plus/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/odinGitGmail/BGLite_Plus/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/odinGitGmail/BGLite_Plus/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/odinGitGmail/BGLite_Plus/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/odinGitGmail/BGLite_Plus/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/odinGitGmail/BGLite_Plus/releases/tag/v0.1.0
