## Why

Installing skills and subagents creates symlinks, directory junctions, and copies files in the user's global folders (`~/.claude/skills/`, `~/.agents/skills/`, `~/.claude/agents/`, etc.). Currently, uninstalling requires users to manually locate and delete these links from the command line, which is error-prone. Providing an automated uninstall script ensures a clean, reliable, and professional cleanup process that restores the user's home directories to their original state.

## What Changes

- Create a `uninstall.sh` script for Unix environments (macOS/Linux/WSL2) to automate the deletion of installed skills and subagent links.
- Create a `uninstall.ps1` script and `uninstall.cmd` wrapper for Windows environments to automate the cleanup of directory junctions and copied agent files.
- Update `setup.sh` and `setup.ps1` to create backup copies (e.g. `<name>.bak`) of any existing files they displace during setup, so that the uninstall scripts can restore them.
- Update the `README.md` to replace the manual uninstall CLI instructions with a simple reference to the new uninstall scripts.

## Capabilities

### New Capabilities
- `uninstall`: Revert all global skill and subagent setup changes, restoring any previous backups.

### Modified Capabilities
- None

## Impact

- New `uninstall.sh`, `uninstall.ps1`, and `uninstall.cmd` files.
- Modified `setup.sh`, `setup.ps1`, and `README.md`.
