# Shortcuts cheat sheet

현재 dotfiles 기준 tmux + nvim 주요 단축키 모음.

- tmux prefix: **`Ctrl-Space`**
- vim leader: `;` (local leader: `,`)

---

## tmux

### Session / 시작

| 명령 | 동작 |
|---|---|
| `tmux` | 기본 세션 진입 (첫 윈도우 자동 생성) |
| `tmux new -s <name>` | 이름 있는 새 세션 |
| `tmux new -s work -n editor \; new-window -n server` | 여러 윈도우 초기화 |
| `tmux attach` / `tmux a -t <name>` | 세션 붙기 |
| `Ctrl-Space` `d` | 세션에서 detach (tmux 백그라운드 유지) |
| `Ctrl-Space` `s` | 세션 목록 선택 |
| `Ctrl-Space` `$` | 세션 이름 변경 |

### Window

| 키 | 동작 |
|---|---|
| `Ctrl-Space` `c` | 새 윈도우 (현재 pane 경로 유지) |
| `Ctrl-Space` `&` | 현재 윈도우 닫기 (확인) |
| `Ctrl-Space` `,` | 윈도우 이름 변경 |
| `Ctrl-Space` `.` | 윈도우 번호 변경 |
| `Ctrl-Space` `0`~`9` | 번호로 점프 |
| `Ctrl-Space` `n` / `p` | 다음 / 이전 윈도우 |
| `Ctrl-Space` `Space` / `BSpace` | 다음 / 이전 윈도우 |
| `Ctrl-Space` `Ctrl-Space` | 직전 활성 윈도우 토글 |
| `Ctrl-Space` `w` | 윈도우 트리 목록 |
| `Ctrl-Space` `f` | 윈도우/pane 텍스트 검색 |
| `Ctrl-Space` `>` / `<` | 다음/이전 슬롯과 swap |
| `Ctrl-Space` `!` | 현재 pane을 새 윈도우로 분리 |

### Pane 생성 / 이동 / 닫기

| 키 | 동작 |
|---|---|
| `Ctrl-Space` `\|` | 세로 분할 (좌/우) |
| `Ctrl-Space` `-` | 가로 분할 (위/아래) |
| `Ctrl-Space` `h` / `j` / `k` / `l` | vim 방향키로 pane 이동 |
| `Ctrl-h` / `j` / `k` / `l` | **prefix 없이** 이동 (vim-tmux-navigator) |
| `Ctrl-Space` `q` | pane 번호 표시 후 번호 키로 점프 |
| `Ctrl-Space` `o` | 다음 pane 순환 |
| `Ctrl-Space` `Tab` / `BTab` | pane 순환 |
| `Ctrl-Space` `x` | 현재 pane 닫기 (확인) |
| `Ctrl-d` 또는 `exit` | 셸 종료 → pane 자동 닫힘 |
| `Ctrl-Space` `z` | 현재 pane **최대화 토글** |
| `Ctrl-Space` `Space` | 레이아웃 순환 |

### Pane 리사이즈

| 키 | 동작 |
|---|---|
| `Ctrl-Space` `H` / `J` / `K` / `L` (반복) | ±5 칸 |
| `Ctrl-Space` `Ctrl-←/→/↑/↓` | 1칸씩 |

### Pane ↔ Window 전환

| 명령 | 동작 |
|---|---|
| `Ctrl-Space` `!` | pane → 새 윈도우 |
| `Ctrl-Space` `:join-pane -s 2` | 윈도우 2의 pane을 현재 윈도우로 합치기 |
| `Ctrl-Space` `:join-pane -t 2` | 현재 pane을 윈도우 2로 이동 |

### 스크롤 / copy-mode

| 키 | 동작 |
|---|---|
| 마우스 위로 스크롤 | 자동 copy-mode 진입 |
| `Ctrl-Space` `[` | copy-mode 수동 진입 |
| `k` / `j` | 한 줄 위 / 아래 |
| `Ctrl-u` / `Ctrl-d` | 반 페이지 |
| `Ctrl-b` / `Ctrl-f` | 한 페이지 |
| `g` / `G` | 최상단 / 최하단 |
| `/` `text` `Enter` | 아래 방향 검색 |
| `?` `text` `Enter` | 위 방향 검색 |
| `n` / `N` | 다음 / 이전 매치 |
| `v` | 선택 시작 |
| `Ctrl-v` | 블록(사각형) 선택 토글 |
| `y` 또는 `Enter` | 선택 → pbcopy 복사 + 종료 |
| `q` / `Esc` | copy-mode 나가기 |
| `Ctrl-Space` `]` | tmux 내부 paste |

### 기타 유용한 조합

| 키 | 동작 |
|---|---|
| `Ctrl-Space` `R` | `~/.tmux.conf` 리로드 |
| `Ctrl-Space` `r` | gpakosz framework 리로드 |
| `Ctrl-Space` `*` | pane 동기 입력 토글 |
| `Ctrl-Space` `C-c` | 현재 pane 스크롤백 → vim으로 열기 |
| `Ctrl-Space` `M-c` | (macOS) iTerm2 윈도우 스크린샷 |
| `Ctrl-Space` `I` | TPM으로 플러그인 설치 |
| `Ctrl-Space` `U` | TPM 플러그인 업데이트 |

---

## nvim / vim

### 스크롤 & 커서 이동

| 키 | 동작 |
|---|---|
| `Ctrl-y` / `Ctrl-e` | 한 줄 위 / 아래 |
| `Ctrl-u` / `Ctrl-d` | 반 페이지 |
| `Ctrl-b` / `Ctrl-f` | 한 페이지 |
| `gg` / `G` | 파일 처음 / 끝 |
| `H` / `M` / `L` | 화면 위 / 중앙 / 아래로 커서 |
| `zz` / `zt` / `zb` | 현재 줄을 화면 중앙 / 상단 / 하단 |
| `%` | 매칭 bracket 점프 |
| `[[` / `]]` | 이전 / 다음 함수 |

### 검색 / 치환

| 키 | 동작 |
|---|---|
| `/pattern` / `?pattern` | 아래 / 위 검색 |
| `n` / `N` | 다음 / 이전 |
| `*` / `#` | 커서 단어를 아래 / 위로 검색 |
| `:%s/old/new/g` | 전체 치환 |
| `:nohl` | 하이라이트 끄기 |

### 파일 / 버퍼 (fzf.vim)

| 키 | 동작 |
|---|---|
| `Ctrl-p` | `:Files` 파일 fuzzy 검색 |
| `;` `p` | 동일 (leader = `;`) |
| `;` `ob` | `:Buffers` 열린 버퍼 |
| `;` `oh` | `:History` 최근 파일 |
| `;` `e` | 커서 단어를 `:Rg`로 프로젝트 검색 |
| `;` `E` | `:Rg` 프롬프트 |

### NERDTree

| 키 | 동작 |
|---|---|
| `;` `T` | `:NERDTreeToggle` |
| `;` `t` | `:NERDTreeFind` (현재 파일 위치로) |

### LSP (nvim-lspconfig + nvim-cmp)

| 키 | 동작 |
|---|---|
| `gd` | definition으로 점프 |
| `gD` | declaration |
| `gr` | references 목록 |
| `gi` | implementation |
| `K` | hover 문서 표시 |
| `;` `rn` | rename |
| `;` `ca` | code action |
| `;` `f` | format (비동기) |
| `[d` / `]d` | 이전 / 다음 diagnostic |

### nvim-cmp (자동 완성)

| 키 | 동작 |
|---|---|
| `Ctrl-n` / `Ctrl-p` | 다음 / 이전 후보 |
| `Ctrl-Space` | 완성 트리거 |
| `Enter` | 확정 (select=false라 명시 선택 필요) |
| `Ctrl-e` | 취소 |
| `Ctrl-b` / `Ctrl-f` | 문서 스크롤 |

### UltiSnips 스니펫

| 키 | 동작 |
|---|---|
| `Tab` | 확장 / 다음 placeholder |
| `Ctrl-Tab` | 이전 placeholder |

### Window / Tab 관리 (vim native)

| 키 | 동작 |
|---|---|
| `Ctrl-w` `v` / `s` | 세로 / 가로 분할 |
| `Ctrl-w` `h/j/k/l` | window 이동 (vim-tmux-navigator로 tmux pane까지 통합) |
| `Ctrl-w` `c` | window 닫기 |
| `Ctrl-w` `=` | 균등 리사이즈 |
| `gt` / `gT` | 다음 / 이전 tab |
| `:tabe <file>` | 새 tab |

### Tagbar

| 키 | 동작 |
|---|---|
| `;` `.` | `:TagbarToggle` (파일 심볼 아웃라인) |

### 유용한 편집 (tpope + textobj)

| 키 | 동작 |
|---|---|
| `gcc` | 현재 줄 주석 토글 (vim-commentary) |
| `gc` + motion | 범위 주석 토글 |
| `cs"'` | 주변 `"` → `'` 변경 (vim-surround) |
| `ds(` | 주변 `()` 제거 |
| `ysiw)` | 단어를 `()`로 감싸기 |
| `vii` / `vai` | indent 텍스트 객체 (vim-indent-object) |
| `vae` | 전체 버퍼 텍스트 객체 (vim-textobj-entire) |
| `.` | 직전 변경 반복 (vim-repeat로 플러그인 동작까지) |

### Git (vim-fugitive + gitsigns)

| 명령 | 동작 |
|---|---|
| `:Git status` / `:G` | 상태창 |
| `:Git blame` | blame 뷰 |
| `:Gdiff` | 변경 diff |
| `:GBrowse` | 원격 브라우저로 (vim-rhubarb) |

gitsigns는 gutter에 `+ / ~ / _` 자동 표시.

---

## 관련 참고

- **tmux copy-mode에서 선택한 내용은 자동으로 macOS 클립보드(pbcopy)로 복사**
- **Ctrl-Space 충돌 주의**: macOS 시스템 환경설정의 "입력 소스 변경" 단축키가 기본 `Ctrl-Space`인 경우 해제 필요
- **Ctrl-h/j/k/l**은 vim-tmux-navigator가 가로채므로 tmux pane ↔ vim window 이동이 자연스럽게 연결
- **Ctrl-W 같은 터미널 단축키가 깨질 때**는 `source ~/.zshrc`에 포함된 `modifyOtherKeys` 리셋이 동작하는지 확인
