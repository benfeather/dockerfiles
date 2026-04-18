FROM ghcr.io/openclaw/openclaw@sha256:9d5f1dfbd5deedc37706c78f745b958ffbe9b4f20840cfb4d49c617a50326902

ARG IMAGE_VERSION=dev
LABEL org.opencontainers.image.title="openclaw" \
  org.opencontainers.image.description="OpenClaw runtime image with ffmpeg and helper CLIs installed" \
  org.opencontainers.image.version="${IMAGE_VERSION}"

USER root

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ffmpeg=7:5.1.8-0+deb12u1 && \
  rm -rf /var/lib/apt/lists/*

RUN npm install -g @steipete/summarize@0.13.0 clawhub@0.9.0 && \
  npm cache clean --force

RUN mkdir -p /usr/local/share/openclaw-plugins && \
  chown node:node /usr/local/share/openclaw-plugins

USER node

RUN npm pack @martian-engineering/lossless-claw@0.9.1 --pack-destination /usr/local/share/openclaw-plugins --silent && \
  openclaw plugins install /usr/local/share/openclaw-plugins/martian-engineering-lossless-claw-0.9.1.tgz && \
  npm cache clean --force

CMD ["node", "openclaw.mjs", "gateway", "--allow-unconfigured"]
