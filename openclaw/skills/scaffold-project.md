---
name: scaffold-project
description: Generate a complete project structure with frontend, backend, Docker, and CI
modelHint: research
---

# Project Scaffold Skill

## Trigger
Use this skill when asked to "scaffold", "create a new project", "set up a repo", or "start a new app".

## Required inputs
- Project name
- Stack (e.g., "React + Node.js + PostgreSQL", "Next.js + Prisma", "FastAPI + PostgreSQL")
- Purpose (one sentence)

## Output

Generate the full directory tree and file contents for:

### Frontend (if applicable)
- `src/` with components, hooks, pages, utils
- Tailwind CSS or CSS modules
- TypeScript configured
- `package.json` with scripts: dev, build, test, lint

### Backend
- Entry point, routes, controllers, services, models
- Environment config via dotenv
- Health check endpoint (`GET /health`)
- TypeScript or Python type hints throughout

### Infrastructure
- `Dockerfile` (multi-stage build)
- `docker-compose.yml` (app + database + optional cache)
- `.env.example`
- `.gitignore`

### CI/CD
- `.github/workflows/ci.yml` (lint + test + build on PR)

### Documentation
- `README.md` with: purpose, setup, dev commands, env vars, deploy notes

## Quality standards
- No TODO comments in generated code
- All environment variables documented in `.env.example`
- Docker image under 200MB (use alpine/slim base)
