# Linear Issue Management Commands

Automatically analyzes the current Git branch's changes to manage Linear issues.

## Commands

### `/linear create`
Analyzes the current branch's changes and creates a new Linear issue.

**How it works:**
1. Check changes with `git diff main` or `git diff origin/main`
2. Check recent commit messages with `git log`
3. Compose the issue content based on changed files and commit messages
4. Fill out Johan as the asignee
5. Create the issue under the ml-infra team
6. Provide the issue ID and URL

**Issue structure:**
- Title: Automatically extracted from commit messages or changes
- Description: Key changes and essential context
- Labels: Auto-assigned based on change type (bug, feature, refactor, etc.)

---

### `/linear update`
Finds the issue ID from the current branch name and updates its description.

**How it works:**
1. Extract the issue ID from the branch name (e.g., `feature/ABC-123-fix` -> `ABC-123`)
2. Check changes with `git diff main` or `git diff origin/main`
3. Check recent commit messages with `git log`
4. Append to the existing description or rewrite it entirely
5. Notify when the update is complete

**Update content:**
- Summary of major changes
- Work history based on commit messages
- Only context essential for understanding

---

### `/linear comment`
Finds the issue ID from the current branch name and adds the changes as a comment.

**How it works:**
1. Extract the issue ID from the branch name
2. Check changes with `git diff main` or `git diff origin/main`
3. Check recent commit messages with `git log`
4. Write a summary of changes as a comment
5. Notify when the comment is added

**Comment content:**
- Work progress
- Changed files and key modifications
- Next steps (optional)

---

## Additional Options

Each command accepts additional options:
```bash
/linear create --title "Custom title"
/linear create --priority high
/linear update --append   # Append to existing content
/linear update --replace  # Replace existing content entirely
/linear comment --message "Custom message"
```

---

## How Changes Are Analyzed

**Checking file changes:**
- `git diff --name-status main`: List of modified, added, or deleted files
- `git diff --stat main`: Lines changed per file
- `git diff main`: Detailed change content

**Checking commit history:**
- `git log main..HEAD --oneline`: All commits on the branch
- `git log -1 --pretty=%B`: Most recent commit message

**Analysis criteria:**
- Number and type of changed files (source code, config, docs, etc.)
- Lines added/removed
- Commit message patterns (fix, feat, refactor, etc.)
- Change scope (single file vs. multiple files)
- Which submodule is affected if it's a monorepo

**Writing criteria:**
- Exclude file names
- Focus on the current state rather than past history
- Only context essential for understanding

---

## Auto-Generation Templates

### Issue Creation Template
Title: [Main change]
Changes
[3-5 bullets, one line each]
Background (optional)
[Only when commit messages provide an explicit reason]
Impact (optional)
[Only when there is actual impact on other teams/systems]

### Comment Template
Work Progress

[Change 1]
[Change 2]
[Change 3]


---

## Usage Examples

**Creating an issue after developing a new feature**
Current branch: feature/add-user-login
Changes: 3 files modified, 150 lines added
-> /linear create
-> Issue created: "Add user login feature"

**Updating an issue description during work**
Current branch: feature/ABC-123-refactor-api
Additional work: 2 more files modified
-> /linear update
-> ABC-123 description reflects the latest changes

**Adding a comment after completing work**
Current branch: fix/ABC-456-bug-fix
All changes committed
-> /linear comment
-> Comment added: "Bug fix complete, tests passing"

---

## Requirements

- Run from within a Git repository
- Linear MCP connection required
- Access scoped to the ml-infra team
- Must be in a state that allows comparison with the main branch

---

## What Not to Write

- **Design or implementation documents** — never attach, embed, or link them, and never paste their contents into the issue/comment. This includes brainstorming specs (`docs/superpowers/specs/**`), plans (`docs/superpowers/plans/**`), solution learnings (`docs/solutions/**`), and any local design/architecture notes. These are local working artifacts that are **not committed**, so teammates cannot open them — referencing them only causes confusion. Distill the conclusion into the issue body instead of pointing at the document.
- Self-evident details from the diff (listing changed functions/classes/parameters)
- Speculative background not in commit messages ("probably because of -")
- Generic effect statements ("readability improved", "maintainability improved")
- Outcome predictions ("performance is expected to improve")
- Closing/summary sentences ("with this -", "overall -")
- Emphatic adjectives/adverbs ("successfully", "effectively", "stably")
- Restating the same information in different words

---

## Notes

- If changes are too large, only a summary is provided
- Sensitive information is filtered automatically
- Without an issue ID, only `create` is available
- Uncommitted changes are also included
- PRs are auto-linked to Linear, so no separate PR link is needed
- Never attach or reference local design/implementation docs (they are not committed and teammates cannot access them) — write the distilled conclusion directly into the issue
