---
name: writing-style
description: Use when writing any prose that ships to a person: PR descriptions, PR review comments, commit messages, Linear/Jira issues and comments, design notes, status updates, READMEs, docs. Korean sentence clarity comes from the fluent-korean output style; this skill adds AI-tell bans (em-dash, contrastive negation, smell words, marketing adjectives), plain concrete wording, house conventions, and action-first layout for PR descriptions and Linear issues adapted from i-have-adhd. Owns voice only; the invoking context owns format. Load alongside pull-request / git-commit / the /create-pr-local, /linear, and /review-pr commands.
---

<!--
  Single source of truth for the house voice. CLAUDE.md, /create-pr-local, /linear, pull-request,
  git-commit all point here. Change a rule here, nowhere else. fluent-korean이 이미 정한 규칙은 여기 다시 쓰지 않는다.
-->

# Writing Style (house voice)

## 먼저 읽을 것

1. 한국어 산문이면 fluent-korean 원문을 요약하지 말고 읽는다: `~/.claude/plugins/cache/fluent-korean/fluent-korean/*/output-styles/fluent-korean.md`. 문장 성분과 조사, 어미 살리기, 명사구로 문장을 끝내지 않기(헤더와 목록 제외), `~의` 남용, 비유 어휘, 한자어와 조사 결합은 그 문서가 정한다.
2. 한국어 산문(PR 본문, 이슈, 설계 문서, README, Slack 초안, 리뷰 코멘트)이면 `references/korean.md`도 읽는다.
3. PR 본문과 Linear 이슈면 아래 "PR 본문과 Linear 이슈" 절을 적용한다. 원본: `~/.claude/plugins/cache/i-have-adhd/i-have-adhd/*/skills/i-have-adhd/SKILL.md`.

fluent-korean과 부딪히면 이 스킬이 이긴다.

- 코드 개념, UI 요소, 도메인 명사는 정착된 번역어가 있어도 영어 원어로 쓴다(`Timeseries`, `early return`, `table`).
- em-dash는 자제가 아니라 0회다.
- 조사와 어미는 살리되, 뜻을 더하지 않는 부사와 보조 용언, 진행형은 뺀다. 의미가 분명한 쪽을 먼저, 그다음 짧은 쪽을 고른다.

## Scope: voice, not format

| Context | Owns the format |
|---|---|
| commit messages | `git-commit` skill (repo의 커밋 스타일 감지) |
| PR descriptions | `pull-request` skill (템플릿 감지 후 house style) |
| `/create-pr-local` | Linear PR 템플릿 + 해요체, 헤더 없음 |
| `/linear` | 이슈 / 코멘트 구조 |
| `/review-pr` | 인라인 코멘트 (해요체, 1-2문장, 줄 앵커) |

호출 컨텍스트나 감지된 house style이 이 파일의 generic format defaults와 다르면 house style이 이긴다.

## Core principle

피곤한 리뷰어가 해독 없이 한 번에 읽도록 쓴다. 사실을 기록하고 변경을 팔지 않는다. 금지되는 두 방향을 오가지 않는다.

- **AI-slop**: em-dash, smell 단어, 마케팅 형용사, 반사적 3항 나열, 격언형 마무리.
- **Jargon 압축**: 인과 사슬을 내부 용어 한 단어에 눌러 담아 독자에게 해독을 떠넘기는 것.

## Hard bans

- **대조 부정문**: "not just X but Y", "단순히 X가 아니라 Y", "X에 그치지 않고", `A라기보다 B`. `단순히 조회 최적화가 아니라 구조 개선이에요` → `조회 구조를 바꿔요`. 사실 정정 한 번(`원인은 lock이 아니라 timeout이에요`)은 예외.
- **은유 공식** "X는 Y의 Z다": `Redis는 이 시스템의 심장이다` → `모든 잡 상태가 Redis를 거친다`.
- **격언형 마무리**, **연속 단문 드라마**(`빠르다. 단순하다. 안전하다.`), **반사적 3항 나열**(실제로 3개일 때만 3개).
- **em-dash(—)와 가운뎃점(·, ㆍ)** 0회. 쉼표나 마침표로 끊는다. 고유명사 쌍도 쉼표.
- **어휘**: 자기과시 형용사(clean, elegant, powerful, robust, seamless, comprehensive, 강력한, 우아한, 혁신적, 획기적, 압도적, 파격적, 전례 없는), smell 단어(delve, tapestry, realm, landscape, leverage, intricate, pivotal, crucial, underscore, foster, harness, unlock, showcase, myriad), 군더더기 전환어(Moreover, Furthermore, Notably, "It's worth noting"), 마케팅 톤. 목록은 최근 출력과 대조해 갱신한다.
- **콜론**: Slack, GitHub, Linear, Obsidian은 양옆이 붙은 `:단어:`를 이모지로 바꾼다. 콜론 뒤에는 공백을 두고(`라벨: 본문`), 목록 도입 문장 끝 콜론은 마침표로 바꾼다.

## Plain and concrete

- 독자에게 가장 정확하면서 잘 읽히는 단어를 고른다(`emit해요` → `전송해요`, `안 막아요` → `블로킹하지 않아요`). 내부 jargon은 구체 명사로 푼다(`ledger` → "in-flight 정보가 적재된 Redis").
- 도구 분류어보다 팀의 목적 중심 용어를 쓴다(Datadog "monitor" 파일은 "알람").
- 인과는 단계로 푼다: "buffer 조건이 항상 충족 → Job 무한 submit → 큐 제출 조건 무시".
- 코드 식별자는 backtick으로 두고 옆에 일상어 설명을 붙인다.
- diff와 변경 파일만 근거로 쓴다. 추측과 무출처 일반론("probably because…", "많은 전문가들은")을 더하지 않는다.
- 불릿당 한 줄, 설명은 3문장 이내. "polish", "enhance" 같은 목표어 대신 정확함과 간결함을 목표로 한다. 기존 톤(`git log`, 최근 PR)을 따른다.

## PR 본문과 Linear 이슈

독자는 한 번 훑고 다음 행동을 정한다. 템플릿 구조(인사말, Issue, Motivation, Changes, 이슈 섹션)는 호출 컨텍스트가 정하고, 이 절은 그 안의 배치만 정한다.

- **첫 문장이 결론**: Motivation과 이슈 첫 문장은 무엇이 문제이고 무엇을 바꾸는지다. "이번 PR에서는" 같은 예고로 시작하지 않는다.
- **사람이 할 일은 번호 목록**: 배포 순서, 수동 적용, 확인 요청이 있으면 단계당 한 행동으로 번호를 매긴다. 없으면 쓰지 않는다.
- **묶음당 5개 이하**: 넘으면 상위 개념으로 묶되 관련 항목을 지우지 않는다.
- **곁가지는 분리**: 이번 변경과 무관한 발견은 "후속" 한 줄이나 별도 이슈로 뺀다.
- **결과와 추정은 구체 단위**: "개선했어요" 대신 무엇이 어떻게 동작하는지와 수치를, 규모와 위험은 시간, 건수, 영향 범위로 적는다.
- **실패는 증상, 원인, 조치 순서**로 적고 감탄과 완곡을 뺀다.
- **서두, 끝 요약, 맺음말 금지**("정리하면", "참고 부탁드려요").

제출 전: 첫 문장과 마지막 불릿만 읽어도 무엇이 바뀌었는지와 독자가 할 일을 알 수 있어야 한다.

## 한국어와 영어 레이어

- 한국어 세부 규칙(종결어미, 어휘, PR 구조, AI스러움 패턴, 리뷰 코멘트)은 `references/korean.md`.
- `값`은 `value`로 쓰고 조사는 영어 발음에 맞춘다(`같은 값을` → `같은 value를`, `기본값` → `default value`).
- 소스 코드의 주석과 docstring은 영어, 사람에게 나가는 산문(채팅, PR 본문, 이슈)은 한국어 정책을 따른다. 기존 한국어 주석은 손대는 부분만 영어로 바꾼다. 영어 주석도 같은 voice로 쓴다.

Generic format defaults (house style도 호출 컨텍스트 지정도 없을 때만):

- commit: Conventional Commits `type(scope): subject`. subject는 명령형 50자 이내 마침표 없음, body는 무엇/왜만 72자 줄바꿈.
- PR: `## Summary` / `## Changes` / `## Test plan`. 불릿은 동사로 시작해 한 줄.

## Post-filter (run before showing output)

걸린 문장은 완화하지 말고 재작성한다. 파일이나 툴로 나가는 산문(PR 본문, 리뷰 코멘트, Linear 이슈, 커밋 메시지, 문서 파일)은 아래를 실제로 실행한다. 채팅 답변은 mental check로 충분하다. `--`(dash 용도), `:shortcode:`, 은유 공식, 빈도 신호 외 패턴은 오탐이 많아 mental check로 본다.

```bash
grep -nE '—|[·ㆍ]|되어진|보여지|쓰여진|세져' <draft>
grep -nE '단순히 .*아니라|에 그치지 않|not (just|only|merely).*but' <draft>
grep -inE 'delve|leverage|intricate|pivotal|crucial|foster|harness|unlock|showcase|myriad|seamless|robust|comprehensive|elegant' <draft>
grep -nE '결론적으로|시사하는 바|주목할 만|수 있을 것으로|것으로 보인다|지금이야말로|할 시점이|인 셈이' <draft>
grep -nE '혁신적|획기적|압도적|파격적|전례 없|에 있어서|가지고 있|에 의해|에서의|으로의|로부터의' <draft>
grep -inE 'fail-(fast|loud|safe)|이연|현행화|스모크 테스트|실측|뒤집|접[어었히]' <draft>
grep -nE '의거하|금번|에 위치하|에 위치해|에도 불구하고|필요로 하|필요로 해|않을 수 없|했었|는가를' <draft>
grep -nE '싸(요|다|서|고|니)' <draft> | grep -v 감싸
grep -nE '회계|장부|방어선|예산' <draft>
grep -nE '\^[][]' <draft>
grep -n '값' <draft>
grep -oE '에 대해|를 통해|을 위해|할 수 있|해야 한다' <draft> | sort | uniq -c | awk '$1 >= 3'   # 빈도 신호
```

각 패턴의 재작성 기준은 korean.md의 같은 이름 항목을 본다.

## Red flags: stop and rewrite

- "조금 밋밋하니 마지막에 한 줄 멋지게 붙이자."
- "여기엔 em-dash가 더 어울려."
- "이 한 단어면 다 설명돼." (독자가 해독해야 한다는 뜻)
- "전환어 하나 넣으면 매끄러워질 텐데."
