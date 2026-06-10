# PR Review Command
Review the code changes in a PR and leave inline comments.

## Execution Procedure
1. Check repository information with `gh repo view --json owner,name`
2. Check PR information with `gh pr view --json number,headRefOid,body`
3. Check changes with `gh pr diff`
4. Analyze code changes and write review comments using the latest Opus model
5. Show the written comments to the user and get confirmation
6. Submit the review with `gh api` upon user approval

## Comment Writing Rules
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
