---
name: setup-ci
description: Generate a CI/CD pipeline for GitHub Actions or Azure DevOps
modelHint: repetitive
---

# CI/CD Setup Skill

## Trigger
Use this skill when asked to "set up CI", "add a pipeline", "create a GitHub Actions workflow", or "set up Azure DevOps".

## Required inputs
- Platform: GitHub Actions or Azure DevOps
- Language / runtime
- What to run: lint, test, build, deploy?
- Deploy target (if any): Azure Web App, AKS, Container Registry, etc.

## GitHub Actions — Standard Pipeline

Generate `.github/workflows/ci.yml`:

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npm run lint
      - run: npm test
      - run: npm run build
```

## Quality standards
- Use pinned action versions (`@v4`, not `@main`)
- Cache dependencies (npm, pip, pnpm)
- Fail fast: lint before test before build
- Secrets referenced via `${{ secrets.NAME }}`, never hardcoded
- For deploys: separate `deploy.yml` triggered only on `main` push

## Output
Complete YAML file(s). Add a comment at the top explaining what the pipeline does and any secrets that need to be configured in the repo settings.
