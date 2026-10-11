#!/usr/bin/env bash
# Structural checks for the stop-slop skill package.
# Run from anywhere: ./scripts/verify.sh (it cds to the repo root itself)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail() {
  echo "verify: FAIL — $*" >&2
  exit 1
}

ok() {
  echo "  ok: $*"
}

echo "verify: checking $ROOT"

# 1. SKILL.md frontmatter
if [[ "$(head -n 1 SKILL.md)" != "---" ]]; then
  fail "SKILL.md does not start with frontmatter delimiter '---'"
fi
grep -q '^name: stop-slop' SKILL.md || fail "SKILL.md frontmatter missing 'name: stop-slop'"
grep -q '^description:' SKILL.md || fail "SKILL.md frontmatter missing 'description:'"
grep -q '^license: MIT' SKILL.md || fail "SKILL.md frontmatter missing 'license: MIT'"
ok "SKILL.md frontmatter (name, description, license: MIT)"

# 2. Reference links from SKILL.md resolve
for f in phrases structures examples; do
  test -f "references/$f.md" || fail "SKILL.md references missing file: references/$f.md"
done
ok "reference links resolve (phrases, structures, examples)"

# 3. Quick-check coverage: every quick check has a backing rule or section
grep -q "matching length" references/structures.md \
  || fail "quick check 'Three consecutive sentences match length' has no backing rule in references/structures.md"
grep -q "No em dashes at all" references/structures.md \
  || fail "quick check 'Em-dash anywhere' has no backing rule in references/structures.md"
grep -q "Sentence Starters to Avoid" references/structures.md \
  || fail "quick check 'Sentence starts with a Wh- word' has no backing section in references/structures.md"
ok "quick-check coverage (matching length, em dashes, Wh- openers)"

# 4. Self-compliance: the skill's own prose follows its own rules
if grep -rn "—" SKILL.md references/; then
  fail "em dash found in the skill's own prose (SKILL.md or references/)"
fi
ok "no em dashes in SKILL.md or references/"

nobody_count="$(awk '/\*\*After:\*\*/{getline; print}' references/examples.md | grep -cE "\b[Nn]obody\b" || true)"
if [[ "$nobody_count" != 0 ]]; then
  fail "found $nobody_count 'nobody' occurrence(s) in After lines of references/examples.md (Before lines are intentionally slop)"
fi
ok "no 'nobody' in After lines of references/examples.md"

# 5. README tree mentions every top-level file
grep -q "CHANGELOG.md" README.md \
  || fail "README.md Skill Structure tree does not mention CHANGELOG.md"
ok "README.md tree mentions CHANGELOG.md"

echo "verify: OK"
exit 0
