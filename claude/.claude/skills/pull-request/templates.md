# When the repo has no PR template

**Stop and return to `SKILL.md` if any of these files exist in the repo:**
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/pull_request_template.md`
- `.github/PULL_REQUEST_TEMPLATE/*.md`
- `docs/pull_request_template.md`
- `PULL_REQUEST_TEMPLATE.md` (root)

If any exists, *that* file is the source of truth, and this file should not be loaded. Re-check Step 1 of `SKILL.md`.

---

## Sizing the description to the PR

Pick the structure that matches the change. Size is judged by *cognitive scope* (concepts a reviewer must hold in mind) — not by line count alone. A 500-line dependency bump is small; a 50-line auth change is medium.

**Binary tier-up question:** "After my current draft, is there a *second* sentence that adds information the reviewer cannot get from the diff (a constraint, a contract, a deploy plan, a rollback)?"
- **No** → you're in the smaller tier. Stop.
- **Yes** → step up one tier and add that sentence in the appropriate section.

Use the LOC ranges as a sanity check, not a deciding rule. The question above wins when they disagree.

### Small — single fix, single concept (typically <100 LOC, 1–3 files)

A short paragraph is enough. No headers needed.

> Stops the 'random logout' bug — expired tokens now return 401, so the SDK refresh flow works. Previously the broad `catch` in `validateToken` returned 500 on any failure, which the SDK couldn't recover from. New unit test in `auth.test.ts` covers the expiry case; manually verified with an expired JWT against local dev.

**Required content:** Outcome + Cause + how to verify, in prose. That's it.

### Medium — one logical change touching several places (100–500 LOC, multiple files)

Either a longer paragraph, or 2–3 short sections — match the repo's house style. If unsure, lean toward the simpler form.

```
**Outcome:** <1–2 sentences — what changes for users / the system>

**Cause:** <1–3 sentences — the specific reason this was necessary now>

**Verification:** <how the reviewer confirms; tests added; manual steps; dashboards>
```

### Large — refactor with behavior change, or feature spanning multiple modules (>500 LOC)

Add a risk / rollback section.

```
**Outcome:** <what changes>

**Cause:** <why now>

**Approach (only if non-obvious):** <a sentence on key design decisions a reviewer should know before reading the diff>

**Verification:** <tests + manual + monitoring>

**Risk and rollback:** <what could break; what to watch; how to revert safely>
```

Resist the urge to use this structure for medium or small PRs — the ceremony itself adds load and trains reviewers to skim.

### Migration / data / infrastructure — any size

Always include a risk and rollback section, even for "small" changes. Always specify what to watch *post-deploy* and what threshold should trigger a rollback.

### Chore — dependency bump, formatting, lint config

One line stating the change, one line stating the verification. Done.

> Bumps `axios` from 1.6.0 to 1.7.2 for the cookie-parsing fix in 1.7.x. No call-site changes; existing integration tests pass. No behavioral change expected.

---

## What to leave out when the repo has no template

A repo with no template usually has no enforced section structure. Resist:

- Inventing `## What`, `## Why`, `## How`, `## Testing`, `## Risk` for a small bugfix.
- Adding `## Screenshots` sections when there is nothing visual to show.
- Copy-pasting a generic template you remember from another repo.

If recent merged PRs (see `gathering.md` for the command) use sections, use sections. If they're prose, write prose. **Match the team you are reviewing for.**

---

## Things to *always* include regardless of size

Even the smallest PR description should:

- State the **Outcome** in the first sentence (what changes for users or the system).
- Name the **Cause** somewhere (specific incident, contract, constraint, or decision — not "improvement").
- Make the change **verifiable** by the reviewer (one test name, one curl command, one dashboard link — whichever is most direct).

The structure can shrink to a single paragraph. The three layers cannot.
