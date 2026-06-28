# ────────────────────────────────────────────────────────────────────────────
# GENERATED FILE — do not edit the copy in ai-tooling-free\.
# Source of truth: ai-tooling\templates\ai-tooling-free.setup.ps1
# ai-tooling\setup.ps1 rewrites ai-tooling-free\setup.ps1 from this template on
# every run (when that sibling repo is present). Edit the template, then re-run.
# ────────────────────────────────────────────────────────────────────────────
# ai-tooling-free setup — Windows (PowerShell 5.1+ or pwsh 7+)
#
# Installs skills globally utilizing the Agent Skills CLI (npx skills)
# and copies Claude Code subagents into ~\.claude\agents\.
$ErrorActionPreference = 'Stop'
$Repo = Split-Path -Parent $MyInvocation.MyCommand.Path

# Backup helper function
function Backup-If-Exists($Target, $Source) {
    if (Test-Path -LiteralPath $Target) {
        $item = Get-Item -LiteralPath $Target
        # If it is a directory junction (link) pointing to our repo, do not backup
        if ($item.LinkType -and $item.Target -eq $Source) { return }
        
        # If it is a file and content hash matches, do not backup
        if (-not $item.PSIsContainer) {
            $same = (Get-FileHash -LiteralPath $Target).Hash -eq (Get-FileHash -LiteralPath $Source).Hash
            if ($same) { return }
        }
        
        Move-Item -LiteralPath $Target -Destination "$Target.bak" -Force
        Write-Host "Backed up existing $(Split-Path $Target -Leaf) to $(Split-Path $Target -Leaf).bak" -ForegroundColor Yellow
    }
}

Write-Host "Backing up pre-existing skills and agents..." -ForegroundColor Green
Get-ChildItem -Directory "$Repo\skills" | ForEach-Object {
    Backup-If-Exists (Join-Path "$env:USERPROFILE\.claude\skills" $_.Name) $_.FullName
    Backup-If-Exists (Join-Path "$env:USERPROFILE\.agents\skills" $_.Name) $_.FullName
}

Write-Host "Installing skills globally using the Agent Skills CLI..." -ForegroundColor Green
npx -y skills add $Repo -g -y

Write-Host "Copying subagents to Claude Code..." -ForegroundColor Green
$agentsDir = "$env:USERPROFILE\.claude\agents"
New-Item -ItemType Directory -Force -Path $agentsDir | Out-Null
Get-ChildItem "$Repo\agents\*.md" | ForEach-Object {
    $targetPath = Join-Path $agentsDir $_.Name
    Backup-If-Exists $targetPath $_.FullName
    Copy-Item -Path $_.FullName -Destination $targetPath -Force
}

Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "You can revert this by running the \`uninstall.cmd\` (or \`uninstall.ps1\`) script." -ForegroundColor Green
