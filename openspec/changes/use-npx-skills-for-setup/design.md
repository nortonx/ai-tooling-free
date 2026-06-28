## Context

The current setup scripts (`setup.sh`, `setup.ps1`, `setup.cmd`) manage skill installations using custom path resolution and filesystem operations (symlinks on Unix, directory junctions on Windows, and backup logic).
Google Antigravity is not explicitly supported by these custom scripts.
We want to transition to using the open-standard `skills` CLI (`npx skills`) for managing the global skill installations, which reduces custom script complexity and aligns the repository with modern AI-agent standards.

## Goals / Non-Goals

**Goals:**
- Target Google Antigravity global customization root (`~/.gemini/config/skills/`) for skill installations.
- Use `npx skills` to install and link skills across all available agents globally.
- Simplify `setup.sh` and `setup.ps1` to minimal boilerplate.
- Preserve the ability to install Claude Code subagents (`agents/*.md`).
- Update `README.md` to reflect these changes.

**Non-Goals:**
- We are not modifying any existing AI skills or their logic.
- We are not creating a custom plugin or MCP server for Antigravity.
- We are not writing a custom subagent manager (we will stick to a basic loop).

## Decisions

1. **Decision**: Use `npx -y skills add . -g -y` under the hood in the setup scripts.
   - *Rationale*: `npx skills` is the official CLI for Agent Skills. It is fully cross-platform and handles symlinking, permissions, and directory discovery.
   - *Alternatives*:
     - *Continue using custom scripts*: More code, more complex, harder to maintain, does not align with the standard.
     - *Ditch setup scripts completely and ask user to run `npx skills`*: Users would still have to manually link Claude Code agents (`agents/*.md`), which `npx skills` does not support. Hence, a hybrid script is best.
2. **Decision**: Copy subagents (`agents/*.md`) to `~/.claude/agents/` in both scripts using basic shell / PowerShell loop.
   - *Rationale*: `npx skills` only manages `SKILL.md` folders (skills), not subagent files. Keeping a tiny copy loop ensures subagents are still installed.
3. **Decision**: Add `~/.gemini/config/skills` explicitly as a target in the setup scripts or document it.
   - *Rationale*: Antigravity reads global customizations from `~/.gemini/config/`. Symlinking the skills folder here ensures Antigravity detects the skills.

## Risks / Trade-offs

- **Risk**: `npx` requires a Node.js runtime and internet access on the first execution (to download `skills` CLI).
  - *Mitigation*: Claude Code itself requires Node.js, so users installing this repo for Claude Code will already have Node/npm. For other agents (e.g. Antigravity), Node.js is widely standard, and we will clearly document it as a setup prerequisite.
