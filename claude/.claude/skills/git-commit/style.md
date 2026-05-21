**Stop and return to `SKILL.md` if you have already inferred the repo's commit style earlier in this conversation.**
Re-running detection is wasteful and may produce a different answer than the first run.

---

## Sample the recent commits

```bash
git log -10 --pretty=format:'%H%n%s%n%b%n---'
```

Read the 10 most recent commits on the default branch (usually `main` or `master`). If the working branch has diverged significantly and the user is clearly committing in that branch's style, sample from `HEAD` instead.

A parseable block looks like:

```
a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0
fix: handle expired refresh tokens on /auth/refresh

Previously the endpoint returned 500 when the refresh token had expired.
Now it returns 401 with a clear error code so clients can re-auth.

Refs #4821
---
```

One commit per block, separated by `---`. The first line after the SHA is the subject; everything until `---` is the body.

## What to infer (in this order)

- **Language**: tally subjects by character set (Latin / Hangul / mixed Latin+Hangul / CJK other). Majority wins. Tie → ask the user.
- **Prefix format**: do subjects start with `feat:`, `fix:`, `refactor:`, `chore:`, etc.? Adopt the convention if 4 of 10 or more use it. If only 1-2 use prefixes, treat as noise and skip them.
- **Subject tense**:
  - English: imperative ("Fix expired tokens") vs. past ("Fixed expired tokens"). Imperative is the Git default; only deviate if the repo clearly does.
  - Korean: noun-ending ("토큰 만료 처리 수정") vs. verb-ending ("토큰 만료 처리를 수정했다"). Noun-ending is more common in Korean tech repos.
  - Japanese: する / 対応 / 修正 patterns ("トークン期限切れに対応", "リフレッシュトークンの修正").
- **Body usage**: does the team write multi-line bodies, or are subjects standalone? When bodies appear, do they reference tickets (`#1234`), incidents, or just elaborate the subject? Match the prevailing pattern — do not add a body to a repo that does not use them, and do not omit one in a repo that consistently writes them.

## Tie-breaker question template

If language or format is ambiguous after the sample, ask the user **exactly one** question. Examples:

> "Recent commits are mixed English / Korean — should this commit be in English or 한국어?"

> "Recent commits don't use Conventional Commits prefixes consistently. Should I include one (e.g. `fix:`) or not?"

> "Recent subjects are noun-ending Korean (`...수정`, `...개선`). Continue that style?"

Ask one, take the answer, proceed. Do not keep asking — a second clarifying question on style is almost always a sign you should have just picked one and let the user correct it at Step 6.

## Non-English label note

Do not literal-translate English commit conventions. "Why now" → "배경" / "동기", not "왜 이제". Use the phrase a native engineer would actually write. The same guidance lives in `pull-request/SKILL.md` Step 4 for PR section headers — apply the same instinct here for commit body labels and inline references.

Common substitutions:

- "Background" / "Why now" → "배경", "동기"
- "Changes" → "변경 사항", "수정 내용"
- "Impact" → "영향"
- "Test plan" → "테스트", "검증"

If a label has no idiomatic equivalent, drop it rather than translate awkwardly.

## Carrying the inferred style forward

The inferred style is for the whole skill run — do not re-detect for every commit when splitting one diff into several. Carry the inferred language, prefix convention, tense, and body usage forward into the Step 6 presentation so the user sees what you settled on and can correct it before any commit lands. A one-line preface like:

> "Detected: Korean, no Conventional Commits prefixes, noun-ending subjects, bodies when changes are non-obvious."

is enough. If the user pushes back, update the cached style and re-render the proposed commits — do not re-run detection.
