#!/usr/bin/env python3
"""Automated tests for instructional quality, persona consistency, and fragile command cleanup."""

from pathlib import Path
import re
import sys

REPO_ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = REPO_ROOT / "skills"

def test_takeaways_arguments_and_fallback():
    """Verify takeaways has unified arguments, Copilot note, and realistic transcript fallback."""
    takeaways_file = SKILLS_DIR / "takeaways" / "SKILL.md"
    content = takeaways_file.read_text(encoding="utf-8")

    # Should not have the disconnected individual argument bullet points
    assert "- `content`:" not in content, "takeaways still lists obsolete '- `content`:' argument"
    assert "- `video`:" not in content, "takeaways still lists obsolete '- `video`:' argument"

    # Should reference unified argument and Copilot note
    assert "<url | text>" in content, "takeaways missing '<url | text>' in Arguments section"
    assert "Copilot CLI note" in content, "takeaways missing Copilot CLI note"

    # Should have realistic fallback instruction for transcript
    assert "transcript" in content.lower(), "takeaways missing explicit transcript guidance"
    assert "output template" in content.lower() or "## output" in content.lower(), "takeaways missing output specification"

def test_learn_agent_persona_and_validation():
    """Verify learn is written as an operational agent directive with validation."""
    learn_file = SKILLS_DIR / "learn" / "SKILL.md"
    content = learn_file.read_text(encoding="utf-8")

    # Inverted first-person persona must be removed
    assert "# Help me understand" not in content, "learn still uses user-first-person '# Help me understand'"
    assert "Connect to concepts I already know" not in content, "learn still uses first-person 'concepts I already know'"

    # Must contain input validation
    assert "validate input" in content.lower() or "if `$arguments` is empty" in content.lower(), (
        "learn missing input validation step"
    )

    # Must contain structured pedagogical framework
    assert "eli5" in content.lower(), "learn missing ELI5 concept section"
    assert "pitfall" in content.lower(), "learn missing pitfalls section"
    assert "best practice" in content.lower(), "learn missing best practices section"

def test_optimize_scope_and_report_only():
    """Verify optimize resolves scope contradiction, enforces report-only, and includes Vue."""
    opt_file = SKILLS_DIR / "optimize" / "SKILL.md"
    content = opt_file.read_text(encoding="utf-8")

    # Must resolve contradiction: empty argument must prompt menu, not scan full codebase
    assert "full or explicit omission" not in content.lower(), (
        "optimize still contains contradictory 'full or explicit omission' text"
    )

    # Must enforce report only
    assert "report only" in content.lower(), "optimize missing explicit 'Report only' directive"

    # Must include Vue SFC / reactivity in Frontend analysis
    assert "vue" in content.lower(), "optimize frontend section missing Vue SFC support"

def test_check_tests_sanitized_foreign_context():
    """Verify check-tests does not reference foreign repository prior bugs."""
    check_tests = SKILLS_DIR / "check-tests" / "SKILL.md"
    content = check_tests.read_text(encoding="utf-8")

    assert "in this repo's prior bugs" not in content, (
        "check-tests still contains foreign inherited text 'in this repo\\'s prior bugs'"
    )

def test_batch4_skills_no_em_dashes():
    """Verify Batch 4 skill files contain no unicode em dashes or prose spaced hyphens."""
    target_skills = ["takeaways", "learn", "optimize", "check-tests"]
    errors = []
    for skill_name in target_skills:
        skill_file = SKILLS_DIR / skill_name / "SKILL.md"
        content = skill_file.read_text(encoding="utf-8")
        if "\u2014" in content:
            errors.append(f"{skill_file.relative_to(REPO_ROOT)} contains unicode em dash (\u2014)")
        for idx, line in enumerate(content.splitlines(), 1):
            if re.search(r'[A-Za-z0-9\)\"]\s+-\s+[A-Za-z0-9\(\"]', line):
                errors.append(f"{skill_file.relative_to(REPO_ROOT)}:{idx} contains spaced hyphen (' - ')")
    assert not errors, "\n".join(errors)

def main():
    test_functions = [
        test_takeaways_arguments_and_fallback,
        test_learn_agent_persona_and_validation,
        test_optimize_scope_and_report_only,
        test_check_tests_sanitized_foreign_context,
        test_batch4_skills_no_em_dashes,
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
