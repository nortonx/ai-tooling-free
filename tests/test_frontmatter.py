#!/usr/bin/env python3
"""
Automated test suite validating Agent Skills YAML frontmatter compliance.
Verifies all 18 skills in skills/*/SKILL.md.
"""

import os
import re
import sys
import yaml

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SKILLS_DIR = os.path.join(REPO_ROOT, "skills")

EM_DASH_PATTERN = re.compile(r"[\u2014\u2013]|\s-\s")


def extract_frontmatter(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return None, "Missing or invalid '---' frontmatter delimiters"

    raw_yaml = match.group(1)
    try:
        data = yaml.safe_load(raw_yaml)
        return data, None
    except Exception as e:
        return None, f"YAML parse error: {e}"


def main():
    skill_dirs = sorted(
        [
            d
            for d in os.listdir(SKILLS_DIR)
            if os.path.isdir(os.path.join(SKILLS_DIR, d))
        ]
    )

    total = len(skill_dirs)
    failed = 0
    failures = []

    print(f"Validating YAML frontmatter for {total} skills...")

    for skill_name in skill_dirs:
        skill_path = os.path.join(SKILLS_DIR, skill_name, "SKILL.md")
        if not os.path.isfile(skill_path):
            failures.append(f"{skill_name}: SKILL.md not found")
            failed += 1
            continue

        data, err = extract_frontmatter(skill_path)
        if err:
            failures.append(f"{skill_name}: {err}")
            failed += 1
            continue

        # Check 1: name field
        if "name" not in data:
            failures.append(f"{skill_name}: Missing 'name' in frontmatter")
            failed += 1
            continue
        if data["name"] != skill_name:
            failures.append(
                f"{skill_name}: Name '{data['name']}' does not match directory '{skill_name}'"
            )
            failed += 1
            continue

        # Check 2: description field
        if "description" not in data:
            failures.append(f"{skill_name}: Missing 'description' in frontmatter")
            failed += 1
            continue
        desc = str(data["description"])
        if len(desc.strip()) == 0:
            failures.append(f"{skill_name}: Empty 'description'")
            failed += 1
            continue

        # Check 3: character length limit (<300 characters to prevent prompt bloat)
        if len(desc) > 300:
            failures.append(
                f"{skill_name}: Description length ({len(desc)} chars) exceeds 300 chars limit"
            )
            failed += 1
            continue

        # Check 4: no em dashes or spaced hyphens in description
        if EM_DASH_PATTERN.search(desc):
            failures.append(
                f"{skill_name}: Description contains em dash or spaced hyphen"
            )
            failed += 1
            continue

        # Check 5: argument-hint scalar typing (must be string, not list/array)
        if "argument-hint" in data:
            arg_hint = data["argument-hint"]
            if not isinstance(arg_hint, str):
                failures.append(
                    f"{skill_name}: 'argument-hint' is type '{type(arg_hint).__name__}', expected string scalar"
                )
                failed += 1
                continue

        # Check 6: takeaways must provide argument-hint
        if skill_name == "takeaways" and "argument-hint" not in data:
            failures.append(
                f"{skill_name}: Missing mandatory 'argument-hint' for argument discovery"
            )
            failed += 1
            continue

    print("-" * 50)
    if failed == 0:
        print(f"ALL {total} SKILLS PASSED FRONTMATTER VALIDATION!")
        return 0
    else:
        print(f"FAILED: {failed} out of {total} skills have frontmatter defects:\n")
        for f in failures:
            print(f"  [X] {f}")
        print("-" * 50)
        return 1


if __name__ == "__main__":
    sys.exit(main())
