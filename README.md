# ai-tooling-free

Curated, cross-platform AI coding **skills** and **agents** for Claude Code, GitHub Copilot CLI, Gemini CLI / Antigravity, and any Agent Skills standard adopter.

18 skills, 10 agents, a dependency-light setup script. No npm install, no postinstall magic, no settings rewriting.

## Requirements

- One or more supported tools: Claude Code, GitHub Copilot CLI, Gemini CLI / Antigravity, or other Agent Skills adopters.
- `git` (recommended)
- Keep the cloned repo where it is: skills are **symlinked**, not copied.

## Skills Catalog

| Skill | Command | Arguments | Description |
|---|---|---|---|
| `check-dry` | `/check-dry` | `[branch \| <path>]` | Detect DRY violations and recommend refactoring strategies. |
| `check-dx` | `/check-dx` | `<eslint \| prettier \| biome>` | Audit enabled eslint, prettier, or biome rules and rank keep, tune, or drop via Wilson consensus across 5 lenses. |
| `check-tests` | `/check-tests` | `[<file-or-module>]` | Check test coverage and missing test cases for changes on the current branch. |
| `create-commit-message` | `/create-commit-message` | None | Produce a single ready-to-paste conventional commit message from current git changes. |
| `create-unit-tests` | `/create-unit-tests` | `[<file-path \| directory \| module>]` | Write unit tests for branch changes or scoped target following best practices. |
| `fanout-review` | `/fanout-review` | None | Multi-perspective code review with breaking-change detection, deterministic merge gate, and questions for the dev. |
| `fix-security-audit` | `/fix-security-audit` | `[<path-to-project>]` | Audit dependencies and fix vulnerabilities safely, least-invasive first, with automatic rollback backups. |
| `framework-upgrade-guide` | `/framework-upgrade-guide` | `[<path-to-repo-or-package.json>]` | Stepwise major-by-major upgrade guide for TypeScript/Node projects (Angular, React, Vue). |
| `generate-adr` | `/generate-adr` | `<decision title>` | Scaffold an Architecture Decision Record (Nygard format) in `docs/adr/` with auto-numbering and lifecycle tracking. |
| `generate-spec` | `/generate-spec` | `<feature name>` | Scaffold a feature spec in `./specs/` using a reusable 9-section template. |
| `learn` | `/learn` | `<concept>` | Learn and understand a concept in depth across multiple progressive depths. |
| `optimize` | `/optimize` | `[branch \| backend \| frontend \| <path>]` | Analyze code for performance bottlenecks and recommend optimizations. Supports Vue SFCs. |
| `plan-or-execute` | `/plan-or-execute` | `<task description>` | Decide whether to enter plan mode or execute directly for a given task. |
| `pr-description` | `/pr-description` | `[<base-branch>]` | Generate pull request description from commits, diff, and inferred test steps. |
| `ship-it` | `/ship-it` | `[<branch-name-or-card>]` | Branch (if needed), commit, and push current changes to remote in one step. |
| `smart-fix` | `/smart-fix` | `<issue description>` | Intelligently classify, diagnose, and route bug, perf, security, or feature requests. |
| `takeaways` | `/takeaways` | `<url \| text>` | Extract conclusions and key takeaways from video transcripts, articles, or posts with a direct final verdict. |
| `update-claude-md` | `/update-claude-md` | `[<path-to-CLAUDE.md>]` | Update the project CLAUDE.md with conventions and patterns discovered in recent changes. |

## Subagents (Claude Code)

| Agent | Invocation | Role / Focus |
|---|---|---|
| `communication-excellence-coach` | `@communication-excellence-coach` | Review communication drafts, email refinement, and difficult conversation prep. |
| `debugger` | `@debugger` | Deep debugging specialist for complex runtime errors and test failures. |
| `doc-writer` | `@doc-writer` | Documentation expert creating developer and architecture docs. |
| `mermaid-diagram-specialist` | `@mermaid-diagram-specialist` | Specialist for creating flowcharts, sequence diagrams, and architecture maps. |
| `performance-optimizer` | `@performance-optimizer` | Performance engineering expert eliminating algorithmic and memory bottlenecks. |
| `refactoring-expert` | `@refactoring-expert` | Refactoring specialist improving code quality without changing behavior. |
| `security-auditor` | `@security-auditor` | Security reviewer auditing against OWASP Top 10 and vulnerability patterns. |
| `system-architect` | `@system-architect` | System design expert for scalable architecture and modular boundaries. |
| `test-automator` | `@test-automator` | Testing specialist ensuring thorough critical path test coverage. |
| `ui-ux-designer` | `@ui-ux-designer` | UI/UX critic and advisor providing research-backed interface feedback. |

## Install

You can install all skills globally without cloning the repository by using the Agent Skills CLI:

```bash
npx skills add nortonx/ai-tooling-free -g
```

*(Alternatively, to install both skills and Claude Code subagents, clone this repository and run `./setup.sh` on macOS/Linux or `setup.cmd` on Windows).*

## Uninstall

The repository provides automated scripts to completely remove all installed skills and restore any backups.

- **macOS / Linux / WSL2**: Run `./uninstall.sh`
- **Windows**: Run `uninstall.cmd`

## License

[MIT](LICENSE)
