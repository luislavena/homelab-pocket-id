# Deploy PocketID to Fly.io

These instructions assume you:

1. Have a Fly.io account and installed `flyctl` locally
2. Have a domain name to use
3. Have created your two S3-compatible buckets

## Create the application

```console
$ flyctl launch --name APP_NAME --copy-config --no-deploy
```

The above will create the application, give it a random name, reuse the existing
`fly.toml` configuration, but it will not automatically deploy it.

## Allocate IPs

```console
$ flyctl ips allocate-v4 --shared
$ flyctl ips allocate-v6
```

## Create `secrets.env`

Copy the template file:

```console
$ cp secrets.env.template secrets.env
```

Edit `secrets.env` and replace Replica 1 credentials and bucket information with
the ones from the previous step. Repeat this for Replica 2.

Also update `APP_URL` with the final domain to be used by your application.

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
