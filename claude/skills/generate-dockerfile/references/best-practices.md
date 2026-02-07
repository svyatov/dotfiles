# Dockerfile Best Practices Reference

Apply these when relevant to the project. The "verify everything" principle overrides all.

## Security

| Practice | Description |
|----------|-------------|
| Non-root user | Create dedicated user (UID 10001+), never run as root |
| Pin image versions | Use specific tags like `node:20-alpine`, never `:latest` |
| Official images | Prefer Docker Official Images or Verified Publishers |
| No secrets in image | Never embed credentials, API keys, or passwords |
| No sudo | Switch USER explicitly when root access is needed |
| Minimal packages | Only install packages actually required |
| `--no-install-recommends` | Use with apt-get to prevent optional packages |
| COPY over ADD | Always use COPY unless you need ADD's tar extraction; never ADD URLs |
| No debugging tools | No curl, wget, vim, netcat unless required by the app |
| Clean in same layer | Remove package manager caches in same RUN as installation |
| Executables owned by root | Binaries owned by root, executed by non-root user |

## Image Selection

| Practice | Description |
|----------|-------------|
| Minimal base images | Prefer alpine, slim, distroless, or scratch |
| Multi-stage builds | Separate build dependencies from runtime |
| Match language needs | Compiled → distroless/scratch; Interpreted → slim/alpine |
| Derive version from project | Get language version from project files, not assumptions |

## Build Optimization

| Practice | Description |
|----------|-------------|
| Layer caching | Copy dependency manifests before source code |
| Combine RUN commands | Chain with `&&` to reduce layers and enable cleanup |
| Explicit COPY | Never use `COPY . .`; copy only required files |
| Order by change frequency | Stable instructions first, volatile ones last |
| Production deps only | No devDependencies in runtime |

## Maintainability

| Practice | Description |
|----------|-------------|
| Sort arguments | Alphabetize multi-line package lists |
| Use WORKDIR | Never `RUN cd` |
| Exec form for CMD | `CMD ["executable", "arg1"]` for proper signal handling |
| Comment non-obvious decisions | Explain why, not what |
| OCI labels (optional) | `org.opencontainers.image.*` metadata |

## Stage Patterns

### Builder Stage

```dockerfile
FROM <language-image>:<version>-<variant> AS builder
WORKDIR /app

# Copy dependency manifests FIRST for layer caching
COPY <dependency-manifest-files> ./

# Install dependencies, clean cache in same layer
RUN <install-deps> && <clean-cache>

# Copy only source files needed for build (never COPY . .)
COPY <source-directories> ./
COPY <config-files-needed-for-build> ./

RUN <build-command>
```

**Checklist**: named stage, version from project files, manifests before source, cache cleanup, explicit COPY, correct build command.

### Runtime Stage

```dockerfile
FROM <minimal-runtime-image>:<version>
WORKDIR /app

# Create non-root user
RUN <create-group> && <create-user>

# Copy ONLY runtime artifacts from builder
COPY --from=builder <build-outputs> ./
COPY --from=builder <runtime-dependencies> ./

RUN chown -R <user>:<group> /app
USER <non-root-user>

# Only if port was verified during analysis
EXPOSE <port>

CMD ["<executable>", "<args>"]
```

**Checklist**: minimal base, non-root user (UID 10001+), only runtime artifacts, proper ownership, USER before CMD, EXPOSE only if verified, exec form CMD.

## Package Installation by Base Image

```dockerfile
# apt-get (Debian, Ubuntu)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        package1 \
        package2 && \
    rm -rf /var/lib/apt/lists/*

# apk (Alpine)
RUN apk add --no-cache \
        package1 \
        package2

# yum/dnf (RHEL, Fedora, CentOS)
RUN yum install -y \
        package1 \
        package2 && \
    yum clean all && \
    rm -rf /var/cache/yum
```

**Checklist**: correct package manager for base, skip optional packages, alphabetized, cache cleaned in same RUN, only required packages.
