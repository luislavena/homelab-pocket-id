# syntax=registry.docker.com/docker/dockerfile:1

# stage 0: download zip package of PocketID specific commit
# stage 1: build front-end (Vite/Svelte) artifacts
# stage 2: build back-end (Go) packed with front-end artifacts
# stage 3: copy artifacts and configuration into the final image

# ---
# stage 0: download zip package of PocketID specific commit

ARG ALPINE_VERSION=3.21.3
FROM registry.docker.com/library/alpine:${ALPINE_VERSION} AS stage0

# download tools to help with the build process
RUN --mount=type=cache,target=/var/cache/apk \
    set -eux; \
    apk add \
        curl \
        zip \
    ;

# https://github.com/pocket-id/pocket-id/archive/COMMIT.zip
RUN set -eux -o pipefail; \
    cd /tmp; \
    export \
        POCKET_ID_COMMIT=44b595d10ff4365befbf08b93701c6156b3d10c3 \
        POCKET_ID_SHA256=6447529dc27a6703d5983981c36ebcdd9f799052ab8c8a36207d789f81030781 \
    ; \
    { \
        curl --fail -Lo pocket-id.zip https://github.com/pocket-id/pocket-id/archive/${POCKET_ID_COMMIT}.zip; \
        echo "${POCKET_ID_SHA256} pocket-id.zip" | sha256sum -c - >/dev/null 2>&1; \
        unzip -q pocket-id.zip; \
        mv pocket-id-${POCKET_ID_COMMIT} /pocket-id; \
        rm pocket-id.zip; \
    }

# ---
# stage 1: build front-end (Vite/Svelte) artifacts

FROM registry.docker.com/library/node:22-alpine AS stage1
WORKDIR /build

# install dependencies
COPY --from=stage0 /pocket-id/frontend/package*.json /build/
RUN npm ci

# copy source code
COPY --from=stage0 /pocket-id/frontend /build/

# build artifacts
RUN set -eux -o pipefail; \
    export BUILD_OUTPUT_PATH=dist; \
    npm run build

# ---
# stage 2: build back-end (Go) packed with front-end artifacts

FROM registry.docker.com/library/golang:1.24-alpine AS stage2
WORKDIR /build

COPY --from=stage0 /pocket-id/backend/go.mod /pocket-id/backend/go.sum /build/
RUN go mod download

# copy source code, front-end artifacts and version information
COPY --from=stage0 /pocket-id/backend /build/
COPY --from=stage1 /build/dist /build/frontend/dist/
COPY --from=stage0 /pocket-id/.version /build/

# build application
RUN set -eux -o pipefail; \
    export \
    VERSION=$(cat /build/.version) \
    CGO_ENABLED=0 \
    GOOS=linux \
    ; \
    go build \
        -ldflags="-X github.com/pocket-id/pocket-id/backend/internal/common.Version=${VERSION} -buildid=${VERSION}" \
        -trimpath \
        -o pocket-id \
        ./cmd/main.go \
    ;

# ---
# stage 3: copy artifacts and configuration into the final image

FROM registry.docker.com/library/alpine:${ALPINE_VERSION} AS stage3

# install litestream
RUN --mount=type=cache,target=/var/cache/apk \
    --mount=type=tmpfs,target=/tmp \
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

COPY ./container/litestream.yml /etc/
COPY ./container/entrypoint.sh /

COPY --from=stage2 /build/pocket-id /app/

EXPOSE 1411
VOLUME [ "/app/data" ]
ENTRYPOINT ["/entrypoint.sh"]
