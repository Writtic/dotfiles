# llmwiki-researcher Agent Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the `llmwiki-researcher` subagent that surfaces prior cross-repo knowledge from the central LLM Wiki before non-trivial work, resolving the broken reference in the global `~/.claude/CLAUDE.md` RECALL workflow.

**Architecture:** A single read-only agent definition file (`claude/.claude/agents/llmwiki-researcher.md`) in the stow-managed dotfiles repo. It navigates the wiki hub-first (read `index.md` → relevant `systems/` hubs → follow `related` links), falls back to frontmatter grep, and returns a system-grouped digest with Obsidian `[[wikilink]]` + absolute-path references. Wiki-only scope: it caveats staleness via `status`/`updated` but never reads repo code. The deliverable is prose, not code; "tests" are inline shell assertions over the file's frontmatter, tool grants, and spec-section coverage.

**Tech Stack:** Markdown + YAML frontmatter (Claude Code agent format), GNU Stow (symlink deploy), `rg`/`grep` for validation. No runtime dependencies.

**Spec:** `docs/superpowers/specs/2026-06-01-llmwiki-researcher-agent-design.md`

---

## File Structure

- **Create:** `claude/.claude/agents/llmwiki-researcher.md` — the entire deliverable. One file, one responsibility: the agent's identity (frontmatter) + operational instructions (body).
- **Reference (read-only, do not edit):** `claude/.claude/CLAUDE.md` — already names `llmwiki-researcher` in its RECALL section; creating the file resolves that reference. Validation asserts the names match.
- **Reference (read-only):** `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work/LLMWiki/CLAUDE.md` — the wiki canon; the agent's embedded schema/path must stay consistent with it.

No test framework, no source tree — this repo is dotfiles. Validation is inline shell.

---

## Task 1: Author the agent definition file

**Files:**
- Create: `claude/.claude/agents/llmwiki-researcher.md`

- [ ] **Step 1: Write the validation script and run it (expect FAIL — file absent)**

Save this as a throwaway check (run from repo root). It is the "failing test" — it must fail now because the file does not exist yet. Do NOT commit this script; it is run inline.

```bash
cat > /tmp/validate-llmwiki-researcher.sh <<'SH'
#!/bin/bash
# Inline validation for the llmwiki-researcher agent file. Exit 0 = all pass.
set -u
F="claude/.claude/agents/llmwiki-researcher.md"
fail=0
check() { if eval "$2"; then echo "PASS: $1"; else echo "FAIL: $1"; fail=1; fi; }

check "file exists"                         "[ -f '$F' ]"
check "has opening frontmatter delimiter"   "head -1 '$F' | grep -qx -- '---'"
check "name matches filename (llmwiki-researcher)" "grep -qE '^name:[[:space:]]*llmwiki-researcher[[:space:]]*$' '$F'"
check "model: inherit"                       "grep -qE '^model:[[:space:]]*inherit[[:space:]]*$' '$F'"
check "tools line present"                   "grep -qE '^tools:' '$F'"
check "tools include Read/Grep/Glob/Bash"    "grep -E '^tools:' '$F' | grep -q 'Read' && grep -E '^tools:' '$F' | grep -q 'Grep' && grep -E '^tools:' '$F' | grep -q 'Glob' && grep -E '^tools:' '$F' | grep -q 'Bash'"
check "tools are READ-ONLY (no Write/Edit)"  "! grep -E '^tools:' '$F' | grep -qE 'Write|Edit'"
check "embeds the canonical wiki path"       "grep -qF 'iCloud~md~obsidian/Documents/Work/LLMWiki' '$F'"
check "availability guard (unreachable/skip)" "grep -qiE 'unreachable|reachable' '$F'"
check "hub-first: reads index.md"            "grep -qF 'index.md' '$F'"
check "hub-first: systems hubs"              "grep -qiE 'systems/' '$F' && grep -qiE 'hub' '$F'"
check "follows related wikilinks"            "grep -qiE 'related' '$F'"
check "grep fallback present"                "grep -qiE 'fallback' '$F' && grep -qF 'rg ' '$F'"
check "staleness caveat (status/superseded)" "grep -qiE 'superseded|archived' '$F' && grep -qiE 'updated' '$F'"
check "wiki-only: does NOT read repo code"   "grep -qiE 'do( not| NOT)? read repo code|never read repo code|not read repo' '$F'"
check "output: wikilink + absolute path"     "grep -qF '[[wikilink]]' '$F' || grep -qF '[[' '$F'"
check "output: cross-repo source_repo"       "grep -qF 'source_repo' '$F'"
check "output: caps (~3 systems)"            "grep -qiE 'cap' '$F' && grep -qE '3 systems' '$F'"
check "output: no-results handling"          "grep -qiE 'no results|absence' '$F'"
check "non-goals: does not write to wiki"    "grep -qiE 'never write|do not write|not your job' '$F'"
check "name referenced by global CLAUDE.md"  "grep -qF 'llmwiki-researcher' claude/.claude/CLAUDE.md"

echo "----"
[ "$fail" -eq 0 ] && echo "ALL CHECKS PASSED" || echo "SOME CHECKS FAILED"
exit $fail
SH
bash /tmp/validate-llmwiki-researcher.sh
```

Run: `bash /tmp/validate-llmwiki-researcher.sh`
Expected: **FAIL: file exists** (and the run prints `SOME CHECKS FAILED`, exit 1) because the agent file is not yet created.

- [ ] **Step 2: Create the agent file with the complete content below**

Write this exact content to `claude/.claude/agents/llmwiki-researcher.md`:

````markdown
---
name: llmwiki-researcher
description: "Use before non-trivial work, decisions, plans, or solution design to surface prior cross-repo knowledge from the central LLM Wiki. Run in parallel with compound's ce-learnings-researcher — central hub vs repo-local."
tools: Read, Grep, Glob, Bash
model: inherit
---

You are the central cross-repo knowledge researcher for the LLM Wiki. Your job is to
surface relevant prior knowledge — systems, decisions, learnings, specs — before new work
begins, so the caller doesn't rediscover what was already worked out in this or another
repo. You read the wiki and report; you never write to it, never read repo code, and never
invent answers the wiki doesn't contain.

You are the central-hub counterpart to `ce-learnings-researcher`, which searches the
repo-local `docs/solutions/`. You are typically dispatched alongside it: central hub vs
repo-local.

## The LLM Wiki

- **Path**: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work/LLMWiki`
- **Page types**: `systems/` (hubs), `decisions/`, `learnings/`, `specs/`, `prompts/`, `_meta/`
- **Root files**: `index.md` (catalog), `log.md` (chronological log)
- **Hub structure**: every non-system page links to at least one `systems/` page — systems are the hubs.
- **Frontmatter** (every page): `type, module, status, created, updated, tags, related, source`.
  Learnings additionally carry `problem_type, severity, source_repo, source_doc`.

The wiki path is outside whatever repo you're invoked from and contains spaces, so use Bash
(`rg`, `find`, `ls`) with the quoted absolute path for searching and existence checks, and
use Read for reading specific pages.

## Step 0 — Availability guard (always first)

Check the wiki is reachable before anything else:

```bash
ls "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work/LLMWiki/index.md"
```

If this fails (the iCloud path can briefly vanish), STOP and return exactly one line:

> LLM Wiki unreachable — central recall skipped. Proceed without it; the wiki is a secondary artifact and must not block your work.

Never error out, never block the caller.

## Input

You receive a `<work-context>` block — the same shape the orchestrator passes to
ce-learnings-researcher:

```
<work-context>
Activity:  <what the caller is doing or considering>
Concepts:  <named ideas, abstractions, approaches the work touches>
Decisions: <specific decisions under consideration, if any>
Domains:   <optional hint>
</work-context>
```

Free-form prose is also accepted — treat it as the Activity field and extract keywords
heuristically. Search `prompts/` only when the work-context explicitly asks for a reusable
prompt.

## Search strategy — hub-first

1. **Extract keywords** from the work-context: module/system names, concepts, decisions, domains.
2. **Read `index.md`** — the catalog is your entry map.
3. **Identify relevant `systems/` hubs** from the index by module/keyword match. The system
   page is the synthesized current understanding — the highest-value entry point.
4. **Drill down through hubs**: read each relevant system page and follow its `related`
   wikilinks into the connected `decisions/`, `learnings/`, and `specs/` pages.
5. **Grep fallback** — when the index/hub doesn't surface a confident match, or you suspect
   a relevant page not yet linked from a hub, run parallel frontmatter greps over the wiki
   (case-insensitive, synonyms joined with `|`):

   ```bash
   WIKI="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work/LLMWiki"
   rg -li "^type:\s*(system|decision|learning|spec)" "$WIKI" -g '*.md'
   rg -li "^module:.*(<kw1>|<kw2>)" "$WIKI" -g '*.md'
   rg -li "^(tags|title):.*(<kw1>|<kw2>)" "$WIKI" -g '*.md'
   ```

6. **Read the shortlist** — fully read the candidate pages, within the output caps below.
7. **Scale note**: at the wiki's current size (tens of pages) the index/hub walk is primary
   and grep is the fallback. As the wiki grows past a few hundred pages, promote the grep
   pass to a primary pre-filter. If a wiki search tool (obsidian-mcp, qmd) is present in
   your runtime, you may use it as the pre-filter; otherwise use the filesystem.

## Staleness caveat — wiki-only

For each page you surface, read `status` and `updated`/`created`:

- `status: superseded` or `archived` → flag with a strong caveat, or drop it when a newer page supersedes it.
- An old `updated` date → note "may be stale (updated YYYY-MM-DD)".
- If the page itself carries a contradiction callout, pass it through verbatim.

You do NOT read repo code. Surface findings with date/status caveats and leave the actual
conflict-with-reality judgment to the caller, who holds the full repo context. Research
agents can be confidently wrong — never let a wiki claim silently override present evidence.

## Output format

Return a system-grouped digest. Every page reference is both a `[[wikilink]]` (for Obsidian)
and an absolute path (so the caller can open it). The output is consumed as prose — optimize
for a human reading it with Obsidian open, not for field parsing. Write the prose in Korean
(the wiki's body language); keep identifiers, paths, and `[[wikilinks]]` verbatim.

```markdown
## LLM Wiki Recall

### Search context
- **Activity**: <one-line summary of the caller's work>
- **Keywords**: <systems / modules / concepts / domains searched>
- **Wiki**: ~/.../Work/LLMWiki — <N> pages scanned, <M> matched

### [[systems/<name>]] — <module>
<1–3 line current-understanding summary from the hub> · <status/date caveat if any>

- **Decision** [[decisions/<page>]] (`<abs path>`) — <one-line insight> · <caveat>
- **Learning** [[learnings/<page>]] (`<abs path>`) — <one-line insight> · source_repo: <repo> · <caveat>
- **Spec** [[specs/<page>]] (`<abs path>`) — <one-line insight>

### [[systems/<other>]] — ...

### Recommendations
- <what to reuse, mirror, or watch out for, grounded in the surfaced pages>
```

- **Cross-repo signal**: always surface `source_repo`/`module` so the caller sees when a
  finding came from a *different* repo's work — that is the central hub's main value.
- **Caps**: up to ~3 systems, ~5 supporting items each. If you truncate, add a one-line
  "N additional matches exist" note.
- **No results**: say so explicitly, include the search context, and note that this work may
  be worth syncing into the wiki after it lands — the absence is itself signal.

## You do not

- Write to the wiki — that is never your job; the SYNC workflow belongs to the main agent.
- Read repo code or docs outside the wiki.
- Invent answers when the wiki is silent.
- Search `prompts/` unless explicitly asked for a reusable prompt.
````

- [ ] **Step 3: Run the validation script (expect ALL CHECKS PASSED)**

Run: `bash /tmp/validate-llmwiki-researcher.sh`
Expected: every line prints `PASS:`, final line `ALL CHECKS PASSED`, exit 0.

If any check fails, fix the file content to satisfy it (the checks encode the spec's required sections), then re-run until all pass.

- [ ] **Step 4: Commit**

```bash
git add claude/.claude/agents/llmwiki-researcher.md
git commit -m "feat(claude): add llmwiki-researcher agent for central wiki recall

Resolves the broken reference in the global RECALL workflow. Hub-first
navigation, system-grouped digest with Obsidian links, wiki-only scope
with staleness caveats. Read-only; mirrors ce-learnings-researcher input.

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 2: Verify spec coverage and consistency with the canon

**Files:**
- Reference: `claude/.claude/agents/llmwiki-researcher.md`, `claude/.claude/CLAUDE.md`, wiki canon

- [ ] **Step 1: Assert the wiki path is byte-identical to the global CLAUDE.md**

Run:

```bash
grep -oF 'iCloud~md~obsidian/Documents/Work/LLMWiki' claude/.claude/agents/llmwiki-researcher.md | sort -u
grep -oF 'iCloud~md~obsidian/Documents/Work/LLMWiki' claude/.claude/CLAUDE.md | sort -u
```

Expected: both print the identical single line `iCloud~md~obsidian/Documents/Work/LLMWiki`. If they differ, fix the agent file to match the canon path exactly.

- [ ] **Step 2: Confirm page types and frontmatter fields match the canon**

Run:

```bash
for t in systems decisions learnings specs prompts; do
  grep -qF "$t/" claude/.claude/agents/llmwiki-researcher.md && echo "ok: $t" || echo "MISSING: $t"
done
for f in type module status created updated tags related source source_repo problem_type; do
  grep -qF "$f" claude/.claude/agents/llmwiki-researcher.md && echo "ok: $f" || echo "MISSING: $f"
done
```

Expected: every line prints `ok:`. Any `MISSING:` means a spec field/type was dropped — add it to the agent's "The LLM Wiki" or frontmatter notes and re-run.

- [ ] **Step 3: Spec section walk (manual cross-check)**

Open `docs/superpowers/specs/2026-06-01-llmwiki-researcher-agent-design.md` and confirm each spec section maps to agent content:

- §3.1 metadata → frontmatter (name/tools/model) ✓ asserted in Task 1
- §3.2 input contract → "## Input" `<work-context>` block
- §3.3 availability guard → "## Step 0 — Availability guard"
- §3.4 hub-first search → "## Search strategy — hub-first" steps 1–7
- §3.5 staleness caveat → "## Staleness caveat — wiki-only"
- §3.6 output format → "## Output format" + caps + cross-repo + no-results
- §3.7 non-goals → "## You do not"

Fix any gap inline, then re-run the Task 1 validation script.

- [ ] **Step 4: Commit any fixes (skip if clean)**

```bash
git add claude/.claude/agents/llmwiki-researcher.md
git commit -m "fix(claude): align llmwiki-researcher with canon path and schema

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

If `git status --short` shows no changes to the agent file, skip the commit.

---

## Activation & smoke test (post-merge, manual — not a committable task)

The agent only becomes live after the dotfiles are stowed and a new session starts (stow
symlinks individual files into `~/.claude/agents/`, and the agent registry is read at
session start). After merging this branch to `master`:

1. **Re-stow** from the main checkout so the new file is symlinked:
   ```bash
   cd ~/repo/dotfiles && ./bootstrap.sh
   ls -l ~/.claude/agents/llmwiki-researcher.md   # expect a symlink into repo/dotfiles
   ```
2. **Start a new `claude` session** so the agent registry picks it up.
3. **Smoke-test three scenarios** (dispatch the agent via the Agent tool with `subagent_type: llmwiki-researcher`):
   - **Hub match**: pass a `<work-context>` naming a system that exists in the wiki (e.g. one under `systems/`). Expect a system-grouped digest with `[[wikilinks]]` + absolute paths and any `status`/`updated` caveats.
   - **No results**: pass a `<work-context>` about a topic absent from the wiki. Expect the explicit "no results + worth syncing after it lands" message.
   - **Unreachable**: temporarily rename the wiki dir (or test on a machine where iCloud hasn't synced) and confirm the agent returns the single-line "LLM Wiki unreachable — central recall skipped" without erroring.

Record any prompt adjustments needed and fold them back into the agent file (a follow-up commit).

---

## Self-Review (plan author)

- **Spec coverage**: every §3 subsection maps to an agent section and a Task 1 validation check (Task 2 §3 re-verifies). ✓
- **Placeholder scan**: the only `<...>` tokens are inside the agent's own output-format template and the work-context block — they are illustrative template content the agent fills at runtime, not plan gaps. The full agent file content is provided verbatim. ✓
- **Consistency**: the wiki path string, page-type names, and frontmatter fields used in Task 2 assertions match those written in Task 1's file content and the canon. The validation script's tool-grant check (Read/Grep/Glob/Bash, no Write/Edit) matches the frontmatter `tools:` line. ✓
