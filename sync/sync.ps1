# Syncs Claude Code conversation history (~/.claude/projects) across machines via git.
# Redacts known secret patterns before every commit.
$ErrorActionPreference = "Stop"
$claudeDir = Split-Path -Parent $PSScriptRoot
Set-Location $claudeDir

node "$claudeDir\sync\redact-secrets.mjs"

$remoteHasMain = $false
git ls-remote --exit-code --heads origin main *> $null
if ($LASTEXITCODE -eq 0) { $remoteHasMain = $true }

if ($remoteHasMain) {
    git pull origin main --no-edit
}

git add .gitignore projects sync
$staged = git diff --cached --name-only
if (-not $staged) {
    Write-Output "Nothing to sync."
    exit 0
}

git commit -m "sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git push origin main
