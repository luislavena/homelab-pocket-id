# syntax=registry.docker.com/docker/dockerfile:1

ARG ALPINE_VERSION=3.24.1
FROM registry.docker.com/library/alpine:${ALPINE_VERSION}

# ---
# system tools & non-root user (1000)
RUN --mount=type=cache,target=/var/cache/apk \
    set -eux; \
    { \
        apk add \
            su-exec \
        ; \
    }; \
    # non-root user and group
    { \
        addgroup -g 1000 pocket-id; \
        adduser -u 1000 -G pocket-id -h /app -s /bin/sh -D pocket-id; \
        # cleanup backup copies
        rm /etc/group- /etc/passwd- /etc/shadow-; \
    }

# ---
# litestream
RUN --mount=type=tmpfs,target=/tmp \
    set -eux; \
    cd /tmp; \
    { \
        export LITESTREAM_VERSION=0.3.14; \
        case "$(arch)" in \
        x86_64) \
            export \
                LITESTREAM_ARCH=amd64 \
                LITESTREAM_SHA256=880ccafc9514650c4a2a0cc78eb1e61aaad95dd3e86e877c8694f955c9095436 \
            ; \
            ;; \
        aarch64) \
            export \
                LITESTREAM_ARCH=arm64 \
                LITESTREAM_SHA256=4d375a66653e4a9b27a5b38ce9cb73681c39893ba0485f81ab860d4cd427e642 \
            ; \
            ;; \
        esac; \
        wget -q -O litestream.tar.gz https://github.com/benbjohnson/litestream/releases/download/v${LITESTREAM_VERSION}/litestream-v${LITESTREAM_VERSION}-linux-${LITESTREAM_ARCH}.tar.gz; \
        echo "${LITESTREAM_SHA256} *litestream.tar.gz" | sha256sum -c - >/dev/null 2>&1; \
        tar -xf litestream.tar.gz; \
        mv litestream /usr/local/bin/; \
        rm -f litestream.tar.gz; \
    }; \
    # smoke test
    [ "$(command -v litestream)" = '/usr/local/bin/litestream' ]; \
    litestream version

# ---
# pocket-id
RUN --mount=type=tmpfs,target=/tmp \
    set -eux; \
    mkdir -p /app; \
    cd /tmp; \
    { \
        export POCKETID_VERSION=2.11.0; \
        case "$(arch)" in \
        x86_64) \
            export \
                POCKETID_ARCH=amd64 \
                POCKETID_SHA256=ae15e3c71770bf59cae4935d328692bbb6a336008e149f648a965644d0300b7f \
            ; \
            ;; \
        aarch64) \
            export \
                POCKETID_ARCH=arm64 \
                POCKETID_SHA256=cff9fb5f2f8887d1aae33614b5e7af8624ad7b8573b1bcecdeb1ea3d6b77d04e \
            ; \
            ;; \
        esac; \
        wget -q -O pocket-id https://github.com/pocket-id/pocket-id/releases/download/v${POCKETID_VERSION}/pocket-id_linux_${POCKETID_ARCH}; \
        echo "${POCKETID_SHA256} *pocket-id" | sha256sum -c - >/dev/null 2>&1; \
        chmod +x pocket-id; \
        mv pocket-id /app/; \
    }

COPY ./container/litestream.yml /etc/
COPY ./container/entrypoint.sh /

# adjust default configuration
# Ref: https://pocket-id.org/docs/configuration/environment-variables
ENV \
    APP_ENV=production \
    FILE_BACKEND=database \
    DB_CONNECTION_STRING=/app/data/pocket-id.db \
    ANALYTICS_DISABLED=true \
    LOG_LEVEL=warn

EXPOSE 1411
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/app/pocket-id", "/app/data/pocket-id.db"]
