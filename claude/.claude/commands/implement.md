---
description: Design a change with Codex Astra and Claude Fable in parallel, merge the two designs, ask only what you cannot decide, implement with Opus, review with /review-all, fix, commit
argument-hint: '<task description | MLI-1234>'
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(node:*), Agent, SendMessage, SlashCommand, Skill, AskUserQuestion, EnterWorktree, mcp__claude_ai_Linear__get_issue
---

Take one task from design to a reviewed commit, with Codex and Claude each writing a design first.

Raw slash-command arguments:
`$ARGUMENTS`

## Core constraint
- Commit once, at step 7. Never push, never open a PR.
- Do not read the Codex design before the Fable design is done, and do not show either model the other's design. The two designs must be independent; the merge is where they meet.
- Models are fixed: design on `gpt-6-astra` (Codex) and `fable` (Claude), implementation on `opus` (Claude), review through `/review-all`.

## Input
If `$ARGUMENTS` is a Linear key such as `MLI-1234`, fetch the issue and use its title and description as the task. Otherwise the arguments are the task.

## 1. Worktree
Call EnterWorktree with the name `implement-<slug>` (slug from the Linear key or the first words of the task). Record the worktree's absolute path; every later step runs inside it so `/review-all` sees the same git state.

## 2. Two designs, in parallel
Launch both, then wait for both. Each design uses this format:

```
## Approach
## Files to change (path: what changes)
## Risks
## Open questions (only decisions the author could not settle from the code)
```

**Codex (Astra).** Write the prompt to `/tmp/implement-<slug>-codex.md` with Write: the task, the format above, and these rules: "Design only. Do not modify files. Explore the repository with read-only git, rg, sed, cat. Do not search the web, spawn sub-agents, or load skills. Return the design as markdown in the format above, nothing else." Find the companion with Glob `~/.claude/plugins/cache/openai-codex/codex/*/scripts/codex-companion.mjs` (take the highest version), then run it from the worktree with Bash and `run_in_background`:
```bash
node <companion> task --model gpt-6-astra --prompt-file /tmp/implement-<slug>-codex.md
```
Without `--write` the companion runs read-only. Do not read its output until the merge step. Exit code 1, `requires a newer version of Codex`, or `failed to load configuration` mean the pass failed; the last one comes from a stale `app-server-broker.mjs serve --cwd <path>` whose directory was deleted, so kill that broker and rerun once. If Codex still fails, merge from the Fable design alone and say so in the report.

**Claude (Fable).** Agent tool, `subagent_type: general-purpose`, `model: fable`, `run_in_background: true`. The prompt: the task, the worktree absolute path with "Work from this path only, read-only, do not modify files", and the format above.

## 3. Merge
Fold the two designs into one.
- Where they agree, that is the design.
- Where they differ, read the code the disagreement is about and decide. Record each disagreement, which design you took, and why. Your judgment governs; a design is not right because of which model wrote it.
- Write the merged design to the wiki as `LLMWiki/specs/YYYY-MM-DD-<slug>.md` with the canon frontmatter (`type: spec`, `module`, `status: draft`, `created`, `updated`, `tags`, `related`, `source`), a link to at least one `systems/` page, and a "Disagreements" section. Append a `spec-sync` line to `log.md`. If the wiki is unreachable, write it to `docs/superpowers/specs/` in the worktree and note it for the next session.

## 4. Questions
Collect the open questions that survive the merge: only decisions the code cannot settle and whose answer changes what gets built. If there are any, ask them in one AskUserQuestion call, most important first, and record the answers in the spec (`status: approved`). If there are none, go straight on.

## 5. Implement (Opus)
Agent tool, `subagent_type: general-purpose`, `model: opus`. Give it the full spec text and the worktree absolute path with "Work from this path only". It implements the spec, runs the relevant tests, and reports changed files and test output. It must not commit. Keep its agent id; step 7 continues the same agent.

## 6. Review
Invoke `/review-all` via SlashCommand with no arguments. Its default scope is the working tree, which is exactly the uncommitted implementation.

## 7. Fix and commit
- Send the surviving findings from the `/review-all` report to the Opus agent with SendMessage. It fixes them and reruns the tests.
- Run `/review-all` once more. Whatever remains after this second pass goes into the report; do not loop again.
- Commit with the `git-commit` skill: one commit, English message, `type: subject (MLI-XXXX)` when there is a Linear key, no `Co-Authored-By` trailer.

## 8. Report
Design summary, each disagreement and the choice made, the spec path, the commit hash, test result, and any findings left after the second review.
