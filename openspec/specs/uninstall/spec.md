# uninstall Specification

## Purpose
Reverting an installation: removing the skills and Claude Code subagents that setup installed, and restoring any pre-existing files setup backed up.

## Requirements
### Requirement: Uninstall Script Execution
The system SHALL provide an automated script to remove all installed skills and subagent links.

#### Scenario: Running uninstall on Unix
- **WHEN** user executes `./uninstall.sh`
- **THEN** system SHALL delete all global skill links and Claude Code subagent symlinks.

#### Scenario: Running uninstall on Windows
- **WHEN** user executes `uninstall.cmd` or `uninstall.ps1`
- **THEN** system SHALL delete all global skill junctions and Claude Code subagent copies.

### Requirement: Restore Backups
The uninstall script SHALL restore any pre-existing files or folders that were backed up during installation.

#### Scenario: Restoring a backed-up agent configuration
- **WHEN** setup renames an existing `debugger.md` to `debugger.md.bak`
- **THEN** system SHALL rename `debugger.md.bak` back to `debugger.md` when uninstall is run.

