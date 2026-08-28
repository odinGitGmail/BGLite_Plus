# 一次性：把 CurseForge 凭据写入 GitHub Secrets（与 TitanCharOverview 相同用法）
# 用法：在 PowerShell 中运行，按提示粘贴 CF API Key 和项目 ID
param(
    [string]$Repo = "odinGitGmail/BGLite_Plus",
    [string]$CfApiKey,
    [string]$CfProjectId,
    [string]$CfGameVersionIds,
    [string]$GitHubToken
)

$ErrorActionPreference = "Stop"

function Set-GhSecret([string]$Name, [string]$Value) {
    if (-not $Value) { return }
    $body = @{ encrypted_value = $Value; key_id = $keyId } | ConvertTo-Json
    $uri = "https://api.github.com/repos/$Repo/actions/secrets/$Name"
    Invoke-RestMethod -Method Put -Uri $uri -Headers $headers -Body $body -ContentType "application/json" | Out-Null
    Write-Host "已设置 Secret: $Name"
}

if (-not $GitHubToken) {
    $GitHubToken = $env:GITHUB_TOKEN
}
if (-not $GitHubToken) {
    Write-Host "需要 GitHub Personal Access Token（权限：repo）。"
    Write-Host "在 https://github.com/settings/tokens 创建，然后："
    Write-Host '  $env:GITHUB_TOKEN = "ghp_..."'
    Write-Host "  .\scripts\setup-secrets.ps1"
    exit 1
}

if (-not $CfApiKey) {
    $CfApiKey = Read-Host "粘贴 CurseForge API Key（与 TitanCharOverview 相同）"
}
if (-not $CfProjectId) {
    $CfProjectId = Read-Host "粘贴 BGLite Plus 的 CurseForge 项目 ID（纯数字）"
}

$headers = @{
    Authorization = "Bearer $GitHubToken"
    Accept        = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

$pubKey = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/actions/secrets/public-key" -Headers $headers
$keyId = $pubKey.key_id
$publicKey = $pubKey.key

# GitHub 要求 libsodium 加密；用 gh 更简单。无 gh 时提示手动配置。
if (Get-Command gh -ErrorAction SilentlyContinue) {
    gh secret set CF_API_KEY --body $CfApiKey --repo $Repo
    if ($CfProjectId) { gh secret set CF_PROJECT_ID --body $CfProjectId --repo $Repo }
    if ($CfGameVersionIds) { gh secret set CF_GAME_VERSION_IDS --body $CfGameVersionIds --repo $Repo }
    Write-Host "Secrets 已通过 gh 写入 $Repo"
    exit 0
}

Write-Host ""
Write-Host "未检测到 gh CLI。请手动在以下页面添加 Secrets（与 TitanCharOverview 用同一个 CF_API_KEY 即可）："
Write-Host "https://github.com/$Repo/settings/secrets/actions"
Write-Host ""
Write-Host "  CF_API_KEY          = （CurseForge API Key）"
Write-Host "  CF_PROJECT_ID       = $CfProjectId"
Write-Host "  CF_GAME_VERSION_IDS = （可选，Titan 游戏版本 ID，逗号分隔）"
