#!/bin/bash
# bootstrap.sh -- apply dotfiles via GNU Stow, idempotent & reversible.
#
# Usage:
#   ./bootstrap.sh              # default: stow --adopt (safe, preserves drift)
#   ./bootstrap.sh --dry-run    # simulate, make no filesystem changes
#   ./bootstrap.sh --backup     # move conflicts to ~/.dotfiles-backup/<ts>/ then stow
#   ./bootstrap.sh --unstow     # remove all symlinks (stow -D)
#   ./bootstrap.sh --help       # show this help
#
# Packages:
#   common : zsh vim tmux starship
#   linux  : xinit (X11 only; auto-skipped if empty)
#   (emacs, spacemacs, and claude are intentionally managed outside this repo)
#
# Post-stow hooks (idempotent): vim-plug, tmux tpm, nvim -> vim symlinks.
#
# bash 3.2 compatible (macOS default).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# -------- flags --------
MODE="adopt"        # adopt | backup | unstow | dry-run
for arg in "$@"; do
	case "$arg" in
		--dry-run)  MODE="dry-run" ;;
		--backup)   MODE="backup"  ;;
		--unstow)   MODE="unstow"  ;;
		--adopt)    MODE="adopt"   ;;
		--help|-h)
			sed -n '2,18p' "$0"
			exit 0
			;;
		*)
			echo "Unknown flag: $arg" >&2
			echo "Try: $0 --help" >&2
			exit 2
			;;
	esac
done

# -------- stow presence check --------
if ! command -v stow >/dev/null 2>&1; then
	echo "ERROR: GNU Stow is not installed." >&2
	echo "  macOS:  brew install stow" >&2
	echo "  Debian: sudo apt install stow" >&2
	exit 1
fi

# -------- packages (bash 3.2: plain arrays, no assoc arrays) --------
PACKAGES_COMMON=(zsh vim tmux starship)
PACKAGES_LINUX=(xinit)

PACKAGES=("${PACKAGES_COMMON[@]}")
case "$(uname -s)" in
	Linux*) PACKAGES=("${PACKAGES[@]}" "${PACKAGES_LINUX[@]}") ;;
esac

# Filter out packages whose directory is missing or empty.
FILTERED=()
for pkg in "${PACKAGES[@]}"; do
	if [ ! -d "$SCRIPT_DIR/$pkg" ]; then
		echo "skip: $pkg (not a directory)" >&2
		continue
	fi
	if [ -z "$(ls -A "$SCRIPT_DIR/$pkg" 2>/dev/null || true)" ]; then
		echo "skip: $pkg (empty package)" >&2
		continue
	fi
	FILTERED=("${FILTERED[@]}" "$pkg")
done
PACKAGES=("${FILTERED[@]}")

echo ":: target packages: ${PACKAGES[*]}"

# -------- mode dispatch --------
case "$MODE" in
	dry-run)
		for pkg in "${PACKAGES[@]}"; do
			echo "--- stow -nv -t \"\$HOME\" $pkg ---"
			stow -nv -t "$HOME" -d "$SCRIPT_DIR" "$pkg" || true
		done
		echo ":: dry-run complete (no changes made)"
		exit 0
		;;

	unstow)
		for pkg in "${PACKAGES[@]}"; do
			echo "--- unstow $pkg ---"
			stow -D -v -t "$HOME" -d "$SCRIPT_DIR" "$pkg" || true
		done
		echo ":: unstow complete"
		exit 0
		;;

	backup)
		TS="$(date +%Y%m%d-%H%M%S)"
		BACKUP_DIR="$HOME/.dotfiles-backup/$TS"
		for pkg in "${PACKAGES[@]}"; do
			CONFLICTS=$(stow -nv -t "$HOME" -d "$SCRIPT_DIR" "$pkg" 2>&1 \
				| awk '/existing target is/ {print $NF}' || true)
			if [ -n "$CONFLICTS" ]; then
				mkdir -p "$BACKUP_DIR"
				echo "$CONFLICTS" | while IFS= read -r f; do
					[ -z "$f" ] && continue
					src="$HOME/$f"
					dst="$BACKUP_DIR/$f"
					mkdir -p "$(dirname "$dst")"
					mv "$src" "$dst"
					echo "  backup: $src -> $dst"
				done
			fi
			echo "--- stow $pkg ---"
			stow -v -t "$HOME" -d "$SCRIPT_DIR" "$pkg"
		done
		if [ -d "$BACKUP_DIR" ]; then
			ln -sfn "$BACKUP_DIR" "$HOME/.dotfiles-backup/latest"
			echo ":: conflicts backed up to $BACKUP_DIR (symlink: ~/.dotfiles-backup/latest)"
		fi
		;;

	adopt)
		# --adopt pulls existing target files INTO the package (overwriting package
		# content with the user's live file). Review with `git diff` afterwards and
		# `git checkout -- <file>` to discard unwanted drift.
		for pkg in "${PACKAGES[@]}"; do
			echo "--- stow --adopt $pkg ---"
			stow --adopt -v -t "$HOME" -d "$SCRIPT_DIR" "$pkg"
		done
		echo ":: adopted. Review with: (cd $SCRIPT_DIR && git status)"
		;;
esac

# -------- idempotent post-stow hooks --------
echo ":: running post-stow hooks"

# nvim <- vim config symlinks
if command -v nvim >/dev/null 2>&1; then
	mkdir -p "$HOME/.config/nvim" "$HOME/.local/share/nvim"
	[ -e "$HOME/.config/nvim/init.vim" ] || ln -s "$HOME/.vimrc" "$HOME/.config/nvim/init.vim"
	[ -e "$HOME/.local/share/nvim/site" ] || ln -s "$HOME/.vim" "$HOME/.local/share/nvim/site"
fi

# vim-plug
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
	curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim || \
		echo "WARN: vim-plug install failed (offline?)" >&2
fi

# tmux tpm
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
	mkdir -p "$HOME/.tmux/plugins"
	git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" || \
		echo "WARN: tpm clone failed (offline?)" >&2
fi

echo ":: bootstrap complete."
echo "   Next: open vim once to run :PlugInstall, tmux prefix+I to install tpm plugins."
