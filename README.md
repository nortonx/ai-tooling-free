# ai-tooling-free

Curated, cross-platform AI coding **skills** and **agents** for [Claude Code](https://claude.com/claude-code), [GitHub Copilot CLI](https://github.com/github/copilot-cli), Gemini CLI / Antigravity, and any [Agent Skills](https://agentskills.io) standard adopter (OpenAI Codex CLI, Cursor, Amp, OpenCode, …) — one source of truth, symlinked into all of them.

16 skills, 10 agents, a dependency-light setup script. No npm install, no postinstall magic, no settings rewriting.

## Requirements

- One or more of: Claude Code, GitHub Copilot CLI, Gemini CLI / Antigravity, or any [Agent Skills](https://agentskills.io) adopter (OpenAI Codex CLI, Cursor, …)
- `git` (recommended — several skills are git-centric)
- Keep the cloned repo where it is: skills are **symlinked**, not copied. If you move the clone, re-run setup.

## Install

### macOS / Linux / WSL2

```bash
git clone https://github.com/nortonx/ai-tooling-free
cd ai-tooling-free
./setup.sh
```

### Windows

```bat
git clone https://github.com/nortonx/ai-tooling-free
cd ai-tooling-free
setup.cmd
```

Windows uses directory junctions (`mklink /J`) — **no admin rights or Developer Mode needed**. `setup.cmd` works with both Windows PowerShell 5.1 and pwsh 7+.

## What setup does (and doesn't)

Does:

- Symlinks each skill into `~/.claude/skills` (Claude Code) and `~/.agents/skills` — the latter is the canonical user dir of the [Agent Skills open standard](https://agentskills.io), so one link target covers Copilot CLI, Codex CLI, Cursor, Gemini CLI / Antigravity, and every other adopter. (Skills are *not* also linked into `~/.copilot/skills` — Copilot reads `~/.agents/skills` too, and since it reads both roots without de-duplicating it would list every skill twice; nor into `~/.gemini/skills` — Gemini treats `~/.agents/skills` as a same-tier alias that takes precedence. Setup prunes any `~/.copilot/skills` and `~/.gemini/skills` links left by older installs.)
- Links each agent into `~/.claude/agents` (Claude Code only; copied on Windows)
- Backs up anything already at a destination to `<name>.bak` before linking
- Is idempotent — re-run it any time

Doesn't:

- Touch your `settings.json`, model, theme, permissions, or plugins
- Deploy any global `CLAUDE.md` / instruction files
- Delete anything (backups only)
- Require `jq`, Node, or anything beyond a shell

## Skills

| Skill | What it does |
|---|---|
| `fanout-review` | Multi-perspective code review: 6 parallel reviewers + deterministic merge gate, output ready to paste into a PR thread |
| `check-dx` | Audit your eslint / prettier / biome rules and rank keep / tune / drop via consensus across 5 independent evaluation passes |
| `framework-upgrade-guide` | Stepwise major-by-major upgrade guide for Angular / React / Vue projects, with lockstep version matrices and per-hop verification |
| `check-dry` | Detect DRY violations and recommend refactoring strategies |
| `check-tests` | Check test coverage for the changes on the current branch |
| `create-commit-message` | Ready-to-paste conventional commit message from your current changes |
| `create-unit-tests` | Write unit tests for branch changes following best practices |
| `generate-adr` | Scaffold an Architecture Decision Record (Nygard format) with auto-numbering and supersedes links |
| `generate-spec` | Scaffold a feature spec using a reusable 9-section template |
| `learn` | Explain a concept in depth — ELI5, technical, analogies, pitfalls |
| `optimize` | Find performance bottlenecks and recommend optimizations |
| `plan-or-execute` | Recommend plan mode vs direct execution for a task |
| `pr-description` | Generate a PR description from commits and diff |
| `ship-it` | Branch (if needed), commit, and push in one reviewed step |
| `smart-fix` | Route an issue description to the right flow: bug, performance, security, or feature |
| `update-claude-md` | Update a project's CLAUDE.md with conventions learned from recent changes |

Skills work in Claude Code, Copilot CLI, Gemini CLI, and Agent Skills adopters like Codex CLI and Cursor (same `SKILL.md` format).

### Cross-tool caveats

- **`$ARGUMENTS` only substitutes in Claude Code** — every other tool's skill body sees the literal text. Pass arguments inline in your prompt; each skill documents this in its `## Arguments` section.
- **Skill bodies use Claude Code tool names** (Read, Edit, Grep, Agent, …). Other tools map them to their own equivalents loosely — most skills work fine, but agent-dispatch steps are Claude-only.
- **Codex CLI**: list skills with `/skills` or `$`-mention; disable individual skills via `~/.codex/config.toml`. This repo does **not** create `~/.codex/AGENTS.md` or any global instructions.
- **Copilot and Cursor scan both `~/.claude/skills` and `~/.agents/skills` without de-duplicating**, so they list each skill **twice**. This is inherent, not a setup bug: Claude Code reads only `~/.claude/skills` and Codex reads only `~/.agents/skills`, so both roots must stay populated, and Copilot/Cursor read both. Removing `~/.copilot/skills` brings Copilot down from three entries to two; reaching exactly one would mean dropping Claude Code or waiting on Copilot to de-dup ([github/copilot-cli#2161](https://github.com/github/copilot-cli/issues/2161)). The duplicate links resolve to the same target, so it's cosmetic.
- **Skill discovery in Codex/Cursor hasn't been smoke-tested by this setup** — the links follow the documented Agent Skills locations; verify with `/skills` (Codex) or the Agent skill list (Cursor) after install.

## Agents (**Claude Code only**)

`communication-excellence-coach` · `debugger` · `doc-writer` · `mermaid-diagram-specialist` · `performance-optimizer` · `refactoring-expert` · `security-auditor` · `system-architect` · `test-automator` · `ui-ux-designer`

Agents are **subagents** — specialist personas Claude Code delegates to in their own context window. Unlike skills, they have no slash command, and only Claude Code supports them (Copilot CLI, Gemini, and Codex have no subagent mechanism, so setup doesn't link agents into them).

Two ways to use one:

- **Automatic** — Claude reads each agent's `description` and delegates when the task fits (several are marked *"Use PROACTIVELY"*).
- **Explicit** — name the agent in your prompt:

  ```
  > Use the debugger subagent to find why this test fails
  ```

Manage installed agents with the `/agents` command.

## Uninstall

The repository provides automated scripts that completely remove all installed skills and subagent links, and restore any pre-existing backups (`.bak`) that were displaced during setup.

### macOS / Linux / WSL2

Run the following command:

```bash
./uninstall.sh
```

### Windows

Run the following command:

```bat
uninstall.cmd
```

## License

[MIT](LICENSE)
