# Agents

Guidelines for AI agents working with this repository.

## Project overview

Docker container packaging project bundling
[Pocket ID](https://github.com/pocket-id/pocket-id) (OIDC provider) with
[Litestream](https://github.com/benbjohnson/litestream) (SQLite replication).
No application source code; only Dockerfile, shell scripts, YAML configs,
and CI workflows.

## Repository structure

```
Dockerfile                  # Multi-arch container build (amd64/arm64)
Makefile                    # Local build helper (`make build`)
VERSION                     # Current version (plain text)
container/
  entrypoint.sh             # Container startup script (POSIX shell)
  litestream.yml            # Litestream config template
docs/
  compose.yaml              # Docker Compose for local development
  fly.toml                  # Fly.io deployment config
  secrets.env.template      # S3 credentials template
.changes/                   # Changie changelog entries
.github/workflows/          # CI/CD pipelines
```

## Contribution policy

Only **bug fixes** accepted. Feature requests go to issues.
Every PR must include a changelog entry.

## Constraints

- Do not modify `VERSION` directly; managed by the release process
- Do not modify `.github/workflows/` unless explicitly requested
- Do not change upstream app behavior or add features; packaging-only repo
- Do not add secrets or credentials
- Do not modify `docs/fly.toml` or `docs/compose.yaml` unless required for a
  documented bug fix

## Branch and commit conventions

- Branch from `main` using dashes (e.g. `fix-entrypoint-bug`), no slashes
- Commits: imperative mood, 50-char subject, body wrapped at 72 chars
  explaining what and why

## Making changes

### Key files

- `Dockerfile`: binary versions, SHA256 checksums, base image, env defaults
- `container/entrypoint.sh`: startup logic, database restore, process execution
- `container/litestream.yml`: replication config template
- `docs/compose.yaml`: local development stack with MinIO replicas

### Bumping upstream versions

The `Dockerfile` pins each binary by version and per-architecture SHA256
checksum. Always update **both** architectures together.

#### Pocket ID

1. Compute checksums (replace `VERSION` with target release, e.g. `1.12.0`):

   ```
   curl -sL https://github.com/pocket-id/pocket-id/releases/download/vVERSION/pocket-id-linux-amd64 | sha256sum -
   curl -sL https://github.com/pocket-id/pocket-id/releases/download/vVERSION/pocket-id-linux-arm64 | sha256sum -
   ```

2. Update `POCKETID_VERSION` and each `POCKETID_SHA256` in the corresponding
   `x86_64`/`aarch64` `case` branches.

#### Litestream

1. Compute checksums (replace `VERSION` with target release, e.g. `0.3.13`):

   ```
   curl -sL https://github.com/benbjohnson/litestream/releases/download/vVERSION/litestream-vVERSION-linux-amd64.tar.gz | sha256sum -
   curl -sL https://github.com/benbjohnson/litestream/releases/download/vVERSION/litestream-vVERSION-linux-arm64.tar.gz | sha256sum -
   ```

2. Update `LITESTREAM_VERSION` and each `LITESTREAM_SHA256` in the
   corresponding `x86_64`/`aarch64` `case` branches.

#### Validation

Run `make build` to confirm correct binary downloads, checksum verification,
and smoke tests pass.

### Building locally

```
make build
```

Builds image tagged `ghcr.io/luislavena/homelab-pocket-id:latest`.
Use `make build VERSION=vX.Y.Z` for a specific tag. No tests beyond
Dockerfile's built-in smoke tests and SHA256 verification.

### Validation

Verify changes by:

1. Running `make build` successfully (Dockerfile syntax, checksums, smoke tests)
2. Testing locally with `docs/compose.yaml` when changes affect runtime behavior

## Pull request conventions

PR titles should be short and descriptive. PR descriptions should focus on the
user-facing "why" using concise bullet points rather than restating
implementation details. Avoid repeating file names, checksums, or env var
names that are already visible in the diff.

Extract this information from the session context or ask the user if it cannot
be extrapolated from it.

## Changelog workflow

Uses [changie](https://changie.dev/). Every PR requires a changelog entry
unless labeled `skip changelog`.

### Creating a changelog entry

```
changie new -k fixed -b "Description of the change"
```

Valid `-k` values: `added`, `changed`, `fixed`, `security`, `internal`.
Run `changie new --help` for all options.

### CI checks

- **check-changelog**: fails PRs missing entries in
  `.changes/unreleased/*.yaml` or unmodified `CHANGELOG.md`
- **create-release-pr**: manually triggered; batches unreleased changie
  entries, updates `CHANGELOG.md` and `VERSION`, and opens a release PR.
  Trigger it with:

  ```
  gh workflow run create-release-pr.yml
  ```

- **release**: on `main` when `CHANGELOG.md` changes; builds multi-arch image
  and creates GitHub release
- **release-tip**: on `main` when `CHANGELOG.md` unchanged; builds `tip`
  pre-release image
