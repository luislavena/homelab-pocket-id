# syntax=registry.docker.com/docker/dockerfile:1

ARG ALPINE_VERSION=3.22.0
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
        export POCKETID_VERSION=1.3.1; \
        case "$(arch)" in \
        x86_64) \
            export \
                POCKETID_ARCH=amd64 \
                POCKETID_SHA256=eb245e1819de7f600f614f2d470e416a0ecc8a30cd69c0959fa14590d9e11819 \
            ; \
            ;; \
        aarch64) \
            export \
                POCKETID_ARCH=arm64 \
                POCKETID_SHA256=fa81b1976a917426fb672ce57fea6974823eab150b00e6f1462e3d33f58c6677 \
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

EXPOSE 1411
VOLUME [ "/app/data" ]
ENTRYPOINT ["/entrypoint.sh"]
