# Pull Request Creation Command
Create a new branch, commit the changes, and submit a Pull Request.

## Pull Request Template
### PR Title
```markdown
feat: changes title example
```

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
- Related Links: Leave links related to the tech spec or changes. If there are none in particular, leave it as None
- Motivation: Describe the reason for writing this PR in two lines or less
- Changes: Describe the semantic explanation of the code changes

## How It Works
- Create a new branch based on the current changes
- Format the modified files using Biome
- Analyze the changes and automatically separate them into logical units for committing
- Each commit focuses on a single logical change or feature
- Write a descriptive commit message appropriate for each logical unit
- Push the branch to remote

## PR Description Writing Guidelines

Voice (word choice, sentence shape, anti-slop) comes from the `writing-style` skill. Invoke it. It is the
source of truth for the no-em-dash / no-contrastive-negation / no-smell-word / no-marketing rules and the
plain-concrete principle. The bullets below are this command's **format** specifics, which take precedence
over the skill's generic format defaults.

- Don't include the ticket number in the title
- Wrap variable and function names in backticks (`), but do not overuse them. Use the full identifier rather than an abbreviation (`tpu_queue_state_updater`, not `state_updater`)
- Use polite informal style ("해요체") when writing
- Do not use emojis, emoticons, or headers
- Focus on the meaning and reason behind code changes rather than just listing changes. Start the Motivation from the structural cause (why the usual approach can't work), not the symptom, and name the precise execution context rather than a vague label
- When there are many changes, group them up to 2 levels deep so that changes of the same nature can be easily recognized. If a single point has layers (cause, constraint, resolution), use nested bullets instead of one comma-chained sentence
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
