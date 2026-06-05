# ai-tooling-free setup — Windows (PowerShell 5.1+ or pwsh 7+)
#
# Creates directory junctions for each skill into ~\.claude\skills,
# ~\.copilot\skills, ~\.gemini\skills and ~\.agents\skills (the Agent
# Skills open-standard dir — Codex CLI, Cursor, etc.), and copies each
# agent into ~\.claude\agents. Junctions need no admin rights or Developer Mode.
# Anything already at a destination is backed up to <name>.bak first.
# It never reads or writes settings.json, models, themes, or global
# instruction files. Re-running is safe (idempotent).

$ErrorActionPreference = 'Stop'
$Repo = Split-Path -Parent $MyInvocation.MyCommand.Path

function Info($msg) { Write-Host "[OK] $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Warn 'git not found - several skills (ship-it, pr-description, check-tests) need it.'
    Write-Host '  Install: winget install Git.Git'
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

# Skills -> the three CLIs plus the Agent Skills standard dir (~\.agents\skills)
foreach ($target in @("$env:USERPROFILE\.claude\skills",
                      "$env:USERPROFILE\.copilot\skills",
                      "$env:USERPROFILE\.gemini\skills",
                      "$env:USERPROFILE\.agents\skills")) {
    New-Item -ItemType Directory -Force -Path $target | Out-Null
    Get-ChildItem -Directory "$Repo\skills" | ForEach-Object {
        Link-Dir $_.FullName (Join-Path $target $_.Name)
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
