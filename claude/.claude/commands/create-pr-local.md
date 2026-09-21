# Pull Request Creation Command
Create a new branch, commit the changes, and submit a Pull Request.

## Pull Request Template
### PR Title
```markdown
feat: changes title example
```
- If the repo has a PR title checker config (e.g. `.github/pr-title-checker-config.json`), the title prefix must be one of its entries. Typical set: `feat`, `fix`, `docs`, `perf`, `refactor`, `style`, `test`, `chore`, `ci`, `revert`, `config` (scoped form like `feat(scope):` is also allowed)

### PR Descriptions
```markdown
* Issue: https://linear.app/daangn/issue/MLI-XXX
* Related Links:
    - [Content]
* Motivation:
    - [Content]
* Changes:
    - [Content]
```
- Issue: Fill in XXX by referencing the branch name
- Related Links: Leave links related to the tech spec or changes
- Issue/Related Links: use `n/a` only when it is **confirmed** there is none. If not confirmed from the branch name or conversation, ask the user before creating the PR instead of guessing `n/a`
- Motivation: Describe the reason for writing this PR in two lines or less
- Changes: Describe the semantic explanation of the code changes. Do not enumerate modified files one by one; the description shows the forest before the reviewer reads the diff

## How It Works
- Create a new branch based on the current changes
- Format the modified files using the repo's formatter (e.g. Biome, ruff)
- Analyze the changes and automatically separate them into logical units for committing
- Each commit focuses on a single logical change or feature
- Write a descriptive commit message appropriate for each logical unit
- Push the branch to remote

## Submit Workflow

### Creating a new PR

```bash
git add <files>
git commit -m "<commit message>"
git push origin <branch-name>

# Use --body-file to avoid shell escaping issues in the body.
gh pr create --title "<PR title>" --body-file <path>
```

### Updating an existing PR

```bash
git add <files>
git commit -m "<brief update message>"
git push origin <branch-name>
```

- In repos where `gh pr edit --body` is unstable, set the body with `gh api -X PATCH repos/<owner>/<repo>/pulls/<PR_NUMBER> -F body=@<file>`, then read the PR back to verify. (`-F` reads the file; `-f` puts the literal path string into the body and overwrites it, so never mix them up)
- If `gh` CLI is not available, output the PR title and body in the template format above for manual copy-paste

## PR Description Writing Guidelines

Voice (word choice, sentence shape, anti-slop) comes from the `writing-style` skill. Invoke it. It is the
source of truth for the no-em-dash / no-contrastive-negation / no-smell-word / no-marketing rules and the
plain-concrete principle. The bullets below are this command's **format** specifics, which take precedence
over the skill's generic format defaults.

- Don't include the ticket number in the title
- Wrap variable and function names in backticks (`), but do not overuse them. Use the full identifier rather than an abbreviation (`tpu_queue_state_updater`, not `state_updater`)
- Use polite informal style ("해요체") for prose sections such as Motivation
- End every Changes/Validation list item with a noun form ("추가", "변경", "삭제", "실행", "통과"), not "~함" or "~해요". When an item needs more than one sentence, split the rest into nested bullets
- Do not use emojis, emoticons, or headers
- Focus on the meaning and reason behind code changes rather than just listing changes. Start the Motivation from the structural cause (why the usual approach can't work), not the symptom, and name the precise execution context rather than a vague label
- When there are many changes, group them up to 2 levels deep so that changes of the same nature can be easily recognized. If a single point has layers (cause, constraint, resolution), use nested bullets instead of one comma-chained sentence
- Never pack multiple distinct changes behind a label with commas ("라벨: A, B, C"). Make the label a parent bullet and give each change its own nested bullet:

  개선 전:
  ```markdown
  - 리뷰 반영: 폴링 race 주석을 htmx 실제 동작(OOB가 요청 element의 rootNode로 해소)에 맞게 교정, dashboard/live partial의 컨텍스트 조립 공용화, range controller에 rollup 휴리스틱 주입 지원 추가
  ```

  개선 후:
  ```markdown
  - 리뷰 반영
    - 폴링 race 주석을 htmx 실제 동작(OOB가 요청 element의 rootNode로 해소)에 맞게 교정
    - dashboard/live partial의 컨텍스트 조립 공용화
    - range controller에 rollup 휴리스틱 주입 지원 추가
  ```
- Look at the big picture, and keep the number of 1st-depth list items to a maximum of 4
- Write each list item of the changes within 120 characters
- Attach external links that may serve as reference for the changes if necessary
- Do not append the phrase "🤖 Generated with Claude Code"

## Automatic Commit Separation Guidelines

For splitting and message wording, follow the `git-commit` skill (split criteria, house-style detection)
and the `writing-style` skill (message voice). The bullets below summarize the split intent.

- Separate commits by feature, component, or concern
- Group related file changes into the same commit
- Separate refactoring from feature additions
- Each commit should be understandable independently
- Separate unrelated changes into separate commits
- Utilize bullet point depth to represent the hierarchical structure of changes
