# Information gathering via `gh`

**Stop and return to `SKILL.md` if none of these conditions apply:**
- Layer 1 (conversation + `git log <base>..HEAD` + branch name) left the Outcome or Cause ambiguous.
- The branch name or a commit message references `#<n>` and you have not read that issue.
- You are editing an existing PR and need its body, comments, or check status.
- You need to detect the repo's house language and style.

If none of those is true, this file is not needed for the current PR.

---

## Layer 2 — read these first, when applicable

### Linked issue (mandatory whenever `#<n>` appears in branch or commits)

`<base>` in the commands below = the branch you'll merge into (usually `main` or `master`). If unsure, run `git merge-base HEAD origin/main` and use the resulting commit SHA, or substitute `origin/main` directly.

```bash
# Extract any issue references from branch name and commit messages
git rev-parse --abbrev-ref HEAD                              # branch name
git log --format=%B <base>..HEAD | grep -oE '#[0-9]+' | sort -u

# Read each referenced issue in full
gh issue view <n>
```

The linked issue almost always contains the real "why" — incident reports, user impact, business constraints, acceptance criteria — that the diff cannot encode. If you find one, treat its content as primary source for the **Cause** layer.

### House language and style (run once per repo)

```bash
gh pr list --state merged --limit 5 --json title,body --jq '.[] | {title, body}'
```

Skim the bodies and produce a 5-line summary (do not paste the raw JSON into your reasoning):

- **Language**: the most-used language in the 5 most recent merged PRs. Tie or mixed → ask the author.
- **Structure**: prose vs. markdown sections. Match it.
- **Length**: average word count (order of magnitude — 50? 200? 500?). Match it.
- **Title prefixes**: `fix:`, `feat:`, `refactor:`, `chore:` (Conventional Commits) — adopt if present.
- **Ambiguities**: anything you cannot infer with confidence — ask one question before drafting.

For non-English repos, also note the **tense convention** in titles (Korean often uses noun-ending like "...수정" / "...개선"; Japanese often "...する" / "...対応"). The title guidance in `SKILL.md` Step 5 is English-centric — match what you see, not the English imperative.

### Fetch a remote template when local clone may be stale

```bash
gh api repos/{owner}/{repo}/contents/.github/PULL_REQUEST_TEMPLATE.md \
  --jq '.content' | base64 -d
```

Try the alternative paths (`pull_request_template.md`, `PULL_REQUEST_TEMPLATE/*.md`, `docs/pull_request_template.md`, root `PULL_REQUEST_TEMPLATE.md`) if the first 404s. If a template is fetched this way, treat Step 1 in `SKILL.md` as having succeeded — that file is now the source of truth.

---

## Edit-mode — improving an existing PR

When called to *edit* rather than create, run **exactly** this command — do not drop fields, do not pipe through `head`, do not redirect with `2>&1 | head -N`:

```bash
gh pr view <n> --json title,body,comments,reviewRequests
```

`title,body` is the **current PR state you are revising** — without these you cannot diff the old vs. new body before re-confirming with the user. Adding `reviews` to the field list is fine when you need check status; truncating the output is not — `body` can easily exceed 50 lines and `head` will silently drop the tail.

Then:

- Read every review comment. Note push-back, accepted suggestions, and unresolved threads.
- Reflect resolved decisions in the updated description rather than leaving the reviewer to re-derive them.
- Preserve still-accurate content. Do not rewrite for its own sake.
- Re-run all five self-verification checks against the updated version.

---

## Pre-submit — surface known failing checks

```bash
gh pr checks <n>           # omit <n> for the current branch's PR
```

If a check is failing for reasons unrelated to this PR, name the specific failure in the description so the reviewer is not distracted by it. If a check is failing because of this PR and is expected to pass after a fix, do not yet open / update the PR — fix first.

---

## Layer 3 — rarely needed; ask before using

```bash
gh pr view <n> --json reviewRequests,assignees    # tailor emphasis to a specific reviewer
gh api repos/{owner}/{repo}/issues/<n>/timeline   # incident threads, related PRs
gh pr list --search "linked:<n>"                  # related PRs
```

Skip these unless the user asks for them or a specific question requires them. They tend to produce noise more often than signal.

---

## When you still cannot determine the cause

After gathering, if Outcome or Cause is still ambiguous, ask the author **one focused** question. Examples:

- "I see the diff and the four commits but the 'why' is not clear from branch name or commit messages — was this prompted by an incident, a user request, or planned cleanup?"
- "No linked issue and the repo has no obvious language convention — should this description be in English or 한국어?"
- "Recent merged PRs use prose; this one is large enough that I'd lean toward a `## Risk` section. OK to break style here?"

Ask one question, take the answer, and proceed. Do not keep digging.
