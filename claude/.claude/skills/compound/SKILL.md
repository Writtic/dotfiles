---
name: compound
description: Document a recently solved problem to compound your knowledge into the LLM Wiki (docs/ detail + learnings/ synthesis). Self-contained, no plugin dependency.
argument-hint: "[optional: brief context] [mode:headless]"
---

# /compound

Coordinate multiple subagents working in parallel to document a recently solved problem.

## Purpose

Captures problem solutions while context is fresh, creating structured documentation directly in the LLM Wiki with YAML frontmatter for searchability and future reference. Writes two wiki pages per learning: a full detail page at `$WIKI/docs/<slug>.md` and a concise synthesis at `$WIKI/learnings/<slug>.md`. Uses parallel subagents for maximum efficiency.

**Why "compound"?** Each documented solution compounds your team's knowledge. The first time you solve a problem takes research. Document it, and the next occurrence takes minutes. Knowledge compounds.

## Usage

```bash
/compound                            # Document the most recent fix
/compound [brief context]            # Provide additional context hint
/compound mode:headless              # Non-interactive run for automations
/compound mode:headless [context]    # Non-interactive run with context hint
```

## CONCEPTS.md bootstrap requests

If invoked specifically to create or bootstrap `CONCEPTS.md` from scratch rather than to document a solved problem, do not run the normal phases — `/compound` populates `CONCEPTS.md` only as a side effect of documenting a real learning (it seeds the *learning's area*, not the whole repo; see Phase 2.4). Repo-wide concept-map creation is outside the scope of this skill. Redirect a standalone bootstrap request and exit.

## Mode Detection

Check `$ARGUMENTS` for a `mode:headless` token. Tokens starting with `mode:` are flags, not context — strip `mode:headless` from arguments before treating the remainder as the brief context hint.

| Mode | When | Behavior |
|------|------|----------|
| **Interactive** (default) | No mode token present | Ask Full vs Lightweight, end with "What's next?" |
| **Headless** | `mode:headless` in arguments | No blocking questions. Run **Full mode**. Skip Phase 3 specialized reviews. End with a structured terminal report — no "What's next?" menu. |

Headless mode is intended for automations and skill-to-skill invocation where no human is present to answer questions. The doc itself is identical to what an interactive Full run would produce — classification work (track, category, overlap) follows the same rules and writes nothing extra into the artifact. Once detected, headless mode applies for the entire run.

## Support Files

These files are the durable contract for the workflow. Read them on-demand at the step that needs them — do not bulk-load at skill start.

- `references/schema.yaml` — canonical frontmatter fields and enum values (read when validating YAML)
- `references/yaml-schema.md` — category mapping from problem_type to directory (read when classifying)
- `references/concepts-vocabulary.md` — CONCEPTS.md format and inclusion rules (read in Phase 2.4 when domain terms surface)
- `assets/resolution-template.md` — section structure for new docs (read when assembling)

When spawning subagents, pass the relevant file contents into the task prompt so they have the contract.

## Execution Strategy

**In headless mode**, skip the question below and go directly to **Full Mode**. Proceed straight to research.

**In interactive mode**, present the user with two options before proceeding, using the platform's blocking question tool: `AskUserQuestion` in Claude Code (call `ToolSearch` with `select:AskUserQuestion` first if its schema isn't loaded), `request_user_input` in Codex, `ask_user` in Gemini, `ask_user` in Pi (requires the `pi-ask-user` extension). Fall back to presenting options in chat only when no blocking tool exists in the harness or the call errors (e.g., Codex edit modes) — not because a schema load is required. Never silently skip the question.

```
1. Full (recommended) — the complete compound workflow. Researches,
   cross-references, and reviews your solution to produce documentation
   that compounds your team's knowledge.

2. Lightweight — same documentation, single pass. Faster and uses
   fewer tokens, but won't detect duplicates or cross-reference
   existing docs. Best for simple fixes or long sessions nearing
   context limits.
```

In interactive mode, do NOT pre-select a mode, do NOT skip this prompt, and wait for the user's choice before proceeding. (Headless mode bypasses this prompt per the "**In headless mode**" rule above and runs Full directly — these "do not skip" directives do not apply to headless.)

---

### Full Mode

<critical_requirement>
**The primary deliverables are TWO wiki pages - the detail doc and the synthesis.**

Phase 1 subagents return TEXT DATA to the orchestrator. They must NOT use Write, Edit, or create any files. Only the orchestrator writes files. Beyond the Phase 2 wiki pages, its other writes are maintenance side effects — not additional deliverables, and creating one when absent is expected, not a violation of this rule:
- **`CONCEPTS.md`** — create or update in Phase 2.4 (Vocabulary Capture) when a qualifying domain term surfaces.

The wiki pages ensure knowledge is centralized and discoverable across repos.
</critical_requirement>

### Phase 0.5: Auto Memory Scan

Before launching Phase 1 subagents, check the auto-memory block injected into your system prompt for notes relevant to the problem being documented.

1. Look for a block labeled "user's auto-memory" (Claude Code only) already present in your system prompt context — MEMORY.md's entries are inlined there
2. If the block is absent, empty, or this is a non-Claude-Code platform, skip this step and proceed to Phase 1 unchanged
3. Scan the entries for anything related to the problem being documented -- use semantic judgment, not keyword matching
4. If relevant entries are found, prepare a labeled excerpt block:

```
## Supplementary notes from auto memory
Treat as additional context, not primary evidence. Conversation history
and codebase findings take priority over these notes.

[relevant entries here]
```

5. Pass this block as additional context to the Context Analyzer and Solution Extractor task prompts in Phase 1. If any memory notes end up in the final documentation (e.g., as part of the investigation steps or root cause analysis), tag them with "(auto memory [claude])" so their origin is clear to future readers.

If no relevant entries are found, proceed to Phase 1 without passing memory context.

### Phase 1: Research

Launch research subagents. Each returns text data to the orchestrator.

**Dispatch order:**
- Launch `Context Analyzer`, `Solution Extractor`, and `Related Docs Finder` in parallel (background)

<parallel_tasks>

#### 1. **Context Analyzer**
   - Extracts conversation history
   - Reads `references/schema.yaml` for enum validation and **track classification**
   - Determines the track (bug or knowledge) from the problem_type
   - Identifies problem type, component, and track-appropriate fields:
     - **Bug track**: symptoms, root_cause, resolution_type
     - **Knowledge track**: applies_when (symptoms/root_cause/resolution_type optional)
   - Incorporates auto memory excerpts (if provided by the orchestrator) as supplementary evidence
   - Reads `references/yaml-schema.md` for category mapping (category lives in frontmatter/tags, not in path — `$WIKI/docs/` is flat)
   - Suggests a filename using the pattern `[sanitized-problem-slug].md` — no date suffix, even if existing files in the wiki have one; the `date:` frontmatter field is the canonical creation date
   - Returns: YAML frontmatter skeleton (must include `category:` field mapped from problem_type, plus `source_repo` for provenance), suggested slug/filename, and which track applies
   - Does not invent enum values, categories, or frontmatter fields from memory; reads the schema and mapping files above
   - Does not force bug-track fields onto knowledge-track learnings or vice versa

#### 2. **Solution Extractor**
   - Reads `references/schema.yaml` for track classification (bug vs knowledge)
   - Adapts output structure based on the problem_type track
   - Incorporates auto memory excerpts (if provided by the orchestrator) as supplementary evidence -- conversation history and the verified fix take priority; if memory notes contradict the conversation, note the contradiction as cautionary context

   **Bug track output sections:**

   - **Problem**: 1-2 sentence description of the issue
   - **Symptoms**: Observable symptoms (error messages, behavior)
   - **What Didn't Work**: Failed investigation attempts and why they failed
   - **Solution**: The actual fix with code examples (before/after when applicable)
   - **Why This Works**: Root cause explanation and why the solution addresses it
   - **Prevention**: Strategies to avoid recurrence, best practices, and test cases. Include concrete code examples where applicable (e.g., gem configurations, test assertions, linting rules)

   **Knowledge track output sections:**

   - **Context**: What situation, gap, or friction prompted this guidance
   - **Guidance**: The practice, pattern, or recommendation with code examples when useful
   - **Why This Matters**: Rationale and impact of following or not following this guidance
   - **When to Apply**: Conditions or situations where this applies
   - **Examples**: Concrete before/after or usage examples showing the practice in action

#### 3. **Related Docs Finder**
   - Searches `$WIKI/docs/` and `$WIKI/learnings/` for related documentation (where `WIKI="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work/LLMWiki"`)
   - Identifies cross-references and links
   - Finds related GitHub issues
   - Flags any related learning or pattern docs that may now be stale, contradicted, or overly broad
   - **Assesses overlap** with the new doc being created across five dimensions: problem statement, root cause, solution approach, referenced files, and prevention rules. Score as:
     - **High**: 4-5 dimensions match — essentially the same problem solved again
     - **Moderate**: 2-3 dimensions match — same area but different angle or solution
     - **Low**: 0-1 dimensions match — related but distinct
   - Returns: Links, relationships, refresh candidates, and overlap assessment (score + which dimensions matched)

   **Search strategy (grep-first filtering for efficiency):**

   1. Extract keywords from the problem context: module names, technical terms, error messages, component types
   2. Search both `$WIKI/docs/` (flat directory, no category subdirectories) and `$WIKI/learnings/`
   3. Use the native content-search tool (e.g., Grep in Claude Code) to pre-filter candidate files BEFORE reading any content. Run multiple searches in parallel, case-insensitive, targeting frontmatter fields. These are template patterns -- substitute actual keywords:
      - `title:.*<keyword>`
      - `tags:.*(<keyword1>|<keyword2>)`
      - `module:.*<module name>`
      - `component:.*<component>`
   4. If search returns >25 candidates, re-run with more specific patterns. If <3, broaden to full content search
   5. Read only frontmatter (first 30 lines) of candidate files to score relevance
   6. Fully read only strong/moderate matches
   7. Return distilled links and relationships, not raw file contents

   **GitHub issue search:**

   Prefer the `gh` CLI for searching related issues: `gh issue list --search "<keywords>" --state all --limit 5`. If `gh` is not installed, fall back to the GitHub MCP tools (e.g., `unblocked` data_retrieval) if available. If neither is available, skip GitHub issue search and note it was skipped in the output.

</parallel_tasks>

### Phase 2: Assembly & Write

<sequential_tasks>

**WAIT for all Phase 1 subagents to complete before proceeding** — the three parallel subagents must all return before Phase 2 begins.

The orchestrating agent (main conversation) performs these steps:

1. Collect all text results from Phase 1 subagents

2. **Availability guard.** Set `WIKI="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work/LLMWiki"`. Run `ls "$WIKI/index.md"`. If the command fails (the iCloud path can vanish), STOP immediately and report one line: "LLM Wiki unreachable — capture deferred. Leave a note in the repo and reconcile next session." Do not write anything.

3. **Check the overlap assessment** from the Related Docs Finder before deciding what to write:

   | Overlap | Action |
   |---------|--------|
   | **High** — existing wiki doc covers the same problem, root cause, and solution | **Update the existing `$WIKI/docs/<slug>.md`** with fresher context (new code examples, updated references, additional prevention tips) rather than creating a duplicate. The existing doc's path and frontmatter structure stay the same. Also update the corresponding `$WIKI/learnings/<slug>.md` synthesis if it exists. |
   | **Moderate** — same problem area but different angle, root cause, or solution | **Create the new docs** normally. Flag the overlap for Phase 2.5 to recommend consolidation review. |
   | **Low or none** | **Create the new docs** normally. |

   The reason to update rather than create: two docs describing the same problem and solution will inevitably drift apart. The newer context is fresher and more trustworthy, so fold it into the existing doc rather than creating a second one that immediately needs consolidation.

   When updating an existing doc, preserve its file path and frontmatter structure. Update the solution, code examples, prevention tips, and any stale references. Add a `last_updated: YYYY-MM-DD` field to the frontmatter. Do not change the title unless the problem framing has materially shifted.

4. Assemble the complete detail markdown from the collected pieces, reading `assets/resolution-template.md` for the section structure.

5. Validate YAML frontmatter against `references/schema.yaml`, including the YAML-safety quoting rule for array items (see `references/yaml-schema.md` > YAML Safety Rules). The detail doc frontmatter must include: `type: learning`, `module`, `status`, `created`, `updated`, `tags`, `source_repo` (the repo where the problem occurred, for provenance), `problem_type`, and `severity`. Do NOT include a `source_doc:` repo-path field. Include an outbound `[[wikilink]]` to the relevant `systems/` hub page in the frontmatter `related:` field. Do NOT add a back-link to `learnings/`.

6. **Write the DETAIL doc to `$WIKI/docs/<slug>.md`**: the fully assembled content from step 4. The `docs/` directory is flat — no subdirectories; category lives in frontmatter `tags` and `problem_type`, not in the path.

7. **Run `python3 claude/.claude/skills/compound/scripts/validate-frontmatter.py "$WIKI/docs/<slug>.md"`** to catch silent-corruption parser-safety issues: malformed `---` delimiter lines, unquoted ` #` in scalar values (silent comment truncation), and unquoted `: ` in scalar values (silent mapping confusion). Exit 0 means the doc is parser-safe; exit 1 means the script's stderr names the offending field(s) and what to fix — quote the value(s), re-write the doc, and re-run until exit 0. Do not declare success while validation fails.

8. **Write the SYNTHESIS doc to `$WIKI/learnings/<slug>.md`**: a concise synthesis of the learning. Its frontmatter must include `detail: "[[docs/<slug>]]"` (one-way link to the detail doc) and a `related:` field with a `[[systems/...]]` hub wikilink. The synthesis is the catalog-facing entry — keep it short (problem in one sentence, solution in two, key takeaway).

9. **Cross-link**: update the relevant `$WIKI/systems/<hub>.md` page's "관련 작업/맥락" section (or equivalent) with a wikilink to the new `[[learnings/<slug>]]`.

10. **Update `$WIKI/index.md`**: add the learning under the Learnings category with a `→ [[systems/...]]` hub reference and note the detail doc at `docs/<slug>.md`. Append to **`$WIKI/log.md`** a new entry: `## [YYYY-MM-DD] compound | <title>`.

When creating new docs, preserve the section order from `assets/resolution-template.md` unless the user explicitly asks for a different structure.

</sequential_tasks>

### Phase 2.4: Vocabulary Capture

**First, read `references/concepts-vocabulary.md`.** This is unconditional. Do not pre-judge from memory that nothing qualifies — the reference's criteria are non-obvious and qualifying terms often live in the surrounding conversation rather than the new doc itself. Reading the reference is what makes the rest of the phase possible.

Then, applying those criteria, scan the new doc **and** the surrounding conversation for qualifying domain terms. If `CONCEPTS.md` exists at repo root, add missing qualifying terms and refine existing entries when new precision surfaced. If it does not exist and at least one qualifying term surfaced, create it.

**Seed the learning's area at creation — don't write a lone term.** When `CONCEPTS.md` does not yet exist, alongside the surfaced term also seed the core domain nouns of the area this learning touched, following the **Seed goal** and **Scope of a seed** rules in `references/concepts-vocabulary.md`. The seed is scoped to the learning's area (the modules and domain the fix touched) and defines only terms investigated here — it does not reach for repo-wide nouns. This anchors the surfaced term so it does not dangle against undefined siblings. A repo-wide concept map bootstrap is outside the scope of this skill.

**At creation, hold the qualifying bar conservatively for borderline terms.** A borderline term, or a class/table/file name dressed up as an entity, defers to a later run — clear core nouns are seeded, borderline ones wait. The conservatism is about quality, not count; updates to an existing file follow the normal criteria.

**When bootstrapping the file, start with this preamble under the `# Concepts` heading**, then add the qualifying entries below it:

> Shared domain vocabulary for this project — entities, named processes, and status concepts with project-specific meaning. Seeded with core domain vocabulary, then accretes as /compound processes learnings; direct edits are fine. Glossary only, not a spec or catch-all.

**Refresh the coherence neighborhood of any entry you touch.** When adding or editing an entry, also inspect its *coherence neighborhood* — its cluster siblings and the terms it cross-references or that reference it. Within that neighborhood, do two things: fix glossary violations (implementation specifics — file paths, class names, function signatures, current-config values), and refresh entries the learning's own evidence shows have drifted. Bounds: neighborhood only, never a full-file audit; refresh only on evidence already in hand; if judging a neighbor would require investigation this learning did not do, flag it for a future refresh rather than editing on a guess. The test: after the edit, would a reader find the touched entry's siblings or referenced terms inconsistent with it? Broader audit is deferred to a dedicated refresh pass.

If no terms qualified after applying the reference's criteria, record that outcome explicitly in the success output (e.g., "Vocabulary capture: scanned, no qualifying terms"). Do not silently skip — the visible scan-and-no-result record is the audit signal that the reference was consulted.

**Apply edits silently in every mode — no user prompt in interactive, lightweight, or headless.** Vocabulary capture is a side effect of compounding, not a decision the user makes per run. Lightweight mode reaches this through its own single-pass step (see Lightweight Mode), and runs an **update-only** version — it refines an existing `CONCEPTS.md` but defers creation/seeding to a Full run.

### Phase 2.5: Refresh 권고 (호출 없음)

새 학습이 기존 문서를 낡게 만들 수 있으면, 어느 문서가 후보인지 한 줄로 권고만 한다.
refresh 스킬은 이 환경에 없으므로 호출하지 않는다. 권고는 성공 출력의 "Refresh recommendation" 줄에 싣는다.


### Phase 3: Optional Enhancement

**WAIT for Phase 2 to complete before proceeding.**

**Skip Phase 3 entirely in headless mode** to bound token usage — the caller does not have a human-in-the-loop to act on reviewer findings, and downstream automations can run specialized reviewers themselves if they want that pass.

<parallel_tasks>

Based on problem type, optionally invoke specialized agents to review the documentation:

- performance_issue → `performance-engineer`
- database_issue → `database-administrator`
- security_issue → `code-reviewer` (dotfiles에 전용 보안 에이전트 없음)
- 코드 무거운 학습 → `code-reviewer`

기본은 코드 무거운 학습에 code-reviewer만 돌린다. 나머지는 옵션이다. Headless에서는 Phase 3을 건너뛴다.

</parallel_tasks>

---

### Lightweight Mode

<critical_requirement>
**Single-pass alternative — same documentation, fewer tokens.**

This mode skips parallel subagents entirely. The orchestrator performs all work in a single pass, producing the same solution document without cross-referencing or duplicate detection.

Headless mode forces Full and does not enter Lightweight — automations get the cross-reference and overlap detection benefits without the interactive overhead.
</critical_requirement>

The orchestrator (main conversation) performs ALL of the following in one sequential pass:

1. **Extract from conversation**: Identify the problem and solution from conversation history. Also scan the "user's auto-memory" block injected into your system prompt, if present (Claude Code only) -- use any relevant notes as supplementary context alongside conversation history. Tag any memory-sourced content incorporated into the final doc with "(auto memory [claude])"
2. **Classify**: Read `references/schema.yaml` and `references/yaml-schema.md`, then determine track (bug vs knowledge), category, and slug/filename
3. **Availability guard**: Set `WIKI="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work/LLMWiki"`. Run `ls "$WIKI/index.md"`. If it fails, stop and report: "LLM Wiki unreachable — capture deferred. Reconcile next session." Do not write anything.
4. **Write minimal docs**: Write `$WIKI/docs/<slug>.md` (detail) and `$WIKI/learnings/<slug>.md` (synthesis) using the appropriate track template from `assets/resolution-template.md`, with:
   - Detail doc: YAML frontmatter with track-appropriate fields (`type: learning`, `source_repo`, `problem_type`, `severity`, hub wikilink in `related:`), applying the YAML-safety quoting rule for array items (see `references/yaml-schema.md` > YAML Safety Rules). No back-link to learnings/.
   - Synthesis doc: frontmatter includes `detail: "[[docs/<slug>]]"` and a `[[systems/...]]` hub wikilink
   - Bug track body: Problem, root cause, solution with key code snippets, one prevention tip
   - Knowledge track body: Context, guidance with key examples, one applicability note
   - After writing, append to `$WIKI/log.md`: `## [YYYY-MM-DD] compound | <title>`
5. **Vocabulary capture (update-only)**: if `CONCEPTS.md` exists at repo root, read `references/concepts-vocabulary.md`, then scan the new doc and the conversation for qualifying terms and add/refine entries silently (same criteria as Phase 2.4). Do **not** bootstrap or seed in lightweight mode — if `CONCEPTS.md` does not exist, defer creation to a Full run, which owns seeding. Record the outcome in the output (e.g., "Vocabulary: 1 entry refined" or "scanned, no qualifying terms").
6. **Skip specialized agent reviews** (Phase 3) to conserve context

**Lightweight output:**
```
✓ Documentation complete (lightweight mode)

Files written:
- LLMWiki/docs/<slug>.md  (detail)
- LLMWiki/learnings/<slug>.md  (synthesis)

[If CONCEPTS.md was refined this run:]
Vocabulary: <N entry refined | scanned, no qualifying terms>

Note: This was created in lightweight mode. For richer documentation
(cross-references, detailed prevention strategies, specialized reviews,
systems/ cross-linking, index.md update),
re-run /compound in a fresh session.
```

**No subagents are launched. No parallel tasks. The two wiki pages are the deliverables** (vocabulary capture may also refine an existing `CONCEPTS.md`).

In lightweight mode, the overlap check is skipped (no Related Docs Finder subagent). This means lightweight mode may create a doc that overlaps with an existing one. That is acceptable — a later refresh pass will catch it. Only note a refresh candidate if there is an obvious narrow target. Do not broaden into a large refresh sweep from a lightweight session.

---

## What It Captures

- **Problem symptom**: Exact error messages, observable behavior
- **Investigation steps tried**: What didn't work and why
- **Root cause analysis**: Technical explanation
- **Working solution**: Step-by-step fix with code examples
- **Prevention strategies**: How to avoid in future
- **Cross-references**: Links to related issues and docs

## Preconditions

<preconditions enforcement="advisory">
  <check condition="problem_solved">
    Problem has been solved (not in-progress)
  </check>
  <check condition="solution_verified">
    Solution has been verified working
  </check>
  <check condition="non_trivial">
    Non-trivial problem (not simple typo or obvious error)
  </check>
</preconditions>

## What It Creates

**Two wiki pages per learning (flat structure, category in frontmatter):**

- Detail: `LLMWiki/docs/<slug>.md` — full content, systems/ hub wikilink, `source_repo` provenance field
- Synthesis: `LLMWiki/learnings/<slug>.md` — concise entry, `detail: "[[docs/<slug>]]"` one-way link, systems/ hub wikilink

**Category lives in `problem_type` frontmatter and `tags` — not in directory paths.**

Bug track problem_types:
- `build_error`, `test_failure`, `runtime_error`, `performance_issue`, `database_issue`, `security_issue`, `ui_bug`, `integration_issue`, `logic_error`

Knowledge track problem_types:
- `architecture_pattern` — architectural or structural patterns (agent/skill/pipeline/workflow shape decisions)
- `design_pattern` — reusable non-architectural design approaches (content generation, interaction patterns, prompt shapes)
- `tooling_decision` — language, library, or tool choices with durable rationale
- `convention` — team-agreed way of doing something, captured so it survives turnover
- `workflow_issue`, `developer_experience`, `documentation_gap`
- `best_practice` — fallback only, use when no narrower knowledge-track value applies

## Common Mistakes to Avoid

| Wrong | Correct |
|-------|---------|
| Subagents write files like `context-analysis.md`, `solution-draft.md` | Subagents return text data; orchestrator writes files |
| Research and assembly run in parallel | Research completes, then assembly runs |
| Writing to the repo's `docs/solutions/` directory | Write to `$WIKI/docs/<slug>.md` (detail) and `$WIKI/learnings/<slug>.md` (synthesis) |
| Creating a new doc when an existing wiki doc covers the same problem | Check overlap assessment; update the existing wiki doc when overlap is high |
| `learnings/<slug>` linking back to `docs/<slug>` only — no reverse link | One-way: learnings/ links to docs/; docs/ must NOT link back to learnings/ |

## Success Output

### Headless mode

Emit a structured terminal report and end the turn. No "What's next?" question, no blocking prompt. End with `Documentation complete` as the terminal signal so callers can detect completion.

```
✓ Documentation complete (headless mode)

Detail:    LLMWiki/docs/<slug>.md  (created | updated)
Synthesis: LLMWiki/learnings/<slug>.md  (created | updated)
Track: <bug | knowledge>
Category: <category>
Overlap: <none | low | moderate — see <slug> | high — existing doc updated>
CONCEPTS.md: <scanned, no qualifying terms | created with N entries (M seeded from the learning's area) | updated — N added, N refined>
Refresh recommendation: <none | scope hint for a future refresh pass>

Documentation complete
```

When no doc was written (e.g., headless invoked on a session where the problem is not yet solved), emit a structured failure instead and end with `Documentation skipped` so callers can distinguish success from no-op:

```
✗ Documentation skipped (headless mode)

Reason: <one-sentence explanation — e.g., "no solved problem detected in
conversation history" or "solution not yet verified">

Documentation skipped
```

### Interactive mode

```
✓ Documentation complete

Auto memory: 2 relevant entries used as supplementary evidence

Subagent Results:
  ✓ Context Analyzer: Identified performance_issue in brief_system, category: performance-issues
  ✓ Solution Extractor: 3 code fixes, prevention strategies
  ✓ Related Docs Finder: 2 related issues

Specialized Agent Reviews (Auto-Triggered):
  ✓ performance-engineer: Validated query optimization approach
  ✓ code-reviewer: Solution is appropriately minimal

Files written:
- LLMWiki/docs/n-plus-one-brief-generation.md (created)
- LLMWiki/learnings/n-plus-one-brief-generation.md (created)
- CONCEPTS.md (created with 3 entries: BriefSystem, EmailQueue, Brief Status)

This learning is now in the wiki and will surface via wiki recall when
similar issues occur in the Email Processing or Brief System modules.

What's next?
1. Continue workflow (recommended)
2. Link related documentation
3. Update other references
4. View documentation
5. Other
```

**After displaying the interactive success output above, present the "What's next?" options using the platform's blocking question tool:** `AskUserQuestion` in Claude Code (call `ToolSearch` with `select:AskUserQuestion` first if its schema isn't loaded), `request_user_input` in Codex, `ask_user` in Gemini, `ask_user` in Pi (requires the `pi-ask-user` extension). Fall back to numbered options in chat only when no blocking tool exists in the harness or the call errors (e.g., Codex edit modes) — not because a schema load is required. Never silently skip the question. Do not continue the workflow or end the turn without the user's selection. (Interactive mode only — headless skips this per the headless block above.)

**Alternate interactive output (when updating an existing doc due to high overlap):** in headless mode, this case is communicated via the `Overlap: high — existing doc updated` line of the headless terminal report above, not as a separate output block.

```
✓ Documentation updated (existing doc refreshed with current context)

Overlap detected: LLMWiki/docs/n-plus-one-queries.md
  Matched dimensions: problem statement, root cause, solution, referenced files
  Action: Updated existing doc with fresher code examples and prevention tips

Files updated:
- LLMWiki/docs/n-plus-one-queries.md (added last_updated: 2026-03-24)
- LLMWiki/learnings/n-plus-one-queries.md (synthesis updated)
```

## The Compounding Philosophy

This creates a compounding knowledge system:

1. First time you solve "N+1 query in brief generation" → Research (30 min)
2. Document the solution → LLMWiki/docs/n-plus-one-briefs.md + learnings/ synthesis (5 min)
3. Next time similar issue occurs → Wiki recall surfaces it in 2 min
4. Knowledge compounds across every repo

The feedback loop:

```
Build → Test → Find Issue → Research → Improve → Document → Validate → Deploy
    ↑                                                                      ↓
    └──────────────────────────────────────────────────────────────────────┘
```

**Each unit of engineering work should make subsequent units of work easier—not harder.**

## Auto-Invoke

<auto_invoke> <trigger_phrases> - "that worked" - "it's fixed" - "working now" - "problem solved" - "됐다" - "해결됐" - "고쳤" - "이제 된다" </trigger_phrases>

<manual_override> Use /compound [context] to document immediately without waiting for auto-detection. </manual_override> </auto_invoke>

## Output

Writes two wiki pages directly into the LLM Wiki: `$WIKI/docs/<slug>.md` (detail) and `$WIKI/learnings/<slug>.md` (synthesis). Nothing is written to the repo.

## Applicable Specialized Agents

Based on problem type, these agents can enhance documentation:

- **performance-engineer**: Analyzes performance_issue category solutions
- **database-administrator**: Reviews database_issue migrations and queries
- **code-reviewer**: Reviews security issues and code-heavy learnings for clarity and correctness

### When to Invoke
- **Auto-triggered** (optional): Agents can run post-documentation for enhancement
- **Manual trigger**: User can invoke agents after /compound completes for deeper review

