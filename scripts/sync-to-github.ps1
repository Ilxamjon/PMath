# Loyihadagi o'zgarishlarni commit + push qiladi.
$ErrorActionPreference = 'Continue'
Set-Location (Split-Path -Parent $PSScriptRoot)

if (-not (Test-Path '.git')) {
  Write-Error 'Git repo topilmadi.'
  exit 1
}

$branch = git rev-parse --abbrev-ref HEAD
if (-not (git remote get-url origin 2>$null)) {
  Write-Error 'origin remote yo''q. Avval GitHub repo ulang.'
  exit 1
}

$dirty = git status --porcelain
if ($dirty) {
  git add -A
  $msg = "chore: sync $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
  git commit -m $msg
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

git push origin $branch
exit $LASTEXITCODE
