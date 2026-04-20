---
name: code-generation
description: Generate production-quality code in React, Node.js, Python, or Go from a natural-language description
modelHint: research
---

# Code Generation Skill

## Trigger
Use this skill when asked to write, implement, or build a function, component, module, API endpoint, or any code artifact.

## Behavior

1. **Clarify requirements** — Before writing code, confirm:
   - Language and framework
   - Input/output shape
   - Any constraints (performance, auth, error handling)

2. **Write production-ready code** — Standards to follow:
   - TypeScript types (if JS/TS)
   - Error handling (try/catch, Result types)
   - No magic numbers or hardcoded strings
   - Comments only for non-obvious logic

3. **Output format**
   - Return the full file content, not just the function
   - Include imports
   - End with a brief explanation of key decisions

## Examples

**Input**: "Write a Node.js Express route to upload a file to Azure Blob Storage"
**Output**: Complete `upload.ts` route file with multer middleware, Azure SDK v12, error handling, and types

**Input**: "Write a React hook to debounce a search input"
**Output**: Complete `useDebounce.ts` with generic type, cleanup effect, and JSDoc
