# ────────────────────────────────────────────────────────────────────────────
# ai-tooling-free uninstall — Windows (PowerShell 5.1+ or pwsh 7+)
#
# Removes installed skills and Claude Code subagents, and restores pre-existing
# backups (.bak) if they exist.
$ErrorActionPreference = 'Stop'
$Repo = Split-Path -Parent $MyInvocation.MyCommand.Path

function Remove-And-Restore($Target) {
    if (Test-Path -LiteralPath $Target) {
        $item = Get-Item -LiteralPath $Target
        if ($item.LinkType -eq 'Junction') {
            cmd /c rmdir "$Target" | Out-Null
        } else {
            Remove-Item -LiteralPath $Target -Force -Recurse
        }
        Write-Host "Removed: $Target" -ForegroundColor Green
    }
    
    $bak = "$Target.bak"
    if (Test-Path -LiteralPath $bak) {
        Move-Item -LiteralPath $bak -Destination $Target -Force
        Write-Host "Restored backup: $Target" -ForegroundColor Yellow
    }
}

Write-Host "Uninstalling skills and subagents..." -ForegroundColor Green

# Skills cleanup
Get-ChildItem -Directory "$Repo\skills" | ForEach-Object {
    Remove-And-Restore (Join-Path "$env:USERPROFILE\.claude\skills" $_.Name)
    Remove-And-Restore (Join-Path "$env:USERPROFILE\.agents\skills" $_.Name)
}

# Agents cleanup
Get-ChildItem "$Repo\agents\*.md" | ForEach-Object {
    Remove-And-Restore (Join-Path "$env:USERPROFILE\.claude\agents" $_.Name)
}

Write-Host "Uninstall complete!" -ForegroundColor Green
