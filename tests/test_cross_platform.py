#!/usr/bin/env python3
"""Automated tests for cross-platform portability and runtime interoperability."""

from pathlib import Path
import re
import sys

REPO_ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = REPO_ROOT / "skills"

def test_no_posix_redirections():
    """Verify zero occurrences of 2>/dev/null across all skill files."""
    errors = []
    for skill_file in sorted(SKILLS_DIR.glob("*/SKILL.md")):
        content = skill_file.read_text(encoding="utf-8")
        if "2>/dev/null" in content:
            errors.append(f"{skill_file.relative_to(REPO_ROOT)} contains '2>/dev/null'")
    assert not errors, "\n".join(errors)

def test_check_dx_rules_typo():
    """Verify check-dx references /check-dx rather than /check-dx-rules."""
    check_dx = SKILLS_DIR / "check-dx" / "SKILL.md"
    content = check_dx.read_text(encoding="utf-8")
    assert "/check-dx-rules" not in content, (
        f"{check_dx.relative_to(REPO_ROOT)} still references '/check-dx-rules'"
    )

def test_check_dx_multi_runtime():
    """Verify check-dx documents runtime guidance (Agent, invoke_subagent, and sequential fallback)."""
    check_dx = SKILLS_DIR / "check-dx" / "SKILL.md"
    content = check_dx.read_text(encoding="utf-8")
    assert "invoke_subagent" in content, (
        f"{check_dx.relative_to(REPO_ROOT)} missing 'invoke_subagent' guidance"
    )
    assert "sequential" in content.lower(), (
        f"{check_dx.relative_to(REPO_ROOT)} missing sequential fallback guidance"
    )

def test_generate_adr_directory_creation():
    """Verify generate-adr uses tool-agnostic directory creation instead of mkdir -p."""
    adr_file = SKILLS_DIR / "generate-adr" / "SKILL.md"
    content = adr_file.read_text(encoding="utf-8")
    assert "mkdir -p" not in content, (
        f"{adr_file.relative_to(REPO_ROOT)} contains hardcoded 'mkdir -p'"
    )

def test_generate_spec_directory_creation():
    """Verify generate-spec uses tool-agnostic directory creation instead of mkdir -p."""
    spec_file = SKILLS_DIR / "generate-spec" / "SKILL.md"
    content = spec_file.read_text(encoding="utf-8")
    assert "mkdir -p" not in content, (
        f"{spec_file.relative_to(REPO_ROOT)} contains hardcoded 'mkdir -p'"
    )

def test_fanout_review_quotes():
    """Verify fanout-review uses double quotes for git log format."""
    fanout = SKILLS_DIR / "fanout-review" / "SKILL.md"
    content = fanout.read_text(encoding="utf-8")
    assert "pretty=format:'%h %s'" not in content, (
        f"{fanout.relative_to(REPO_ROOT)} uses single quotes in git log format"
    )
    assert 'pretty=format:"%h %s"' in content, (
        f'{fanout.relative_to(REPO_ROOT)} missing double quotes git log format'
    )

def test_fanout_review_multi_runtime():
    """Verify fanout-review documents runtime guidance (Agent, invoke_subagent, and sequential fallback)."""
    fanout = SKILLS_DIR / "fanout-review" / "SKILL.md"
    content = fanout.read_text(encoding="utf-8")
    assert "invoke_subagent" in content, (
        f"{fanout.relative_to(REPO_ROOT)} missing 'invoke_subagent' guidance"
    )
    assert "sequential" in content.lower(), (
        f"{fanout.relative_to(REPO_ROOT)} missing sequential fallback guidance"
    )

def test_create_unit_tests_decoupled_role():
    """Verify create-unit-tests generalizes @test-automator."""
    unit_tests = SKILLS_DIR / "create-unit-tests" / "SKILL.md"
    content = unit_tests.read_text(encoding="utf-8")
    assert "@test-automator" not in content, (
        f"{unit_tests.relative_to(REPO_ROOT)} contains hardcoded '@test-automator'"
    )

def test_check_dry_decoupled_feature_dev():
    """Verify check-dry decouples /feature-dev."""
    check_dry = SKILLS_DIR / "check-dry" / "SKILL.md"
    content = check_dry.read_text(encoding="utf-8")
    assert "/feature-dev" not in content, (
        f"{check_dry.relative_to(REPO_ROOT)} contains '/feature-dev'"
    )

def test_smart_fix_decoupled_namespaces():
    """Verify smart-fix decouples superpowers:* and feature-dev:* namespaces."""
    smart_fix = SKILLS_DIR / "smart-fix" / "SKILL.md"
    content = smart_fix.read_text(encoding="utf-8")
    assert "superpowers:" not in content, (
        f"{smart_fix.relative_to(REPO_ROOT)} contains 'superpowers:'"
    )
    assert "feature-dev:" not in content, (
        f"{smart_fix.relative_to(REPO_ROOT)} contains 'feature-dev:'"
    )

def test_target_skills_no_em_dashes():
    """Verify target skill files contain no em dashes."""
    target_skills = [
        "check-dx",
        "generate-adr",
        "generate-spec",
        "fanout-review",
        "create-unit-tests",
        "check-dry",
        "smart-fix",
    ]
    errors = []
    for skill_name in target_skills:
        skill_file = SKILLS_DIR / skill_name / "SKILL.md"
        content = skill_file.read_text(encoding="utf-8")
        if "\u2014" in content:
            errors.append(f"{skill_file.relative_to(REPO_ROOT)} contains unicode em dash (\u2014)")
        for idx, line in enumerate(content.splitlines(), 1):
            if "wilson_lower" in line:
                continue
            if re.search(r'[A-Za-z0-9\)\"]\s+-\s+[A-Za-z0-9\(\"]', line):
                errors.append(f"{skill_file.relative_to(REPO_ROOT)}:{idx} contains spaced hyphen (' - ')")
    assert not errors, "\n".join(errors)

def main():
    test_functions = [
        test_no_posix_redirections,
        test_check_dx_rules_typo,
        test_check_dx_multi_runtime,
        test_generate_adr_directory_creation,
        test_generate_spec_directory_creation,
        test_fanout_review_quotes,
        test_fanout_review_multi_runtime,
        test_create_unit_tests_decoupled_role,
        test_check_dry_decoupled_feature_dev,
        test_smart_fix_decoupled_namespaces,
        test_target_skills_no_em_dashes,
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
