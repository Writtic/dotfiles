# Global Instructions

## LLM Wiki — central cross-repo knowledge hub (recall + sync)

My work knowledge (decisions, architecture, debugging learnings, design specs, prompts) is
synthesized and maintained in a central Obsidian wiki. Repo-local capture (ce-compound
`docs/solutions/`, superpowers `docs/superpowers/`) stays as-is; the wiki sits on top as the
single point that aggregates that knowledge across repos.

```
Wiki:  ~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work/LLMWiki
Canon: Work/LLMWiki/CLAUDE.md   ← schema, conventions, workflows. Follow it before reading/writing the wiki.
```

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
- (Recommended) Register the Wiki path `**` under `permissions.allow` in `~/.claude/settings.json` for Read/Edit/Write
  so writes work without permission prompts from other repos. Without it, prompts may appear depending on mode.
- The wiki lives on an iCloud path and may briefly vanish → on write failure, **don't abort**; leave a note in the repo
  and reconcile next session. A wiki-sync failure must never block repo-local capture (ce-compound, etc.). The wiki is a secondary artifact.
