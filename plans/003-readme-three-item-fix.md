# Plan 003: Rewrite README intro to stop self-violating the three-item rule

> Drift check: `git diff --stat 1f626d3..HEAD -- README.md`
> Repo-level gate (mandatory): `bash scripts/verify.sh` exits 0.

## Status

- Priority: P2
- Effort: XS
- Risk: LOW
- Depends on: none
- Category: correctness
- Planned at: commit `1f626d3`, 2026-10-12

## Why this matters

The README is the first thing a reader sees. The current intro paragraph at line 9 contains a three-item list ("Predictable phrases, structures, rhythms.") that the skill's own `references/structures.md:122` ("Three-item lists | Use two items or one") bans. The em-dash self-check at `scripts/verify.sh:44-48` only scans `SKILL.md` and `references/`, so it does not see README. Net effect: the introduction teaches the very pattern the skill exists to remove.

## Current state

All paths relative to `/Users/ohmskiii/Desktop/stop-slop`.

- `README.md:9` (offending line, current text):

  ```
  AI writing has patterns. Predictable phrases, structures, rhythms. This skill teaches Claude (or any LLM) to catch and remove them.
  ```

- Rule the line violates: `references/structures.md:122`:

  ```
  | Three-item lists | Use two items or one |
  ```

- Existing verifier scope: `scripts/verify.sh:45` greps only `SKILL.md` and `references/`. README is out of em-dash scope and has no three-item check at all.

## Scope

**In scope**: `README.md` (one sentence in the intro paragraph). Optionally `scripts/verify.sh` (extend the em-dash scan to cover README; one-line diff that reduces future regression risk in the same PR).

**Out of scope**: SKILL.md, references/, CHANGELOG.md, plans/, examples/, or any other rule-text file.

## Git workflow

- Branch: `advisor/003-readme-three-item-fix`
- Commit: `docs: rewrite README intro to comply with the three-item rule`
- Do NOT push or open a PR unless instructed.

## Steps

### Step 1: rewrite README.md line 9

Replace:

```
AI writing has patterns. Predictable phrases, structures, rhythms. This skill teaches Claude (or any LLM) to catch and remove them.
```

With:

```
AI writing has patterns. Predictable words and shapes repeat. This skill teaches Claude (or any LLM) to catch and remove them.
```

Reason for the wording: a two-item list ("words and shapes") is permitted by `structures.md:122`. Sentences stay complete and read as prose rather than staccato fragments.

**Verify**:

```bash
sed -n '8,10p' README.md             # shows the new line
grep -c "rhythms" README.md          # returns 0
```

### Step 2: extend scripts/verify.sh em-dash scan to README (optional co-fix)

In `scripts/verify.sh:45`, change:

```bash
if grep -rn "—" SKILL.md references/; then
```

to:

```bash
if grep -rn "—" README.md SKILL.md references/; then
```

This is a two-token behavioural change. It catches any future em dash introduced into README, including future intro rewrites.

**Verify**: `bash scripts/verify.sh` exits 0.

### Step 3: smoke-test the optional co-fix

Temporarily append `\n— test\n` to `README.md`, run `bash scripts/verify.sh`, expect non-zero exit with a message containing `em dash found`. Restore with `git checkout -- README.md`.

**Verify**: `git status --short` shows `README.md` clean after the probe; verify.sh exits 0 on a clean tree.

### Step 4: commit

```bash
git add README.md scripts/verify.sh
git commit -m "docs: rewrite README intro to comply with the three-item rule"
```

**Verify**: `git show --stat HEAD` lists `README.md` and, if Step 2 was included, `scripts/verify.sh`.

## Test plan

- This repo has no test framework. Verification is the gate `bash scripts/verify.sh` plus the grep checks above.
- Manual gate: open README.md and confirm the intro paragraph still reads as a continuous invitation to the skill. Tone change is acceptable; loss of clarity is not.

## Done criteria

- [ ] `README.md` line 9 no longer matches the three-item pattern `\b\w+, \w+,? and? \w+\b`.
- [ ] `bash scripts/verify.sh` exits 0 on the current tree.
- [ ] `wc -l README.md` is within plus or minus two of the pre-plan value.
- [ ] No file outside `README.md` (and optionally `scripts/verify.sh`) is modified.
- [ ] Commit on branch `advisor/003-readme-three-item-fix`.

## STOP conditions

Stop and report back (do not improvise) if:

- A grep for the three-item pattern matches a file you did not intend to touch (such as a rule table inside `references/`); restrict the search to prose lines before reporting false positives.
- The intro paragraph tone feels worse after the rewrite. Propose two alternative single-sentence replacements in NOTES for the reviewer to pick; do not iterate indefinitely.
- `verify.sh` exits non-zero under a healthy tree. Step 2 is the only mutation; if the script broke something else, revert Step 2 and restart.

## Maintenance notes

- Future README additions should not introduce three-item serializations, em dashes, narrator-from-a-distance, or any other structure banned in `references/structures.md` or `references/phrases.md`.
- A pre-commit hook that runs `bash scripts/verify.sh` is a direction finding (D4 below), not a fix here.
- If finding HIGH #1 from this audit (Example 4 "After" still violates the three-item rule) is planned later, sequence it after this plan so each executor carries one mental model at a time.
