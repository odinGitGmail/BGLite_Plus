param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Version
)

# 发版：只改 toc ## Version 并 commit；post-commit 自动 push
# GitHub Actions 检测到 toc 版本变化后打 tag 并用 BigWigs packager 上传 CurseForge
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$toc = Join-Path $root "BGLite_Plus.toc"

if (-not (Test-Path $toc)) {
    Write-Error "toc file not found: $toc"
}

$content = Get-Content $toc -Raw -Encoding UTF8
$pattern = '(?m)^## Version:.*'
if ($content -notmatch $pattern) {
    Write-Error "missing ## Version in toc"
}

$newContent = [regex]::Replace($content, $pattern, "## Version: $Version")
Set-Content -Path $toc -Value $newContent -Encoding UTF8 -NoNewline

Set-Location $root
git add BGLite_Plus.toc
git commit -m "release: v$Version"

Write-Host ""
Write-Host "[BGLite_Plus] toc ## Version -> $Version committed."
Write-Host "[BGLite_Plus] post-commit will push; Actions publishes when toc version changes."
