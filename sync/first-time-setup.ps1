# First-time setup for a new machine joining Claude Code conversation-history sync.
# Safely handles the case where this machine already has its own pre-existing
# ~/.claude/projects data (e.g. memory/*.md for a project path also used elsewhere)
# by backing up any conflicting local files before pulling in the shared history.
$claudeDir = "$env:USERPROFILE\.claude"
Set-Location $claudeDir

if (-not (Test-Path ".git")) {
    git init
}
$hasOrigin = git remote 2>$null | Select-String -Pattern "^origin$"
if (-not $hasOrigin) {
    git remote add origin https://github.com/lightchen1101/apocalypse-sync.git
}

git fetch origin
if ($LASTEXITCODE -ne 0) { Write-Error "git fetch failed"; exit 1 }

git rev-parse --verify main *> $null
if ($LASTEXITCODE -eq 0) {
    Write-Output "Branch 'main' already exists -- setup already done on this machine. Use sync.ps1 instead."
    exit 0
}

$errFile = Join-Path $env:TEMP "claude-sync-checkout-err.txt"
git checkout -b main origin/main 2> $errFile
$checkoutExit = $LASTEXITCODE
$errText = if (Test-Path $errFile) { Get-Content $errFile -Raw } else { "" }
Remove-Item -ErrorAction SilentlyContinue $errFile

if ($checkoutExit -ne 0) {
    $conflicts = ($errText -split "`r?`n") | Where-Object { $_ -match '^\s+projects[/\\]' } | ForEach-Object { $_.Trim() }
    if (-not $conflicts) {
        Write-Error "git checkout failed for a reason other than file conflicts:"
        Write-Error $errText
        exit 1
    }
    Write-Output "Found $($conflicts.Count) pre-existing local file(s) that collide with the synced history. Backing them up:"
    foreach ($rel in $conflicts) {
        $full = Join-Path $claudeDir $rel
        if (-not (Test-Path -LiteralPath $full)) { continue }
        $dir = Split-Path $full -Parent
        $name = [System.IO.Path]::GetFileNameWithoutExtension($full)
        $ext = [System.IO.Path]::GetExtension($full)
        $backup = Join-Path $dir "$name.pre-sync-backup$ext"
        Move-Item -LiteralPath $full -Destination $backup -Force
        Write-Output "  $rel -> $(Split-Path -Leaf $backup)"
    }
    git checkout -b main origin/main
    if ($LASTEXITCODE -ne 0) { Write-Error "git checkout still failed after backing up conflicts"; exit 1 }
}

node "$claudeDir\sync\redact-secrets.mjs"
if ($LASTEXITCODE -ne 0) { Write-Error "redact-secrets.mjs failed"; exit 1 }

git add .gitignore projects sync
$staged = git diff --cached --name-only
if ($staged) {
    git commit -m "sync: add this machine's existing history"
    if ($LASTEXITCODE -ne 0) { Write-Error "git commit failed"; exit 1 }
    git push origin main
    if ($LASTEXITCODE -ne 0) { Write-Error "git push failed"; exit 1 }
} else {
    Write-Output "Nothing new to add from this machine."
}

Write-Output ""
Write-Output "Done. If any *.pre-sync-backup files were created, review them and manually merge"
Write-Output "anything worth keeping into the corresponding memory/*.md file, then delete the backup."
