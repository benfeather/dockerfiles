ARG OPENCLAW_VERSION=2026.4.15

FROM ghcr.io/openclaw/openclaw:${OPENCLAW_VERSION}

ARG IMAGE_VERSION=dev
ARG FFMPEG_VERSION=7:*
ARG SUMMARIZE_VERSION=0
ARG CLAWHUB_VERSION=0
ARG LOSSLESS_CLAW_VERSION=0

LABEL org.opencontainers.image.title="openclaw" \
      org.opencontainers.image.description="OpenClaw runtime image with ffmpeg and helper CLIs installed" \
      org.opencontainers.image.version="${IMAGE_VERSION}"

USER root

RUN apt-get update \
  && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ffmpeg="${FFMPEG_VERSION}" \
  && \
  rm -rf /var/lib/apt/lists/*

RUN npm install -g \
    @steipete/summarize@"${SUMMARIZE_VERSION}" \
    clawhub@"${CLAWHUB_VERSION}" \
  && \
  npm cache clean --force

USER node

RUN plugin_tgz="$(npm pack @martian-engineering/lossless-claw@"${LOSSLESS_CLAW_VERSION}" --pack-destination /tmp --silent)" \
  && \
  openclaw plugins install "/tmp/${plugin_tgz}" \
  && \
  rm -f "/tmp/${plugin_tgz}" \
  && \
  npm cache clean --force
