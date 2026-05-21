---
name: git-commit
description: Use when creating one or more git commits from working tree changes, or splitting/reshaping existing commits — running `git commit`, deciding what to stage, writing commit messages, or asked to "commit these changes" / "split this commit". Skip for PR descriptions (use pull-request), branch naming, in-code comments.
---

# Git Commit

## Preconditions

- The changes you intend to commit are **settled** — work-in-progress checkpoints intended to land are fine, but you are not mid-edit on a file you are about to stage. Do not interleave implementation with commit work.
- Unrelated in-flight changes will be surfaced by Check 3 and **stashed, not committed**. This skill never silently bundles incidental work into a "real" commit.
- This skill writes commits only. Mid-split implementation edits are forbidden (Hard rule 3) — if a split surfaces a missing change, abort, finish the change, then re-enter the skill.

## Core principle

One commit = one concern the reviewer can hold in mind at once. A commit that mixes two concerns forces the reviewer to load two contexts simultaneously, makes a revert impossible without collateral, and turns the log into noise.

`git diff` already carries the *what*. The commit message carries the *why* and the framing the diff cannot show: the incident that triggered the change, the constraint that ruled out the alternative, the contract being honored. If the message restates the diff, it has spent its space on nothing.

## Hard rules

1. **No AI-attribution trailer.** Never append `Co-Authored-By: Claude <noreply@anthropic.com>` or any equivalent AI-attribution line to a commit message. The default Bash-tool prompt suggests it — strip it explicitly before invoking `git commit`. Legitimate trailers required by the repo (`Signed-off-by:`, `Refs:`, `Fixes:`, `Reviewed-by:`, etc.) are fine; this rule targets AI-attribution only.
2. **No mixed concerns in a single commit.** "It's a small unrelated fix, I'll fold it in" is a rationalization. Split or stash; do not bundle.
3. **No mid-split implementation edits.** Once the split plan is set, the only allowed operations are stage / unstage / commit / stash. If you discover a missing change, exit the skill, make the change as a normal edit, re-enter.
4. **(Soft) Cross-commit dependencies must be named.** You are not required to prove each commit builds in isolation, but if commit B depends on commit A (compiles, passes tests, makes semantic sense only after A), say so explicitly in the plan presented at Step 6.

## When to use / not

**Use:** any time changes are about to be committed (new work, follow-up fixes, work-in-progress checkpoints meant to land), or an existing commit needs splitting / reshaping.

**Do not use:** PR descriptions (use `pull-request` skill), branch naming, in-code comments, release notes.

## Mode — create vs. reshape

**Create** is the default — staging working-tree changes into one or more new commits.

**Reshape** covers splitting, reordering, rewording, or otherwise rewriting existing commits. Reshape requires the pushed-commit guard first:

```bash
git fetch --all --tags                          # remote refs must be current first
git rev-list HEAD --not --remotes --tags        # local-only commits
```

The output is the set of **local-only** commits — those are the only commits safe to reshape. **Empty output** means every commit on this branch is already on a remote — refuse the reshape, exit, and tell the user. If a named target is outside the local-only set, refuse by SHA. Force-pushing shared history is not a decision this skill makes.

Reshape mode also loads `reshaping.md` for the `reset --soft` / `rebase -i` / cherry-pick plumbing.

## Split criteria (reviewer-perspective)

Judgment heuristic: *"Could a reviewer reasonably want to merge one of these and reject the other?"* If yes → separate commits.

| Together (one commit) | Separate (different commits) |
|---|---|
| Same concern, mutually-supporting changes (implementation + its tests; new setting + its first call site) | Different concerns (refactor + new feature; dependency bump + behavior change) |
| Splitting would force the reviewer to load the same context twice | Splitting lets the reviewer accept one and defer / reject the other |
| Tiny incidental changes (1–2 line import cleanup adjacent to the real change) | Different shape of work (formatting-only, dependency bump, doc-only) |

## Step 0 — Mode decision (always first)

Decide Create vs Reshape from `git status` and the conversation context. If the user said "split this commit", "reword the last commit", "squash these two" — Reshape. If the user said "commit these changes" and the working tree is dirty — Create. Run the pushed-commit guard immediately if Reshape; do not proceed until it returns at least one SHA.

## Step 1 — Layer 1 information (always)

Gather before planning:

- `git status --short`
- `git diff --stat`
- `git log <base>..HEAD --oneline` (for Reshape mode, or to see commits already on the branch)
- Current conversation context — strongest signal, you were there
- Branch name and any referenced issue numbers

Reuse Layer 1 output later — do not re-run the same `git status` / `git log` to "double-check."

## Step 2 — House-style detection

Sample the most recent 5–10 commits on the branch (or on `main` if the branch is empty) to infer language (English / 한국어 / mixed), prefix conventions (`fix:`, `feat:`, `[area]`, none), subject tense (imperative / past / noun-ending), and whether bodies are typical or rare.

Load `style.md` if repo style is not already established in this conversation.

## Step 3 — Split plan

For each proposed commit, write down:

- **Files / hunks** included
- **One-line summary** (draft of the eventual subject)
- **Dependency** on any prior commit in the same plan
- **Unrelated bucket** — anything that does not belong to any planned commit goes here and will be stashed, not committed

The plan is the artifact you show the user at Step 6. Keep it tight.

A plan with 8+ commits for one feature is a *scope* signal, not a *split* signal — surface the scope problem to the user before subdividing further. Treat commit count the way the `pull-request` skill treats PR size: a symptom of scope, addressed at the scope layer.

## Step 4 — Message drafting

Subject = impact. Lead with the user-visible or system-visible effect, not the mechanism of the diff ("Stop dropping retry headers on 502" > "Refactor retry middleware").

Body only when the *why* is not self-evident from the subject + diff. When a body is warranted, it must name a specific incident, contract, constraint, or decision. Generic refactor-justifications ("cleaner", "easier to test", "more flexible") fail Check 5.

## Step 5 — Self-verification (six checks)

Run all six before showing the plan. Three cover the split, three cover the messages. Each failure has one fix.

1. **Mixed-concerns check** — Does any commit cover two or more independent concerns? Fix: split.
2. **Dependency-order check** — Does every commit make sense atop the previous one, and are any inter-commit dependencies named in the plan? Fix: reorder, merge, or add the dependency note.
3. **Unrelated-changes check** — Are any in-flight / debug / off-topic changes silently riding along? Fix: surface them as a stash recommendation in the plan.
4. **Subject impact check** — Does the subject express the *effect* of the change, not the *mechanism* of the diff? Fix: rewrite subject impact-first.
5. **Body-why check** — If a body exists, is the "why" a specific incident, contract, constraint, or decision? Generic refactor-justifications ("cleaner", "easier to test", "more flexible") fail. Fix: name the specific cause, or drop the body.
6. **House-style + attribution check** — Do language, prefix, and tense match the recent 5–10 commits? Is the AI-attribution trailer absent from every message? Fix: align style; strip attribution.

If a check fails and the fix is not obvious → **load `examples.md`** for bad→good transformations grouped by check number.

## Step 6 — Present plan and wait

Show the user the full plan: per-commit file list, subject, body (if any), dependency notes, and the stash bucket. **Include a six-line verification block from Step 5** — `Check 1: pass — single concern`, `Check 2: pass — no inter-commit dependency`, …, one line per check. An unwritten check is an unrun check; the block forces each check to materialize as output.

Wait for confirmation or edits. Do not run `git add` / `git commit` / `git reset` / `git rebase` until the user approves the exact text shown. A single approval at Step 6 covers the full plan (all N commits + the stash bucket); per-commit re-confirmation is not required unless the plan was revised.

**Auto mode does not waive this gate.** Step 6 is the approval surface, not a clarifying question. Auto-mode "bias toward working without stopping" applies to investigative work, not to writes to shared history.

Confirmation is per-text, not per-session. Any revision after approval requires re-showing the new version. Earlier "looks good" does not authorize a different plan.

## Step 7 — Bulk execution

Hand control to the user via interactive `git add -p` for any hunk-level split — this skill does not drive the interactive prompt.

**Create-mode sketch:**

```bash
git reset                          # unstage everything as a known starting point
# for each group:
git add <files>                    # or: git add -p <file> (hand-off for hunk-level)
git commit -F .git/commit-msg-N.txt  # use file, not -m, for multi-line bodies
```

**Reshape-mode sketch:**

```bash
git reset --soft <base>            # collapse target commits into staging
# then proceed as Create-mode loop above
# alternative for surgical edits: git rebase -i <base>
```

**Hook failures:** If `git commit` aborts because a pre-commit / commit-msg hook failed, the commit did not happen. Investigate the failure, fix the underlying issue, re-stage, and create a **new** commit. Never pass `--no-verify` / `--no-gpg-sign` unless the user explicitly authorizes it for this commit; never `--amend` after a hook failure (the previous commit becomes the target). If a `pre-commit` hook reformats files, verify with `git diff HEAD~1` after the commit to confirm what actually landed.

If the user had pre-staged hunks intentionally before invoking the skill, surface that at Step 6 — do not silently `git reset` over their work.

Full plumbing (stash isolation, partial resets, conflict handling during rebase) lives in `reshaping.md`.

## Anti-patterns

| Bad | Why it fails | Fix → |
|---|---|---|
| `git add -A && git commit -m "..."` for a multi-concern working tree | Reviewer carries two+ concerns at once; revert is impossible | Step 3 split |
| Subject = prose rewrite of the diff (`Update auth.ts and add tests`) | The file list already shows this; subject space is wasted | Check 4 → impact-led subject |
| Body = generic refactor justification ("for cleaner separation") | Could justify any refactor; justifies none specifically | Check 5 → specific cause, or drop the body |
| Bundling unrelated changes "to keep commit count down" | Revert is blocked; one reject takes the others down | Checks 1 / 3 → split or stash |

## Red flags — stop and revise

If any of these thoughts surface, the plan is failing:

- "Change is small, so splitting doesn't matter."
- "Squash-merge erases commits anyway." (Individual commits become PR body fodder. Splitting is also self-organization while you work.)
- "User approved a similar plan before, so I can skip re-confirm." (Per-text approval — never carries forward.)
- "The trailer is the default, I should leave it." (Hard rule 1 violation.)
- "Already pushed but a force-push reshape would be cleaner." (Step 0 guard violation.)
- "I'll just touch this one extra line while I'm here." (Hard rule 3 violation. Once you edit mid-split, the diff stops matching the plan you showed at Step 6 — the user's approval is no longer for what you are about to commit.)
- "Auto mode is on, I should keep going past Step 6." (Step 6 is an approval gate, not a clarifying question. Auto mode applies to investigative work, not to writes to shared history.)
- "Repo is personal / a fork / private, so the rules don't apply." (Any branch can become a PR. Hard rules are about the shared review surface, which any branch can become.)
- "User said 'just commit it', so they've waived Step 6." ("Commit" is the *task*, not the *approval*. Show the plan, wait.)
- "The six checks at Step 5 are mental — I don't need to write them down." (Unwritten check = unrun check. Step 6 requires the verification block.)

## Reference files — load ONLY when the condition is met

| File | Load when | Skip when |
|---|---|---|
| `splitting.md` | Create mode with a multi-concern working tree; need `add -p` / file-level add / stash strategy / patch generation guidance | Single file, single concern — no split needed |
| `reshaping.md` | Reshape mode — `reset --soft`, `rebase -i`, cherry-pick sequences, pushed-commit guard details | Create mode |
| `style.md` | Step 2, when repo style is not already established in conversation context | Same repo's style already inferred in this conversation |
| `examples.md` | A self-verification check failed and the fix is not obvious. Grouped by check number | All checks pass, or fix is obvious |

**Anti-rationalization:** "load them all just in case" defeats the structure. Conditions are filters, not suggestions.
