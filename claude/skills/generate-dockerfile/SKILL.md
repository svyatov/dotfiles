---
name: generate-dockerfile
description: >
  Generate optimized, secure, multi-stage Dockerfiles and .dockerignore files for any project.
  Use when the user asks to: (1) containerize a project, (2) create or generate a Dockerfile,
  (3) improve or optimize an existing Dockerfile, (4) add Docker support to a project,
  (5) review a Dockerfile for best practices. Triggers on: "Dockerfile", "dockerize",
  "containerize", "Docker build", "docker image", ".dockerignore".
---

# Generate Production-Ready Dockerfile

Generate an optimized, secure, multi-stage Dockerfile and .dockerignore by analyzing the project's structure, language, framework, and dependencies.

## Critical Rules

### Verify Everything Before Adding

**Before adding ANY instruction to the Dockerfile, verify it by examining the actual codebase.** Search for evidence, read actual source files, trace entry points through imports. Never assume—if uncertain, ask the user.

Thoroughness over speed: shallow analysis leads to broken Dockerfiles. Read actual source files (not just file names), search with multiple queries, trace the application entry point. If analysis feels quick, something was likely missed.

### Multi-Architecture Support

Ensure all instructions support multiple architectures (amd64, arm64). Use multi-arch official images. Detect architecture dynamically for binary downloads—never hardcode amd64/x86_64.

### NEVER Add HEALTHCHECK

Do NOT add HEALTHCHECK under any circumstances. Health endpoints are application-specific and cannot be verified from codebase analysis alone. Adding unverified health checks causes containers to be marked unhealthy incorrectly.

## Process

### Step 0: Check for Existing Files

Check for `Dockerfile` (and variants like `Dockerfile.prod`) and `.dockerignore` in the project root. Read them if present—this determines whether to generate new files or improve existing ones.

### Step 1: Analyze Project

Investigate the actual project (do not pattern-match). For each item, search the codebase for evidence:

1. **Language** — Find dependency manifests (`package.json`, `go.mod`, `requirements.txt`, `Cargo.toml`, `Gemfile`, etc.). Read their contents.
2. **Version** — Check manifests for version constraints, version files (`.node-version`, `.python-version`, `.tool-versions`), CI configs. If no version found, search online for current LTS/stable.
3. **Framework** — Read dependency lists, look for framework config files and directory conventions.
4. **Application type** — Examine entry points: web server (HTTP/routes/port binding), CLI (arg parsing), worker (queue consumers), static site (build output, no server).
5. **Port** — Search for `PORT` env var usage, hardcoded ports in server init, config files. Only add EXPOSE with concrete evidence.
6. **Build requirements** — Read manifest for build scripts, identify build tool and outputs.
7. **System dependencies** — Search for code executing external commands (shell exec, subprocess, system calls). For each binary, verify it's needed at runtime vs. build time. **Ask user when uncertain.**
8. **Environment variables** — Search for env var access patterns, `.env.example`/`.env.sample` files, config/startup code. Determine required (no default) vs. optional (has default). Set sensible defaults for required vars.

### Step 2: Generate or Improve Dockerfile

Consult [references/best-practices.md](references/best-practices.md) for detailed patterns, checklists, and package installation examples.

**New Dockerfile** → Generate multi-stage build following the builder/runtime stage patterns in the reference.

**Existing Dockerfile** → Evaluate against checklists, identify issues, preserve intentional customizations, edit to fix. Briefly explain changes.

Key rules:
- Never use `COPY . .` — explicitly copy only required files
- Copy dependency manifests before source code for layer caching
- Combine RUN commands with `&&`, clean caches in same layer
- Create non-root user (UID 10001+), set USER before CMD
- Pin image versions, use minimal base images
- CMD in exec form (`["executable", "arg"]`)

### Step 3: Create or Improve .dockerignore

Generate a **minimal** .dockerignore (~10-15 lines). Since the Dockerfile uses explicit COPY:

1. Review Dockerfile COPY commands — what directories are copied?
2. Exclude secret patterns that could exist inside copied directories
3. Exclude large directories (>1MB) that slow context transfer
4. Do NOT exclude directories not copied by the Dockerfile

### Step 4: Build, Test, and Iterate

Validate before presenting to user.

**4.1 Build:**
```bash
docker build -t <project>-validation .
```

**4.2 Run:**
```bash
docker run -d --name <project>-test <project>-validation
sleep 5
docker inspect --format='{{.State.Status}}' <project>-test
docker inspect --format='{{.State.ExitCode}}' <project>-test
```
Services should stay running; CLI tools should exit with code 0.

**4.3 Log analysis:**
```bash
docker logs <project>-test 2>&1
```
Use project knowledge from Step 1 to evaluate whether logs indicate success or failure.

**4.4 Lint** (if hadolint installed):
```bash
hadolint Dockerfile
```

**4.5 Security scan** (if trivy installed):
```bash
trivy image --severity HIGH,CRITICAL <project>-validation
```

**4.6 Iterate** — Max 5 attempts. If still failing, present current state with explanation and ask for guidance.

**4.7 Cleanup** (always):
```bash
docker stop <project>-test 2>/dev/null || true
docker rm <project>-test 2>/dev/null || true
docker rmi <project>-validation 2>/dev/null || true
```

## Output

**New Dockerfile:** Present Dockerfile + .dockerignore with brief explanation of key design choices, build/run commands, and image size expectations.

**Improved Dockerfile:** Present improved version with summary of changes (what + why), note preserved customizations.

**Both cases — recommended next steps:** integrate into CI/CD, commit to version control.

## Final Checklists

### Dockerfile
- [ ] Builds successfully
- [ ] Multi-stage build (builder → runtime)
- [ ] Non-root user (UID 10001+)
- [ ] Pinned version tags (no `:latest`)
- [ ] Minimal base images (alpine/slim/distroless)
- [ ] Dependency manifests before source (layer caching)
- [ ] Explicit COPY (no `COPY . .`)
- [ ] Combined RUN with `&&`, caches cleaned in same layer
- [ ] Exec form CMD
- [ ] No secrets, no debugging tools unless required
- [ ] No HEALTHCHECK

### .dockerignore
- [ ] Minimal (~10-15 lines)
- [ ] Excludes secrets inside copied directories
- [ ] Does NOT exclude directories not copied by Dockerfile

### Validation
- [ ] Image builds successfully
- [ ] Container starts without crashing
- [ ] Logs show no application errors
- [ ] Test container and image cleaned up
