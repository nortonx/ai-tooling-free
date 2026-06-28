## Why

The current setup scripts (`setup.sh`, `setup.ps1`, `setup.cmd`) contain custom symlinking, backup, and environment-pruning logic. This is complex (~280 lines of shell and PowerShell), hard to maintain, and does not natively integrate with the official Agent Skills standard CLI (`npx skills`). Additionally, the setup does not install skills for Google Antigravity, which is a major agentic development platform, and the README incorrectly states that Antigravity/Gemini has no subagent support.

## What Changes

- Add Google Antigravity global customizations path (`~/.gemini/config/skills/`) to the setup targets.
- Integrate the official `skills` CLI (`npx skills`) under the hood to perform all skill installations globally and cross-platform.
- Simplify `setup.sh` and `setup.ps1` by replacing custom directory, link, backup, and healing logic with `npx skills` calls, reducing code footprint from ~280 lines to ~15 lines per script.
- Keep a lightweight custom loop to copy Claude Code subagents (`agents/*.md` to `~/.claude/agents/`) since `npx skills` does not manage subagents.
- Update the `README.md` to document Google Antigravity subagent capabilities and usage guidelines.

## Capabilities

### New Capabilities
- `setup`: Simplify global skill installation utilizing the open-standard `skills` CLI, link Claude Code subagents, and add Google Antigravity support.

### Modified Capabilities
- None

## Impact

- `setup.sh`, `setup.ps1`, and `setup.cmd` will be simplified.
- README.md will be updated.
- Node.js (`npx`) will be required to run the setup script (already required for Claude Code).
