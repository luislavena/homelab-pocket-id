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
