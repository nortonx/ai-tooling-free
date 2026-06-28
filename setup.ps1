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

Write-Host "Installing skills globally using the Agent Skills CLI..." -ForegroundColor Green
npx -y skills add $Repo -g -y

Write-Host "Copying subagents to Claude Code..." -ForegroundColor Green
$agentsDir = "$env:USERPROFILE\.claude\agents"
New-Item -ItemType Directory -Force -Path $agentsDir | Out-Null
Get-ChildItem "$Repo\agents\*.md" | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination (Join-Path $agentsDir $_.Name) -Force
}

Write-Host "Setup complete!" -ForegroundColor Green
