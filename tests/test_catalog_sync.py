#!/usr/bin/env python3
"""Automated tests for catalog synchronization, README accuracy, and installer governance."""

from pathlib import Path
import re
import sys

REPO_ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = REPO_ROOT / "skills"
AGENTS_DIR = REPO_ROOT / "agents"
README_FILE = REPO_ROOT / "README.md"
SETUP_SH = REPO_ROOT / "setup.sh"
SETUP_PS1 = REPO_ROOT / "setup.ps1"

def disk_skills():
    return {p.parent.name for p in SKILLS_DIR.glob("*/SKILL.md")}

def disk_agents():
    return {p.stem for p in AGENTS_DIR.glob("*.md")}

def table_rows(header):
    """Return {name: [cells]} for the table rows under a README '## <header>' section."""
    section = README_FILE.read_text(encoding="utf-8").split(f"## {header}\n", 1)[1].split("\n## ", 1)[0]
    rows = {}
    for line in section.splitlines():
        if line.startswith("| `"):
            cells = [c.strip() for c in re.split(r"(?<!\\)\|", line)[1:-1]]
            rows[cells[0].strip("`")] = cells
    return rows

def argument_hint(skill):
    content = (SKILLS_DIR / skill / "SKILL.md").read_text(encoding="utf-8")
    match = re.search(r'^argument-hint:\s*"?(.*?)"?\s*$', content.split("\n---", 1)[0], re.MULTILINE)
    return match.group(1) if match else None

def test_readme_counts():
    """Verify the README count line matches the skills and agents on disk."""
    content = README_FILE.read_text(encoding="utf-8")
    expected = f"{len(disk_skills())} skills, {len(disk_agents())} agents"
    assert expected in content, f"README does not state '{expected}'"

def test_readme_lists_all_skills():
    """Verify the Skills Catalog table lists exactly the skills on disk."""
    listed = set(table_rows("Skills Catalog"))
    missing = disk_skills() - listed
    stale = listed - disk_skills()
    assert not missing, "README catalog is missing skills:\n" + "\n".join(sorted(missing))
    assert not stale, "README catalog lists skills not in skills/:\n" + "\n".join(sorted(stale))

def test_readme_skill_arguments():
    """Verify each catalog Arguments cell matches the skill's argument-hint."""
    errors = []
    for name, cells in table_rows("Skills Catalog").items():
        hint = argument_hint(name) if name in disk_skills() else None
        expected = f"`{hint.replace('|', chr(92) + '|')}`" if hint else "None"
        if cells[2] != expected:
            errors.append(f"{name}: README has {cells[2]}, expected {expected}")
    assert not errors, "README Arguments column drifted:\n" + "\n".join(errors)

def test_readme_lists_all_agents():
    """Verify the Subagents table lists exactly the agents on disk."""
    listed = set(table_rows("Subagents (Claude Code)"))
    missing = disk_agents() - listed
    stale = listed - disk_agents()
    assert not missing, "README is missing agents:\n" + "\n".join(sorted(missing))
    assert not stale, "README lists agents not in agents/:\n" + "\n".join(sorted(stale))

def test_readme_no_em_dashes():
    """Verify README contains zero em dashes or prose spaced hyphens."""
    content = README_FILE.read_text(encoding="utf-8")
    assert "\u2014" not in content, "README.md contains unicode em dash (\u2014)"
    for idx, line in enumerate(content.splitlines(), 1):
        if re.search(r'[A-Za-z0-9\)\"]\s+-\s+[A-Za-z0-9\(\"]', line):
            assert False, f"README.md:{idx} contains spaced hyphen (' - '): {line}"

def test_setup_scripts_clean_headers():
    """Verify setup scripts have removed zombie template headers and em dashes."""
    sh_content = SETUP_SH.read_text(encoding="utf-8")
    ps_content = SETUP_PS1.read_text(encoding="utf-8")

    assert "ai-tooling/templates" not in sh_content, "setup.sh contains zombie template header"
    assert "ai-tooling/templates" not in ps_content and "ai-tooling\\templates" not in ps_content, (
        "setup.ps1 contains zombie template header"
    )

    assert "\u2014" not in sh_content, "setup.sh contains unicode em dash (\u2014)"
    assert "\u2014" not in ps_content, "setup.ps1 contains unicode em dash (\u2014)"

def main():
    test_functions = [
        test_readme_counts,
        test_readme_lists_all_skills,
        test_readme_skill_arguments,
        test_readme_lists_all_agents,
        test_readme_no_em_dashes,
        test_setup_scripts_clean_headers,
    ]
    passed = 0
    failed = 0
    for fn in test_functions:
        name = fn.__name__
        try:
            fn()
            print(f"PASS: {name}")
            passed += 1
        except AssertionError as e:
            print(f"FAIL: {name} -> {e}")
            failed += 1
        except Exception as e:
            print(f"ERROR: {name} -> {e}")
            failed += 1

    print(f"\nResult: {passed} passed, {failed} failed")
    if failed > 0:
        sys.exit(1)

if __name__ == "__main__":
    main()
