# llmwiki-researcher 에이전트 설계

- **날짜**: 2026-06-01
- **상태**: approved (구현 대기)
- **산출물**: `claude/.claude/agents/llmwiki-researcher.md` (dotfiles → stow → `~/.claude/agents/`)

## 1. 배경 & 문제

전역 지침([`~/.claude/CLAUDE.md`](../../../claude/.claude/CLAUDE.md))의 RECALL 워크플로는 비자명한
작업·결정·계획·솔루션 설계 전에 `llmwiki-researcher` 에이전트를 호출해 중앙 LLM Wiki에서 선행
지식을 surface하도록 지시한다. 그러나 **이 에이전트는 아직 정의되어 있지 않다** — dotfiles가 관리하는
`claude/.claude/agents/`(55개 에이전트)에 없어, 지침이 깨진 참조를 가리킨다.

이 스펙은 그 에이전트를 정의한다. 형제 격인 compound의 `ce-learnings-researcher`(repo-로컬
`docs/solutions/` 검색)와 **병행** 호출되며, 차이는 **중앙 허브 vs repo-로컬**이다.

### LLM Wiki 구조 (대상 지식 베이스)

- **경로**: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work/LLMWiki` (iCloud/Obsidian 볼트)
- **정본(canon)**: `LLMWiki/CLAUDE.md` — 스키마·컨벤션·워크플로의 정의서
- **페이지 타입**: `systems/`(허브) · `decisions/` · `learnings/` · `specs/` · `prompts/` · `_meta/`
- **루트 파일**: `index.md`(카탈로그) · `log.md`(시간순 로그)
- **허브 구조**: 모든 비-system 페이지는 최소 하나의 `systems/` 페이지로 링크한다 (시스템이 허브)
- **탐색 컨벤션**: 질의 시 먼저 `index.md`를 읽고 관련 페이지로 드릴다운 (임베딩 RAG 불필요, ~수백 페이지 규모까지 유효)
- **frontmatter**: 모든 페이지가 `type, module, status, created, updated, tags, related, source` 공통 필드를 가짐.
  타입별 추가 필드 존재 (learning은 compound 스키마 승계: `problem_type, severity, source_repo, source_doc` 등)

## 2. 설계 결정 (브레인스토밍 합의)

| 축 | 결정 | 근거 |
|---|---|---|
| **Recall 범위** | 허브 우선 (systems 진입) | 위키의 systems-as-hub 구조를 그대로 활용. 작업이 닿는 시스템의 합성된 현재 이해가 가장 고가치 신호. prompts는 명시 요청 시에만 |
| **출력 형식** | 시스템별 다이제스트 + Obsidian 링크 | 사용자가 Obsidian을 옆에 띄우고 그래프/링크를 따라가는 워크플로와 정합. `[[wikilink]]`+절대경로로 클릭 즉시 열람 |
| **충돌 처리** | 위키 전용 + 노후 캐빗 | 임의 repo에서 호출됨. 경계를 깔끔히: 연구자는 surface·캐빗만, 충돌 판단은 전체 컨텍스트를 가진 메인 에이전트가 |
| **탐색 깊이** | Lean hub-walker (성장 여지) | 17페이지 현실에 정확히 맞음. grep은 폴백. 위키가 커지면 grep→주력 승격 |

## 3. 에이전트 명세

### 3.1 메타데이터 (frontmatter)

```yaml
---
name: llmwiki-researcher
description: >
  비자명한 작업·결정·계획·솔루션 설계 전, 중앙 LLM Wiki에서 선행 지식을 surface한다.
  compound의 ce-learnings-researcher와 병행 호출 — 중앙 허브 vs repo-로컬.
tools: Read, Grep, Glob, Bash
model: inherit
---
```

- **읽기 전용**: Write/Edit 없음. 위키 쓰기(SYNC)는 메인 에이전트의 별도 워크플로.
- **Bash 필요 이유**: 위키 경로가 cwd 밖 + 공백 포함 절대경로라, `rg`/`find`로 검색·존재 확인이 필요.

### 3.2 입력 계약

형제 에이전트와 동일한 `<work-context>` 블록을 받는다 (같은 오케스트레이터가 두 연구자에 동일 입력 전달):

```
<work-context>
Activity:  <무엇을 하려는가 / 검토 중인가>
Concepts:  <작업이 닿는 명명된 아이디어·추상·접근>
Decisions: <검토 중인 구체 결정, 있으면>
Domains:   <선택적 힌트>
</work-context>
```

- 자유 서술 입력도 폴백 허용 (Activity로 간주, 휴리스틱 키워드 추출).
- `prompts/`는 work-context가 **명시적으로 재사용 프롬프트를 요청할 때만** 탐색.

### 3.3 위치 & 가용성 가드

1. **첫 동작**: 위키 경로와 `index.md` 접근 가능 여부 확인.
2. **도달 불가 시** (iCloud 일시 소실 등): `"위키 도달 불가 — 중앙 recall 생략"` 한 줄을 깔끔히 반환.
   **에러를 던지지 않고, 절대 호출자를 블로킹하지 않는다.** (전역 CLAUDE.md sync 가드와 동일 철학: 위키는 2차 산출물)

### 3.4 탐색 전략 (허브 우선)

1. **키워드 추출** — work-context에서 module/system 이름, 개념, 결정, 도메인을 뽑는다.
2. **`index.md` 정독** — 카탈로그가 진입 지도.
3. **관련 `systems/` 허브 식별** — 인덱스에서 module/키워드로 매칭되는 시스템 페이지를 고른다.
4. **허브 드릴다운** — 허브 페이지를 읽고 `related` wikilink를 따라 decisions·learnings·specs로 확장.
5. **grep 폴백** — 인덱스/허브로 확신 매치가 안 잡히거나 미링크 페이지가 의심되면, 절대경로에
   `rg`(Bash)로 frontmatter를 **병렬** grep: `type:`·`module:`·`tags:`·`title:` (대소문자 무시, 동의어 `|`).
6. **한정 정독** — 후보를 정독하되 cap을 둔다 (§3.6 수치).
7. **성장 여지** — 위키가 수백 페이지로 커지면 grep 패스를 폴백→주력 프리필터로 승격.
   런타임에 위키 검색 도구(obsidian-mcp/qmd)가 있으면 프리필터로 써도 됨 — 없으면 파일시스템. (현재는 둘 다 미설치)

### 3.5 노후 & 충돌 캐빗 (위키 전용)

- 각 surface 페이지의 `status` + `updated`/`created`를 읽는다.
  - `status: superseded | archived` → 강한 캐빗 또는 다운웨이트.
  - `updated`가 오래됨 → `"노후 가능성 (updated YYYY-MM-DD)"` 표기.
- **repo 코드를 읽지 않는다.** surface + 캐빗만 제공하고, 실제 충돌 판단은 호출자에게 위임.
- 페이지 자체에 모순 callout이 있으면 그대로 전달한다.

### 3.6 출력 형식 (시스템별 다이제스트 + Obsidian 링크)

```markdown
## LLM Wiki Recall 결과

### 검색 컨텍스트
- **작업**: [work-context의 Activity 요약]
- **사용 키워드**: [system/module/개념/도메인]
- **위키 경로**: ~/.../Work/LLMWiki
- **스캔/매치**: [N 페이지 스캔, M 매치]

### [[systems/<name>]]  — <module>
[허브의 현재 이해 1~3줄 요약] · status/date 캐빗

- **결정** [[decisions/<page>]] (`경로`) — [한 줄 인사이트] · [status/date 캐빗]
- **학습** [[learnings/<page>]] (`경로`) — [한 줄 인사이트] · source_repo: <repo> · [캐빗]
- **스펙** [[specs/<page>]] (`경로`) — [한 줄 인사이트]

### [[systems/<other>]] ...

### 권고
- [작업 시 참고/주의할 점, surface된 지식 기반]
```

- **크로스-repo 표시**: `source_repo`/`module`을 노출해 "다른 repo 작업에서 온 지식"임을 호출자가 알게 한다 (중앙 허브의 핵심 가치).
- **한정 (cap)**: 최대 **~3 시스템 × 각 ~5 지원 항목**. 잘리면 `"추가 매치 N건 있음"` 한 줄.
- **무결과**: 명시적으로 `"관련 선행 지식 없음"` + `"이 작업은 끝난 뒤 위키에 sync할 가치 있음(부재도 신호)"`.
- 출력은 사람+메인 에이전트가 **산문으로 소비** (다운스트림이 필드를 파싱하지 않음).

### 3.7 하지 않는 것 (non-goals)

- 위키에 쓰기 (SYNC는 메인 에이전트의 별도 워크플로)
- repo 코드/문서 읽기
- 위키가 침묵할 때 답을 지어내기
- prompts/를 기본 탐색 대상에 포함 (명시 요청 시에만)

## 4. 통합 지점

- **전역 CLAUDE.md RECALL**: 비자명한 작업 전, `ce-learnings-researcher`와 **병행** 호출.
- **호출 방식**: 메인 에이전트가 Agent 도구로 `subagent_type: llmwiki-researcher` 디스패치.
  (stow 후 `~/.claude/agents/`에 등록되어야 인식됨)

## 5. 활성화 (stow 워크플로)

1. 이 브랜치를 master에 머지.
2. main 체크아웃에서 `./bootstrap.sh` (re-stow) — 신규 에이전트 파일을 `~/.claude/agents/`에 심링크.
3. 새 `claude` 세션에서 에이전트 인식.

## 6. 미해결 / 후속

- **검증의 한계**: 에이전트의 실제 동작은 위키 상태에 의존하므로, 구현 후 실제 work-context로
  스모크 테스트(허브 매치 1건, 무결과 1건, 위키 도달 불가 1건)를 권장.
- **성장 트리거**: 위키가 ~수백 페이지를 넘어서면 §3.4-7의 grep-주력 승격 / 검색 도구 도입을 재검토.
