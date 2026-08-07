$repoUrl = "https://github.com/0ce10tsgit/createModpack.git"
$modsPath = $PSScriptRoot

Write-Host "`n=== Mod Updater ===" -ForegroundColor Cyan
Write-Host "1. Check for updates" -ForegroundColor White
Write-Host "2. Clean reinstall" -ForegroundColor White
Write-Host "`nSelect an option (1 or 2): " -ForegroundColor Yellow -NoNewline
$choice = Read-Host

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git is not installed, if you think it is google Path issue Git and do the fix, do git --version to check" -ForegroundColor Red
    pause
    exit
}

if (-not (Test-Path "$modsPath\.git")) {
    Write-Host "First time setup" -ForegroundColor Yellow
    Set-Location $modsPath
    git init
    git remote add origin $repoUrl
}

Set-Location $modsPath

if ($choice -eq "2") {
    Write-Host "`nStarting clean reinstall..." -ForegroundColor Yellow

    # Remove all .jar files
    Write-Host "Removing all .jar files..." -ForegroundColor Cyan
    Get-ChildItem -Path $modsPath -Filter "*.jar" | Remove-Item -Force

    # Empty .connector folder
    if (Test-Path "$modsPath\.connector") {
        Write-Host "Emptying .connector folder..." -ForegroundColor Cyan
        Remove-Item "$modsPath\.connector\*" -Recurse -Force
    }

    # Fetch latest from origin
    Write-Host "Fetching from repository..." -ForegroundColor Cyan
    git fetch origin

    # Reset to master and clean
    Write-Host "Restoring files from master..." -ForegroundColor Cyan
    git reset --hard origin/master
    git clean -fd

    Write-Host "`nClean reinstall complete!" -ForegroundColor Green
    pause
    exit
}

# Option 1: Check for updates
Write-Host "`nChecking for updates..." -ForegroundColor Cyan
git fetch origin

$changes = git diff --name-status HEAD origin/master
if ($changes) {
    Write-Host "diff:" -ForegroundColor Yellow
    foreach ($line in $changes) {
        $parts = $line -split "`t"
        switch ($parts[0]) {
            "A" { Write-Host "  + $($parts[1])" -ForegroundColor Green }
            "D" { Write-Host "  - $($parts[1])" -ForegroundColor Red }
            "M" { Write-Host "  ~ $($parts[1])" -ForegroundColor Yellow }
        }
    }

    git reset --hard origin/master
    git clean -fd

    Write-Host "`nUpdated to latest version" -ForegroundColor Green
} else {
    Write-Host "Already up to date." -ForegroundColor Green
}

pause