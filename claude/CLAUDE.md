# Global Preferences

## Code

- Write the minimum code needed. Fewer lines is better. Prefer TDD approach.
- Bias toward deletion. Remove dead code, unused imports, unnecessary abstractions.

## Git

- Use Conventional Commits for all commit messages unless the project's CLAUDE.md or documentation specifies a different convention.
- Format: `type(scope): description` (e.g., `feat(auth): add JWT refresh token rotation`, `fix(api): handle null response from payments endpoint`).
- Common types: feat, fix, refactor, docs, test, chore, perf, ci, build, style.
- When merging pull requests, prefer squash merge as the default strategy.

## Workflow

- Before claiming work is complete, verify it actually works (run tests, check output). Use the `verification-before-completion` approach.
- When reviewing or writing UI code, consider using `web-design-guidelines` for accessibility compliance.
