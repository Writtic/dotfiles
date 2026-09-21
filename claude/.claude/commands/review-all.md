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

## Scope
Resolve the scope once up front so all three passes look at the same diff.
- `--scope working-tree`: uncommitted changes (staged + unstaged + untracked).
- `--scope branch`: `git diff <base>...HEAD`; `--base` sets the base ref (default: the repo's main branch).
- `--scope auto` (default): working-tree changes if any exist, else fall back to the branch diff.
- Check `git status --short --untracked-files=all` plus `git diff --shortstat` and `git diff --shortstat --cached`. Untracked files count as reviewable work. If the resolved scope is empty, say so and stop.

## Passes
Run all three against the resolved scope. Codex runs in the background while you do the other two.

1. **Codex (`/codex:review`)**: launch it first via SlashCommand so it works while you review.
   - Default: `/codex:review --background`. If the user passed `--wait`, forward `--wait` so Codex runs in the foreground instead.
   - Forward `--base` and `--scope` through unchanged.
   - Codex reviews the local git state, so the changes you want reviewed must be the current working tree or checked-out HEAD.
   - Do not fetch its output yet. Collect it in the merge step.
2. **claude `/review`**: invoke the built-in `/review` via SlashCommand for the correctness, security, and bug lens. Built-in `/review` is PR-oriented, so if it has no local target to work with, fall back to analyzing the scope diff yourself for correctness.
3. **ponytail (`ponytail-review` skill)**: run it on the same diff for the over-engineering lens only (delete / stdlib / native / yagni / shrink). Keep its `net: -N lines possible.` summary.

## Merge
When the Codex background task finishes, fold all three sources into one report.
- Dedup findings that point at the same file and line and issue. Keep one, and tag it with every source that raised it.
- Your own judgment governs. Drop auxiliary findings you assess as false positives and say which ones and why.
- Tag each surviving finding with its origin: `own`, `codex`, or `ponytail`.
- If Codex is still running when the other two passes are done, wait for it (check `/codex:status`). If Codex failed or was skipped, proceed with the remaining sources and note the gap.

## Output
One report to the user. No submission, no file writes, no fixes.
- Group by severity or by file, whichever fits the diff.
- Each finding: location (`file:line`), the issue in 1-2 sentences, and the origin tag.
- End with the ponytail line: `net: -N lines possible.`, or `Lean already.` when there is nothing to cut.
- If all three passes come back clean, say so plainly and stop.

## Execution mode
- `--background` (default): Codex as a background task; run `/review` and ponytail while it works, then merge.
- `--wait`: run Codex in the foreground first, then `/review` and ponytail, then merge.
