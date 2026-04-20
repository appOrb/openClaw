---
name: pr-creation
description: Push a feature branch and open a GitHub pull request with a clear description
modelHint: repetitive
---

# PR Creation Skill

## Trigger
Use this skill when code changes are ready to be submitted for review, or when asked to "open a PR", "submit changes", or "create a pull request".

## Behavior

1. **Stage and commit**
   ```bash
   git add -A
   git commit -m "feat: <concise description in imperative mood>"
   ```

2. **Push branch**
   ```bash
   git push origin HEAD
   ```

3. **Open PR via GitHub CLI**
   ```bash
   gh pr create \
     --title "<title>" \
     --body "<body>" \
     --base main
   ```

4. **PR body must include**:
   - **What**: one-sentence summary of what changed
   - **Why**: motivation or ticket reference
   - **How**: key implementation decisions
   - **Test plan**: how to verify it works

## Commit message format
- `feat:` new feature
- `fix:` bug fix
- `refactor:` code change without behavior change
- `test:` adding/updating tests
- `chore:` tooling, deps, config

## Output
Return the PR URL after creation.
