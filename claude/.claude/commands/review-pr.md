# PR Review Command
Review the code changes in a PR and leave inline comments.

## Execution Procedure
1. Check repository information with `gh repo view --json owner,name`
2. Check PR information with `gh pr view --json number,headRefOid,baseRefName,body`
3. Check changes with `gh pr diff`
4. Launch the auxiliary reviews (see Auxiliary Reviews below): the Codex adversarial review first, then `/ponytail-review` on the PR diff
5. Invoke the `writing-style` skill, then analyze code changes and write review comments using the latest Opus model
6. When the Codex background task completes, merge all findings (own + ponytail + codex) into one comment set per the merging rules
7. Show the merged comments to the user with each comment's origin tagged, and get confirmation
8. Submit the review with `gh api` upon user approval (origin tags stripped)

## Auxiliary Reviews
Two extra passes run alongside your own analysis and their findings are folded into the same inline comments.

- **Codex adversarial review on `gpt-6-astra`**: launch it right after `gh pr diff` so it runs while you analyze.
  - Use `adversarial-review`, not the built-in `review`. The built-in reviewer on astra returns a one-line "No actionable regressions were identified" even on PRs where the other passes find real behavior bugs. `adversarial-review` on the same model reports concrete findings with file, line, and confidence.
  - The `/codex:*` slash commands cannot be invoked by the model, so run the companion CLI with Bash `run_in_background`. Codex reads the **local git state**, so check out the PR head in a detached worktree. Never switch the user's branch.
    ```bash
    git fetch origin pull/<number>/head
    git worktree add --detach .claude/worktrees/review-<number> <headRefOid>
    cd .claude/worktrees/review-<number> && node ~/.claude/plugins/cache/openai-codex/codex/<ver>/scripts/codex-companion.mjs \
      adversarial-review --wait --base origin/<baseRefName> --scope branch --model gpt-6-astra "<one-line intent from the PR Motivation>"
    ```
  - The output file stays empty until Codex finishes (about 5 minutes). Wait for the completion notification.
  - A verdict of `approve` with no findings is a valid result. These are failures, so report the Codex pass as failed instead of "no findings": exit code 1, `Reviewer failed to output a response`, `requires a newer version of Codex`, or `failed to load configuration`. The last one comes from a stale `app-server-broker.mjs serve --cwd <path>` whose directory was deleted; kill that broker and rerun once.
  - Adversarial findings lean skeptical. Check each one against the code before adopting it.
  - Remove the worktree after the review is submitted.
- `/ponytail-review`: run it on the PR diff after launching Codex. It hunts over-engineering only (deletions, stdlib replacements, dead flexibility); treat it as a complement to your correctness-focused pass.

**Merging rules:**
- Dedup findings that point at the same file/line and issue; keep one comment.
- Your own judgment governs. Drop auxiliary findings you assess as false positives and say so in the confirmation step.
- Rewrite every adopted finding into this command's comment style (해요체, 1-2 sentences, inline anchor). Never paste Codex or ponytail output verbatim into the submitted review; show the raw Codex output to the user once during confirmation instead.
- If the Codex task is still running when your own comments are ready, tell the user and wait for it before the confirmation step; if Codex fails or was skipped, proceed with the remaining sources and note it.

## Comment Writing Rules
Voice is owned by the `writing-style` skill; invoking it before drafting any comment is mandatory, and its post-filter applies to every comment body. The rules below own the format only.

**Requirements:**
- Each comment must be an inline comment linked to a specific file and line
- Write concisely in 1-2 sentences
- Sentences should not exceed 120 characters
- Use polite informal style ("해요"체) (e.g., 좋겠어요, 필요해요)
- Do not use emojis, emoticons, bullets, or headers
- Include examples or explanations only when absolutely necessary
- Wrap variable and function names in backticks (`), but do not excessively list variable or function names
- Handle escape characters according to markdown conventions
- Use code suggestions when necessary
- Provide related documents or reference links used in the review if available
- Lead with the key takeaway, then explain

**Review Status:**
- No issues: Use `event="APPROVE"` with a single comment "LGTM!"
- Issues found: Use `event="REQUEST_CHANGES"` with inline comments and a main comment "검토 부탁드려요!" (Please review!)

## Review Items
Bugs, security vulnerabilities, performance issues, data loss risks, code style, maintainability, scalability, compatibility, documentation, missing tests

## Comment Examples
Good: "This DELETE statement deletes all data. A WHERE clause needs to be added."
Bad: "## 🚨 Critical\nThis code is...\n### Issues\n1. ..."

## API Usage
```bash
# Get repository information
gh repo view --json owner,name
# Get PR information
gh pr view --json number,headRefOid
# Check the list of changed files
gh pr diff --name-only
# Submit review (no issues)
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews \
  -X POST \
  -f commit_id="{head_commit_sha}" \
  -f body="LGTM!" \
  -f event="APPROVE"
# Submit review (with inline comments)
# 1. First, create the review JSON file
cat > /tmp/review.json << 'EOF'
{
  "commit_id": "{head_commit_sha}",
  "body": "Please review.",
  "event": "REQUEST_CHANGES",
  "comments": [
    {
      "path": "file_path",
      "line": actual_line_number,
      "side": "RIGHT",
      "body": "comment content"
    }
  ]
}
EOF
# 2. Submit the review with the JSON file
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews \
  -X POST \
  --input /tmp/review.json
```

**Cautions:**
- Use the absolute line number of the changed file for `line`
- Use `"RIGHT"` for `side` on added/modified lines, and `"LEFT"` for deleted lines
- Add multiple comments to the `comments` array
- Use the result of `gh repo view` for owner/repo
- If quotation marks are included in strings within the JSON file, they must be escaped as `\"`
- Always show the review content and get confirmation before submission
- Avoid simply listing changes; include analysis and improvement suggestions
- Write PR review comments in Korean
