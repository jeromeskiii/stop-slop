# Plan 001: Make every "After" example comply with the rules it demonstrates

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: written against commit `8da1f03` of
> `/Users/ohmskiii/Desktop/stop-slop` (clean tree). Confirm the excerpts in
> "Current state" match the live files. On a mismatch, STOP.

## Status

- **Priority**: P1
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: correctness
- **Planned at**: commit `8da1f03`, 2026-10-11

## Why this matters

The examples file is the skill's proof of competence: an LLM (or human) learns
the rules by studying the rewrites. Three "After" texts violate the skill's
own rules, so the showcase teaches the exact behavior the skill exists to
remove. Fixing the examples is content repair, not style preference.

## Current state

All paths relative to `/Users/ohmskiii/Desktop/stop-slop`.

- `references/examples.md:45` — the Example 4 "After" line contains an em
  dash, which SKILL.md:43 ("Em-dash anywhere? Remove it.") and
  `references/structures.md:125` ("Em-dashes | Remove. Use commas or periods.
  No em dashes at all.") ban unconditionally:

  ```
  > "Speed, quality, cost—pick two."
  ```

  It also presents a three-item list (`Speed, quality, cost`), which
  `structures.md:122` ("Three-item lists | Use two items or one") bans as a
  rhythm pattern.
- `references/examples.md:21` — the Example 2 "After" line:

  ```
  > "Teams struggle with alignment. Nobody admits confusion."
  ```

  "Nobody" is a lazy extreme (`structures.md:133` bans "every, always, never,
  everyone, everybody, nobody" as "False authority"), and the sentence is the
  narrator-from-a-distance pattern `structures.md:88-93` bans ("Nobody
  designed this. | Disembodied observation").
- `references/examples.md:9` — the Example 1 "After" line:

  ```
  > "Building products is hard. Technology is manageable. People aren't."
  ```

  Three staccato sentences ending in a fragment ("People aren't."),
  violating `structures.md:126` ("Staccato fragmentation | Don't stack short
  punchy sentences") and SKILL.md:25 ("Vary rhythm").
- The banned character check today (proof it is otherwise clean):
  `grep -rn "—" SKILL.md references/` currently matches only
  `references/examples.md:45`.
- CHANGELOG convention: rule/content changes get dated entries
  (`CHANGELOG.md` has sections per date with Added/Changed subsections).

## Scope

**In scope**: `references/examples.md` (the three After lines and their
"Changes:" captions), `CHANGELOG.md` (one new entry).
**Out of scope**: `SKILL.md`, `references/phrases.md`,
`references/structures.md`, `README.md` — the rules themselves are correct;
only the examples violate them.

## Steps

### Step 1: rewrite Example 1's After (examples.md:9)

Replace the After line with:

```
> "Building products is hard. The technology is manageable; people are not."
```

Update the Example 1 "Changes:" caption to:
`Direct statements; two sentences of different length; complete clauses.`

**Verify**: `sed -n '9p' references/examples.md` shows the new line and
contains no em dash and no three-sentence staccato stack.

### Step 2: rewrite Example 2's After (examples.md:21)

Replace with:

```
> "Teams struggle with alignment. Few leaders admit it."
```

("few" is specific enough to escape the banned-extremes list; the actor is a
person; the second sentence varies length.) Update the Example 2
"Changes:" caption to: `Cut hedging, removed throat-clearing, named the
actor instead of the disembodied "nobody".`

**Verify**: `sed -n '21p' references/examples.md` shows the new line; the
word "Nobody"/"nobody" no longer appears anywhere in the file.

### Step 3: rewrite Example 4's After (examples.md:45)

Replace with:

```
> "Of speed, quality, and cost, you can pick two."
```

(The three options are the actual tradeoff, named as content rather than as
a rhythmic three-beat list; no em dash; complete sentence.) Update the
Example 4 "Changes:" caption to: `Complete sentence, no em dash, no
performative emphasis.`

**Verify**: `grep -rn "—" SKILL.md references/` returns **no matches**.

### Step 4: record the change in the CHANGELOG

Add a new top section to `CHANGELOG.md`, above the `## 2026-01-13` section:

```markdown
## 2026-10-11

### Changed

**Examples (references/examples.md)**
- Rewrote Example 1/2/4 "After" texts that violated the skill's own rules
  (em dash, lazy extreme "nobody", narrator-from-a-distance, staccato
  fragments). The examples now comply with the rules they demonstrate.
```

**Verify**: `sed -n '1,10p' CHANGELOG.md` shows the new section first.

## Test plan

- This repo has no test framework; verification is the grep gates below plus
  a human read of `references/examples.md` top to bottom.
- Manual gate: every "After" line in `references/examples.md` must survive
  the skill's own Quick Checks list (`SKILL.md:31-46`): no em dash, no "not
  X, it's Y", no staccato stack, no lazy extreme, human subject in every
  sentence.

## Done criteria

Machine-checkable. ALL must hold:

- [ ] `grep -rn "—" SKILL.md references/` returns no matches
- [ ] `awk '/\*\*After:\*\*/{getline; print}' references/examples.md | grep -cE "\b[Nn]obody\b"` returns 0 (Before lines are intentionally slop and are exempt — amendment after executor review, 2026-10-11)
- [ ] `sed -n '9p;21p;45p' references/examples.md` shows the three rewritten lines
- [ ] `CHANGELOG.md` first dated section is `## 2026-10-11`
- [ ] No files outside `references/examples.md` and `CHANGELOG.md` modified (`git status --short`)
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- The excerpt lines at `examples.md:9, 21, 45` do not match the live file
  (drift).
- Your replacement text would itself violate a Quick Check from
  `SKILL.md:31-46` and you cannot find a compliant wording — propose
  options, do not pick unilaterally beyond the ones given above.
- You notice additional self-violations elsewhere: report them as a finding
  list; do not fix them in this plan (out of scope).

## Maintenance notes

- Any future rule added to `SKILL.md` or `references/structures.md` should be
  followed by a self-compliance pass over `references/examples.md`.
- Reviewer should read all five examples against the Quick Checks list; the
  three fixed here were caught by exactly that reading.
- Follow-up (out of scope): plan 002 adds `scripts/verify.sh`, which
  mechanizes the em-dash and lazy-extreme gates this plan checks by hand.