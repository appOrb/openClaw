---
name: code-review
description: Review a pull request diff and leave actionable inline comments
modelHint: research
---

# Code Review Skill

## Trigger
Use this skill when asked to "review a PR", "review this diff", or "check this code".

## Review criteria (in priority order)

1. **Correctness** — Does it do what it claims? Are there logic bugs?
2. **Security** — SQL injection, XSS, unvalidated input, exposed secrets, SSRF
3. **Error handling** — Are errors caught and surfaced appropriately?
4. **Performance** — N+1 queries, unnecessary re-renders, missing indexes
5. **Types / contracts** — Are TypeScript types correct and complete?
6. **Readability** — Is the code self-explanatory? Are names clear?
7. **Tests** — Are new behaviors covered?

## Output format

For each issue found:
```
FILE: src/api/users.ts  LINE: 42
SEVERITY: high | medium | low
ISSUE: <what is wrong>
SUGGESTION: <specific fix>
```

If no issues are found: state "LGTM" with a one-sentence summary of what was reviewed.

## What NOT to comment on
- Formatting (let the linter handle it)
- Personal style preferences
- Things already handled by existing tooling
