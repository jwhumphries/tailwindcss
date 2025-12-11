FROM --platform=$BUILDPLATFORM alpine:latest@sha256:51183f2cfa6320055da30872f211093f9ff1d3cf06f39a0bdb212314c5dc7375 AS builder

RUN apk add --no-cache curl jq

ARG TARGETPLATFORM
ARG BUILDPLATFORM

RUN echo "Building on $BUILDPLATFORM for $TARGETPLATFORM" && \
    TAG_NAME=$(curl -sL https://api.github.com/repos/tailwindlabs/tailwindcss/releases/latest | jq -r ".tag_name") && \
    echo "Latest version is: $TAG_NAME" && \
    ARCH=$(echo $TARGETPLATFORM | cut -d / -f 2) && \
    case "$ARCH" in \
      "amd64") BINARY_ARCH="x64" ;; \
      "arm64") BINARY_ARCH="arm64" ;; \
      *) echo "Unsupported architecture: $ARCH"; exit 1 ;; \
    esac && \
    FILENAME="tailwindcss-linux-${BINARY_ARCH}-musl" && \
    URL="https://github.com/tailwindlabs/tailwindcss/releases/download/${TAG_NAME}/${FILENAME}" && \
    echo "Downloading $URL..." && \
    curl -sL -o /tailwindcss "$URL" && \
    chmod +x /tailwindcss

FROM alpine:latest@sha256:51183f2cfa6320055da30872f211093f9ff1d3cf06f39a0bdb212314c5dc7375
COPY --from=builder /tailwindcss /usr/local/bin/tailwindcss
WORKDIR /workdir
RUN apk add --no-cache gcompat 
ENTRYPOINT ["tailwindcss"]
