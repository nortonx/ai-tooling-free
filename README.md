# ai-tooling-free

Curated, cross-platform AI coding **skills** and **agents** for Claude Code, GitHub Copilot CLI, Gemini CLI / Antigravity, and any Agent Skills standard adopter.

16 skills, 10 agents, a dependency-light setup script. No npm install, no postinstall magic, no settings rewriting.

## Requirements

- One or more supported tools: Claude Code, GitHub Copilot CLI, Gemini CLI / Antigravity, or other Agent Skills adopters.
- `git` (recommended)
- Keep the cloned repo where it is: skills are **symlinked**, not copied.

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
