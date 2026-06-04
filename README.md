# ai-tooling-free

Curated, cross-platform AI coding **skills** and **agents** for [Claude Code](https://claude.com/claude-code), [GitHub Copilot CLI](https://github.com/github/copilot-cli), and Gemini CLI / Antigravity — one source of truth, symlinked into all three.

16 skills, 10 agents, a dependency-light setup script. No npm install, no postinstall magic, no settings rewriting.

## Requirements

- One or more of: Claude Code, GitHub Copilot CLI, Gemini CLI / Antigravity
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

- Symlinks each skill into `~/.claude/skills`, `~/.copilot/skills`, and `~/.gemini/skills`
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

Skills work in Claude Code, Copilot CLI, and Gemini CLI (same `SKILL.md` format). Note: Copilot CLI doesn't substitute `$ARGUMENTS` — pass arguments inline in your prompt; each skill documents this.

## Agents (Claude Code only)

`communication-excellence-coach` · `debugger` · `doc-writer` · `mermaid-diagram-specialist` · `performance-optimizer` · `refactoring-expert` · `security-auditor` · `system-architect` · `test-automator` · `ui-ux-designer`

## Uninstall

Setup only creates links (plus `.bak` backups) — nothing of yours is deleted. To remove:

```bash
# remove the skill symlinks this repo created
for d in ~/.claude/skills ~/.copilot/skills ~/.gemini/skills; do
  find "$d" -maxdepth 1 -type l -lname "*/ai-tooling-free/*" -delete
done
# remove the agent links
find ~/.claude/agents -maxdepth 1 -type l -lname "*/ai-tooling-free/*" -delete
```

On Windows, delete the junctions under `%USERPROFILE%\.claude\skills` (and `.copilot`, `.gemini`) — `rmdir <name>` removes a junction without touching this repo. Restore any `.bak` files you want back.

## License

[MIT](LICENSE)
