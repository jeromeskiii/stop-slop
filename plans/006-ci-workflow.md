# Plan 006: Add a GitHub Actions workflow that runs scripts/verify.sh on PR and push

> Drift check: `git diff --stat 1f626d3..HEAD -- .github/workflows/ README.md CHANGELOG.md`

## Status

- Priority: P2
- Effort: S
- Risk: NONE
- Depends on: none
- Category: dx
- Planned at: commit `1f626d3`, 2026-10-12

## Why this matters

`scripts/verify.sh` is the only structural gate in the repo, and it exits 0 in code review as much as on the maintainer's machine. There is no CI today (no `.github/workflows/`). Rule or frontmatter regressions could land to main and silently fail later. Wrapping `verify.sh` in a single GitHub Actions job on PR and push turns the script's exit code into a required check.

## Current state

- `ls -la .github/workflows/` returns "No such file or directory".
- `scripts/verify.sh` is portable bash: `set -euo pipefail`, deterministic file paths, no network, no dependencies. It is CI-portable as-is.
- Branch-protection / required-check policy is on the maintainer. This plan adds only the workflow file.

## Scope

**In scope**: a new file `.github/workflows/verify.yml`; one README change; one CHANGELOG entry.

**Out of scope**: any branch-protection configuration (owner decision); any cross-repo CI matrix.

## Git workflow

- Branch: `advisor/006-ci-workflow`
- Commit: `ci: run verify.sh on PR and push`
- Do NOT push or open a PR unless instructed.

## Steps

### Step 1: write the workflow

Create `.github/workflows/verify.yml`:

```yaml
name: verify

on:
  pull_request:
  push:
    branches: [main]

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run verify.sh
        run: bash scripts/verify.sh
```

Notes:
- No dependency install step. The repo is markdown and bash only.
- `ubuntu-latest` is sufficient: verify.sh is pure POSIX bash. macOS-specific tooling is not used.
- Single job, single step. Expand only when real new checks demand it.

**Verify**:

```bash
bash -n .github/workflows/verify.yml
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/verify.yml'))"
```

Both must exit 0.

### Step 2: smoke-test verify.sh locally

`bash scripts/verify.sh` exits 0 on the current tree.

**Verify**: as expected.

### Step 3: add the workflow pointer to README

In `README.md`, under the existing "Verify" section (around line 28), add a single sentence:

```markdown
Same script runs on every PR and push from .github/workflows/verify.yml.
```

Keep the line short. Do not rewrite surrounding text.

**Verify**: `grep -n "verify.yml" README.md` shows 1 match.

### Step 4: CHANGELOG entry

Append to `CHANGELOG.md`, above the existing `## 2026-10-11` section:

```markdown
## 2026-10-12

### Added

**CI (.github/workflows/verify.yml)**
- GitHub Actions job on PR and push runs bash scripts/verify.sh. After
  this lands, the gate is enforced on every change to main.
```

**Verify**: `head -n 12 CHANGELOG.md` shows the new section.

### Step 5: commit

```bash
git add .github/workflows/verify.yml README.md CHANGELOG.md
git commit -m "ci: run verify.sh on PR and push"
```

**Verify**: `git show --stat HEAD` lists only in-scope files.

## Test plan

- The CI itself is the test: the workflow executes verify.sh and fails the PR when the script exits non-zero.
- Manual smoke: verify.sh already runs locally; the workflow runs the same script.

## Done criteria

- [ ] `.github/workflows/verify.yml` exists, parses as YAML, contains the verify.sh step.
- [ ] `bash scripts/verify.sh` exits 0 on the current tree.
- [ ] `README.md` has one line mentioning the workflow.
- [ ] CHANGELOG.md has a new dated entry.
- [ ] `git status --short` shows only in-scope files.

## STOP conditions

- YAML fails to parse. STOP and report the exact parse error. Do not simplify the workflow to mask the error.
- The README change introduces three-item lists or em dashes. STOP and re-apply plan 003 style constraints.
- Branch-protection configuration requires repo admin scope. STOP and surface this to the maintainer. Do not attempt to enable it from the executor.

## Maintenance notes

- Future rule extensions that need real parsers (such as a YAML parser for frontmatter) should bump `actions/checkout@v4` to a pinned SHA if the project later opts into supply-chain hardening.
- Use `pull_request_target` only if a future workflow needs write access. `pull_request` on plain `ubuntu-latest` is sufficient for read-only verification and is the safer default.
- A multi-OS matrix is a future direction finding, not in scope here: the verifier is portable bash, with no macOS-specific behavior to test.
