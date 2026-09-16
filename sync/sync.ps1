# Syncs Claude Code conversation history (~/.claude/projects) across machines via git.
# Redacts known secret patterns before every commit.
$claudeDir = Split-Path -Parent $PSScriptRoot
Set-Location $claudeDir

node "$claudeDir\sync\redact-secrets.mjs"
if ($LASTEXITCODE -ne 0) { Write-Error "redact-secrets.mjs failed"; exit 1 }

git ls-remote --exit-code --heads origin main *> $null
$remoteHasMain = ($LASTEXITCODE -eq 0)

if ($remoteHasMain) {
    git pull origin main --no-edit
    if ($LASTEXITCODE -ne 0) { Write-Error "git pull failed"; exit 1 }
}

git add .gitignore projects sync
$staged = git diff --cached --name-only
if (-not $staged) {
    Write-Output "Nothing to sync."
    exit 0
}

git commit -m "sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
if ($LASTEXITCODE -ne 0) { Write-Error "git commit failed"; exit 1 }

git push origin main
if ($LASTEXITCODE -ne 0) { Write-Error "git push failed"; exit 1 }
