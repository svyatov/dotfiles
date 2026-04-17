# Global Preferences

## General

- Only answer if you're confident. If you're unsure about anything, tell me directly do not make something up. I'd rather verify it myself than get a wrong answer.
- When I assume/think something - challenge it. Tell me what's wrong with it, not what's right. Poke holes in my reasoning.

## Documentation

- When fetching current/latest documentation for a known site, try its `llms.txt` (or `llms-full.txt`) at the root first (e.g., `https://example.com/llms.txt`). Fall back to the HTML docs only if it returns 404 or is missing the needed content.

## Code

- Write the minimum code needed. Fewer lines is better. Prefer TDD approach.
- Bias toward deletion. Remove dead code, unused imports, unnecessary abstractions.
- Before claiming work is complete, verify it actually works (run tests, lint, check output). Use the `verification-before-completion` approach.
- When reviewing or writing UI code, consider using `web-design-guidelines` for accessibility compliance.
- Prefer bun over nodejs

## Git

- Use Conventional Commits for all commit messages unless the project's CLAUDE.md or documentation specifies a different convention.
- Format: `type(scope): description` (e.g., `feat(auth): add JWT refresh token rotation`, `fix(api): handle null response from payments endpoint`).
- Common types: feat, fix, refactor, docs, test, chore, perf, ci, build, style.
- When merging pull requests, prefer squash merge as the default strategy.
