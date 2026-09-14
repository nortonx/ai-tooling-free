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

def test_readme_counts():
    """Verify README accurately states 18 skills and 10 agents."""
    content = README_FILE.read_text(encoding="utf-8")
    assert "18 skills, 10 agents" in content, "README does not state '18 skills, 10 agents'"
    assert "16 skills" not in content, "README still contains obsolete '16 skills' count"

def test_readme_lists_all_skills():
    """Verify README includes all 18 skills in the catalog table."""
    content = README_FILE.read_text(encoding="utf-8")
    skill_names = sorted(p.name for p in SKILLS_DIR.glob("*/") if p.is_dir())
    assert len(skill_names) == 18, f"Expected 18 skills on disk, found {len(skill_names)}"

    missing = []
    for name in skill_names:
        if f"`{name}`" not in content and f"/{name}" not in content:
            missing.append(name)
    assert not missing, f"README is missing these skills from its catalog table:\n" + "\n".join(missing)

def test_readme_lists_all_agents():
    """Verify README includes all 10 agents in the catalog table."""
    content = README_FILE.read_text(encoding="utf-8")
    agent_names = sorted(p.stem for p in AGENTS_DIR.glob("*.md"))
    assert len(agent_names) == 10, f"Expected 10 agents on disk, found {len(agent_names)}"

    missing = []
    for name in agent_names:
        if f"`{name}`" not in content and f"@{name}" not in content:
            missing.append(name)
    assert not missing, f"README is missing these agents from its catalog table:\n" + "\n".join(missing)

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
