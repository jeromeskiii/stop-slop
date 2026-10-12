# Plan 004: Assert closing YAML frontmatter delimiter in scripts/verify.sh

> Drift check: `git diff --stat 1f626d3..HEAD -- scripts/verify.sh SKILL.md`
> Repo-level gate (mandatory): `bash scripts/verify.sh` exits 0.

## Status

- Priority: P2
- Effort: XS
- Risk: LOW
- Depends on: none
- Category: tests
- Planned at: commit `1f626d3`, 2026-10-12

## Why this matters

`scripts/verify.sh:21` checks only that line 1 of `SKILL.md` is `---`. It never verifies that a matching `---` closes the frontmatter block. A SKILL.md whose frontmatter opens with `---` but never closes passes today's gate while downstream parsers (Claude Code skill loader, future tooling) silently treat the file as broken.

## Current state

- `scripts/verify.sh:21-23`:

  ```bash
  if [[ "$(head -n 1 SKILL.md)" != "---" ]]; then
    fail "SKILL.md does not start with frontmatter delimiter '---'"
  fi
  ```

  No closing-delimiter assertion exists.
- `SKILL.md:1-8` opens with `---`, lists YAML keys, closes with `---` on line 8. The current tree is well-formed; the bug is the test gap, not an existing defect.

## Scope

**In scope**: `scripts/verify.sh` (one new check inserted after the existing opening-delimiter check).

**Out of scope**: SKILL.md, references/, README.md, plans/.

## Git workflow

- Branch: `advisor/004-yaml-close-check`
- Commit: `test: assert SKILL.md closing YAML frontmatter delimiter`
- Do NOT push or open a PR unless instructed.

## Steps

### Step 1: add a closing-delimiter check after the opening check

In `scripts/verify.sh`, immediately after line 23 (the `fi` closing the opening-delimiter check), insert:

```bash
if ! awk 'NR > 1 && /^---$/ {found = 1; exit} END {exit !found}' SKILL.md; then
  fail "SKILL.md frontmatter has opening '---' but no matching closing '---'"
fi
```

**Verify**: `bash scripts/verify.sh` exits 0 (the current tree is well-formed).

### Step 2: negative-test the closing check

Temporarily remove the closing `---` from `SKILL.md` by writing `awk 'NR==8{next}1' SKILL.md > SKILL.md.tmp && mv SKILL.md.tmp SKILL.md`. Run `bash scripts/verify.sh`. Expect non-zero exit with `verify: FAIL — SKILL.md frontmatter has opening '---' but no matching closing '---'`.

Restore the file with `git checkout -- SKILL.md`. Re-run: exits 0 again.

**Verify**: failure observed on the broken tree; `git status --short` shows `SKILL.md` clean after restoration; verify.sh exits 0 again.

### Step 3: commit

```bash
git add scripts/verify.sh
git commit -m "test: assert SKILL.md closing YAML frontmatter delimiter"
```

**Verify**: `git show --stat HEAD` lists only `scripts/verify.sh`.

## Test plan

- The check itself runs on every `verify.sh` invocation. Step 2 is the manual negative-test confirmation.

## Done criteria

- [ ] `bash scripts/verify.sh` exits 0 on the current tree.
- [ ] `awk 'NR>1 && /^---$/{found=1;exit}END{exit !found}' SKILL.md` prints nothing and exits 0.
- [ ] Removing the closing delimiter trips the gate to non-zero exit with the expected message.
- [ ] `git status --short` shows no working-tree residue from Step 2.
- [ ] Commit on branch `advisor/004-yaml-close-check`.

## STOP conditions

- Step 2 deletes more than the closing delimiter (for instance, removes a `## License` heading by mistake). STOP and re-read before restoring.
- The `awk` expression fails to match a SKILL.md you know has a clean closing delimiter. STOP and report the exact `awk` script and the current frontmatter block; do not "fix" `awk` with a different regex in this plan, that would be scope creep.

## Maintenance notes

- The check is intentionally narrow: it asserts "closing delimiter exists", not "frontmatter parses as YAML". A real YAML parser (`yq`) is a future direction finding, not in scope here.
- If frontmatter format ever switches to TOML (`+++`), this awk needs to be updated in the same PR.
