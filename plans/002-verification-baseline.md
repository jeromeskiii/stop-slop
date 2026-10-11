# Plan 002: Add a structural verification script and close the rule drift it catches

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: written against commit `8da1f03` **plus plan
> 001 already executed** (its rewrites of `references/examples.md:9, 21, 45`
> and its CHANGELOG entry are expected to be present). If plan 001 has not
> landed in this branch, STOP — this plan's self-compliance checks assume
> it. Also confirm the excerpts below match the live files.

## Status

- **Priority**: P1
- **Effort**: M
- **Risk**: LOW
- **Depends on**: plans/001-rule-compliant-examples.md
- **Category**: tests / dx
- **Planned at**: commit `8da1f03`, 2026-10-11

## Why this matters

The whole product of this repo is a set of rules that must stay mutually
consistent across four files. Nothing verifies that. Drift has already
happened: `SKILL.md:41` asks writers to check "Three consecutive sentences
match length?", but no rule for it exists anywhere in
`references/structures.md`, so an editor following the Quick Checks hits a
check with no backing rule and no fix guidance. Three rule-expansion commits
(`1fdf64d`, `444630f`, `8da1f03`) landed with nothing detecting this class of
problem. A small dependency-free bash script that pins the structural
invariants turns future drift into a failing check instead of a surprise.

## Current state

- `SKILL.md:41` — the orphaned quick check: `- Three consecutive sentences
  match length? Break one.` No "sentence length" rule exists in
  `references/structures.md` (its Rhythm Patterns table, lines 118-127, has
  three-item lists, punchy paragraph endings, em-dashes, staccato
  fragmentation, hedging-as-reassurance — but nothing about matching
  sentence lengths).
- `SKILL.md:1-7` — frontmatter has `name`, `description`, `metadata` but no
  `license` (body claims MIT at `SKILL.md:66-68`).
- `README.md:13-21` — the "Skill Structure" tree lists SKILL.md,
  references/, README.md, LICENSE — it omits `CHANGELOG.md`.
- Exemplar for the script's shape: the improve skill's verifier at
  `/Users/ohmskiii/improve/scripts/verify-skill.sh` — read it first. Its
  pattern: plain bash, one `ok:` line per check, non-zero exit on first
  failure class, final `verify-skill: OK` line. Match that shape; keep this
  repo's naming (`verify.sh`, final line `verify: OK`).

## Scope

**In scope**: new `scripts/verify.sh`; `references/structures.md` (one new
row closing the orphaned quick check); `SKILL.md` frontmatter (add `license:
MIT`); `README.md` (tree fix); `CHANGELOG.md` (one entry).
**Out of scope**: all rule *content* beyond the one new row; `references/
phrases.md` and `references/examples.md` content; adding any dependency or
test framework.

## Steps

### Step 1: close the orphaned quick check

In `references/structures.md`, add one row to the end of the Rhythm Patterns
table (lines 120-127):

```
| Three consecutive sentences of matching length | Break one; vary the lengths |
```

**Verify**: `grep -n "matching length" references/structures.md` → 1 match.

### Step 2: write `scripts/verify.sh`

Create `scripts/verify.sh` (executable, `#!/usr/bin/env bash`, `set -euo
pipefail`), run from the repo root, with one `ok:` line per check and
non-zero exit on failure. Checks, in order:

1. Frontmatter: first line of `SKILL.md` is `---`; `grep -q '^name:
   stop-slop' SKILL.md`; `grep -q '^description:' SKILL.md`; `grep -q
   '^license: MIT' SKILL.md`.
2. Reference links resolve: every `references/*.md` mentioned in `SKILL.md`
   exists (`for f in phrases structures examples; do test -f
   "references/$f.md"; done`).
3. Quick-check coverage: the "Three consecutive sentences" quick check in
   `SKILL.md` has a backing rule — `grep -q "matching length"
   references/structures.md`; the em-dash quick check has its backing rule —
   `grep -q "No em dashes at all" references/structures.md`; the Wh- opener
   check has its backing section — `grep -q "Sentence Starters to Avoid"
   references/structures.md`.
4. Self-compliance: `! grep -rn "—" SKILL.md references/` (no em dash
   anywhere in the skill's own prose); the "nobody" check applies to
   **After lines only** — Before lines are intentionally slop:
   `test "$(awk '/\*\*After:\*\*/{getline; print}' references/examples.md |
   grep -cE "\b[Nn]obody\b")" = 0`.
5. README tree mentions every top-level file: `grep -q "CHANGELOG.md"
   README.md`.

Model each check as `check "<label>" <command>` helper printing `  ok: <label>`
on success and failing the script otherwise, like the exemplar script does.

**Verify**: `chmod +x scripts/verify.sh && bash scripts/verify.sh` → exits 0
and ends with `verify: OK`.

### Step 3: prove the script catches violations (negative test)

Temporarily append a line containing an em dash to `references/phrases.md`,
run `bash scripts/verify.sh` → must exit non-zero. Then `git checkout --
references/phrases.md` (or revert the edit) and re-run → OK again.

**Verify**: both runs observed as described; final `git status --short` shows
no leftover edits to `references/phrases.md`.

### Step 4: README tree and CHANGELOG

- In `README.md`'s Skill Structure tree (lines 13-21), add the CHANGELOG and
  scripts entries so the tree matches reality:

  ```
  stop-slop/
  ├── SKILL.md              # Core instructions
  ├── references/
  │   ├── phrases.md        # Phrases to remove
  │   ├── structures.md     # Structural patterns to avoid
  │   └── examples.md       # Before/after transformations
  ├── scripts/
  │   └── verify.sh         # Structural verification
  ├── CHANGELOG.md
  ├── README.md
  └── LICENSE
  ```

- Add a `## 2026-10-11` CHANGELOG section (below plan 001's, or merged into
  it if it already exists for today): Added — `scripts/verify.sh`
  structural verification; Changed — added the matching-sentence-length rule
  row, README tree now complete, frontmatter `license` added.

**Verify**: `bash scripts/verify.sh` → OK (check 5 now passes); `grep -n
"CHANGELOG.md" README.md` → 1 match; `grep -n "^license: MIT" SKILL.md` → 1
match.

## Test plan

- The script itself is the test: its checks run on every invocation, and
  Step 3 is a manual negative test proving failure detection works.
- Regression: after Step 1, re-read `SKILL.md:31-46` — every quick check
  must now have a backing rule or section in `references/structures.md` or
  `references/phrases.md`. If you find another orphan while checking, report
  it; do not silently add more rules (out of scope).

## Done criteria

Machine-checkable. ALL must hold:

- [ ] `bash scripts/verify.sh` exits 0 and prints `verify: OK`
- [ ] `test -x scripts/verify.sh` succeeds (executable bit set)
- [ ] `grep -n "matching length" references/structures.md` returns 1 match
- [ ] `grep -n "^license: MIT" SKILL.md` returns 1 match
- [ ] `grep -n "CHANGELOG.md" README.md` returns 1 match
- [ ] The Step 3 negative test was observed failing (em dash seeded → non-zero exit) and the seeded edit reverted
- [ ] No files outside the Scope list modified (`git status --short`)
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- Plan 001's example rewrites are absent from this branch (dependency
  unmet — the self-compliance checks would fail for the wrong reason).
- The exemplar script `/Users/ohmskiii/improve/scripts/verify-skill.sh` does
  not exist or cannot be read (pick its shape from this plan's Step 2
  description alone, note the deviation in your report).
- More than one orphaned quick check surfaces (report the list; adding
  multiple rules exceeds this plan's scope).
- Any check you write cannot be expressed with grep/test (e.g. you want real
  frontmatter parsing) — use grep anchors as specified rather than adding
  dependencies like `yq`.

## Maintenance notes

- Every future rule or quick check added to `SKILL.md`/`references/` must
  come with a matching check (or an explicit decision not to verify it) in
  `scripts/verify.sh` — the script is the drift guard, not a one-time tool.
- Reviewer should run the negative test themselves once before approving.
- Deliberately deferred: a fixture corpus of flagged passages (direction
  finding); frontmatter validation with a real parser.