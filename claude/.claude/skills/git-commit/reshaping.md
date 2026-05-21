# Reshape mode — rewriting local history

**Stop and return to `SKILL.md` if you are not in Reshape mode.**

If you are in Reshape mode, the **first action is the pushed-commit check below — before any other command.**

---

## Pushed-commit guard (run first, before any reshape)

```bash
git fetch --all --tags                          # remote refs must be current first
git rev-list HEAD --not --remotes --tags        # local-only commits
```

The output is the list of **local-only** commits — these are the only commits safe to reshape.

- **Any SHA listed** → safe to proceed, but only on commits in this list.
- **Empty output** → every commit on this branch is already shared. Refuse, exit, and tell the user:

  > "Every commit on this branch is already on a remote. Reshaping would require force-push, which this skill does not perform. Update the design intentionally outside this skill, or work on a new branch."

If a target named by the user is outside the local-only set, refuse by SHA:

> "Commit `<sha>` is not in the local-only set — it is already on a remote. Force-push is not a decision this skill makes."

Do not offer to do it anyway. Do not run any `git reset` / `rebase` after refusal.

---

## Identify the rewrite base

```bash
git log --oneline -10                       # see recent history
git merge-base HEAD @{upstream}             # base when an upstream is configured
# fallback if no upstream: substitute the default branch literally — e.g.
#   git merge-base HEAD origin/main
#   git merge-base HEAD origin/master
#   git merge-base HEAD origin/trunk
# find it with: git symbolic-ref refs/remotes/origin/HEAD
```

Pick the SHA *just before* the oldest commit you want to reshape. That SHA = `<base>`. Everything from `<base>..HEAD` is in scope; everything at or below `<base>` is untouched.

---

## Soft-reset strategy (default for full rewrite of last N commits)

```bash
git reset --soft <base>
# all changes are now staged; working tree is unchanged
git status --short
```

This collapses the commits into one staging area, then re-enter Create-mode-style per-group staging (see `splitting.md` if loaded). Use this when the whole range needs to be re-partitioned — when the existing commit boundaries no longer reflect the work.

---

## Interactive rebase strategy (for surgical edits — split one commit in the middle)

```bash
git rebase -i <base>
# mark the target line with `edit`, save, exit
git reset HEAD^         # uncommit the target; changes return to working tree, unstaged (default --mixed)
# ... per-group stage + commit as in splitting.md ...
git rebase --continue
```

When to prefer `rebase -i` over `reset --soft`: when you must preserve later commits intact. Soft-reset throws away every commit message after `<base>`; interactive rebase keeps them and only edits the one you marked.

---

## Cherry-pick strategy (rare — reorder + split)

Use only when neither soft-reset nor `rebase -i` fits — usually when commits need to be reordered as well as split.

```bash
git branch backup-<date>           # safety branch first
git reset --hard <base>
git cherry-pick <sha> -n           # apply without committing
# split into multiple commits as needed
git cherry-pick <next-sha> -n
# ...
```

The `backup-<date>` branch is non-negotiable. `git reset --hard` discards the working tree; without the backup branch, recovery depends on reflog alone.

If a `cherry-pick -n` produces a conflict, resolve it as a normal merge conflict (edit, `git add`, then continue), or `git cherry-pick --abort` and restore from the `backup-<date>` branch. Do not chain further `-n` picks until the conflicted state is resolved — the next pick will fail on a dirty index.

---

## Recovery via reflog (if something goes wrong)

```bash
git reflog -20
git reset --hard HEAD@{N}    # restore to a known good state
```

Reachable reflog entries survive 90 days by default; **unreachable entries — the common case after `reset --hard` or `rebase` — default to 30 days** (`gc.reflogExpireUnreachable`). Recovery is reliable within the first weeks, not indefinitely. Locate the `HEAD@{N}` entry from just before the reshape started, confirm its SHA matches what you expect with `git log HEAD@{N} --oneline -5`, then reset.

---

## When to stop and escalate to the user

Any of:

- History contains merge commits in the target range. Rewriting across a merge silently loses one side; do not attempt it.
- Conflicts arise during rebase that touch logic the skill did not produce. The author knows the intent; you are guessing.
- The user is unsure about a force-push exception. Do not make this decision unilaterally — pushed history belongs to everyone who has pulled it.
