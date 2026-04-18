FROM alpine:latest

ARG IMAGE_VERSION=dev
LABEL org.opencontainers.image.title="alpine-tools" \
  org.opencontainers.image.description="Small Alpine image with common command-line tools" \
  org.opencontainers.image.version="${IMAGE_VERSION}"

RUN apk add --no-cache \
  bash \
  ca-certificates \
  curl \
  git \
  jq

CMD ["bash"]
