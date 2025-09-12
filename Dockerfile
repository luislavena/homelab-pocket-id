# syntax=registry.docker.com/docker/dockerfile:1

ARG ALPINE_VERSION=3.22.1
FROM registry.docker.com/library/alpine:${ALPINE_VERSION}

# install litestream
RUN --mount=type=tmpfs,target=/tmp \
    set -eux; \
    cd /tmp; \
    { \
        export LITESTREAM_VERSION=0.3.13; \
        case "$(arch)" in \
        x86_64) \
            export \
                LITESTREAM_ARCH=amd64 \
                LITESTREAM_SHA256=eb75a3de5cab03875cdae9f5f539e6aedadd66607003d9b1e7a9077948818ba0 \
            ; \
            ;; \
        aarch64) \
            export \
                LITESTREAM_ARCH=arm64 \
                LITESTREAM_SHA256=9585f5a508516bd66af2b2376bab4de256a5ef8e2b73ec760559e679628f2d59 \
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

# install pocket-id binary
RUN --mount=type=tmpfs,target=/tmp \
    set -eux; \
    mkdir -p /app; \
    cd /tmp; \
    { \
        export POCKETID_VERSION=1.10.0; \
        case "$(arch)" in \
        x86_64) \
            export \
                POCKETID_ARCH=amd64 \
                POCKETID_SHA256=be00ac2358042294d80078ad19cb98528f9eefa6202fe35930f5ff81afd4293d \
            ; \
            ;; \
        aarch64) \
            export \
                POCKETID_ARCH=arm64 \
                POCKETID_SHA256=bc3aed53c123721f8c493337c50024f0dba16ac5a66acaa9cbd7bb022d84f79a \
            ; \
            ;; \
        esac; \
        wget -q -O pocket-id https://github.com/pocket-id/pocket-id/releases/download/v${POCKETID_VERSION}/pocket-id-linux-${POCKETID_ARCH}; \
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
    KEYS_STORAGE=database \
    DB_CONNECTION_STRING=/app/data/pocket-id.db \
    ANALYTICS_DISABLED=true

EXPOSE 1411
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/app/pocket-id", "/app/data/pocket-id.db"]
