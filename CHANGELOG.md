# Changelog

## 2026-10-11

### Added

**Tooling (scripts/verify.sh)**
- Structural verification script: frontmatter, reference links,
  quick-check coverage, self-compliance (no em dashes; no "nobody" in After
  lines), and README tree completeness, ending with `verify: OK`.

### Changed

**Examples (references/examples.md)**
- Rewrote Example 1/2/4 "After" texts that violated the skill's own rules
  (em dash, lazy extreme "nobody", narrator-from-a-distance, staccato
  fragments). The examples now comply with the rules they demonstrate.

**Rules (references/structures.md)**
- Added the matching-sentence-length rule row to the Rhythm Patterns table,
  backing the "Three consecutive sentences match length" quick check.

**Docs (README.md, SKILL.md)**
- README Skill Structure tree now complete: scripts/verify.sh and
  CHANGELOG.md listed.
- Frontmatter `license: MIT` added to SKILL.md.

## 2026-01-13

### Added

**Phrases (references/phrases.md)**
- Throat-clearing: "Here's what I find interesting", "Here's the problem though"
- Performative emphasis: "creeps in", "I promise", "They exist, I promise"
- Telling instead of showing: "This is genuinely hard", "This is what leadership actually looks like"

**Structures (references/structures.md)**
- Binary contrasts: "Not X. But Y.", "It's not this. It's that.", "stops being X and starts being Y"
- Rhythm patterns: staccato fragmentation, dashes for dramatic pause, hedging as reassurance
- Word patterns: absolute words (always, never, everyone, etc.), AI-overused intensifiers (deeply, truly, fundamentally, inherently, simply, literally, inevitably)

## 2026-01-12

- Restructured skill following Claude Code best practices (PR #1)
- Split into SKILL.md and references/ folder

## 2025-01-12

- Initial release
