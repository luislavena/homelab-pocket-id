# Homelab Pocket ID

Deploy [Pocket ID](https://github.com/pocket-id/pocket-id) with pre-configured
replicas using Litestream.

## Create your buckets

Create one bucket on Digital Ocean (Spaces) inside Amsterdam region (`ams3`) and
another in Nuremberg (`nbg1`). Or use a different provider like Hetzner,
Cloudflare R2 or AWS S3.

Then create the read-write S3 keys (Access Key + Secret Key) for each.

Suggestion: use random names for your buckets.

You can check [Litestream guides](https://litestream.io/guides/#replica-guides)
for instructions on how to setup them.

Save the credentials as you will need them later to setup the respective replica
configurations.

## Setup the administrator account

Now visit https://$APP_DOMAIN/login/setup and add the first Passkey to the
account.

## Contribution policy

Inspired by [Litestream](https://github.com/benbjohnson/litestream) and
[SQLite](https://sqlite.org/copyright.html#notopencontrib), this project is
open to code contributions for bug fixes only. Features carry a long-term
burden so they will not be accepted at this time. Please
[submit an issue](https://github.com/luislavena/homelab-pocket-id/issues/new) if you have
a feature you would like to request or discuss.

## License

Licensed under the Apache License, Version 2.0. You may obtain a copy of
the license [here](./LICENSE).
