# ────────────────────────────────────────────────────────────────────────────
# ai-tooling-free uninstall (Windows PowerShell 5.1+ or pwsh 7+)
#
# Removes installed skills and Claude Code subagents, and restores pre-existing
# backups (.bak) if they exist.
$ErrorActionPreference = 'Stop'
$Repo = Split-Path -Parent $MyInvocation.MyCommand.Path

$script:ProcessedTargets = New-Object System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)

function Get-CanonicalTarget($Path) {
    $parent = Split-Path -Parent $Path
    $leaf = Split-Path -Leaf $Path
    if (Test-Path -LiteralPath $parent) {
        $realParent = (Resolve-Path -LiteralPath $parent).Path
        return (Join-Path $realParent $leaf)
    }
    return $Path
}

function Remove-And-Restore($Target) {
    $canon = Get-CanonicalTarget $Target
    if ($script:ProcessedTargets.Contains($canon)) {
        return
    }
    [void]$script:ProcessedTargets.Add($canon)

    $bak = "$Target.bak"
    $hasBak = Test-Path -LiteralPath $bak

    if (Test-Path -LiteralPath $Target) {
        $item = Get-Item -LiteralPath $Target -Force
        if ($item.LinkType -in @('Junction', 'SymbolicLink')) {
            if ($item.PSIsContainer) {
                # Safely delete the junction/symlink pointer without recursing into target files
                [System.IO.Directory]::Delete($Target)
            } else {
                [System.IO.File]::Delete($Target)
            }
            Write-Host "Removed link: $Target" -ForegroundColor Green
        } elseif ($hasBak) {
            Remove-Item -LiteralPath $Target -Force -Recurse
            Write-Host "Removed installed target: $Target" -ForegroundColor Green
        }
    }
    
    if ($hasBak) {
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
