FROM alpine:latest

RUN apk add --no-cache \
  wget \
  build-base \
  cmake \
  g++ \
  zstd-dev \
  zstd-static \
  xz-dev \
  lzo-dev \
  zlib-dev \
  lz4-dev \
  eudev-dev \
  linux-headers

COPY build.sh /build.sh
ENTRYPOINT ["/build.sh"]
