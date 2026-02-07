# CI/CD Best Practices Reference

## Use Project Automation, Not Inline Commands

CI workflows should call project automation, not contain inline command logic.

```yaml
# BAD - Logic in CI, can't run locally the same way
- run: |
    jest --coverage --ci
    eslint src/ --format=stylish

# GOOD - CI calls project automation
- run: npm test
- run: npm run lint
```

**Why**: Local/CI parity, CI platform portability, easier debugging, single source of truth.

When project automation doesn't exist, ask the user whether to add it to the project (recommended) or use inline commands.

## Actions vs Project Commands

| Category | Examples | Approach |
|----------|----------|----------|
| CI Infrastructure | checkout, setup runtime, cache, registry login | Use actions |
| Project Logic | build, test, lint, docker build, deploy | Use project automation |

## Secret Handling

Secrets are only accessible from the org/owner that has them configured. Fork PRs cannot access base repo secrets.

Use conditionals to skip steps when secrets are unavailable:

```yaml
- name: Run integration tests
  if: secrets.API_KEY != ''
  run: npm run test:integration
  env:
    API_KEY: ${{ secrets.API_KEY }}
```

Document required secrets clearly with a table and `gh secret set` commands (but do NOT execute them).

## Security

| Practice | Description |
|----------|-------------|
| Minimal permissions | Use `permissions:` block, grant only what's needed |
| OIDC over long-lived tokens | For cloud providers, prefer OIDC federation |
| Pin action versions | Use SHA or version tags, never `@latest` |
| Disable credential persistence | Use `persist-credentials: false` on `actions/checkout` |
| Prevent script injection | Never interpolate untrusted inputs (branch names, PR titles) into `run:` commands |
| Avoid `pull_request_target` | Has access to secrets but can checkout fork code — dangerous |
| Environment protection | Use GitHub environments with required reviewers for production |

## Testing

| Practice | Description |
|----------|-------------|
| Fail fast | Run quick checks (lint) before slow ones (tests) |
| Test before build | Don't waste time building if tests fail |
| Parallel jobs | Run independent checks concurrently |
| Test matrix | Consider multiple versions/platforms if relevant |

## Caching

Implement caching based on detected package manager and lock files.
