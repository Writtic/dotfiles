---
name: pull-request
description: Use when creating or editing a pull request description — running gh pr create, gh pr edit, finalizing a branch before opening a PR, or asked to write or improve PR body text.
---

<!--
  This skill is committed in-tree to deliberately shadow any upstream
  `pull-request` skill that a Claude Code plugin may later ship. If both
  load, this local copy takes precedence. If a future plugin update
  changes that resolution order, rename this skill (e.g. to
  `pull-request-house-style`) to keep the override intentional rather
  than coincidental.
-->

# PR Description

## Preconditions

Code, commits, and any source files are **final** before this skill is invoked. If you notice that README, settings, or any other source still needs to change to match the PR, finish that work *before* drafting — do not interleave implementation edits with description writing. This skill writes the description only.

## Core principle

GitHub already shows the file list, line counts, and diff. Your description carries everything a reviewer cannot extract from those: the user-visible outcome, the cause that justified the change, and how someone confirms it works.

**Hard rule 1:** if a sentence in the description can be reproduced by reading `git diff`, delete it.

**Hard rule 2:** never append a "Generated with [Claude Code](https://claude.com/claude-code)" footer (or any equivalent AI-attribution line) to the description. The default Bash-tool example for `gh pr create` includes this line — strip it. Commit messages use a `Co-Authored-By` trailer; PR descriptions do not get one.

## When to use / not

**Use:** writing or editing any PR body, on any platform that surfaces a description.

**Do not use:** commit messages (these describe what), branch naming, in-code comments.

## Mode — create vs. edit

Before Step 1, decide which mode you are in:

- **Create** — branch has no PR yet. Default mode. Proceed to Step 1.
- **Edit** — a PR already exists (you ran `gh pr edit`, the user said "update the description", or `gh pr view` returned a body). **Load `gathering.md` first** for the `gh pr view --json title,body,comments,reviewRequests` workflow before doing anything else. Then return here for Step 1.

The rest of this skill is the same in both modes; the difference is that edit-mode requires reading existing review comments and preserving still-accurate content before applying the five checks.

## Step 1 — Template detection (always first)

Check these paths in order and stop at the first hit:

1. `.github/PULL_REQUEST_TEMPLATE.md`
2. `.github/pull_request_template.md`
3. `.github/PULL_REQUEST_TEMPLATE/*.md` (multi-template repo — pick by PR type)
4. `docs/pull_request_template.md`
5. `PULL_REQUEST_TEMPLATE.md` (repo root)

If any exists → that file is the source of truth. Fill every required section. **Do not load `templates.md`.**

If nothing exists → load `templates.md` for size-adaptive structure guidance.

## Step 2 — Three layers every description must answer

| Layer | Question | Primary source |
|---|---|---|
| **Outcome** | What changes for the user or the system after this merges? | conversation, linked issue |
| **Cause** | Why was this necessary *now*? What incident, constraint, or decision drove it? | linked issue, conversation, commit messages |
| **Verification** | How does the reviewer confirm it works? | tests added, manual steps, dashboards, screenshots |

Lead with **Outcome**. The first one or two sentences must let a reviewer answer *what does this PR do and why does it matter* without scrolling.

## Step 3 — Information gathering (lazy)

**Layer 1 — always check, never skip:**
- Current conversation context (strongest signal — you were there)
- `git log --oneline <base>..HEAD`
- Branch name

**Reuse Layer 1 output in later steps** — never re-run the same `git log` or `gh pr view` to "double-check" or get a broader view. If you already have `<base>..HEAD` commits, do not also run `git log -20`; if you already pulled `title,body,comments,reviewRequests` from `gh pr view`, do not call it again with different flags.

**Escalate to `gh` — load `gathering.md` — when any of these is true:**
- Layer 1 leaves Outcome or Cause ambiguous.
- Branch name or any commit message references `#<n>` (mandatory: read that issue before drafting — the real "why" lives there, not in the diff).
- You are editing an existing PR and need its body, comments, or check status.
- You need to detect the repo's house language and style.

**If still unclear after gathering → ask the author one focused question. Never invent a "why."**

## Step 4 — Match the repo's house style

Mirror the most recent 3–5 merged PRs in:

- **Language** (English / 한국어 / mixed) — the most recent 5 merged PRs are the tie-breaker. Ambiguous → ask.
- **Structure** — if recent PRs are short prose, do not impose markdown headers; if they use sections, follow that structure.
- **Length** — match the order of magnitude. Resist the urge to be more thorough than the team.
- **Section labels in non-English bodies** — do **not** literal-translate English PR-convention phrases. "Why now" → "배경" / "동기" (never "왜 이제" — Korean reads it as *belatedness*); "Outcome" → "변경 사항" / "효과" (not "결과물"); "Verification" → "검증" / "확인 방법"; "Risk and rollback" → "리스크와 복구계획". Pick the phrase a native engineer would actually write, not the word-for-word equivalent. Same principle applies to Japanese and other non-English targets. See `examples.md` Check 5 for a bad→good case.

Commands for detection are in `gathering.md`.

## Step 5 — Title

- **Imperative mood (English repos):** "Fix expired tokens returning 500", not "Fixed" or "Fixes".
- **Non-English repos:** match the tense convention of recent merged PRs (Korean often uses noun-ending like "...수정", "...개선"; Japanese often "...する" / "...対応"). If you cannot tell, ask.
- **Lead with a user / system outcome**, not the code mechanism: "Stop kicking users to login on token expiry" > "Refactor validateToken".
- **Follow repo prefix conventions** (e.g. `fix:`, `feat:`, `refactor:`) if recent merged PRs use them.
- **No ticket-only titles** (`[JIRA-123]`). Use the ticket as a body link.

## Step 6 — Self-verification (run before showing the draft to the user)

Five checks. Every "no" requires a fix.

1. **Diff-rewriting check** — could any sentence be reproduced by a reviewer reading the diff? Delete it.
2. **Outcome-first check** — do the first one or two sentences tell a reviewer what changes for users or the system?
3. **Concrete cause check** — is the "why" a specific incident, constraint, contract, or decision? "Needed", "improvement", "cleaner", "more flexible", "easier to test" all fail.
4. **Verification check** — is there a clear way for the reviewer to confirm it works (test names, manual steps, dashboards, screenshots for UI)?
5. **House style check** — language, structure, and length match the last 3–5 merged PRs?

If a check fails and the fix is not obvious → **load `examples.md`** for bad→good transformations grouped by check.

## Step 7 — Output protocol

1. Show the drafted title and description to the user.
2. Wait for confirmation or edits.
3. Only after confirmation, run `gh pr create` / `gh pr edit`.

A PR is shared state. Always confirm before creating or editing.

**Confirmation does not carry across drafts.** Earlier approvals ("looks good, go ahead") only authorize the *exact text shown at that moment*. If you revise the draft afterwards — even to fix a typo or apply your own feedback — show the new version and re-confirm. "The user said go" is not a license to push a different body than they saw.

**Before running `gh pr create` / `gh pr edit`:** double-check that the HEREDOC body does NOT end with `🤖 Generated with [Claude Code](https://claude.com/claude-code)` or any similar attribution line. The Bash tool's PR-creation example shows it; this skill forbids it (see Hard rule 2). Strip it before invoking the command.

## Anti-patterns (the most common failures)

The four highest-frequency failures, one line each. Full bad→good rewrites live in `examples.md` (load only when a check fails).

| Bad | Why it fails | Fix → |
|---|---|---|
| Bullet list reading the diff aloud (`## What\n- Extracts X...\n- Rewrites Y...`) | Duplicates the file tree; reviewer holds two copies of the same info. | `examples.md` Check 1 |
| "Why: cleaner separation of concerns / easier to test." | Could justify any refactor; justifies none specifically. | `examples.md` Check 3 |
| `Fixes #1247.` as the entire body. | Forces a context switch just to know what's being reviewed. | Lead with outcome + cause in-line; link the ticket as a reference. |
| "Tested locally." / "Watch for issues after deploy." | Not reproducible; no threshold for alarm. | `examples.md` Check 4 |

## Red flags — stop and revise

If any of these thoughts surface, the draft is failing:

- "The diff explains it"
- "Reviewers can read the linked issue"
- "It's a small PR, a description isn't needed"
- "More detail is always better"
- "I'll just dump the commit messages into the body"
- "I don't actually know the why, but I'll word it abstractly so it sounds right"
- "The user already approved an earlier draft, so I can push my revised version without re-showing it"

All of these are rationalizations for skipping the actual work. The description carries meaning the diff, the issue, and the commits each carry only partially.

## Reference files — load ONLY when the condition is met

| File | Load when | Skip when |
|---|---|---|
| `templates.md` | Step 1 found no PR template file anywhere in the repo | Any `.github/` or `docs/` template file exists — that file is the source of truth |
| `gathering.md` | Layer 1 (conversation + `git log` + branch name) leaves Outcome or Cause ambiguous, OR an issue is referenced and unread, OR you are editing an existing PR, OR you need to detect house language/style | Layer 1 alone yields a confident draft and the repo style is already evident from context |
| `examples.md` | A self-verification check failed and the fix is not obvious | All checks pass, or the fix is obvious |

**Anti-rationalization:** "let me load them all just in case" defeats the entire structure. If the condition is not met, do not load the file. These are filters, not suggestions.
