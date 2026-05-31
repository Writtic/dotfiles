# 전역 지침

## LLM Wiki — 중앙 크로스레포 지식 허브 (recall + sync)

내 업무 지식(결정·아키텍처·디버깅 학습·설계 스펙·프롬프트)은 Obsidian의 중앙 위키에 합성·유지된다.
레포-로컬 캡처(ce-compound `docs/solutions/`, superpowers `docs/superpowers/`)는 그대로 두되, 그 위에서
여러 레포를 가로질러 집약하는 단일 지점이 이 위키다.

```
Wiki:  /Users/johan/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work/LLMWiki
정본:  Work/LLMWiki/CLAUDE.md   ← 스키마·컨벤션·워크플로 상세는 여기. 쓰기/읽기 전 이 파일을 따른다.
```

### RECALL — 비자명한 작업·결정·계획·솔루션 설계에 들어가기 전
`llmwiki-researcher` 에이전트로 위키에서 관련 선행지식을 surface 한다.
compound의 `ce-learnings-researcher`(레포-로컬 `docs/solutions/`)와 **병행**한다(중앙 허브 vs 레포 로컬).
표면화된 내용이 현재 코드/문서와 충돌하면 그대로 따르지 말고 충돌을 플래그하고 날짜로 노후 여부를 판단.

### SYNC — 다음이 레포에 기록되면, 위키에 합성 페이지를 미러 + `index.md`/`log.md` 갱신
- `/ce-compound` 학습 (`docs/solutions/**`)            → `LLMWiki/learnings/`
- brainstorming 스펙 (`docs/superpowers/specs/**`)      → `LLMWiki/specs/`
- writing-plans 계획 (`docs/superpowers/plans/**`)      → `LLMWiki/specs/` (스펙 페이지에 링크로 흡수)

**복붙 금지·합성**: 관련 `systems/`·`decisions/` 페이지 갱신, 교차링크, 모순은 플래그. 상세 절차는 위 정본 참고.

### 동기화 가드
- 위키엔 Write/Edit로 **직접 쓰기**(절대경로). obsidian-mcp는 검색 fallback 용도로만.
- (권장) `~/.claude/settings.json`의 `permissions.allow`에 위 Wiki 경로 `**`를 Read/Edit/Write로 등록하면
  타 레포에서도 권한 프롬프트 없이 쓰기 가능. 미설정 시 모드에 따라 프롬프트가 날 수 있음.
- 위키는 iCloud 경로라 일시적으로 사라질 수 있음 → 쓰기 실패 시 **중단 말고** 레포에 메모, 다음 세션 보정.
  위키 동기화 실패가 레포-로컬 캡처(ce-compound 등)를 막아선 안 된다. 위키는 2차 산출물.
