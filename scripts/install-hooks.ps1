# 安装 post-commit 钩子：commit 后自动 git push
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $root ".git"))) {
    Write-Error "未找到 .git 目录：$root"
}
$src = Join-Path $root ".githooks\post-commit"
$dst = Join-Path $root ".git\hooks\post-commit"
Copy-Item -Force $src $dst
Write-Host "已安装 post-commit 钩子 -> $dst"
Write-Host "提交到 master/main 后将自动 git push。"
Write-Host "正式版 CurseForge 发布请用: .\\release.cmd <版本号>（会打 v* tag 并触发 Actions）。"
