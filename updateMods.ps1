$repoUrl = "https://github.com/0ce10tsgit/createModpack.git"
$modsPath = $PSScriptRoot

Write-Host "checking" -ForegroundColor Cyan

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
} else {
    Write-Host "up to date." -ForegroundColor Green
    pause
    exit
}

git reset --hard origin/master
git clean -fd

Write-Host "up to date" -ForegroundColor Green
pause