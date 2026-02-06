# Global Preferences

## Communication

- Be direct and concise. Skip preamble, caveats, and filler.
- When writing any prose (commit messages, docs, comments, PR descriptions, explanations), apply the `writing-clearly-and-concisely` skill principles: prefer active voice, omit needless words, use definite and specific language.
- Don't repeat back what I just said. Don't summarize what you're about to do -- just do it.
- Don't explain what you changed after making edits -- I can see the diff.

## Code

- Write the minimum code needed. Fewer lines is better.
- Bias toward deletion. Remove dead code, unused imports, unnecessary abstractions.

## Git

- Use Conventional Commits for all commit messages unless the project's CLAUDE.md or documentation specifies a different convention.
- Format: `type(scope): description` (e.g., `feat(auth): add JWT refresh token rotation`, `fix(api): handle null response from payments endpoint`).
- Common types: feat, fix, refactor, docs, test, chore, perf, ci, build, style.

## Workflow

- For complex features (>2 files, unclear requirements), use the `requirements-clarity` skill to clarify before coding.
- Before claiming work is complete, verify it actually works (run tests, check output). Use the `verification-before-completion` approach.
- When adding logging, follow the `logging-best-practices` skill (wide events, canonical log lines).
- When reviewing or writing UI code, consider using `web-design-guidelines` for accessibility compliance.
