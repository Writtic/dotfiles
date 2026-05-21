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
#   common : zsh vim tmux starship claude
#   linux  : xinit (X11 only; auto-skipped if empty)
#   (emacs and spacemacs are intentionally managed outside this repo)
#
# Claude Code (claude package):
#   - Tracks only user-authored config under claude/.claude/. Heavy runtime
#     state (sessions/, todos/, cache/, history.jsonl, plugins/...) and
#     marketplace cache are .gitignored. Settings tracked: settings.json,
#     .mcp.json (no secrets), agents/, commands/, hooks/, skills/.
#     Marketplaces are declared via extraKnownMarketplaces in settings.json;
#     Claude Code regenerates plugins/known_marketplaces.json from that.
#   - On a fresh machine: after stow completes, launch `claude` and run
#     `/plugin` to install plugins listed under `enabledPlugins` in
#     settings.json from the known marketplaces.
#   - Atomic-rename recovery: Claude Code rewrites some config via temp-file
#     + atomic rename, which silently replaces our stow symlinks with real
#     files. recover_atomic_writes() runs before each adopt/backup stow to
#     drop identical-content live files so stow can re-link cleanly. Drifted
#     files are left in place with a diff hint.
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
PACKAGES_COMMON=(zsh vim tmux starship claude)
PACKAGES_LINUX=(xinit)

PACKAGES=("${PACKAGES_COMMON[@]}")
case "$(uname -s)" in
	Linux*) PACKAGES=("${PACKAGES[@]}" "${PACKAGES_LINUX[@]}") ;;
esac

# Filter out packages whose directory is missing or empty.
# bash 3.2 + 'set -u': use += and guard empty-array expansion.
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
	FILTERED+=("$pkg")
done
if [ ${#FILTERED[@]} -eq 0 ]; then
	echo "ERROR: no packages to operate on (all skipped)." >&2
	exit 1
fi
PACKAGES=("${FILTERED[@]}")

echo ":: target packages: ${PACKAGES[*]}"

# -------- atomic-write recovery (pre-stow) --------
# Detect real-files in the home tree that replaced our stow-managed symlinks
# (e.g. Claude Code's /plugin atomic-rename pattern) and drop them when
# identical to the tracked copy, so stow can re-link without --adopt
# silently moving the live file into the repo. Files that diverged are
# left alone with a recovery hint.
recover_atomic_writes() {
	local pkg="$1"
	local conflicts file live tracked
	# stow 2.4.1 conflict line:
	#   * cannot stow <src> over existing target <dst> since neither a link
	#     nor a directory and --adopt not specified
	# Extract <dst> (a path relative to $HOME).
	conflicts=$(stow -nv --no-folding -t "$HOME" -d "$SCRIPT_DIR" "$pkg" 2>&1 \
		| sed -n 's|.*existing target \([^ ]*\) since neither a link nor a directory.*|\1|p' \
		|| true)
	[ -z "$conflicts" ] && return 0
	while IFS= read -r file; do
		[ -z "$file" ] && continue
		live="$HOME/$file"
		tracked="$SCRIPT_DIR/$pkg/$file"
		[ ! -f "$live" ] && continue
		[ -L "$live" ] && continue
		if [ -f "$tracked" ] && cmp -s "$live" "$tracked"; then
			rm "$live"
			echo "recover: removed redundant ~/$file (identical to tracked copy)"
		else
			echo "WARN: ~/$file diverged from $tracked" >&2
			echo "      Inspect:               diff -u \"$tracked\" \"$live\"" >&2
			echo "      Accept live drift:     cp \"$live\" \"$tracked\"" >&2
			echo "      Discard live drift:    rm \"$live\"" >&2
		fi
	done <<< "$conflicts"
}

# -------- mode dispatch --------
case "$MODE" in
	dry-run)
		for pkg in "${PACKAGES[@]}"; do
			echo "--- stow -nv --no-folding -t \"\$HOME\" $pkg ---"
			stow -nv --no-folding -t "$HOME" -d "$SCRIPT_DIR" "$pkg" || true
		done
		echo ":: dry-run complete (no changes made)"
		exit 0
		;;

	unstow)
		for pkg in "${PACKAGES[@]}"; do
			echo "--- unstow $pkg ---"
			stow -D -v --no-folding -t "$HOME" -d "$SCRIPT_DIR" "$pkg" || true
		done
		echo ":: unstow complete"
		exit 0
		;;

	backup)
		TS="$(date +%Y%m%d-%H%M%S)"
		BACKUP_DIR="$HOME/.dotfiles-backup/$TS"
		for pkg in "${PACKAGES[@]}"; do
			recover_atomic_writes "$pkg"
			CONFLICTS=$(stow -nv --no-folding -t "$HOME" -d "$SCRIPT_DIR" "$pkg" 2>&1 \
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
			stow -v --no-folding -t "$HOME" -d "$SCRIPT_DIR" "$pkg"
		done
		if [ -d "$BACKUP_DIR" ]; then
			ln -sfn "$BACKUP_DIR" "$HOME/.dotfiles-backup/latest"
			echo ":: conflicts backed up to $BACKUP_DIR (symlink: ~/.dotfiles-backup/latest)"
		fi
		;;

	adopt)
		# --adopt pulls existing target files INTO the package (overwriting package
		# content with the user's live file). recover_atomic_writes() runs first
		# to drop identical-content live files so --adopt doesn't no-op move them
		# into the repo. --no-folding forces per-file symlinks so empty target
		# dirs don't get replaced with directory symlinks (which would let runtime
		# tools deposit files outside the repo's view). Review with `git diff`
		# afterwards and `git checkout -- <file>` to discard unwanted drift.
		for pkg in "${PACKAGES[@]}"; do
			recover_atomic_writes "$pkg"
			echo "--- stow --adopt --no-folding $pkg ---"
			stow --adopt -v --no-folding -t "$HOME" -d "$SCRIPT_DIR" "$pkg"
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

# Claude Code: nudge plugin sync when settings declares enabled plugins but
# the plugin cache hasn't been built (fresh machine). Claude Code itself owns
# marketplace clone + plugin download — we just remind the user to trigger it.
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
CLAUDE_CACHE="$HOME/.claude/plugins/cache"
if [ -f "$CLAUDE_SETTINGS" ] \
	&& grep -q '"enabledPlugins"' "$CLAUDE_SETTINGS" \
	&& [ ! -d "$CLAUDE_CACHE" ]; then
	echo ":: Claude Code: enabledPlugins declared but plugin cache missing."
	echo "   Run 'claude' and execute '/plugin' to install enabled plugins."
fi

# CCometixLine (https://github.com/Haleclipse/CCometixLine) — statusline tool
# referenced by claude/.claude/settings.json's statusLine.command field.
# Distributed as npm package @cometix/ccline; we stow only the settings
# reference and let bootstrap install the binary + create the path indirection
# that settings.json points at (~/.claude/ccline/ccline).
# Version pinned for reproducibility — bump deliberately, not implicitly.
CCLINE_VERSION="1.1.2"
CCLINE_LINK="$HOME/.claude/ccline/ccline"
# `-x` follows symlinks: real-file-and-executable OR working-symlink → skip.
# Broken symlink (-L true, -x false) falls through and gets repaired below.
if [ ! -x "$CCLINE_LINK" ]; then
	if command -v npm >/dev/null 2>&1; then
		echo ":: installing CCometixLine (@cometix/ccline@$CCLINE_VERSION) globally via npm"
		# stdout silenced (install progress noise); stderr surfaced for real errors.
		npm install -g "@cometix/ccline@$CCLINE_VERSION" >/dev/null || \
			echo "WARN: ccline install failed" >&2
		NPM_PREFIX="$(npm config get prefix 2>/dev/null || true)"
		if [ -n "$NPM_PREFIX" ] && [ -x "$NPM_PREFIX/bin/ccline" ]; then
			mkdir -p "$HOME/.claude/ccline"
			ln -snf "$NPM_PREFIX/bin/ccline" "$CCLINE_LINK"
			echo ":: ccline linked at $CCLINE_LINK"
		fi
	else
		echo "NOTE: npm not found — skip CCometixLine install." >&2
		echo "   Manually: npm install -g @cometix/ccline@$CCLINE_VERSION && \\" >&2
		echo "             mkdir -p ~/.claude/ccline && \\" >&2
		echo "             ln -s \"\$(npm config get prefix)/bin/ccline\" ~/.claude/ccline/ccline" >&2
	fi
fi

echo ":: bootstrap complete."
echo "   Next: open vim once to run :PlugInstall, tmux prefix+I to install tpm plugins."
