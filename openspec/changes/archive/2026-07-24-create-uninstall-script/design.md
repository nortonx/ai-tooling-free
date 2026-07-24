## Context

The simplified setup scripts install skills globally via `npx skills` and Claude Code subagents via symlinks/copies. To make the project professional and clean, we need a corresponding uninstall process that completely reverts these changes and restores any pre-existing files that were backed up during installation.

## Goals / Non-Goals

**Goals:**
- Implement `uninstall.sh` (macOS/Linux/WSL2) to revert all changes.
- Implement `uninstall.ps1` and `uninstall.cmd` wrapper (Windows) to revert all changes.
- Modify `setup.sh` and `setup.ps1` to create `.bak` backup files for any existing files/directories they displace.
- Revert files during uninstall: remove links/copies, and rename `<path>.bak` back to `<path>` if it exists.
- Update `README.md` to document the new uninstall process.

**Non-Goals:**
- We are not writing a registry cleanup tool or deleting unrelated user settings.

## Decisions

1. **Decision**: Handle backups file-by-file during setup.
   - *Rationale*: Before installing a skill or agent link, the setup script checks if a file/symlink already exists at the destination. If it exists and does not point to our repo, we move it to `<name>.bak`. This is simple and doesn't require a state database.
2. **Decision**: Uninstall process runs in reverse.
   - *Rationale*: For each expected skill and agent destination path:
     - Remove the symlink, junction, or copied file.
     - Check if `<name>.bak` exists. If so, move/rename it back to `<name>`.
3. **Decision**: Target directories.
   - The paths targeted will match the setup script installations:
     - Skills: `~/.claude/skills/<name>`, `~/.agents/skills/<name>`, `~/.gemini/config/skills/<name>`.
     - Agents: `~/.claude/agents/<name>.md`.

## Risks / Trade-offs

- **Risk**: A backup file `.bak` could be overwritten if setup is run multiple times.
  - *Mitigation*: Only create `.bak` if the existing file does not already link to our repository. This prevents overwriting the original user backup during repeated setup runs.
