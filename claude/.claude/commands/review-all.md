---
description: Review local git changes through three lenses (Codex + ponytail + claude /review) and return one merged report
argument-hint: '[--wait|--background] [--base <ref>] [--scope working-tree|branch]'
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash(git:*), Bash(node:*), SlashCommand, Skill
---

Review the local git state with three passes and merge their findings into one report.

Raw slash-command arguments:
`$ARGUMENTS`

## Core constraint
- Review-only. Do not fix, patch, stage, commit, or submit anything. The only output is the merged report.
- All three passes read the same local git state, not a PR by number. For PR inline comments, use `/review-pr`.

## Scope
- `--scope working-tree` (default): uncommitted changes (staged + unstaged + untracked). Untracked files are inlined too, so leftover local files such as notes or CSVs grow the Codex prompt; the report lists any untracked file that looks unrelated to the change.
- `--scope branch`: `git diff <base>...HEAD`; `--base` sets the base ref (default: `origin/HEAD`, else `main`).
- If the resolved scope is empty, say so and stop. Do not fall back to another scope on your own.

## Passes
1. **Codex adversarial review on `gpt-6-astra`**: the first action, before reading any diff. Codex is the slowest pass and sets the total time.
   ```bash
   node ~/.claude/scripts/codex-inline-review.mjs [--base <base>] [--scope <scope>]
   ```
   - The script fills the companion's `adversarial-review` prompt with the full diff and runs `codex-companion.mjs task --model gpt-6-astra --effort high`. The companion's own `adversarial-review` inlines the diff only for 2 or fewer changed files, and Codex otherwise spends most of its time re-collecting it. Diffs over 256KB fall back to `adversarial-review` automatically.
   - Run it from the repo root with Bash (`/codex:*` slash commands cannot be invoked by the model): `run_in_background` by default, foreground if the user passed `--wait`.
   - Forward only the `--base` and `--scope` the user passed. The first output line, `[inline-review] scope=<scope> base=<base>`, is the resolved scope; run the other two passes on that same diff. `Nothing to review for scope <scope>.` means stop.
   - Read the output only after Codex finishes. It ends with one JSON object (`verdict`, `summary`, `findings` with `file`, `line_start`, `line_end`, `confidence`, `recommendation`); after a fallback it is the companion's rendered review instead.
   - `approve` with no findings is a valid result. Exit code 1, `Reviewer failed to output a response`, `requires a newer version of Codex`, or `failed to load configuration` mean the pass failed. The last one comes from a stale `app-server-broker.mjs serve --cwd <path>` whose directory was deleted; kill that broker and rerun once.
2. **claude `/review`**: invoke the built-in `/review` via SlashCommand for the correctness, security, and bug lens. It is PR-oriented, so if it has no local target, analyze the scope diff yourself for correctness.
3. **ponytail (`ponytail-review` skill)**: the same diff, over-engineering lens only (delete / stdlib / native / yagni / shrink). Keep its `net: -N lines possible.` summary.

## Merge
When Codex finishes (wait for its completion notification if the other two are done first), fold all three sources into one report.
- Dedup findings on the same file, line, and issue; keep one and tag it with every source that raised it (`own`, `codex`, `ponytail`).
- Your own judgment governs. Check each Codex and ponytail finding against the code before keeping it (adversarial findings lean skeptical); name the ones you drop as false positives and why.
- If Codex failed, proceed with the remaining sources and note the gap.

## Output
- Group by severity or by file, whichever fits the diff.
- Each finding: location (`file:line`), the issue in 1-2 sentences, and the origin tag.
- End with the ponytail line: `net: -N lines possible.`, or `Lean already.` when there is nothing to cut.
- If all three passes come back clean, say so plainly and stop.
