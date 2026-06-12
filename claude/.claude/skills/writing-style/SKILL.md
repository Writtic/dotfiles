---
name: writing-style
description: Use when writing any prose that ships to a person: PR descriptions, commit messages, Linear/Jira issues and comments, design notes, status updates, READMEs, docs. Strips AI-writing tells (em-dash, contrastive negation, smell words, marketing adjectives) and enforces plain, concrete, fact-based phrasing. Owns voice only; the invoking context owns format. Load alongside pull-request / git-commit / the /create-pr and /linear commands.
---

<!--
  Single source of truth for the house writing voice. CLAUDE.md, the
  /create-pr and /linear commands, and the pull-request / git-commit
  skills all point here instead of restating these rules, so the voice
  stays consistent and edits land in one place. If you change a rule,
  change it here.
-->

# Writing Style (house voice)

## Scope: voice, not format

This skill governs how sentences read: word choice, sentence shape, honesty. It does **not** set document structure. Format is owned by the invoking context:

| Context | Owns the format |
|---|---|
| commit messages | `git-commit` skill (detect and match the repo's commit style) |
| PR descriptions | `pull-request` skill (template detection, then house style) |
| `/create-pr` | Linear PR template + 해요체, no headers |
| `/linear` | issue / comment structure |

When this skill's generic format defaults (bottom) disagree with a detected house style or the invoking context, the house style wins. Never reshape a Korean 해요체 PR into `## Summary / ## Changes` just because this skill names that template.

## Core principle

Write so a tired reviewer understands on the first read with no decoding. Plain and concrete beats compressed and clever. Record facts; do not sell the change.

Two failure directions, both banned:

- **AI-slop**: em-dash drama, smell words, marketing adjectives, reflexive three-item lists, weighty closing lines.
- **Jargon-compression**: cramming a causal chain into one internal term so the reader pays the decode cost.

The fix for one must not push you into the other. Terse does not mean cryptic.

## Hard bans: structural (top priority)

- **대조 부정문** (contrastive negation): "단순히 X가 아니라 Y", "X에 그치지 않고", "not just/only/merely X, but Y".
- **은유 공식** (metaphor formula): "X는 Y의 Z다", "X is the Y of Z".
- **격언형 마무리** (aphoristic ending): no meaningful one-liner tacked on at the end.
- **연속 단문 드라마**: no chain of short punchy fragments for dramatic effect.
- **3개 나열** (tricolon habit): avoid the reflexive three-item list.
- **em-dash (—)**: banned. Split with a comma or a period instead.

## Hard bans: lexical

- **자기과시 형용사**: clean, elegant, powerful, robust, seamless, comprehensive, 강력한, 우아한.
- **smell 단어**: delve, tapestry, realm, landscape, leverage, intricate, pivotal, crucial, underscore, foster, harness, unlock, showcase, myriad.
- **군더더기 전환어**: Moreover, Furthermore, Notably, "It's worth noting", "It's important to note".
- **한국어 hedging 최소화**: drop unnecessary "~할 수 있습니다", "~의 정수", "~을 넘어서".
- **마케팅 톤**: do not promote the change. State what it does.

## 콜론(`:`)과 이모지 shortcode

Slack·GitHub·Linear·Obsidian 등 `:shortcode:`를 이모지로 렌더하는 표면에서는 양옆이 붙은 `:단어:`가 이모지로 바뀔 수 있다.

- 콜론을 남발하지 않는다. 문장 부호로 꼭 필요할 때만 쓴다.
- 쓸 때는 콜론 뒤에 공백을 둔다 (`라벨: 본문`). shortcode는 내부에 공백을 담지 못하므로, 공백이 있으면 이모지로 해석되지 않는다.
- 단어를 콜론으로 감싼 `:단어:` 형태를 피한다.

## Plain and concrete

- 내부/영어 jargon을 일상어·구체 명사로 푼다: `floor` → "제한 변수", `ledger` → "in-flight 정보가 적재된 Redis", admission control/budget → "제출 조건", "과다 admit" → "과한 제출".
- 인과를 한 단어로 압축하지 말고 단계로 푼다: "buffer가 매 cycle 재충전" 대신 "buffer 조건이 항상 충족 → Job 무한 submit → 큐 제출 조건 무시".
- 코드 식별자는 backtick으로 유지하되 옆에 일상어 설명을 붙인다.
- 깊은 기술 설명을 요청받으면(예: "정확히 무슨 뜻이냐") 정밀함을 유지한다. 요약·설명문에서는 평이함을 우선한다.

## 한국어 산문 다듬기

한국어 문서(테크스펙·설계 노트·이슈)는 초안부터 아래로 맞춘다.

- **종결어미**: 개요·배경·목표처럼 독자가 먼저 읽는 산문은 해요체("~해요"). 실행 절차·단계 목록·체크리스트는 "~한다"체를 둬도 된다. 개요는 부드럽게, 절차는 건조하게.
- **괄호 부연 최소화**: 흐름을 끊는 보충 괄호를 뺀다. `prefix(KV) cache` → `prefix cache`, `라우터 변경 없이(round-robin 유지)` → `라우터 변경 없이`.
- **불릿은 한 항목 한 메시지**: 효과 설명 꼬리나 둘째 문장을 잘라 한 줄로 만든다. "이 문서를 정리한다" 같은 메타성 항목은 지운다.
- **영어 번역체를 우리말로**: 코드 식별자는 backtick으로 두되, "~을 만들다" 같은 직역 동사를 자연스러운 우리말로. `cross-pod 적중을 만들` → `Pod 간 prefix cache 적중률을 높일`.
- **담백하게**: 강조용 따옴표("…")로 힘주지 말고 평문으로 쓴다. 비유적 단어("함정")는 중립어("부분")로.
- **짧은 두 문장은 자연스럽게 잇는다**: `논의했어요. 하지만 ~` → `논의했지만, ~`.
- **참조는 텍스트가 아니라 링크**: 이슈 번호·페이지명을 적을 때 실제 링크/멘션을 걸어 독자가 바로 이동하게 한다.

## Writing principles

- diff와 변경된 파일을 근거로만 쓴다. 추측이나 일반론은 더하지 않는다 ("probably because…" 금지).
- 길이 상한을 지킨다: 불릿당 한 줄, 설명은 3문장 이내.
- "polish", "enhance", "engaging" 같은 목표어를 따르지 않는다. 목표는 정확함과 간결함이다.
- 기존 톤을 따른다 (`git log`, 최근 PR 참고).

## Generic format defaults (fallback only)

Use these **only** when no house style is detected and the invoking context sets no format. In practice that is rare: commits, PRs, `/create-pr`, and `/linear` all carry their own format, and those win over the table below.

commit-message:
- Conventional Commits: `type(scope): subject`
- subject 명령형, 50자 이내, 끝에 마침표 없음
- body는 무엇/왜만, 72자에서 줄바꿈
- 마크다운 서식(헤더, 볼드, 이모지) 없음

pull-request:
- `## Summary` / `## Changes` / `## Test plan`
- 각 불릿 동사로 시작, 한 줄 유지
- 헤더 외 추가 서식 최소화

## Post-filter (run before showing output)

정규식으로 검출하고, 걸리면 그 문장을 **재작성**한다 (완화가 아니라 재작성):

- em-dash: `—` (그리고 dash로 쓰인 `--`)
- 이모지 shortcode 충돌: `:[^\s:]+:` (콜론으로 단어를 감싼 형태. 콜론 뒤 공백으로 회피)
- 대조 부정문: `not (just|only|merely)\b.*\bbut\b`, `단순히 .*아니라`, `에 그치지 않`
- 은유 공식: `\bis the\b .* \bof\b`
- 금지 단어: 위 lexical 목록 (대소문자 무시)

## Red flags: stop and rewrite

- "조금 밋밋하니 마지막에 한 줄 멋지게 붙이자."
- "여기엔 em-dash가 더 어울려."
- "이 한 단어면 다 설명돼." (읽는 사람이 해독해야 한다는 뜻이다)
- "조금 더 다듬어서 인상적으로 들리게 하자."
- "전환어 하나 넣으면 매끄러워질 텐데."
