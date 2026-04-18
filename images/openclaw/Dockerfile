FROM ghcr.io/openclaw/openclaw:latest

ARG IMAGE_VERSION=dev
LABEL org.opencontainers.image.title="openclaw" \
  org.opencontainers.image.description="OpenClaw runtime image with ffmpeg installed" \
  org.opencontainers.image.version="${IMAGE_VERSION}"

USER root

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ffmpeg && \
  rm -rf /var/lib/apt/lists/*

USER node
