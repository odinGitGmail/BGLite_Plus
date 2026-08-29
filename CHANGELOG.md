# 更新日志

本文档记录 **BGLite Plus** 的重要变更。  
版本号与 `BGLite_Plus.toc` 中的 `## Version` 一致。

格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)。

---

## [0.1.8] - 2026-08-30

### 新增
- `OptionsBridge`：自建设置控件工厂，将页签可靠挂入 BGLite 设置
- **角色总览** 设置补全（自 TitanCharOverview 迁入）：团本 / 任务 / 专业 CD / 声望 / 货币勾选，排序与布局，等级与装等过滤，备注 / 专精 / 阵营等

### 修复
- 心愿格子点击后装备列表不出现或一闪即关（失焦误关列表；抬层改为同 Strata 提高 FrameLevel）
- BGLite 设置中缺少「角色总览 / 心愿清单」页签（原先依赖 BGLite 私有 `ns.O` 导致安装失败）

### 变更
- 角色总览 / 心愿相关设置统一在 **BGLite** 选项内；请禁用独立插件 TitanCharOverview，避免重复
- 更新 README（中/英）说明设置入口、与 TCO 关系及常见问题

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
- 心愿装备选择列表被格子挡住无法点击（弹出后提升列表层级）

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

[0.1.8]: https://github.com/odinGitGmail/BGLite_Plus/compare/v0.1.7...v0.1.8
[0.1.7]: https://github.com/odinGitGmail/BGLite_Plus/compare/v0.1.6...v0.1.7
[0.1.6]: https://github.com/odinGitGmail/BGLite_Plus/compare/v0.1.5...v0.1.6
[0.1.5]: https://github.com/odinGitGmail/BGLite_Plus/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/odinGitGmail/BGLite_Plus/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/odinGitGmail/BGLite_Plus/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/odinGitGmail/BGLite_Plus/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/odinGitGmail/BGLite_Plus/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/odinGitGmail/BGLite_Plus/releases/tag/v0.1.0
