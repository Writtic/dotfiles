# Global Instructions

Cross-repo rules that apply everywhere. Each repo's own CLAUDE.md owns its repo-local conventions;
this file is only for what holds across every repo: the house writing voice and the LLM Wiki workflow below.

## House writing voice — plain, concrete, no AI tells

Every prose artifact I produce (PR descriptions, commit messages, Linear/Jira issues and comments,
design notes, status updates, docs) is written plainly and factually, not in AI-slop register.

The full checklist lives in the `writing-style` skill. Invoke it whenever you draft or edit such prose,
alongside the format-owning skill (`pull-request`, `git-commit`) or command (`/create-pr`, `/linear`).
The skill owns voice; the invoking context owns format (template, 해요체, headers, depth).

**Fallback minimum** (hold even when the skill is not loaded):
- No em-dash (—); split with a comma or a period.
- No contrastive negation ("not just X but Y", "단순히 X가 아니라 Y").
- No smell words (delve, leverage, intricate, pivotal, crucial, foster, harness, unlock, showcase, myriad)
  and no self-aggrandizing adjectives (clean, elegant, powerful, robust, seamless, comprehensive).
- No marketing tone. State what the change does; do not sell it.
- Prefer plain, concrete words over internal jargon; spell out a causal chain in steps, not one compressed term.

## LLM Wiki — central cross-repo knowledge hub (recall + sync)

My work knowledge (decisions, architecture, debugging learnings, design specs, prompts) is
synthesized and maintained in a central Obsidian wiki. Both `/compound` and the superpowers
brainstorming/writing-plans skills write directly to the wiki; the repo keeps no copy. The wiki is
the single point that aggregates knowledge across repos.

```
Wiki:  ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work/LLMWiki
Canon: Work/LLMWiki/CLAUDE.md   ← schema, conventions, workflows. Follow it before reading/writing the wiki.
```

**Canon-unreachable fallback** — the canon lives in the wiki, which may briefly vanish (iCloud; see Sync guards).
If you can't read it, this is the minimum to write a valid page without it (reconcile against the full canon next session):
- Folders: `systems/` `decisions/` `learnings/` `specs/` `plans/` `prompts/`; root `index.md` (catalog) + `log.md` (append-only).
- Frontmatter on every page: `type, module, status, created, updated, tags, related, source` (dates `YYYY-MM-DD`).
- Every non-`system` page links to ≥1 `systems/` page (systems are the hub). Use `[[wikilinks]]`; leave no orphans.
- `log.md` entries: `## [YYYY-MM-DD] <op> | <title>`, `<op>` ∈ `ingest|compound-sync|spec-sync|query|lint|seed|meta`.

### RECALL — before non-trivial work, decisions, plans, or solution design
Use the `llmwiki-researcher` agent to surface relevant prior knowledge from the wiki.
If surfaced content conflicts with current code/docs, don't follow it blindly: flag the conflict and judge staleness by date.

### SYNC — knowledge lands directly in the wiki
- `/compound` writes the detail to `LLMWiki/docs/` and a synthesis to `LLMWiki/learnings/` directly.
- brainstorming spec → write directly to `LLMWiki/specs/`; writing-plans plan → `LLMWiki/plans/`. Both skills document a location override (`User preferences for spec/plan location override this default`) — exercise it: author the page in the wiki (wiki frontmatter + systems link), and skip the skill's repo write and its "commit to git" step. No `docs/superpowers/` copy. The executor (executing-plans/subagent-driven-development) reads and updates the plan's checkboxes at the wiki path.
  - Fallback only: if the wiki is unreachable, write to repo `docs/superpowers/` (gitignored) + leave a note, reconcile to the wiki next session.

**Synthesize, don't copy-paste**: update related `systems/`/`decisions/` pages, cross-link, and flag contradictions.
Full procedure lives in the canon above.

### Sync guards
- Write to the wiki **directly** with Write/Edit (absolute path). Use obsidian-mcp only as a search fallback.
- **Required for unattended sync**: register the Wiki path under `permissions.allow` in `~/.claude/settings.json`
  for Read/Edit/Write (e.g. `Edit(~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work/LLMWiki/**)`).
  The wiki always sits outside whatever repo you're in, so without this rule every wiki write prompts for permission
  and breaks the flow. Scope the rule to the wiki path — don't allow a bare `**`.
- The wiki lives on an iCloud path and may briefly vanish → on write failure, **don't abort**; fall back to the repo
  (gitignored `docs/superpowers/` for specs/plans, a note for compound) and reconcile to the wiki next session.
  Resilience only: the wiki is the primary home, the repo fallback is a temporary holding spot, not a second copy to maintain.
