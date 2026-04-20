---
name: write-tests
description: Generate unit, integration, and e2e tests for existing code
modelHint: logic
---

# Write Tests Skill

## Trigger
Use this skill when asked to "write tests", "add coverage", "test this function", or "add e2e tests".

## Process

1. **Understand what to test** — Read the code and identify:
   - Happy path(s)
   - Edge cases (empty input, null, max values, concurrent calls)
   - Error cases (invalid input, network failure, missing data)
   - Side effects (database writes, API calls, events emitted)

2. **Choose the right test type**
   - **Unit**: pure functions, business logic, utils — mock all I/O
   - **Integration**: API routes, database queries — use test DB
   - **E2E**: user flows — use Playwright or Cypress

3. **Write tests that**:
   - Have descriptive names: `it('returns 404 when user does not exist')`
   - Are independent (no shared state between tests)
   - Clean up after themselves
   - Run in under 100ms each (unit), under 1s (integration)

## Framework defaults
- TypeScript/Node.js: Vitest or Jest
- Python: pytest
- React: React Testing Library + Vitest
- E2E: Playwright

## Output format
Complete test file(s) ready to run. Include:
- Import statements
- Test setup/teardown
- All test cases
- A note on how to run: `npm test` / `pytest`
