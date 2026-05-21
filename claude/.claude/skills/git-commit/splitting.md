# Splitting a multi-concern working tree (Create mode)

**Stop and return to `SKILL.md` if you are not in Create mode with a multi-concern working tree.**
Single file, single concern → this file is not needed.

---

## Inventory the working tree

```bash
git status --short
git diff --stat
git diff --name-only --cached    # staged
git diff --name-only             # unstaged
```

Read the output as a list of files, then mentally group them by concern: refactor vs. feature, dependency bump vs. call-site update, test-only vs. production code, generated vs. hand-edited. One group becomes one commit. If a single file straddles two concerns, mark it for hunk-level staging (see below).

Order matters: commits should land in the order a reviewer would want to read them and a bisect would want to land them. Dependency / schema / interface changes before the call sites that use them. Refactor before feature on top of the refactor. Tests in the same commit as the code they cover, unless the test is a pre-existing characterization test added separately.

---

## Reset to a known starting point

```bash
git reset            # unstage everything; working tree untouched
```

This is the safe baseline before stage-per-group: starting from zero staged paths means every `git diff --cached` reads as the exact contents of the commit you are about to write.

---

## Per-group staging — file-level (default)

```bash
git add path/to/file_a.py path/to/file_b.py
git diff --cached    # verify what is staged
git commit -F .git/commit-msg-1.txt
```

Use a temp message file (heredoc into `.git/commit-msg-N.txt`) so multi-line messages survive shell quoting — avoid `-m` for anything with a body. The pattern:

```bash
cat > .git/commit-msg-1.txt <<'EOF'
Subject impact-led, ~50 chars

Body paragraph naming the specific reason: incident, contract,
constraint, or decision. Wrap at ~72.
EOF
git commit -F .git/commit-msg-1.txt
rm .git/commit-msg-1.txt
```

Increment `N` per commit (`commit-msg-2.txt`, etc.) so a botched commit's message is recoverable from disk until you delete it.

---

## Per-group staging — hunk-level (rare)

```bash
git add -p path/to/mixed_file.py
```

Hand control to the user. The skill does not drive the interactive hunk-selection prompt (`y/n/q/a/d/s/e/?` and friends) — only the human can judge hunk boundaries inside a file they wrote. After the user finishes the interactive session, the skill resumes with `git diff --cached` to verify the staged hunks match the intended group, then commits via the heredoc pattern above.

---

## Stashing unrelated changes

```bash
git stash push -m "unrelated: <one-line>" -- path/to/unrelated.py
# for an untracked (brand-new) file:
git stash push -u -m "unrelated: <one-line>" -- path/to/new_file.py
# ... do the focused commits ...
git stash pop      # bring it back, then handle as its own commit or leave for later
```

Flag order matters: `-m "<msg>"` BEFORE `--`. Everything after `--` is treated as a pathspec, so `git stash push -- <path> -m "<msg>"` silently treats `-m` and the message as paths and fails with `pathspec did not match any file(s)`.

Untracked files require `-u` / `--include-untracked` — without it, `git stash push -- <newfile>` errors out (pathspec mismatch) and the file stays on the workbench while the stash claims success only for known paths.

Stash is preferred over commit when the changes do not belong on this branch at all: leftover debug prints, exploratory edits for a different feature, or secrets that crept in during local testing. Committing them just to "save" them pollutes the history; stash keeps them on the workbench without rewriting it.

---

## Recovering from a botched stage

- `git restore --staged <path>` — un-stage a file. Working tree untouched. Use this when you staged the wrong path.
- `git stash` — rescue valve. Stash everything (staged + unstaged) as a safety net, then re-do staging from a clean slate. Recover with `git stash pop` when the new staging is verified.
- `git restore <path>` — **destructive**: discards working-tree changes on that path with no undo (equivalent to the older `git checkout -- <path>`). Last resort. Require explicit user confirmation naming the path before running.

---

## When to escalate

If the working tree has more than 6 distinct concerns, or if a few files cross-cut every group so that no clean stage-per-group exists, do not try to split it into commits — suggest splitting into multiple PRs or branches instead. Defer to the `pull-request` skill's "split the PR" guidance and surface the recommendation to the user before continuing.
