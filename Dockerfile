FROM --platform=$BUILDPLATFORM alpine:latest@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11 AS builder

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

FROM alpine:latest@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11
COPY --from=builder /tailwindcss /usr/local/bin/tailwindcss
WORKDIR /workdir
RUN apk add --no-cache gcompat 
ENTRYPOINT ["tailwindcss"]
