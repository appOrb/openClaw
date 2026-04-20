---
name: debug-error
description: Analyze a stack trace and code context, identify the root cause, and apply a fix
modelHint: debug
---

# Debug & Fix Skill

## Trigger
Use this skill when given an error message, stack trace, exception, or when something is "not working".

## Process

1. **Parse the error**
   - Error type and message
   - File and line number from stack trace
   - Language / runtime / framework

2. **Identify root cause** — Think through:
   - Is it a null/undefined access?
   - Is it a type mismatch?
   - Is it a race condition or async issue?
   - Is it a missing environment variable or config?
   - Is it a dependency version conflict?

3. **State the diagnosis** in plain English before writing any fix:
   > "The error occurs because X is undefined when Y is called before Z completes."

4. **Apply the fix**
   - Show the exact lines to change (before / after)
   - Explain why this fixes the root cause, not just the symptom

5. **Suggest a test** to prevent regression

## Output format
```
ROOT CAUSE: <one sentence>

FIX:
// Before
<original code>

// After
<fixed code>

WHY: <explanation>

REGRESSION TEST: <test case or assertion to add>
```
