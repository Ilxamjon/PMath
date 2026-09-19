# Cursor agent tugagach: o'zgarishlarni GitHubga yuborish.
$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $root

if (-not (Test-Path (Join-Path $root '.git'))) { exit 0 }
if (-not (git -C $root remote get-url origin 2>$null)) { exit 0 }

& (Join-Path $root 'scripts\sync-to-github.ps1') | Out-Null
exit 0
