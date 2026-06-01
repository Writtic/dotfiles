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
synthesized and maintained in a central Obsidian wiki. Repo-local capture (ce-compound
`docs/solutions/`, superpowers `docs/superpowers/`) stays as-is; the wiki sits on top as the
single point that aggregates that knowledge across repos.

```
Wiki:  ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work/LLMWiki
Canon: Work/LLMWiki/CLAUDE.md   ← schema, conventions, workflows. Follow it before reading/writing the wiki.
```

**Canon-unreachable fallback** — the canon lives in the wiki, which may briefly vanish (iCloud; see Sync guards).
If you can't read it, this is the minimum to write a valid page without it (reconcile against the full canon next session):
- Folders: `systems/` `decisions/` `learnings/` `specs/` `prompts/`; root `index.md` (catalog) + `log.md` (append-only).
- Frontmatter on every page: `type, module, status, created, updated, tags, related, source` (dates `YYYY-MM-DD`).
- Every non-`system` page links to ≥1 `systems/` page (systems are the hub). Use `[[wikilinks]]`; leave no orphans.
- `log.md` entries: `## [YYYY-MM-DD] <op> | <title>`, `<op>` ∈ `ingest|compound-sync|spec-sync|query|lint|seed|meta`.

### RECALL — before non-trivial work, decisions, plans, or solution design
Use the `llmwiki-researcher` agent to surface relevant prior knowledge from the wiki.
Run it **alongside** compound's `ce-learnings-researcher` (repo-local `docs/solutions/`) — central hub vs repo-local.
If surfaced content conflicts with current code/docs, don't follow it blindly: flag the conflict and judge staleness by date.

### SYNC — when the following land in a repo, mirror a synthesized page into the wiki + update `index.md`/`log.md`
- `/ce-compound` learnings (`docs/solutions/**`)        → `LLMWiki/learnings/`
- brainstorming specs    (`docs/superpowers/specs/**`)  → `LLMWiki/specs/`
- writing-plans plans    (`docs/superpowers/plans/**`)  → `LLMWiki/specs/` (absorbed as links on the spec page)

**Synthesize, don't copy-paste**: update related `systems/`/`decisions/` pages, cross-link, and flag contradictions.
Full procedure lives in the canon above.

### Sync guards
- Write to the wiki **directly** with Write/Edit (absolute path). Use obsidian-mcp only as a search fallback.
- **Required for unattended sync**: register the Wiki path under `permissions.allow` in `~/.claude/settings.json`
  for Read/Edit/Write (e.g. `Edit(~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work/LLMWiki/**)`).
  The wiki always sits outside whatever repo you're in, so without this rule every wiki write prompts for permission
  and breaks the flow. Scope the rule to the wiki path — don't allow a bare `**`.
- The wiki lives on an iCloud path and may briefly vanish → on write failure, **don't abort**; leave a note in the repo
  and reconcile next session. A wiki-sync failure must never block repo-local capture (ce-compound, etc.). The wiki is a secondary artifact.
