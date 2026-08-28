# 一次性配置 CurseForge（BGLite_Plus 项目 ID 已固定为 1672098）
param(
    [string]$ProjectId = "1672098",
    [string]$ApiKey
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$localFile = Join-Path $root ".cf.local"
$gh = "C:\Program Files\GitHub CLI\gh.exe"

if (-not $ApiKey) {
    $ApiKey = Read-Host "粘贴 CurseForge API Key（Authors 页面生成，与 TitanCharOverview 相同即可）"
}

Set-Content -Path $localFile -Value @(
    "CF_API_KEY=$ApiKey"
    "CF_PROJECT_ID=$ProjectId"
) -Encoding UTF8
Write-Host "已写入 $localFile"

if (Test-Path $gh) {
    $null = & $gh auth status 2>&1
    if ($LASTEXITCODE -eq 0) {
        & $gh secret set CF_API_KEY --body $ApiKey --repo odinGitGmail/BGLite_Plus
        Write-Host "已写入 GitHub Secret: CF_API_KEY"
    } else {
        Write-Host "gh 未登录。请在浏览器打开："
        Write-Host "https://github.com/odinGitGmail/BGLite_Plus/settings/secrets/actions/new"
        Write-Host "Name=CF_API_KEY，Value=你的 API Key"
    }
}

Write-Host ""
Write-Host "配置完成后发版："
Write-Host "  .\release.cmd 0.1.3"
