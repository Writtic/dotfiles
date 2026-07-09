---
name: writing-style
description: Use when writing any prose that ships to a person: PR descriptions, PR review comments, commit messages, Linear/Jira issues and comments, design notes, status updates, READMEs, docs. Strips AI-writing tells (em-dash, contrastive negation, smell words, marketing adjectives) and enforces plain, concrete, fact-based phrasing. Owns voice only; the invoking context owns format. Load alongside pull-request / git-commit / the /create-pr, /linear, and /review-pr commands.
---

<!--
  Single source of truth for the house writing voice. CLAUDE.md, the /create-pr and /linear
  commands, and the pull-request / git-commit skills all point here instead of restating
  these rules, so the voice stays consistent and edits land in one place. If you change a
  rule, change it here. 한국어 확장 카탈로그는 references/korean.md에 있다.
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
| `/review-pr` | inline comment format (해요체, 1-2 sentences, line anchor) |

When this skill's generic format defaults (bottom) disagree with a detected house style or the invoking context, the house style wins. Never reshape a Korean 해요체 PR into `## Summary / ## Changes` just because this skill names that template.

## Core principle

Write so a tired reviewer understands on the first read with no decoding. Plain and concrete beats compressed and clever. Record facts; do not sell the change.

Two failure directions, both banned:

- **AI-slop**: em-dash drama, smell words, marketing adjectives, reflexive three-item lists, weighty closing lines.
- **Jargon-compression**: cramming a causal chain into one internal term so the reader pays the decode cost.

The fix for one must not push you into the other. Terse does not mean cryptic.

본문은 3계층이다: 공통 코어(언어 불문) → 한국어 레이어(확장은 `references/korean.md`) → 영어 레이어.

## 공통 코어: hard bans, structural (top priority)

- **대조 부정문**: "not just/only/merely X, but Y", "단순히 X가 아니라 Y", "X에 그치지 않고". `단순히 조회 최적화가 아니라 구조 개선이에요` → `조회 구조를 바꿔요`.
- **은유 공식**: "X는 Y의 Z다", "X is the Y of Z". `Redis는 이 시스템의 심장이다` → `모든 잡 상태가 Redis를 거친다`.
- **격언형 마무리**: 끝에 얹는 의미심장한 한 줄. 끝의 `좋은 도구는 보이지 않는 법이다` → 삭제.
- **연속 단문 드라마**: `빠르다. 단순하다. 안전하다.` → `빠르고 단순하며, 실패하면 재시도한다`.
- **3개 나열**: 반사적 3항 나열 금지. 항목이 실제로 3개일 때만 3개를 쓴다.
- **em-dash (—)**: 금지. `큐가 멈췄다 — lock 때문이다` → `큐가 멈췄다. lock 때문이다`.
- **가운뎃점 (`·`)**: 나열 구분자 금지, 고유명사 쌍도 예외 없다. `생성·수정·삭제` → `생성, 수정, 삭제`.

## 공통 코어: hard bans, lexical

- **자기과시 형용사**: clean, elegant, powerful, robust, seamless, comprehensive, 강력한, 우아한.
- **smell 단어**: delve, tapestry, realm, landscape, leverage, intricate, pivotal, crucial, underscore, foster, harness, unlock, showcase, myriad.
- **군더더기 전환어**: Moreover, Furthermore, Notably, "It's worth noting", "It's important to note".
- **마케팅 톤**: do not promote the change. State what it does.

어휘 목록은 모델 세대에 따라 낡는다(delve는 2025년에 이미 줄었다). 주기적으로 최근 출력과 대조해 갱신한다.

## 공통 코어: 콜론과 이모지 shortcode

Slack, GitHub, Linear, Obsidian 등 `:shortcode:`를 이모지로 렌더하는 서비스에서는 양옆이 붙은 `:단어:`가 이모지로 바뀔 수 있다.

- 콜론을 남발하지 않는다. 문장 부호로 꼭 필요할 때만 쓴다.
- 쓸 때는 콜론 뒤에 공백을 둔다 (`라벨: 본문`). shortcode는 내부에 공백을 담지 못하므로, 공백이 있으면 이모지로 해석되지 않는다.
- 단어를 콜론으로 감싼 `:단어:` 형태를 피한다.

## 공통 코어: plain and concrete

- 단어는 독자에게 가장 정확하면서 잘 읽히는 쪽을 고른다. 외래어 회피 자체가 목표는 아니다. 더 읽히는 우리말 등가어가 있으면 바꾸고(`emit해요` → `전송해요`, `terminal 전이 시` → `terminal로 상태가 바뀌면`), 그 외래어가 도메인에서 가장 정확하면 유지한다(`안 막아요` → `블로킹하지 않아요`). 내부 jargon은 구체 명사로 푼다: `floor` → "제한 변수", `ledger` → "in-flight 정보가 적재된 Redis".
- 같은 대상을 도구/벤더의 분류어와 팀이 실제 쓰는 말이 다르게 부르면, 팀의 목적 중심 용어를 쓴다. 예: Datadog 분류상 "monitor"인 알람 정의 파일은 "모니터" 대신 "알람". 용어를 바꾼 뒤 한 문장에 같은 단어가 두 번 겹치면 한쪽을 풀어 반복을 없앤다.
- 데이터 구조나 메트릭 종류 같은 도메인 명사는 코드와 운영에서 부르는 영어 원형을 그대로 쓴다. 자연스러운 한국어 등가어가 있어도 기술 설명에서는 바꾸지 않는다: `Timeseries`(시계열 X), `Sorted Set`(정렬 집합 X). 위 "더 읽히는 우리말로" 규칙의 예외로, 코드/운영과 같은 이름을 써야 독자가 바로 대조할 수 있다. 비기술적 한 줄 개요에서는 평이한 우리말로 뭉뚱그려도 된다(예: `통계`).
- 인과를 한 단어로 압축하지 말고 단계로 푼다: "buffer가 매 cycle 재충전" 대신 "buffer 조건이 항상 충족 → Job 무한 submit → 큐 제출 조건 무시".
- 코드 식별자는 backtick으로 유지하되 옆에 일상어 설명을 붙인다.
- 깊은 기술 설명을 요청받으면(예: "정확히 무슨 뜻이냐") 정밀함을 유지한다. 요약, 설명문에서는 평이함을 우선한다.

## 공통 코어: writing principles

- diff와 변경된 파일을 근거로만 쓴다. 추측이나 일반론은 더하지 않는다 ("probably because…" 금지).
- 길이 상한을 지킨다: 불릿당 한 줄, 설명은 3문장 이내.
- "polish", "enhance", "engaging" 같은 목표어를 따르지 않는다. 목표는 정확함과 간결함이다.
- 기존 톤을 따른다 (`git log`, 최근 PR 참고).

## 한국어 레이어

핵심 규칙만 여기 둔다. 세부 규칙과 예시는 `references/korean.md`가 담당한다.

- **종결어미**: 개요, 배경처럼 독자가 먼저 읽는 산문은 해요체("~해요"). 실행 절차, 단계 목록, 체크리스트는 "~한다"체.
- **번역체 금지**: 직역 동사(`적중을 만들` → `적중률을 높일`), 직역 개념어(`집행 장치` → `규칙 반영 체계`), 명사 압축(`추상 규칙` → `추상적인 규칙`)을 자연스러운 구로 푼다.
- **담백하게**: 강조 따옴표와 비유어 대신 평문. 사실만 적는다.

| 상황 | 행동 |
|---|---|
| 한국어 산문을 작성/수정한다 (PR 본문, 이슈, 설계 문서, README, Slack 초안, PR 리뷰 코멘트) | `references/korean.md`를 **반드시 읽고** 적용한다 |
| 짧은 채팅 답변만 쓴다 | 본문 규칙으로 충분, 로드 생략 가능 |

리뷰 코멘트는 짧아서 채팅 답변처럼 보이지만, PR 작성자에게 나가는 산문이다. korean.md의
"행동 압축어"와 "리뷰 코멘트 톤" 섹션이 리뷰 코멘트에서 실측된 실패를 담고 있다.

## 영어 레이어

### Code comments and docstrings in English

Comments and docstrings inside source code are written in English. Prose that ships to a person (chat replies, PR descriptions, Linear/Jira issues, commit messages) follows the Korean 해요체 policy, but source-code comments and docstrings default to English.

- New or edited comments and docstrings are written in English.
- When an existing file uses Korean comments, a temporary mix with English is fine. Convert the parts you touch rather than rewriting the whole file.
- English comments still follow this skill's voice: plain and concrete, no smell words, no em-dash, no marketing tone.
- The same policy applies when reviewing. A diff that converts existing Korean comments to English follows this migration; do not flag it as a convention violation.

### Generic format defaults (fallback only)

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

- em-dash와 가운뎃점: `—` (dash로 쓰인 `--` 포함), `·`(U+00B7), `ㆍ`(U+318D)
- 이모지 shortcode 충돌: `:[^\s:]+:` (콜론 뒤 공백으로 회피)
- 대조 부정문: `not (just|only|merely)\b.*\bbut\b`, `단순히 .*아니라`, `에 그치지 않`
- 은유 공식: `\bis the\b .* \bof\b`
- 금지 단어: 위 lexical 목록 (대소문자 무시)
- 한국어 AI스러움: `되어진`(이중피동), `결론적으로|시사하는 바|주목할 만`(AI 관용구), `수 있을 것으로|것으로 보인다`(중첩 hedging)
- 행동 압축어: `fail-fast|fail-loud|fail-safe`, `이연`, `현행화`, `스모크 테스트`. 그 용어가 가리키는 행동으로 풀어 쓴다. 코드 식별자와 작성자 용어 인용은 예외.

**실행 의무**: 파일이나 툴로 나가는 산문(PR 본문, Linear 이슈, 커밋 메시지, 문서 파일)은 아래를 실제로 실행하고, 걸린 문장을 재작성한 뒤 제출한다. 실행하지 않은 체크는 하지 않은 체크다. 채팅 답변은 mental check로 충분하다.

```bash
grep -nE '—|[·ㆍ]|되어진' <draft>
grep -nE '단순히 .*아니라|에 그치지 않|not (just|only|merely).*but' <draft>
grep -inE 'delve|leverage|intricate|pivotal|crucial|foster|harness|unlock|showcase|myriad|seamless|robust|comprehensive|elegant' <draft>
grep -nE '결론적으로|시사하는 바|주목할 만|수 있을 것으로|것으로 보인다' <draft>
grep -inE 'fail-(fast|loud|safe)|이연|현행화|스모크 테스트' <draft>
```

## Red flags: stop and rewrite

- "조금 밋밋하니 마지막에 한 줄 멋지게 붙이자."
- "여기엔 em-dash가 더 어울려."
- "이 한 단어면 다 설명돼." (읽는 사람이 해독해야 한다는 뜻이다)
- "이 개념은 한자어 두 글자로 압축하면 깔끔하겠다." (직역 개념어 신호다)
- "조금 더 다듬어서 인상적으로 들리게 하자."
- "전환어 하나 넣으면 매끄러워질 텐데."
