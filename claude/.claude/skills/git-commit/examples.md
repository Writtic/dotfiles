# Commit — bad → good transformations

**Stop and return to `SKILL.md` if you are reading this without a specific failed self-verification check and a non-obvious fix.** This file is grouped by check number — find the one matching your failure mode and apply the transformation.

---

## Check 1 — Mixed-concerns

### Bad

A single working tree contains a new response cache in `/api/items` and an unrelated 500-on-expired-token fix in `auth/validateToken.ts`. The agent runs:

```
git add -A
git commit -m "Add caching and fix auth bug"
```

**Why it fails:** the reviewer is forced to evaluate two independent decisions in one. They might love the auth fix and want the cache benchmarked first, but the commit forces an all-or-nothing call. A revert to back out the cache also pulls out the auth fix.

### Good

Two commits, staged separately:

```
Add response cache to /api/items
```

```
Stop 500 on expired tokens by returning 401
```

The reviewer can accept the auth fix immediately and defer (or reject) the cache pending benchmarks. Each commit reverts cleanly.

**What changed:** per-concern split; each commit holds one decision the reviewer can act on in isolation.

---

## Check 2 — Dependency-order

### Bad

Commit A adds a call site that uses `formatRetryHeader()`; Commit B introduces `formatRetryHeader()` itself. If a bisect or cherry-pick lands A without B, the tree fails to build — and nothing in the plan warns that A presumes B exists.

```
A: Wire retry header into 502 response path
B: Add formatRetryHeader helper
```

**Why it fails:** reordering or partial cherry-pick breaks the tree; the reviewer cannot trust that individual commits are self-consistent. Bisect points at A but the actual cause is "A landed before B."

### Good

Reverse the order, and call the dependency out in the plan presented at Step 6:

```
A: Add formatRetryHeader helper (with unit test)
B: Wire retry header into 502 response path
```

> Plan note: **Commit 2 depends on Commit 1** — `formatRetryHeader` must exist before the call site compiles.

**What changed:** dependency reversed so each commit builds on top of the previous; the cross-commit dependency is named explicitly in the plan so the reviewer is not surprised.

---

## Check 3 — Unrelated-changes

### Bad

While debugging the auth fix, the agent dropped a `console.log("debug")` into `validateToken.ts` and forgot to remove it. The diff for the focused auth-fix commit now includes the stray line, and `git add -A` sweeps it in:

```diff
+ console.log("debug");
  if (!token) return res.status(401).json({ ... });
```

**Why it fails:** noise leaks into history; the reviewer wastes attention on the stray line wondering whether it is intentional, and a later revert of the auth fix pulls the debug `console.log` back into the tree.

### Good

Step 5 flags the unrelated line. The skill recommends quarantining it before the focused commit:

```bash
git stash push -m "debug log to discard or revisit" -- src/auth/validateToken.ts
# re-apply only the real edits, then commit
```

The commit message and diff now contain only the auth fix.

**What changed:** in-flight noise quarantined to the stash; the commit stays focused on its one concern.

---

## Check 4 — Subject impact

### Example 4a — English repo

#### Bad

```
Refactor validateToken to use discriminated union
```

**Why it fails:** describes the mechanism (what kind of code change happened), not the effect anyone reading the log cares about. A reader scanning `git log --oneline` learns the shape of the refactor but not why it was worth doing.

#### Good

```
Return 401 on expired tokens so SDK refresh works
```

**What changed:** lead with the observable behavior change; the mechanism (discriminated union) is for the diff to show. The subject now answers "what shifts for the user / system?" — not "what kind of code edit was this?".

### Example 4b — Korean repo

#### Bad

```
validateToken 함수 리팩토링
```

**Why it fails:** 같은 함정 — 구현 변경의 *형태*만 설명한다. reviewer는 *효과*가 궁금하다. `git log` 한 줄만 보고는 왜 이 커밋이 필요했는지 알 길이 없다.

#### Good

```
토큰 만료 시 401 반환하여 SDK 갱신 흐름 복구
```

**What changed:** subject가 "사용자/시스템에 무엇이 바뀌는지"로 시작한다. 한국어에서도 같은 원칙 — 메커니즘(`validateToken` 리팩토링)은 diff가 보여주므로 subject 자리를 차지할 이유가 없다.

---

## Check 5 — Body-why

### Example 5a — generic justification

#### Bad

```
Refactor token validation

Cleaner separation of concerns and easier to test.
```

**Why it fails:** every refactor commit ever could use this sentence. It justifies nothing specifically — the reader cannot tell what problem prompted the work, what would break if it were reverted, or whether the shape of the refactor is the right one for the cause.

#### Good

```
Return 401 on expired tokens so SDK refresh works

The middleware's broad try/catch turned expiry into a 500 — the SDK's
documented refresh-on-401 path never triggered, so 30+ users got bounced
to the login screen last week (#1247, support tickets #890/#892/#899).
```

**What changed:** specific incident (last week's bouncing), specific contract being broken (SDK refresh-on-401), specific stakes (30+ users) with linkable references (`#1247`, three ticket IDs). A reviewer can now judge whether the fix is the right shape for this exact failure.

### Example 5a-ko — Korean repo

#### Bad

```
토큰 검증 리팩토링

관심사 분리가 깔끔해지고 테스트가 더 쉬워짐.
```

**Why it fails:** 어떤 리팩토링 커밋에도 적용 가능한 일반론. 어떤 문제가 이 작업을 촉발했는지, revert 하면 무엇이 깨지는지, 리팩토링의 형태가 그 원인에 맞는지 — 어느 것도 알 수 없다.

#### Good

```
토큰 만료 시 401 반환하여 SDK 갱신 흐름 복구

미들웨어의 광범위한 try/catch 가 만료를 500 으로 바꿔놓아,
SDK 의 문서화된 refresh-on-401 경로가 트리거되지 않았다.
지난 주 30+ 명의 사용자가 로그인 화면으로 튕겼다
(#1247, 지원 티켓 #890/#892/#899).
```

**What changed:** 구체적 사건(지난 주 튕긴 사용자), 구체적 계약 위반(SDK refresh-on-401), 구체적 영향 규모(30+ 명) + 추적 가능한 레퍼런스(`#1247`, 티켓 ID 3개). 리뷰어가 "이 수정의 형태가 이 실패에 맞는가"를 판단할 수 있다. 한국어에서도 같은 원칙 — 사건 / 계약 / 제약 / 결정 중 하나를 이름으로 부른다.

---

### Example 5b — body restates subject

#### Bad

```
Bump axios to 1.7.2

Bumps the axios package from 1.6.0 to 1.7.2.
```

**Why it fails:** the body adds no information beyond the subject. It restates the version delta the subject already shows, wasting the reader's scroll and contributing nothing the diff does not.

#### Good

```
Bump axios to 1.7.2 for cookie-parsing fix
```

(No body — the change is self-evident once the reason is folded into the subject.)

**What changed:** collapsed into a single self-contained subject; the *reason* (cookie-parsing fix) replaces the redundant body. When the subject can carry the *why* in a few words, the body should disappear entirely.

### Example 5b-ko — Korean repo

#### Bad

```
axios 1.7.2로 업그레이드

axios 패키지를 1.6.0에서 1.7.2로 올림.
```

**Why it fails:** body 가 subject 의 버전 델타를 다시 풀어 쓸 뿐, 리뷰어에게 새로 알려주는 정보가 없다. 스크롤 한 줄을 낭비하면서 diff 가 이미 보여주는 사실을 반복한다.

#### Good

```
axios 1.7.2로 업그레이드 — 쿠키 파싱 버그 수정 포함
```

(body 없음 — *왜*가 subject 에 흡수되었으므로 본문이 더 할 말이 없다.)

**What changed:** 단일 self-contained subject 로 압축; 중복된 body 대신 *이유*(쿠키 파싱 버그 수정)가 subject 자리를 차지한다. subject 가 *why*를 몇 단어로 담을 수 있을 때 body 는 사라지는 게 맞다.

---

## Check 6 — House-style + attribution

### Example 6a — attribution trailer

#### Bad

A commit message ending in:

```
fix: return 401 on expired tokens

The middleware's broad try/catch turned expiry into a 500.

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
```

**Why it fails:** Hard rule 1 violation. The default Bash-tool prompt suggests this trailer; this skill explicitly strips it. AI-attribution lines pollute shared history and have no business being there.

#### Good

The same message, trailer stripped before invoking `git commit -F`:

```
fix: return 401 on expired tokens

The middleware's broad try/catch turned expiry into a 500.
```

**What changed:** trailer removed; no AI-attribution lands in shared history. The commit body still carries the real *why*.

### Example 6b — style mismatch

#### Bad

In a repo whose last ten commits all use lowercase `fix:` / `feat:` prefixes with English imperative subjects, the agent writes:

```
Fix: 토큰 만료 처리 수정함
```

**Why it fails:** language switched mid-history (Korean subject in an English-history repo); the capitalized `Fix:` does not match the team's lowercase `fix:`; the tense (`수정함`, past-tense nominalization) does not match the imperative norm.

#### Good

```
fix: return 401 on expired tokens
```

**What changed:** matches the inferred house style — same prefix casing (`fix:`), same language (English), same tense (imperative). Step 2's house-style detection caught all three drifts in one pass.

---

## Meta-anti-pattern: too many commits

If a single feature naturally fans out into eight or more commits, the skill should suggest revisiting the *scope* of the working tree rather than aggressively splitting further. A 12-commit plan for one feature is usually a signal that the feature itself is doing too much — the fix is to land a smaller slice first, not to subdivide the same diff into ever-thinner cuts. Treat commit count the same way the `pull-request` skill treats PR size: a symptom of scope, addressed at the scope layer.
