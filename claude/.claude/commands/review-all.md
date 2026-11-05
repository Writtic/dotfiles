---
description: Review local git changes through three lenses (Codex + ponytail + claude /review) and return one merged report
argument-hint: '[--wait|--background] [--base <ref>] [--scope auto|working-tree|branch]'
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, Bash(git:*), Bash(node:*), AskUserQuestion, SlashCommand, Skill
---

Review the local git state with three passes and merge their findings into one report.

Raw slash-command arguments:
`$ARGUMENTS`

## Core constraint
- Review-only. Do not fix, patch, stage, commit, or submit anything.
- The output is a single merged report shown to the user, nothing else.
- All three passes read the same local git state, not a PR by number.
- For PR inline comments, this is the wrong command. Use `/review-pr`.

## First action: launch Codex
Before resolving the scope or reading any diff, launch the Codex pass (Passes step 1). Codex is the slowest pass and sets the total time, so every second spent before it starts adds to the wait. The script resolves `--scope auto` and the default base by the same rules as below.

## Scope
Resolve the scope once so the other two passes look at the same diff Codex reviews.
- `--scope working-tree`: uncommitted changes (staged + unstaged + untracked).
- `--scope branch`: `git diff <base>...HEAD`; `--base` sets the base ref (default: the repo's main branch).
- `--scope auto` (default): working-tree changes if any exist, else fall back to the branch diff.
- Check `git status --short --untracked-files=all` plus `git diff --shortstat` and `git diff --shortstat --cached`. Untracked files count as reviewable work. If the resolved scope is empty, say so and stop.

## Passes
Run all three against the resolved scope. Codex runs in the background while you do the other two.

1. **Codex adversarial review on `gpt-6-astra`**: launch it first so it works while you review.
   - Use the adversarial prompt, not the built-in `review`. The built-in reviewer on astra returns a one-line "No actionable regressions were identified" even when the other passes find real behavior bugs.
   - Run it through `~/.claude/scripts/codex-inline-review.mjs`. It fills the companion's `adversarial-review` prompt with the full diff and runs `codex-companion.mjs task --model gpt-6-astra --effort high`. The companion's own `adversarial-review` inlines the diff only for 2 or fewer changed files, so Codex otherwise spends most of its time re-collecting the diff with git/sed/rg. Diffs over 256KB fall back to `adversarial-review` automatically.
   - The `/codex:*` slash commands cannot be invoked by the model, so run it from the repo root with Bash. Use `run_in_background` by default; if the user passed `--wait`, run it in the foreground instead.
     ```bash
     node ~/.claude/scripts/codex-inline-review.mjs [--base <base>] [--scope <scope>]
     ```
   - Forward only the `--base` and `--scope` the user passed; leave them out otherwise so the script resolves them. Its first output line, `[inline-review] scope=<scope> base=<base>`, is the resolved scope; match the other two passes to it. `Nothing to review for scope <scope>.` means the scope is empty: say so and stop. The script reads the local git state, so the changes must be the current working tree or checked-out HEAD.
   - The output ends with one JSON object (`verdict`, `summary`, `findings` with `file`, `line_start`, `line_end`, `confidence`, `recommendation`). If the fallback ran, the output is the companion's rendered review instead.
   - Do not fetch its output yet. Collect it in the merge step. The output file stays empty until Codex finishes.
   - A verdict of `approve` with no findings is a valid result. Exit code 1, `Reviewer failed to output a response`, `requires a newer version of Codex`, or `failed to load configuration` mean the pass failed. The last one comes from a stale `app-server-broker.mjs serve --cwd <path>` whose directory was deleted; kill that broker and rerun once.
2. **claude `/review`**: invoke the built-in `/review` via SlashCommand for the correctness, security, and bug lens. Built-in `/review` is PR-oriented, so if it has no local target to work with, fall back to analyzing the scope diff yourself for correctness.
3. **ponytail (`ponytail-review` skill)**: run it on the same diff for the over-engineering lens only (delete / stdlib / native / yagni / shrink). Keep its `net: -N lines possible.` summary.

## Merge
When the Codex background task finishes, fold all three sources into one report.
- Dedup findings that point at the same file and line and issue. Keep one, and tag it with every source that raised it.
- Your own judgment governs. Drop auxiliary findings you assess as false positives and say which ones and why.
- Tag each surviving finding with its origin: `own`, `codex`, or `ponytail`.
- Adversarial findings lean skeptical. Check each Codex finding against the code before keeping it.
- If Codex is still running when the other two passes are done, wait for its completion notification. If Codex failed or was skipped, proceed with the remaining sources and note the gap.

## Output
One report to the user. No submission, no file writes, no fixes.
- Group by severity or by file, whichever fits the diff.
- Each finding: location (`file:line`), the issue in 1-2 sentences, and the origin tag.
- End with the ponytail line: `net: -N lines possible.`, or `Lean already.` when there is nothing to cut.
- If all three passes come back clean, say so plainly and stop.

## Execution mode
- `--background` (default): Codex as a background task; run `/review` and ponytail while it works, then merge.
- `--wait`: run Codex in the foreground first, then `/review` and ponytail, then merge.
