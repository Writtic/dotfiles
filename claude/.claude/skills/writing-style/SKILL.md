---
name: writing-style
description: Use when writing any prose that ships to a person: PR descriptions, PR review comments, commit messages, Linear/Jira issues and comments, design notes, status updates, READMEs, docs. Strips AI-writing tells (em-dash, contrastive negation, smell words, marketing adjectives), enforces plain, concrete, fact-based phrasing, and applies action-first layout for PR descriptions and Linear issues adapted from i-have-adhd. Owns voice only; the invoking context owns format. Load alongside pull-request / git-commit / the /create-pr-local, /linear, and /review-pr commands.
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

fluent-korean output style이 켜져 있어도 이 스킬과 `references/korean.md`가 먼저다. fluent-korean은 문장 성분과 조사를 점검하는 보조 기준으로만 쓰고, 여기 규칙을 대신하지 않는다. 부딪히면 이 스킬이 이긴다.

## Core principle

피곤한 리뷰어가 해독 없이 한 번에 읽도록 쓴다. 평이하고 구체적인 문장이 압축되고 영리한 문장을 이긴다. 사실을 기록하고 변경을 팔지 않는다.

금지되는 두 방향. 하나를 고치다 다른 쪽으로 넘어가지 않는다. 간결함은 암호가 아니다.

- **AI-slop**: em-dash, smell 단어, 마케팅 형용사, 반사적 3항 나열, 격언형 마무리.
- **Jargon 압축**: 인과 사슬을 내부 용어 한 단어에 눌러 담아 독자에게 해독 비용을 넘기는 것.

3계층: 공통 코어(언어 불문) → 한국어 레이어(세부는 `references/korean.md`) → 영어 레이어.

## 공통 코어: hard bans

구조:

- **대조 부정문** "not just X but Y", "단순히 X가 아니라 Y", "X에 그치지 않고": `단순히 조회 최적화가 아니라 구조 개선이에요` → `조회 구조를 바꿔요`. 변형인 `A라기보다 B`, `A인가 B인가` 대구 연쇄도 같은 계열(korean.md 14번). 사실 정정 한 번(`원인은 lock이 아니라 timeout이에요`)은 예외.
- **은유 공식** "X는 Y의 Z다", "X is the Y of Z": `Redis는 이 시스템의 심장이다` → `모든 잡 상태가 Redis를 거친다`.
- **격언형 마무리**, **연속 단문 드라마**(`빠르다. 단순하다. 안전하다.`), **반사적 3항 나열**(실제로 3개일 때만 3개).
- **em-dash(—)** 0회. 쉼표나 마침표로 끊는다. **가운뎃점(·, ㆍ)** 나열 구분자 금지. 고유명사 쌍도 예외 없이 쉼표.

어휘:

- 자기과시 형용사: clean, elegant, powerful, robust, seamless, comprehensive, 강력한, 우아한, 혁신적, 획기적, 압도적, 파격적, 전례 없는.
- smell 단어: delve, tapestry, realm, landscape, leverage, intricate, pivotal, crucial, underscore, foster, harness, unlock, showcase, myriad.
- 군더더기 전환어: Moreover, Furthermore, Notably, "It's worth noting".
- 마케팅 톤. 변경이 무엇을 하는지만 적는다.

콜론과 이모지 shortcode: Slack, GitHub, Linear, Obsidian은 양옆이 붙은 `:단어:`를 이모지로 바꾼다. 콜론은 꼭 필요할 때만 쓰고 뒤에 공백을 둔다(`라벨: 본문`). 목록 도입 문장 끝의 콜론은 마침표로 바꾼다(`다음과 같습니다:` → `다음과 같습니다.`).

어휘 목록은 모델 세대에 따라 낡으니 최근 출력과 대조해 갱신한다.

## 공통 코어: plain and concrete

- 독자에게 가장 정확하면서 잘 읽히는 단어를 고른다. 더 읽히는 우리말이 있으면 바꾸고(`emit해요` → `전송해요`), 외래어가 도메인에서 가장 정확하면 유지한다(`안 막아요` → `블로킹하지 않아요`). 내부 jargon은 구체 명사로 푼다(`ledger` → "in-flight 정보가 적재된 Redis").
- 데이터 구조, 메트릭 종류, 코드 개념, UI 요소 같은 도메인 명사는 정착된 번역어가 있어도 코드와 운영에서 부르는 영어 원형 그대로(`Timeseries`, `Sorted Set`, `early return`, `table`). 독자가 코드와 바로 대조해야 한다. 비기술적 한 줄 개요에서만 평이한 우리말로 뭉뚱그려도 된다.
- 도구/벤더 분류어와 팀이 쓰는 말이 다르면 팀의 목적 중심 용어를 쓴다(Datadog "monitor" 파일은 "알람").
- 인과를 한 단어로 압축하지 말고 단계로 푼다: "buffer가 매 cycle 재충전" 대신 "buffer 조건이 항상 충족 → Job 무한 submit → 큐 제출 조건 무시".
- 코드 식별자는 backtick으로 두고 옆에 일상어 설명을 붙인다. 깊은 기술 설명을 요청받으면 정밀함을 유지하고, 요약과 설명문에서는 평이함을 우선한다.

## 공통 코어: writing principles

- diff와 변경된 파일만 근거로 쓴다. 추측과 일반론("probably because…", "한 연구에 따르면", "많은 전문가들은" 같은 무출처 인용)을 더하지 않는다.
- 불릿당 한 줄, 설명은 3문장 이내.
- "polish", "enhance", "engaging" 같은 목표어를 따르지 않는다. 목표는 정확함과 간결함이다.
- 기존 톤(`git log`, 최근 PR)을 따른다.

## PR 본문과 Linear 이슈

독자는 한 번 훑고 다음 행동을 정한다. 템플릿 구조(인사말, Issue, Motivation, Changes, 이슈 섹션)는 호출 컨텍스트가 정하고, 이 절은 그 안의 배치만 정한다. 원본: `~/.claude/plugins/cache/i-have-adhd/i-have-adhd/*/skills/i-have-adhd/SKILL.md`.

- **첫 문장이 결론**: Motivation과 이슈 첫 문장은 무엇이 문제이고 무엇을 바꾸는지다. "이번 PR에서는" 같은 예고로 시작하지 않는다.
- **사람이 할 일은 번호 목록**: 배포 순서, 수동 적용, 확인 요청이 있으면 단계당 한 행동으로 번호를 매긴다. 없으면 쓰지 않는다.
- **묶음당 5개 이하**: 넘으면 상위 개념으로 묶되 관련 항목을 지우지 않는다.
- **곁가지는 분리**: 이번 변경과 무관한 발견은 "후속" 한 줄이나 별도 이슈로 뺀다.
- **결과와 추정은 구체 단위**: "개선했어요" 대신 무엇이 어떻게 동작하는지와 수치를, 규모와 위험은 시간, 건수, 영향 범위로 적는다.
- **실패는 증상, 원인, 조치 순서**로 적고 감탄과 완곡을 뺀다.
- **서두, 끝 요약, 맺음말 금지**("정리하면", "참고 부탁드려요").

제출 전: 첫 문장과 마지막 불릿만 읽어도 무엇이 바뀌었는지와 독자가 할 일을 알 수 있어야 한다.

## 한국어 레이어

- **종결어미**: 개요, 배경처럼 먼저 읽는 산문은 해요체. 실행 절차, 단계 목록, 체크리스트는 "~한다"체. 해요체 안에서 "~죠", "~고요" 변주는 허용한다.
- **번역체 금지**: 직역 동사(`적중을 만들` → `적중률을 높일`), 직역 개념어(`집행 장치` → `규칙 반영 체계`), 명사 압축(`추상 규칙` → `추상적인 규칙`, `일시 오류` → `일시적인 오류`)을 자연스러운 구로 푼다. 조사 번역투(`~에 있어서`, `~에 대해` 남발)와 영어식 피동(`~에 의해`, `가지고 있다`)도 같은 계열(korean.md 9~10번).
- **담백하게**: 강조 따옴표와 비유어 대신 평문. 사실만 적는다. 뜻을 더하지 않는 부사와 보조 용언, 진행형은 뺀다.
- `값`은 `value`로 쓰고 조사는 영어 발음에 맞춘다(`같은 값을` → `같은 value를`, `기본값` → `default value`).

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
- 한국어 AI스러움: `되어진|보여지|쓰여진|세져`(이중피동, 세는 동작은 `카운트하다`), `결론적으로|시사하는 바|주목할 만|지금이야말로|할 시점이|인 셈이`(관용구와 결말 공식), `수 있을 것으로|것으로 보인다`(중첩 hedging), `에 있어서|가지고 있|에 의해|에서의|으로의|로부터의`(번역투 조사와 피동)
- 빈도 신호: `에 대해`, `를 통해`, `을 위해`, `할 수 있`, `해야 한다`는 문서 3회 이상이면 검출된다. 걸린 항목은 카탈로그의 해당 기준(문단 반복, 권고형 결말 5회 등)으로 판단해 분산하거나 단언으로 바꾼다(korean.md 2, 9, 19번).
- 군더더기와 일본어투: `의거하|금번|에 위치하|에 위치해|에도 불구하고|필요로 하|필요로 해|않을 수 없|했었|는가를`(korean.md 16~18번)
- 행동 압축어: `fail-fast|fail-loud|fail-safe`, `이연`, `현행화`, `스모크 테스트`, `실측`, `뒤집`, `접[어었히]`(분량 축소의 비유). 그 용어가 가리키는 행동으로 풀어 쓴다. 코드 식별자와 작성자 용어 인용은 예외(korean.md 8번).
- 비교 어휘: `싸(요|다|서|고|니)`(`비싸` 포함, `감싸요` 같은 오탐은 제외). 비용이 크면 `비용이 많이 나와요`, 적으면 `저렴해요`, 시간이면 `시간이 적게/많이 걸려요`로 바꾼다(korean.md "어휘").
- 빌려 온 추상어: `회계|장부|방어선|예산|공백|버려지|꼬리`. 그 동작을 주어와 동사로 쓴다(korean.md "어휘").
- 팀 용어와 지시어: `여기(에)? 포함`(→ `해당돼요`), `모니터(도|가|는) 울리`(→ `알람`), `이 [A-Za-z]`(→ `해당 X`).
- 리뷰 코멘트 어미와 압축: `필요해요`(→ `필요해보여요`), `모니터(는|가) .*적용`(적용 대상은 `~에`), `~의 첫`(압축 명사구는 절로).
- 리뷰 어휘: `응답`(→ `response`), `카운터`(→ `Datadog Count Metric`), `일시 오류`(→ `일시적인 오류`), `드문 조합`/`해당 경우`(→ `케이스`), `돌리면`(→ `실행하면`), `보지 않아서`(→ `확인할 수 없어서`), `이어가면`(→ `~에 도달할 수 있으면`), `로 두고`/`에러만 올려서`(→ `인식하고`/`인식해서`), `부모가`/`취소를`(→ `부모 파이프라인이`/`취소 요청을`, 축약 명사 복원), `못 구한`(→ `계산하지 못한`), `겹쳐서`(→ `중복돼서`), `정당한 호출`(→ `정상적인 호출`), `key로 쓰면`(→ `사용하면`), `비용이 빠져요`(→ `제외돼요`), `incident가 빠지고`/`알람이 빠져요`(→ `누락되고`/`누락돼요`). 기준은 korean.md 어휘 절과 리뷰 내용 절.
- `값`: `value`로 바꾼다.
- 붙여넣기 잔재: `\^[\[\]]`. 터미널 제어문자 표기(`^[`, `^]`)가 단어 사이에 섞인 것.

**실행 의무**: 파일이나 툴로 나가는 산문(PR 본문, 리뷰 코멘트, Linear 이슈, 커밋 메시지, 문서 파일)은 아래를 실제로 실행하고 걸린 문장을 재작성한 뒤 제출한다. 실행하지 않은 체크는 하지 않은 체크다. 채팅 답변은 mental check로 충분하다.

```bash
grep -nE '—|[·ㆍ]|되어진|보여지|쓰여진|세져' <draft>
grep -nE '단순히 .*아니라|에 그치지 않|not (just|only|merely).*but' <draft>
grep -inE 'delve|leverage|intricate|pivotal|crucial|foster|harness|unlock|showcase|myriad|seamless|robust|comprehensive|elegant' <draft>
grep -nE '결론적으로|시사하는 바|주목할 만|수 있을 것으로|것으로 보인다|지금이야말로|할 시점이|인 셈이' <draft>
grep -nE '혁신적|획기적|압도적|파격적|전례 없|에 있어서|가지고 있|에 의해|에서의|으로의|로부터의' <draft>
grep -inE 'fail-(fast|loud|safe)|이연|현행화|스모크 테스트|실측|뒤집|접[어었히]' <draft>
grep -nE '의거하|금번|에 위치하|에 위치해|에도 불구하고|필요로 하|필요로 해|않을 수 없|했었|는가를' <draft>
grep -nE '싸(요|다|서|고|니)' <draft> | grep -v 감싸
grep -nE '회계|장부|방어선|예산|공백|버려지|꼬리' <draft>
grep -nE '여기(에)? 포함|모니터(도|가|는) 울리|(^|\s)이 [A-Za-z]' <draft>   # 해당돼요 / 알람 / 해당 X
grep -nE '필요해요|모니터(는|가) .*적용|[가-힣]+의 첫 ' <draft>   # 리뷰 코멘트: 필요해보여요 / 적용 대상은 ~에 / ~의 압축 명사구는 절로
grep -nE '응답[과을이은에도로]|카운터|일시 (오류|에러|장애)|(드문|해당|이|그) (경우|조합)|(^|[^되])돌리[면고]|(^|[^되])돌려[요서]|보지 (않|못)|이어가[면고요]|로 두[고면]|(에러|예외)[만를] 올|부모[가를는] |취소를 |못 구[한해하]|겹쳐[서요]|정당한 |[로를] 쓰면|(비용|금액|합계|행)[이가] 빠|(incident|알림|알람)[가이는은만도]* 빠' <draft>   # 리뷰 어휘: response / Datadog Count Metric / 일시적인 / 케이스 / 실행 / 확인 / 도달 / 인식 / 축약 명사 복원 / 계산 / 중복 / 정상적인 / 사용 / 제외 / 누락
grep -nE '\^[][]' <draft>
grep -n '값' <draft>
grep -oE '에 대해|를 통해|을 위해|할 수 있|해야 한다' <draft> | sort | uniq -c | awk '$1 >= 3'   # 빈도 신호
```

## Red flags: stop and rewrite

- "조금 밋밋하니 마지막에 한 줄 멋지게 붙이자."
- "여기엔 em-dash가 더 어울려."
- "이 한 단어면 다 설명돼." (독자가 해독해야 한다는 뜻)
- "이 개념은 한자어 두 글자로 압축하면 깔끔하겠다." (직역 개념어 신호)
- "전환어 하나 넣으면 매끄러워질 텐데."
