---
name: writing-style
description: Use when writing any prose that ships to a person: PR descriptions, PR review comments, commit messages, Linear/Jira issues and comments, design notes, status updates, READMEs, docs. Strips AI-writing tells (em-dash, contrastive negation, smell words, marketing adjectives) and enforces plain, concrete, fact-based phrasing. Owns voice only; the invoking context owns format. Load alongside pull-request / git-commit / the /create-pr-local, /linear, and /review-pr commands.
---

<!--
  Single source of truth for the house voice. CLAUDE.md, /create-pr-local, /linear, pull-request,
  git-commit all point here. Change a rule here, nowhere else. 한국어 세부 카탈로그는 references/korean.md.
-->

# Writing Style (house voice)

## Scope: voice, not format

문장이 어떻게 읽히는지(어휘, 문장 형태, 정직함)만 정한다. 문서 구조는 호출한 컨텍스트가 정한다.

| Context | Owns the format |
|---|---|
| commit messages | `git-commit` skill (repo의 커밋 스타일 감지) |
| PR descriptions | `pull-request` skill (템플릿 감지 후 house style) |
| `/create-pr-local` | Linear PR 템플릿 + 해요체, 헤더 없음 |
| `/linear` | 이슈 / 코멘트 구조 |
| `/review-pr` | 인라인 코멘트 (해요체, 1-2문장, 줄 앵커) |

호출 컨텍스트나 감지된 house style이 이 파일의 generic format defaults와 다르면 house style이 이긴다. 해요체 PR을 `## Summary / ## Changes`로 바꾸지 않는다.

## Core principle

피곤한 리뷰어가 해독 없이 한 번에 읽도록 쓴다. 평이하고 구체적인 문장이 압축되고 영리한 문장을 이긴다. 사실을 기록하고 변경을 팔지 않는다.

금지되는 두 방향. 하나를 고치다 다른 쪽으로 넘어가지 않는다. 간결함은 암호가 아니다.

- **AI-slop**: em-dash, smell 단어, 마케팅 형용사, 반사적 3항 나열, 격언형 마무리.
- **Jargon 압축**: 인과 사슬을 내부 용어 한 단어에 눌러 담아 독자에게 해독 비용을 넘기는 것.

3계층: 공통 코어(언어 불문) → 한국어 레이어(세부는 `references/korean.md`) → 영어 레이어.

## 공통 코어: hard bans

구조:

- **대조 부정문** "not just X but Y", "단순히 X가 아니라 Y", "X에 그치지 않고": `단순히 조회 최적화가 아니라 구조 개선이에요` → `조회 구조를 바꿔요`. 변형인 `A라기보다 B`, `A인가 B인가` 대구 연쇄도 같은 계열(korean.md 14번).
- **은유 공식** "X는 Y의 Z다", "X is the Y of Z": `Redis는 이 시스템의 심장이다` → `모든 잡 상태가 Redis를 거친다`.
- **격언형 마무리**, **연속 단문 드라마**(`빠르다. 단순하다. 안전하다.`), **반사적 3항 나열**(실제로 3개일 때만 3개).
- **em-dash(—)** 금지. 쉼표나 마침표로 끊는다. **가운뎃점(·)** 나열 구분자 금지. 고유명사 쌍도 예외 없이 쉼표.

어휘:

- 자기과시 형용사: clean, elegant, powerful, robust, seamless, comprehensive, 강력한, 우아한, 혁신적, 획기적, 압도적, 파격적, 전례 없는.
- smell 단어: delve, tapestry, realm, landscape, leverage, intricate, pivotal, crucial, underscore, foster, harness, unlock, showcase, myriad.
- 군더더기 전환어: Moreover, Furthermore, Notably, "It's worth noting".
- 마케팅 톤. 변경이 무엇을 하는지만 적는다.

콜론과 이모지 shortcode: Slack, GitHub, Linear, Obsidian은 양옆이 붙은 `:단어:`를 이모지로 바꾼다. 콜론은 꼭 필요할 때만 쓰고 뒤에 공백을 둔다(`라벨: 본문`). 목록 도입 문장 끝의 콜론은 마침표로 바꾼다(`다음과 같습니다:` → `다음과 같습니다.`).

어휘 목록은 모델 세대에 따라 낡으니 최근 출력과 대조해 갱신한다.

## 공통 코어: plain and concrete

- 독자에게 가장 정확하면서 잘 읽히는 단어를 고른다. 더 읽히는 우리말이 있으면 바꾸고(`emit해요` → `전송해요`), 외래어가 도메인에서 가장 정확하면 유지한다(`안 막아요` → `블로킹하지 않아요`). 내부 jargon은 구체 명사로 푼다(`ledger` → "in-flight 정보가 적재된 Redis").
- 데이터 구조, 메트릭 종류 같은 도메인 명사는 코드와 운영에서 부르는 영어 원형 그대로(`Timeseries`, `Sorted Set`). 독자가 코드와 바로 대조해야 한다. 비기술적 한 줄 개요에서만 평이한 우리말로 뭉뚱그려도 된다.
- 도구/벤더 분류어와 팀이 쓰는 말이 다르면 팀의 목적 중심 용어를 쓴다(Datadog "monitor" 파일은 "알람").
- 인과를 한 단어로 압축하지 말고 단계로 푼다: "buffer가 매 cycle 재충전" 대신 "buffer 조건이 항상 충족 → Job 무한 submit → 큐 제출 조건 무시".
- 코드 식별자는 backtick으로 두고 옆에 일상어 설명을 붙인다. 깊은 기술 설명을 요청받으면 정밀함을 유지하고, 요약과 설명문에서는 평이함을 우선한다.

## 공통 코어: writing principles

- diff와 변경된 파일만 근거로 쓴다. 추측과 일반론("probably because…", "한 연구에 따르면", "많은 전문가들은" 같은 무출처 인용)을 더하지 않는다.
- 불릿당 한 줄, 설명은 3문장 이내.
- "polish", "enhance", "engaging" 같은 목표어를 따르지 않는다. 목표는 정확함과 간결함이다.
- 기존 톤(`git log`, 최근 PR)을 따른다.

## 한국어 레이어

- **종결어미**: 개요, 배경처럼 먼저 읽는 산문은 해요체. 실행 절차, 단계 목록, 체크리스트는 "~한다"체. 해요체 안에서 "~죠", "~고요" 변주는 허용한다.
- **번역체 금지**: 직역 동사(`적중을 만들` → `적중률을 높일`), 직역 개념어(`집행 장치` → `규칙 반영 체계`), 명사 압축(`추상 규칙` → `추상적인 규칙`)을 자연스러운 구로 푼다. 조사 번역투(`~에 있어서`, `~에 대해` 남발)와 영어식 피동(`~에 의해`, `가지고 있다`)도 같은 계열(korean.md 9~10번).
- **담백하게**: 강조 따옴표와 비유어 대신 평문. 사실만 적는다.

한국어 산문(PR 본문, 이슈, 설계 문서, README, Slack 초안, PR 리뷰 코멘트)을 쓰거나 고칠 때는 `references/korean.md`를 반드시 읽고 적용한다. 짧은 채팅 답변은 위 규칙으로 충분하다. 리뷰 코멘트는 짧아도 작성자에게 나가는 산문이라 korean.md의 "행동 압축어"와 "리뷰 코멘트" 절이 적용된다.

## 영어 레이어

- 소스 코드의 주석과 docstring은 영어. 사람에게 나가는 산문(채팅, PR 본문, 이슈, 커밋 메시지)은 한국어 정책을 따른다.
- 기존 파일이 한국어 주석이면 손대는 부분만 영어로 바꾼다. 리뷰에서도 한국어 주석을 영어로 바꾼 diff는 위반이 아니다.
- 영어 주석도 같은 voice로 쓴다. 평이하고 구체적으로, smell 단어와 em-dash와 마케팅 톤 없이.

Generic format defaults (house style도 호출 컨텍스트 지정도 없을 때만):

- commit: Conventional Commits `type(scope): subject`. subject는 명령형 50자 이내 마침표 없음, body는 무엇/왜만 72자 줄바꿈, 마크다운 서식 없음.
- PR: `## Summary` / `## Changes` / `## Test plan`. 불릿은 동사로 시작해 한 줄.

## Post-filter (run before showing output)

정규식으로 검출하고 걸린 문장은 완화가 아니라 재작성한다. grep 블록에는 오탐이 적은 패턴만 있고, 나머지는 mental check다.

- em-dash와 가운뎃점: `—`, `·`(U+00B7), `ㆍ`(U+318D). dash로 쓰인 `--`도 금지지만 CLI 플래그와 겹쳐 grep 블록에는 없다.
- 이모지 shortcode 충돌: `:[^\s:]+:`. 인용과 시간 표기 오탐이 있어 grep 블록에는 없다.
- 대조 부정문: `not (just|only|merely)\b.*\bbut\b`, `단순히 .*아니라`, `에 그치지 않`
- 은유 공식: `\bis the\b .* \bof\b`. 영어 산문 오탐이 많아 grep 블록에는 없다.
- 금지 단어: 위 어휘 목록(대소문자 무시). clean, powerful, 강력한, 우아한, tapestry, realm, landscape, underscore는 mental check.
- 한국어 AI스러움: `되어진|보여지|쓰여진`(이중피동), `결론적으로|시사하는 바|주목할 만|지금이야말로|할 시점이|인 셈이`(관용구와 결말 공식), `수 있을 것으로|것으로 보인다`(중첩 hedging), `에 있어서|가지고 있|에 의해|에서의|으로의|로부터의`(번역투 조사와 피동)
- 빈도 신호: `에 대해`, `를 통해`, `을 위해`, `할 수 있`, `해야 한다`는 문서 3회 이상이면 검출된다. 걸린 항목은 카탈로그의 해당 기준(문단 반복, 권고형 결말 5회 등)으로 판단해 분산하거나 단언으로 바꾼다(korean.md 2, 9, 19번).
- 군더더기와 일본어투: `의거하|금번|에 위치하|에 위치해|에도 불구하고|필요로 하|필요로 해|않을 수 없|했었|는가를`(korean.md 16~18번)
- 행동 압축어: `fail-fast|fail-loud|fail-safe`, `이연`, `현행화`, `스모크 테스트`, `실측`, `뒤집`, `접[어었히]`(분량 축소의 비유). 그 용어가 가리키는 행동으로 풀어 쓴다. 코드 식별자와 작성자 용어 인용은 예외(korean.md 8번).
- 붙여넣기 잔재: `\^[\[\]]`. 터미널 제어문자 표기(`^[`, `^]`)가 단어 사이에 섞인 것.

**실행 의무**: 파일이나 툴로 나가는 산문(PR 본문, 리뷰 코멘트, Linear 이슈, 커밋 메시지, 문서 파일)은 아래를 실제로 실행하고 걸린 문장을 재작성한 뒤 제출한다. 실행하지 않은 체크는 하지 않은 체크다. 채팅 답변은 mental check로 충분하다.

```bash
grep -nE '—|[·ㆍ]|되어진|보여지|쓰여진' <draft>
grep -nE '단순히 .*아니라|에 그치지 않|not (just|only|merely).*but' <draft>
grep -inE 'delve|leverage|intricate|pivotal|crucial|foster|harness|unlock|showcase|myriad|seamless|robust|comprehensive|elegant' <draft>
grep -nE '결론적으로|시사하는 바|주목할 만|수 있을 것으로|것으로 보인다|지금이야말로|할 시점이|인 셈이' <draft>
grep -nE '혁신적|획기적|압도적|파격적|전례 없|에 있어서|가지고 있|에 의해|에서의|으로의|로부터의' <draft>
grep -inE 'fail-(fast|loud|safe)|이연|현행화|스모크 테스트|실측|뒤집|접[어었히]' <draft>
grep -nE '의거하|금번|에 위치하|에 위치해|에도 불구하고|필요로 하|필요로 해|않을 수 없|했었|는가를' <draft>
grep -nE '\^[][]' <draft>
grep -oE '에 대해|를 통해|을 위해|할 수 있|해야 한다' <draft> | sort | uniq -c | awk '$1 >= 3'   # 빈도 신호
```

## Red flags: stop and rewrite

- "조금 밋밋하니 마지막에 한 줄 멋지게 붙이자."
- "여기엔 em-dash가 더 어울려."
- "이 한 단어면 다 설명돼." (독자가 해독해야 한다는 뜻)
- "이 개념은 한자어 두 글자로 압축하면 깔끔하겠다." (직역 개념어 신호)
- "전환어 하나 넣으면 매끄러워질 텐데."
