# Plan 005: Add CONTRIBUTING.md describing the rule-and-verify contract

> Drift check: `git diff --stat 1f626d3..HEAD -- CONTRIBUTING.md CHANGELOG.md`

## Status

- Priority: P2
- Effort: S
- Risk: NONE
- Depends on: none
- Category: docs
- Planned at: commit `1f626d3`, 2026-10-12

## Why this matters

stop-slop is a publicly distributed skill. The repo's contract is that rules have backing references and verifier checks pinning the rule-to-check alignment. Today the contract is implicit, and reviewers reverse-engineer it on every PR. CONTRIBUTING.md turns implicit expectations into something a first-time contributor can search.

## Current state

- Repo root contents:

  ```
  README.md  CHANGELOG.md  SKILL.md  LICENSE
  references/  scripts/  plans/
  ```

- `CONTRIBUTING.md` does not exist.
- The implicit contract, recovered from `plans/002-verification-baseline.md`: a rule change in `SKILL.md` is three changes (`SKILL.md`, the matching section in `references/`, a check in `scripts/verify.sh`); examples follow the After-only self-pattern (Before lines are intentionally slop); CHANGELOG entry is required.
- CHANGELOG convention: date heading with `### Added` / `### Changed` subsections (see existing `CHANGELOG.md` sections).

## Scope

**In scope**: a new file `CONTRIBUTING.md` at the repo root; one CHANGELOG entry.

**Out of scope**: SKILL.md, references/, scripts/, README.md, plans/.

## Git workflow

- Branch: `advisor/005-contributing-md`
- Commit: `docs: add CONTRIBUTING.md`
- Do NOT push or open a PR unless instructed.

## Steps

### Step 1: write CONTRIBUTING.md

Create `CONTRIBUTING.md` at the repo root. Sections, in order:

1. **What this skill does**. A paragraph linking to `README.md`.
2. **The contract**. A numbered list of the three properties (backing reference exists; verifier check exists; examples keep Before lines sloppy because rules apply to After lines only).
3. **Adding or changing a rule**. A concrete checklist: edit the matching `SKILL.md` Quick Check, edit the matching section in `references/structures.md` or `references/phrases.md`, add a grep anchor in `scripts/verify.sh`.
4. **Adding an example**. Show the Before/After shape from `references/examples.md`; remind that After lines are checked by `scripts/verify.sh`.
5. **Verifier checks**. Describe `scripts/verify.sh`'s pattern: one labelled check per gate, non-zero exit on failure, `verify: OK` summary.
6. **Pull request procedure**. Branch convention `advisor/NNN-<slug>`; commit-message style `feat:` / `fix:` / `docs:` / `test:`; expected local `bash scripts/verify.sh` exit 0; expected CI green after plan 006 lands.
7. **Style for prose in this repo**. The skill teaches prose rules; contributions to CONTRIBUTING.md follow the Quick Checks at `SKILL.md:34-47` before merge.
8. **License**. MIT, per `LICENSE`.

Hard caps: under 120 lines, no em dashes, no three-item serializations in prose, no narrator-from-a-distance. The file is a working demonstration of its own rules.

**Verify**:

```bash
test -f CONTRIBUTING.md
wc -l CONTRIBUTING.md              # under 120
grep -n "—" CONTRIBUTING.md        # no matches
```

### Step 2: confirm the file self-complies via the gate

Run `bash scripts/verify.sh`. Expected: exit 0. The existing em-dash check does not scan CONTRIBUTING.md today, so the manual grep check above must catch any self-violation.

**Verify**: gate exits 0; manual greps show no em dash and no three-item serialization in the prose of CONTRIBUTING.md (table rows are exempt; review prose lines by hand).

### Step 3: add a CHANGELOG entry

Append to `CHANGELOG.md`, above the existing `## 2026-10-11` section:

```markdown
## 2026-10-12

### Added

**Docs (CONTRIBUTING.md)**
- New top-level file describing the rule-plus-reference-plus-verifier
  contract for contributors. See branch advisor/005-contributing-md.
```

**Verify**: `head -n 12 CHANGELOG.md` shows the new section first.

### Step 4: commit

```bash
git add CONTRIBUTING.md CHANGELOG.md
git commit -m "docs: add CONTRIBUTING.md"
```

**Verify**: `git show --stat HEAD` lists CONTRIBUTING.md and CHANGELOG.md.

## Test plan

- Manual: read CONTRIBUTING.md from top to bottom and confirm a first-time contributor could add a rule by following it.

## Done criteria

- [ ] `CONTRIBUTING.md` exists at repo root, 120 lines or fewer.
- [ ] CONTRIBUTING.md has the eight headings listed in Step 1.
- [ ] CONTRIBUTING.md contains no em dash and no three-item serialization in prose.
- [ ] CHANGELOG.md has a new dated section.
- [ ] `bash scripts/verify.sh` exits 0.
- [ ] `git status --short` shows only CONTRIBUTING.md and CHANGELOG.md.
- [ ] Commit on branch `advisor/005-contributing-md`.

## STOP conditions

- CONTRIBUTING.md exceeds 120 lines despite trimming. STOP and report which sections bloated. Do not silently delete headings.
- The body references an out-of-date path (such as an old reference filename). STOP and re-read `references/` before correcting.
- A section needs to enumerate the banned-phrase list verbatim. Defer that content into `references/phrases.md` and link, rather than copying it into CONTRIBUTING.md.

## Maintenance notes

- Update CONTRIBUTING.md whenever a new protocol emerges: branch naming, commit-message prefixes, verifier pattern, or example convention.
- Reviewer should reject rule-only PRs that have no `references/` update and no `scripts/verify.sh` check (or an explicit "no verifier needed" decision in the PR body).
