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
| `xinit` *(Linux only)* | `~/.xinitrc`, `~/.Xmodmap` |

> `emacs`, `spacemacs`, `claude` 설정은 의도적으로 이 repo 밖에서
> 별도 관리한다.

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

## 참고

- GNU Stow: <https://www.gnu.org/software/stow/manual/stow.html>
- Adopt 모드: 기존 파일이 있을 때 패키지로 흡수하므로 첫 세팅에 안전.
  반드시 `git status`로 리뷰할 것.
