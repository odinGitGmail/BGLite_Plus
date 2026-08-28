param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Version
)

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
Write-Host "[BGLite_Plus] release v$Version committed."
Write-Host "[BGLite_Plus] post-commit hook will push and sync to game folder."
