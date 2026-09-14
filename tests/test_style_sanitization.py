#!/usr/bin/env python3
"""Automated tests for whole-catalog em dash eradication and style sanitization."""

from pathlib import Path
import re
import sys

REPO_ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = REPO_ROOT / "skills"

def test_all_18_skills_zero_em_dashes():
    """Verify that every SKILL.md in skills/ contains zero unicode em dashes."""
    skill_files = sorted(SKILLS_DIR.glob("*/SKILL.md"))
    assert len(skill_files) == 18, f"Expected 18 skills, found {len(skill_files)}"

    errors = []
    total_em_dashes = 0
    for skill_file in skill_files:
        content = skill_file.read_text(encoding="utf-8")
        em_count = content.count("\u2014")
        if em_count > 0:
            total_em_dashes += em_count
            errors.append(f"{skill_file.relative_to(REPO_ROOT)}: contains {em_count} em dash(es)")

    assert not errors, f"Found {total_em_dashes} em dash(es) across {len(errors)} skills:\n" + "\n".join(errors)

def test_all_18_skills_zero_prose_spaced_hyphens():
    """Verify that every SKILL.md in skills/ contains zero prose spaced hyphens."""
    skill_files = sorted(SKILLS_DIR.glob("*/SKILL.md"))
    assert len(skill_files) == 18, f"Expected 18 skills, found {len(skill_files)}"

    errors = []
    for skill_file in skill_files:
        content = skill_file.read_text(encoding="utf-8")
        for idx, line in enumerate(content.splitlines(), 1):
            # Skip mathematical formulas
            if "wilson_lower" in line:
                continue
            if re.search(r'[A-Za-z0-9\)\"]\s+-\s+[A-Za-z0-9\(\"]', line):
                errors.append(f"{skill_file.relative_to(REPO_ROOT)}:{idx}: {line.strip()}")

    assert not errors, f"Found {len(errors)} prose spaced hyphen(s):\n" + "\n".join(errors)

def main():
    test_functions = [
        test_all_18_skills_zero_em_dashes,
        test_all_18_skills_zero_prose_spaced_hyphens,
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
