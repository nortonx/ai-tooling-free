## ADDED Requirements

### Requirement: Global Skill Installation
The setup script MUST install the repository's skills globally using the Agent Skills CLI (`npx skills`).

#### Scenario: Running setup on Unix
- **WHEN** user executes `./setup.sh`
- **THEN** system SHALL run `npx -y skills add <path> -g -y` to install all skills globally.

#### Scenario: Running setup on Windows
- **WHEN** user executes `setup.cmd` or `setup.ps1`
- **THEN** system SHALL run `npx -y skills add <path> -g -y` to install all skills globally.

### Requirement: Subagent Installation
The setup script MUST copy or symlink Claude Code subagents (`agents/*.md`) to the Claude Code agents directory (`~/.claude/agents/`).

#### Scenario: Copying subagents on Unix
- **WHEN** user runs `./setup.sh`
- **THEN** system SHALL create symlinks or copy `agents/*.md` to `~/.claude/agents/`.

#### Scenario: Copying subagents on Windows
- **WHEN** user runs `setup.ps1`
- **THEN** system SHALL copy `agents/*.md` to `$env:USERPROFILE\.claude\agents\`.
