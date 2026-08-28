# 发版：改 toc 版本号 → commit → post-commit 自动 push + 同步游戏目录 + Actions 发布
param(
    [Parameter(Mandatory = $true)]
    [string]$Version
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$toc = Join-Path $root "BGLite_Plus.toc"

if (-not (Test-Path $toc)) {
    Write-Error "找不到 $toc"
}

$content = Get-Content $toc -Raw -Encoding UTF8
if ($content -notmatch '(?m)^## Version:') {
    Write-Error "toc 中缺少 ## Version 行"
}

$newContent = [regex]::Replace($content, '(?m)^## Version:.*', "## Version: $Version")
Set-Content -Path $toc -Value $newContent -Encoding UTF8 -NoNewline

Set-Location $root
git add BGLite_Plus.toc
git commit -m "release: v$Version"

Write-Host ""
Write-Host "发版已提交。post-commit 钩子将自动 push 并同步到游戏目录。"
Write-Host "GitHub Actions 检测到版本变化后会打包并发布（GitHub Release + CurseForge）。"
