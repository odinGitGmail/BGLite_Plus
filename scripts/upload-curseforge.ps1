# 本地直传 CurseForge（配置好 .cf.local 后可用）
param(
    [string]$Version
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$localFile = Join-Path $root ".cf.local"
$toc = Join-Path $root "BGLite_Plus.toc"

if (-not (Test-Path $localFile)) {
    Write-Error "缺少 $localFile，请先运行 scripts\setup-cf-once.cmd"
}

$config = @{}
Get-Content $localFile | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') { $config[$matches[1]] = $matches[2] }
}

$token = $config['CF_API_KEY']
$projectId = $config['CF_PROJECT_ID']
if (-not $token -or -not $projectId) {
    Write-Error ".cf.local 需要 CF_API_KEY 和 CF_PROJECT_ID"
}

if (-not $Version) {
    $Version = (Select-String -Path $toc -Pattern '^## Version:' | ForEach-Object { $_.Line -replace '^## Version:\s*','' })
}

$stage = Join-Path $root "dist\stage\BGLite_Plus"
$zip = Join-Path $root "dist\BGLite_Plus-$Version.zip"
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Path $stage -Force | Out-Null
robocopy $root $stage /E /XD .git .github .vscode dist scripts .githooks /XF .gitcommit .gitignore .cf.local /NFL /NDL /NJH /NJS /nc /ns /np | Out-Null
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path $stage -DestinationPath $zip

$gameVersions = @()
if ($config['CF_GAME_VERSION_IDS']) {
    $gameVersions = $config['CF_GAME_VERSION_IDS'].Split(',') | ForEach-Object { [int]$_.Trim() }
} else {
    $gv = Invoke-RestMethod -Uri "https://wow.curseforge.com/api/game/versions" -Headers @{ "X-Api-Token" = $token }
    $ifaceLine = Select-String -Path $toc -Pattern '^## Interface:' | ForEach-Object { $_.Line }
    $iface = [int]($ifaceLine -replace '^## Interface:\s*','')
    $major = [math]::Floor($iface / 10000)
    $minor = [math]::Floor(($iface / 100) % 100)
    $patch = $iface % 100
    $name = "$major.$minor.$patch"
    $match = $gv | Where-Object { $_.name -eq $name } | Select-Object -First 1
    if (-not $match) { Write-Error "无法匹配游戏版本 $name，请在 .cf.local 设置 CF_GAME_VERSION_IDS" }
    $gameVersions = @([int]$match.id)
}

$metadata = @{
    changelog     = "BGLite Plus $Version"
    changelogType = "text"
    displayName   = "BGLite Plus $Version"
    releaseType   = "release"
    gameVersions  = $gameVersions
} | ConvertTo-Json -Compress

$boundary = [System.Guid]::NewGuid().ToString()
$bodyLines = @(
    "--$boundary"
    'Content-Disposition: form-data; name="metadata"'
    ''
    $metadata
    "--$boundary"
    "Content-Disposition: form-data; name=`"file`"; filename=`"BGLite_Plus-$Version.zip`""
    'Content-Type: application/zip'
    ''
)
$enc = [System.Text.Encoding]::UTF8
$bodyStart = $enc.GetBytes(($bodyLines -join "`r`n") + "`r`n")
$fileBytes = [System.IO.File]::ReadAllBytes($zip)
$bodyEnd = $enc.GetBytes("`r`n--$boundary--`r`n")
$body = New-Object byte[] ($bodyStart.Length + $fileBytes.Length + $bodyEnd.Length)
[Array]::Copy($bodyStart, 0, $body, 0, $bodyStart.Length)
[Array]::Copy($fileBytes, 0, $body, $bodyStart.Length, $fileBytes.Length)
[Array]::Copy($bodyEnd, 0, $body, $bodyStart.Length + $fileBytes.Length, $bodyEnd.Length)

$uri = "https://wow.curseforge.com/api/projects/$projectId/upload-file"
$response = Invoke-WebRequest -Method Post -Uri $uri -Headers @{
    "X-Api-Token" = $token
    "Content-Type" = "multipart/form-data; boundary=$boundary"
} -Body $body
Write-Host "CurseForge 上传成功 HTTP $($response.StatusCode)"
