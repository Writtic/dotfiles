# dotfiles

GNU Stow로 관리하는 개인 dotfiles.
새 머신에서 3단계로 복원 가능.

## Quick Start (새 데스크톱)

```bash
# 1) stow 설치
brew install stow            # macOS
sudo apt install -y stow     # Debian/Ubuntu

# 2) clone
git clone git@github.com:Writtic/dotfiles.git ~/repo/dotfiles

# 3) apply
cd ~/repo/dotfiles
./bootstrap.sh
```

`./bootstrap.sh`는 기본적으로 `stow --adopt` 모드로 실행되며, 기존
홈 디렉터리 파일이 있으면 패키지 쪽으로 흡수한 뒤 심링크를 건다.
적용 후 `git status`로 drift를 리뷰하고 원치 않는 변경은
`git checkout -- <path>`로 되돌리면 된다.

## Layout

| 패키지 | 심링크 결과 |
|---|---|
| `zsh` | `~/.zshrc`, `~/.aliases`, `~/.zshrc.d/*` |
| `vim` | `~/.vimrc`, `~/.vim/` |
| `tmux` | `~/.tmux.conf` |
| `starship` | `~/.config/starship.toml` |
| `claude` | `~/.claude/settings.json`, `~/.claude/.mcp.json`, `~/.claude/plugins/{installed_plugins,known_marketplaces}.json`, `~/.claude/{agents,commands,hooks,skills}/` |
| `xinit` *(Linux only)* | `~/.xinitrc`, `~/.Xmodmap` |

> `emacs`, `spacemacs` 설정은 의도적으로 이 repo 밖에서 별도 관리한다.

패키지 목록은 `bootstrap.sh`의 `PACKAGES_COMMON` / `PACKAGES_LINUX`
배열에 정의되어 있으며, 존재하지 않거나 비어있는 디렉터리는 자동으로
건너뛴다.

## Usage

```bash
./bootstrap.sh            # 기본: stow --adopt (권장, drift 보존)
./bootstrap.sh --dry-run  # 적용 없이 시뮬레이션
./bootstrap.sh --backup   # 충돌 파일을 ~/.dotfiles-backup/<ts>/ 로 이동 후 stow
./bootstrap.sh --unstow   # 심링크 전체 제거 (stow -D)
./bootstrap.sh --help     # 사용법

# 패키지별로 직접 쓸 때
stow -nv -t ~ tmux        # 특정 패키지 dry-run
stow    -t ~ tmux         # 특정 패키지 적용
stow -D -t ~ tmux         # 특정 패키지 해제
```

`./sync.sh`는 현재 머신의 변경을 ISO-8601 타임스탬프 커밋으로
기록하고 `git pull --rebase --autostash && git push`를 수행한다.
rebase 충돌 시 자동 abort 후 non-zero 종료.

## 충돌 복구

`--backup` 모드에서 충돌이 발생한 파일은
`~/.dotfiles-backup/<YYYYmmdd-HHMMSS>/`에 보존되고
`~/.dotfiles-backup/latest`가 최신 백업을 가리킨다.

복구는 `cp -r ~/.dotfiles-backup/latest/<file> ~/<file>`로 수행.

## 새 패키지 추가

```bash
cd ~/repo/dotfiles
mkdir newpkg
mv ~/.newrc newpkg/.newrc
stow -nv -t ~ newpkg   # dry-run으로 심링크 맵 확인
```

원하는 결과면 `bootstrap.sh`의 `PACKAGES_COMMON` 배열에 패키지명을
추가한 뒤 commit.

## Secrets

이 repo는 **어떤 비밀 값도 저장하지 않는다**. API 키/토큰/세션은
`.gitignore`로 제외돼 있다 (`.env`, `*.local`, `*.secret` 등).

머신별 비밀 값이 필요한 셸 설정은 다음 중 하나로:

- `~/.zshrc.local` (gitignore 패턴으로 보호된 이름) — `zsh/.zshrc`의
  sourcing 루프가 자동으로 읽어 온다.
- 프로젝트별: [`direnv`](https://direnv.net) + `.envrc` 패턴.
- 시스템 keychain (macOS Keychain, `aws-vault`, `1password-cli`).

민감 파일이 이미 들어간 경우 `git rm --cached <file>`로 언트래킹한 뒤
`.gitignore`에 패턴 추가.

## 패키지별 메모

- **xinit/** — 현재 비어 있어 자동 skip. X11 머신에서만 내용을 채워
  사용.

### claude/ (Claude Code)

`claude/.claude/` 하위는 **화이트리스트** 방식으로 트래킹한다. `.gitignore`에서 전체 무시 후 다음만 추적:

- `settings.json` — 언어, 활성 플러그인 목록, `statusLine` 등 (토큰 없음 확인 필수)
- `.mcp.json` — MCP 서버 정의 (**API 키/토큰이 포함되면 절대 커밋 금지**)
- `plugins/installed_plugins.json` — 설치 플러그인 + `gitCommitSha` 핀
- `plugins/known_marketplaces.json` — 마켓플레이스 소스 (예: `anthropics/claude-plugins-official`)
- `agents/`, `commands/`, `hooks/`, `skills/` — 직접 작성한 자산 (빈 디렉토리는 `.gitkeep`)

현재 활성 플러그인 (마켓플레이스 `claude-plugins-official` = `anthropics/claude-plugins-official`):

- `superpowers` v5.1.0 — `gitCommitSha` 핀 (`f2cbfbe`)
- `ralph-loop` v1.0.0

추가 외부 도구:

- **CCometixLine** ([Haleclipse/CCometixLine](https://github.com/Haleclipse/CCometixLine)) — Claude Code statusline 도구. npm 패키지 `@cometix/ccline`로 배포. `settings.json`의 `statusLine.command`가 `~/.claude/ccline/ccline`을 가리킴. bootstrap이 새 머신에서 `npm install -g @cometix/ccline` + `~/.claude/ccline/ccline` 심링크를 자동으로 만든다 (`npm` 필요).

추적 **제외**:

- `sessions/`, `todos/`, `projects/`, `history.jsonl`, `cache/`, `paste-cache/`, `shell-snapshots/`, `telemetry/`, `debug/`, `backups/`, `file-history/`, `tasks/`, `logs/`, `statsig/` 등 모든 런타임 상태
- `plugins/cache/`, `plugins/marketplaces/`, `plugins/data/`, `plugins/repos/` — Claude Code가 마켓플레이스에서 자동 다운로드 (동일 sha로 재현)
- 서드파티 스킬 내부의 `.git/`, `node_modules/`, `bun.lock`

#### 새 머신 적용 순서

1. `./bootstrap.sh` — stow가 `claude/.claude/`의 트래킹 파일을 `~/.claude/`로 심링크
2. `claude` 실행 → `/plugin` 명령으로 마켓플레이스 동기화 및 매니페스트 플러그인 설치
3. 필요시 `.mcp.json` MCP 서버 인증 (`/mcp` 명령)

#### 새 command / agent / skill 추가 워크플로우

```bash
# 1) repo 안에 직접 작성
$EDITOR ~/repo/dotfiles/claude/.claude/commands/my-command.md

# 2) 심링크 갱신
cd ~/repo/dotfiles && stow -R claude

# 3) Claude Code에서 즉시 /my-command 사용 가능
```

> ⚠️ `~/.claude/commands/`, `~/.claude/skills/` 등이 stow 시점에 이미 존재하면
> stow는 *per-file* 심링크만 만든다. `~/.claude/commands/`에 직접 새 파일을
> 만들어도 repo로 자동 흘러가지 **않으므로**, 반드시 `claude/.claude/` 쪽에
> 먼저 작성하고 `stow -R claude`로 재동기화한다.

#### macOS ↔ Linux 이동

`installed_plugins.json` / `known_marketplaces.json`은 `/Users/...` 또는 `/home/...` 절대 경로를 포함한다. 다른 OS 머신에 적용 후엔 `/plugin` 메뉴에서 재설치하면 Claude Code가 경로를 재작성한다.

## 참고

- GNU Stow: <https://www.gnu.org/software/stow/manual/stow.html>
- Adopt 모드: 기존 파일이 있을 때 패키지로 흡수하므로 첫 세팅에 안전.
  반드시 `git status`로 리뷰할 것.
