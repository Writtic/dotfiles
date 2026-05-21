# PR description — bad → good transformations

**Stop and return to `SKILL.md` if you are reading this without a specific failed self-verification check and a non-obvious fix.** This file is grouped by check number — find the one matching your failure mode and apply the transformation.

---

## Check 1 — Diff-rewriting (deletable sentences)

### Bad

> This change:
> - Extracts token validation into a pure `tokenValidator.validate()` function.
> - Rewrites `validateToken()` in the auth middleware to branch on the result.
> - Removes the broad `catch` that was masking expiry as a server error.
> - `AuthService` now uses the same validator instead of decoding inline.

**Why it fails:** every bullet is a sentence-by-sentence read of the diff. A reviewer scrolling the file tree learns the same thing in less time — and now has two copies of the same information to reconcile.

### Good

> Expired access tokens now return 401 with `WWW-Authenticate: Bearer error="invalid_token"`, so the client SDK's documented refresh-on-401 flow finally works end-to-end. Previously the middleware's broad `try/catch` swallowed expiry into a 500 — the SDK gave up and dumped the user to the login screen.

**What changed:** the description now states the *consequence* (refresh flow works, no more forced re-login) and the *prior failure mode* (500 instead of 401). The structural changes (new validator helper, discriminated union) are invisible — and that's fine, because the diff shows them.

---

## Check 2 — Outcome-first (the lead matters)

### Bad first sentence

> "Refactor the auth middleware to extract token validation into a separate pure function and add a discriminated union type for the result."

**Why it fails:** the reviewer learns *what kind of code change happened* but not *what changes for anyone using the system*. They have to keep reading to find the point.

### Good first sentence

> "Stops the 'random logout' bug that hit 30+ users last week (support tickets #890, #892, #899) — expired tokens now trigger the SDK refresh path instead of crashing the request with a 500."

**What changed:** outcome (no more random logouts) and stakes (30+ users, specific tickets) in the lead. The structural refactor is supporting detail, not the headline.

---

## Check 3 — Concrete cause (the real "why")

### Bad

> "Why: cleaner separation of concerns and easier to test."

**Why it fails:** every refactor PR ever could use this sentence. It justifies nothing specifically. The reader cannot tell whether the change was worth the diff size, whether it should be merged before or after some other work, or whether it is fixing a problem or pre-empting one.

### Better

> "Why: `validateToken`'s broad `try/catch` was returning 500 on any failure, including expired tokens. The SDK's documented contract is to refresh on 401 — a 500 breaks that contract, and 30+ users got bounced to the login screen last week (#1247, support tickets #890/#892/#899). The pure validator helper is a side effect of fixing this cleanly; the fix itself is the explicit 401 branch."

**What changed:** the cause now names a specific behavior (broad catch returning 500), a specific contract being broken (SDK 401-refresh), and specific stakes (30+ users last week, three tickets). The refactor's value is reframed as *enabling the fix*, not the goal itself — a reviewer can now judge whether the refactor was the right shape.

---

## Check 4 — Verification (how does the reviewer confirm)

### Bad

> "Tested locally."

**Why it fails:** the reviewer cannot reproduce. They cannot tell whether "locally" meant unit tests, a manual curl, or staring at the code.

### Good

> **How to verify:**
> - `npm run test:auth` — covers expired / malformed / bad-signature / happy paths.
> - Manual: `AUTH_MOCK=false npm start`, then `curl -i -H 'Authorization: Bearer <expired-jwt>' localhost:3000/api/me` → expect `401` with `WWW-Authenticate` header.
> - After deploy, watch the 401 rate on `/api/*` for ~30 min. A 2–3% uptick is expected (the fix is working). A >10% uptick means something unrelated regressed — page on-call.

**What changed:** every step is reproducible. Post-deploy monitoring includes the *expected* signal *and* the threshold for alarm.

---

## Check 5 — House style match

### Bad in a "short prose" repo

Five `##` sections, eight bullet groups, 400 words — in a repo where the last five merged PRs are 2–3 sentences of prose each.

**Why it fails:** reviewers used to scanning 2–3 sentences now have to parse a wall. The structural mismatch itself adds cognitive load before any content is read.

### Good in the same repo

> Expired tokens now return 401 instead of 500, fixing the SDK refresh flow that has been bouncing users to login (#1247, ~30 users last week). The change is mostly the explicit 401 branch in `validateToken`; the new `tokenValidator` helper exists so the expiry / malformed / signature cases can be unit-tested without spinning up Express. Verified locally and via the new tests; will watch the 401 rate on `/api/*` after deploy.

**What changed:** all three layers (Outcome, Cause, Verification) survive, but in matching prose form. Length and tone now match the repo norm.

### Bad in a "structured sections" repo

A single dense paragraph, in a repo whose template uses `## Summary`, `## Context`, `## Testing`, `## Risk` sections.

**Fix:** convert to that section structure. Do not invent new sections.

### Bad: literal-translating English convention labels into Korean

> **왜 이제**: `~/.claude/`는 작은 사용자 config과 무거운 런타임 상태가 섞여 있어 단순 stow 불가능…

**Why it fails:** "왜 이제" is a word-for-word rendering of "Why now?" — a natural English PR convention. In Korean it lands awkwardly: "이제" ("now") collocates with "왜" to imply *belatedness* ("why only now?", "why are you bringing this up at this point?"). A native reader trips on the label before reading the content.

### Good

> **배경**: `~/.claude/`는 작은 사용자 config과 무거운 런타임 상태가 섞여 있어 단순 stow 불가능…

**What changed:** "배경" (background) is the phrase a Korean engineer would actually write for the same role. The label disappears from the reader's foreground — exactly what a section label is supposed to do. Same principle: "Outcome" → "변경 사항" / "효과" (not "결과물"); "Verification" → "검증" / "확인 방법"; "Risk and rollback" → "리스크와 복구계획". When in doubt, ask: *what would a native engineer write to mean this?* — not *what's the dictionary equivalent?*

---

## A meta-anti-pattern: mixing concerns

If a PR genuinely does N independent things (refactor + feature + dependency bump), the description bloats and the diff balloons. The fix is **not** a longer description — split the PR. Description quality is a symptom of PR scope; treat the scope first.
