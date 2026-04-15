#!/bin/bash
# sync.sh -- commit + pull-rebase + push the dotfiles repo.
# Safe to run from cron; bails out cleanly on rebase conflicts.

set -euo pipefail

cd "$(dirname "$0")"

# Commit any pending changes with a timestamped message.
if ! git diff --quiet || ! git diff --cached --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
	git add -A
	git commit -m "sync: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
else
	echo ":: no local changes to commit"
fi

# Pull with rebase + autostash. If rebase fails, abort cleanly and exit non-zero
# so cron/caller sees the failure instead of a half-merged tree.
if ! git pull --rebase --autostash; then
	echo "ERROR: rebase failed; aborting and leaving working tree clean." >&2
	git rebase --abort 2>/dev/null || true
	exit 1
fi

git push
