---
name: generate-cicd
description: >
  Generate CI/CD workflows (GitHub Actions) through interactive conversation by analyzing
  repository structure and user preferences. Use when the user asks to: (1) set up CI/CD
  for a project, (2) create GitHub Actions workflows, (3) add automated testing/building/deployment
  pipelines, (4) improve or review existing CI/CD configuration. Triggers on: "CI/CD", "CI",
  "GitHub Actions", "workflow", "pipeline", "continuous integration", "continuous deployment",
  ".github/workflows".
---

# Generate CI/CD Workflows

Generate GitHub Actions workflows through interactive conversation: analyze the repository, present findings, ask about workflow preferences, generate workflows based on confirmed choices.

CI/CD involves **policy decisions** (PR vs direct push, release triggers, deployment strategy) that cannot be deduced from code alone. Always present choices and get user confirmation.

## Key Rules

- **Verify everything** before adding any step, secret, or config — examine the actual codebase. Ask when uncertain.
- **Always present workflow choices** — even if tests and a Dockerfile are detected, the user decides when/how they run.
- **Use project automation** over inline commands — call `npm test`, not `jest --coverage --ci`. See [references/best-practices.md](references/best-practices.md).
- **GitHub Actions only** — if user needs another platform, inform them it's not supported and offer to open a feature request at https://github.com/dot-ai-app/dot-ai/issues.

## Process

Execute sequentially. Each phase may change direction. Do NOT batch all questions upfront.

```
PHASE 1: ANALYZE → PHASE 2: PRESENT & ASK → PHASE 3: GENERATE
```

### Step 0: Confirm CI Platform (Blocking Gate)

Ask which CI/CD platform before any analysis. If not GitHub Actions, stop and offer feature request.

### Step 1: Analyze Repository

Analyze the entire repository — source code, automation, configs, docs, existing CI.

1. **Language/Framework** — Identify from source files and dependency manifests. Note version requirements.
2. **Existing Automation** — Find build/test/lint scripts and **read them to understand how they work** (arguments, setup, cleanup). If automation exists → use it. If not → ask user whether to add it or use inline commands.
3. **Existing CI** — Check for `.github/workflows/`. If found, analyze what's configured. Later ask whether to update or create new.
4. **Container/Registry** — Check for Dockerfile and registry references. If no Dockerfile but project could benefit, suggest using the `generate-dockerfile` skill.
5. **Branching/Release** — Check CI triggers, git tags for versioning patterns, docs for workflow hints.
6. **Environment/Secrets** — Find `.env.example`, search code for required env vars, identify needed secrets.
7. **App Definition** — Helm charts, Kustomize, plain K8s manifests, or container-only.
8. **Deployment Mechanism** — GitOps (ArgoCD, Flux), direct (Helm, kubectl), manual, or external. For GitOps: CI updates manifests, does NOT deploy directly. Determine where manifests live.
9. **Tool Manager** — Check for DevBox, mise, asdf, etc. If found, use automatically.

### Step 2: Present Findings

Present analysis summary for user confirmation. Include only what's relevant — adapt format to the project.

User can confirm, correct mistakes, or clarify ambiguities before proceeding.

### Step 3: Present Workflow Choices

Ask about policy decisions relevant to this project. Only ask what applies — skip irrelevant choices.

Common choices:
- **PR Workflow** — What runs on pull requests?
- **Release Trigger** — What triggers a release build?
- **Release Validation** — Re-run all checks (safest/slowest), skip validation (fastest), or security scans only?
- **Container Registry** — Where to push images? (if containerized)
- **Environment Setup** — Native GitHub Actions or DevBox?
- **Deployment Strategy** — GitOps, direct, or manual? (if deployed)

### Step 4: Generate Workflows

Generate workflow files based on analysis and confirmed choices. Apply best practices from [references/best-practices.md](references/best-practices.md).

### Step 5: Validate

Before presenting:
- Ensure valid YAML and GitHub Actions syntax
- Verify referenced automation exists
- List required secrets with setup guidance (`gh secret set` commands — show but do NOT execute)
- Ensure minimal `permissions:` block
- Verify deployment steps match selected mechanism
- Identify required repository settings/permissions and provide setup instructions upfront

### Step 6: Present to User

Provide:
1. Generated workflow file(s) with explanatory comments
2. Summary of detections and decisions
3. Required secrets to configure
4. Required permissions and settings with setup instructions

### Step 7: Commit and Verify

After user approval, commit workflows. Trigger them, monitor runs, iterate on failures until passing.
