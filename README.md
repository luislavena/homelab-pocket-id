# Homelab Pocket ID

Container image bundling [Pocket ID](https://github.com/pocket-id/pocket-id)
(a lightweight OIDC provider with passkey authentication) and
[Litestream](https://github.com/benbjohnson/litestream) (continuous SQLite
replication to S3-compatible storage).

Built for homelab deployments where you want single-binary simplicity with
automated database backups across multiple storage providers.

- Multi-architecture support (amd64/arm64)
- Non-root container execution (UID/GID 1000)
- Automatic database restore from replicas on first start
- Two S3-compatible replica destinations for redundancy
- Optional replication bypass for development

## Quick start

```sh
docker pull ghcr.io/luislavena/homelab-pocket-id:latest
```

Available image tags:

- `latest` -- latest stable release
- `vX.Y.Z` -- specific version (e.g. `v0.3.0`)
- `tip` -- latest build from `main` (pre-release)

## How it works

The container entrypoint performs these steps on startup:

1. Creates the database directory if it does not exist
2. Fixes ownership of the database directory using `PUID`/`PGID`
3. Restores the database from an S3 replica (only if the local database is
   missing and a replica exists)
4. Starts Pocket ID through Litestream for continuous replication, or directly
   if `DISABLE_REPLICATION` is set

## Configuration

### Pocket ID defaults

These environment variables are set in the container image. Override them as
needed:

| Variable | Default | Description |
|---|---|---|
| `APP_ENV` | `production` | Application environment |
| `FILE_BACKEND` | `database` | Store uploaded files in the database |
| `DB_CONNECTION_STRING` | `/app/data/pocket-id.db` | SQLite database path |
| `ANALYTICS_DISABLED` | `true` | Disable analytics collection |
| `LOG_LEVEL` | `warn` | Application log level |

See the [Pocket ID documentation](https://pocket-id.org/docs/configuration/environment-variables)
for the full list of available environment variables.

### Replication settings

Each replica requires its own set of S3-compatible credentials:

| Variable | Description |
|---|---|
| `REPLICA1_BUCKET` | Bucket name |
| `REPLICA1_ENDPOINT` | S3-compatible endpoint |
| `REPLICA1_REGION` | Bucket region |
| `REPLICA1_ACCESS_KEY_ID` | Access key ID |
| `REPLICA1_SECRET_ACCESS_KEY` | Secret access key |
| `REPLICA2_*` | Same as replica 1, for a second storage provider |

Refer to the [Litestream replica guides](https://litestream.io/guides/#replica-guides)
for instructions on setting up S3-compatible storage buckets.

### Runtime options

| Variable | Default | Description |
|---|---|---|
| `PUID` | `1000` | User ID for the running process |
| `PGID` | `1000` | Group ID for the running process |
| `DISABLE_REPLICATION` | _(unset)_ | Set to any value to skip Litestream replication |

## Building locally

```sh
make build
```

This builds the image tagged as `ghcr.io/luislavena/homelab-pocket-id:latest`.
Use `make build VERSION=vX.Y.Z` for a specific tag.

## Deployment

- **Local development**: see [`docs/compose.yaml`](docs/compose.yaml) for a
  Docker Compose setup with MinIO replicas
- **Fly.io**: see the [deployment guide](docs/deploy-fly.md) for step-by-step
  instructions

### Initial setup

After deploying, visit `https://<your-domain>/setup` to create the
first administrator account with a Passkey.

## Contribution policy

Inspired by [Litestream](https://github.com/benbjohnson/litestream) and
[SQLite](https://sqlite.org/copyright.html#notopencontrib), this project is
open to code contributions for bug fixes only. Features carry a long-term
burden so they will not be accepted at this time. Please
[submit an issue](https://github.com/luislavena/homelab-pocket-id/issues/new)
if you have a feature you would like to request or discuss.

## License

Licensed under the Apache License, Version 2.0. You may obtain a copy of
the license [here](./LICENSE).
