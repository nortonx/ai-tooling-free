# ai-tooling-free setup — Windows (PowerShell 5.1+ or pwsh 7+)
#
# Creates directory junctions for each skill into ~\.claude\skills,
# ~\.copilot\skills and ~\.agents\skills (the Agent Skills open-standard dir —
# Codex CLI, Cursor, Gemini CLI, Antigravity, etc.), and copies each agent into
# ~\.claude\agents. Junctions need no admin rights or Developer Mode.
# Anything already at a destination is backed up to <name>.bak first.
# It never reads or writes settings.json, models, themes, or global
# instruction files. Re-running is safe (idempotent). Add -Yes to skip the
# confirmation prompt.

[CmdletBinding()]
param([switch]$Yes)

$ErrorActionPreference = 'Stop'
$Repo = Split-Path -Parent $MyInvocation.MyCommand.Path

function Info($msg) { Write-Host "[OK] $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Warn 'git not found - several skills (ship-it, pr-description, check-tests) need it.'
    Write-Host '  Install: winget install Git.Git'
}

# ── Safety gate ─────────────────────────────────────────────────────
# This script writes ONLY inside your home directory: it junctions skills and
# copies agents, backing up anything already there to <name>.bak. It needs no
# admin, and never writes settings.json, models, themes, or instruction files.
# Read the whole script before running. Skip the prompt with -Yes or ASSUME_YES=1.
if (-not ($Yes -or $env:ASSUME_YES -eq '1')) {
    Write-Host ''
    Write-Host 'This script modifies ONLY your home directory:' -ForegroundColor Yellow
    Write-Host '  - junctions each skill into ~\.claude\skills, ~\.copilot\skills, ~\.agents\skills' -ForegroundColor Yellow
    Write-Host '  - copies each agent into ~\.claude\agents' -ForegroundColor Yellow
    Write-Host '  - backs up anything already there to <name>.bak' -ForegroundColor Yellow
    Write-Host '  It needs NO admin and never writes settings.json, models, themes, or' -ForegroundColor Yellow
    Write-Host '  instruction files. Please READ THE FULL SCRIPT before continuing.' -ForegroundColor Yellow
    $ans = Read-Host '  Proceed? [y/N]'
    if ($ans -notmatch '^[Yy]') { Warn 'Aborted.'; exit 1 }
}

# Junction with .bak backup of anything already there
function Link-Dir($Src, $Dst) {
    $existing = Get-Item -LiteralPath $Dst -ErrorAction SilentlyContinue
    if ($existing -and $existing.LinkType -and $existing.Target -eq $Src) {
        Info "Already linked: $Dst"
        return
    }
    if ($existing) {
        Move-Item -LiteralPath $Dst -Destination "$Dst.bak"
        Warn "Existing $Dst moved to $Dst.bak"
    }
    cmd /c mklink /J "$Dst" "$Src" | Out-Null
    Info "Linked $Dst -> $Src"
}

# File copy with .bak backup (file symlinks need admin on Windows, so copy)
function Copy-File($Src, $Dst) {
    if (Test-Path -LiteralPath $Dst) {
        $same = (Get-FileHash -LiteralPath $Dst).Hash -eq (Get-FileHash -LiteralPath $Src).Hash
        if ($same) { Info "Already up to date: $Dst"; return }
        Move-Item -LiteralPath $Dst -Destination "$Dst.bak" -Force
        Warn "Existing $Dst moved to $Dst.bak"
    }
    Copy-Item -LiteralPath $Src -Destination $Dst
    Info "Copied $Dst"
}

# Skills -> Claude Code, Copilot CLI, plus the Agent Skills standard dir
# (~\.agents\skills). Gemini CLI and Antigravity also read ~\.agents\skills, so
# we do NOT also junction into ~\.gemini\skills — Gemini treats it as a same-tier
# alias and would warn that every skill "overrides" its duplicate.
foreach ($target in @("$env:USERPROFILE\.claude\skills",
                      "$env:USERPROFILE\.copilot\skills",
                      "$env:USERPROFILE\.agents\skills")) {
    New-Item -ItemType Directory -Force -Path $target | Out-Null
    Get-ChildItem -Directory "$Repo\skills" | ForEach-Object {
        Link-Dir $_.FullName (Join-Path $target $_.Name)
    }
}

# Self-healing: an older version junctioned skills into ~\.gemini\skills. Remove
# the junctions we created (those pointing into $Repo\skills), keep user-added
# ones, and drop the dir if it ends up empty. Gemini/Antigravity read
# ~\.agents\skills. (rmdir removes a junction without touching its target.)
$geminiSkills = "$env:USERPROFILE\.gemini\skills"
if (Test-Path $geminiSkills) {
    Get-ChildItem -LiteralPath $geminiSkills -Force -ErrorAction SilentlyContinue | ForEach-Object {
        if (($_.Attributes -band [IO.FileAttributes]::ReparsePoint) -and
            $_.Target -eq (Join-Path "$Repo\skills" $_.Name)) {
            cmd /c rmdir "$($_.FullName)" | Out-Null
            Warn "Unlinked stale Gemini skill: $($_.FullName)"
        }
    }
    if (-not (Get-ChildItem -LiteralPath $geminiSkills -Force -ErrorAction SilentlyContinue)) {
        Remove-Item -LiteralPath $geminiSkills -Force
        Warn "Removed empty $geminiSkills"
    }
}

# Agents -> Claude Code only (per-file, so your own agents are untouched)
$agentsDir = "$env:USERPROFILE\.claude\agents"
New-Item -ItemType Directory -Force -Path $agentsDir | Out-Null
Get-ChildItem "$Repo\agents\*.md" | ForEach-Object {
    Copy-File $_.FullName (Join-Path $agentsDir $_.Name)
}

Info 'Done. Restart your CLI sessions to pick up the skills.'
Write-Host 'Note: agents are copied (not linked) on Windows - re-run setup after pulling updates.'
