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

## Create `secrets.env`

Copy the template file:

```console
$ cp secrets.env.template secrets.env
```

Edit `secrets.env` and replace Replica 1 credentials and bucket information with
the ones from the previous step. Repeat this for Replica 2.

Also update `APP_URL` with the final domain to be used by your application.

## Launch the application

```console
$ flyctl launch --name APP_NAME --copy-config --no-deploy
```

The above will create the application, give it a random name, reuse the existing
`fly.toml` configuration, but it will not automatically deploy it.

## Load the secrets

```console
$ cat secrets.env | flyctl secrets import
```

## Generate a SSL certificate

```console
$ flyctl certs create APP_DOMAIN
```

Note that you will need to introduce the DNS records to point to the application
domain.

## Deploy the application

```console
$ flyctl deploy
```

## Validate the application is working

```console
$ curl -s https://$APP_DOMAIN | jq .
```

## Setup the administrator account

Now visit https://$APP_DOMAIN/login/setup and add the first Passkey to the
account.
