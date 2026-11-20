FROM --platform=$BUILDPLATFORM alpine:latest@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf AS builder

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

FROM alpine:latest@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf
COPY --from=builder /tailwindcss /usr/local/bin/tailwindcss
WORKDIR /workdir
RUN apk add --no-cache gcompat 
ENTRYPOINT ["tailwindcss"]
