param(
    [Parameter(Mandatory = $false, Position = 0)]
    [string]$Version
)

# Release: bump toc ## Version -> commit -> annotated tag v{Version} -> push branch+tag
# Usage:
#   .\release.cmd           # auto: bump last toc segment (0.1.3 -> 0.1.4)
#   .\release.cmd 0.2.0     # explicit version
# Tag push triggers BigWigs packager CurseForge Release
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$toc = Join-Path $root "BGLite_Plus.toc"

if (-not (Test-Path $toc)) {
    Write-Error "toc file not found: $toc"
}

Set-Location $root

function Get-TocVersion([string]$text) {
    $m = [regex]::Match($text, '(?m)^## Version:\s*(.+?)\s*$')
    if (-not $m.Success) {
        throw "missing ## Version in toc"
    }
    return $m.Groups[1].Value.Trim()
}

function Get-NextPatchVersion([string]$ver) {
    if ($ver -notmatch '^\d+(\.\d+)+$') {
        throw "cannot auto-bump version: $ver (expected like 0.1.3)"
    }
    $parts = $ver.Split(".")
    $last = [int]$parts[$parts.Length - 1]
    $parts[$parts.Length - 1] = [string]($last + 1)
    return ($parts -join ".")
}

function Test-GitTagExists([string]$tagName) {
    $out = & git tag -l $tagName 2>$null
    return -not [string]::IsNullOrWhiteSpace($out)
}

$content = Get-Content $toc -Raw -Encoding UTF8
$current = Get-TocVersion $content
$autoBump = [string]::IsNullOrWhiteSpace($Version)

if ($autoBump) {
    $Version = Get-NextPatchVersion $current
    while (Test-GitTagExists ("v" + $Version)) {
        Write-Host ("[BGLite_Plus] tag v" + $Version + " exists, bump again...")
        $Version = Get-NextPatchVersion $Version
    }
    Write-Host ("[BGLite_Plus] auto bump: " + $current + " -> " + $Version)
}
else {
    $Version = $Version.Trim()
    if ($Version -match "^v") {
        $Version = $Version.Substring(1)
    }
}

if ($Version -match "(?i)alpha|beta") {
    Write-Error ("version must not contain alpha/beta: " + $Version)
}
if ($Version -notmatch '^\d+(\.\d+)+$') {
    Write-Error ("invalid version: " + $Version + " (expected like 0.1.4)")
}

$tag = "v" + $Version
if (Test-GitTagExists $tag) {
    Write-Error ("tag already exists: " + $tag + " (bump version and retry)")
}

$pattern = '(?m)^## Version:.*'
$newContent = [regex]::Replace($content, $pattern, ("## Version: " + $Version))
Set-Content -Path $toc -Value $newContent -Encoding UTF8 -NoNewline

# Include release pipeline files so the tagged commit can trigger tag-based Actions
$releaseFiles = @(
    "BGLite_Plus.toc",
    ".github/workflows/release.yml",
    "scripts/release.ps1",
    "scripts/release.cmd",
    "scripts/install-hooks.ps1",
    "README.md",
    "README.zh-CN.md",
    "CHANGELOG.md"
)
foreach ($f in $releaseFiles) {
    if (Test-Path (Join-Path $root $f)) {
        git add -- $f
    }
}

git commit -m ("release: " + $tag)
if ($LASTEXITCODE -ne 0) {
    Write-Error "git commit failed"
}

git tag -a $tag -m ("release: " + $tag + " (toc ## Version)")
if ($LASTEXITCODE -ne 0) {
    Write-Error ("git tag failed: " + $tag)
}

$env:HTTP_PROXY = ""
$env:HTTPS_PROXY = ""
$env:http_proxy = ""
$env:https_proxy = ""
$env:ALL_PROXY = ""
$env:all_proxy = ""

git -c http.proxy= -c https.proxy= push origin HEAD
if ($LASTEXITCODE -ne 0) {
    Write-Warning "git push branch failed; run manually: git push origin HEAD"
}

git -c http.proxy= -c https.proxy= push origin ("refs/tags/" + $tag)
if ($LASTEXITCODE -ne 0) {
    Write-Error ("git push tag failed; run: git push origin " + $tag)
}

Write-Host ""
Write-Host ("[BGLite_Plus] toc ## Version -> " + $Version)
Write-Host ("[BGLite_Plus] tagged " + $tag + " and pushed. Actions will upload CurseForge Release.")
