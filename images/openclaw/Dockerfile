FROM ghcr.io/openclaw/openclaw:2026.4.29-slim

LABEL org.opencontainers.image.title="openclaw" \
      org.opencontainers.image.description="OpenClaw runtime image with useful packages pre-installed"

USER root

RUN apt-get update \
    && \
    DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
      ffmpeg \
    && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g \
      @steipete/summarize \
      bun \
      clawhub \
      oxfmt \
      oxlint \
      typescript \
    && \
    npm cache clean --force

USER node
