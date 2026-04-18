# openclaw

OpenClaw runtime image with `ffmpeg` installed.

## Build

```sh
make build IMAGE=openclaw VERSION=0.1.0
```

The Dockerfile defaults to OpenClaw `2026.4.15`. The npm package defaults use `0`, so fresh builds can pick up newer `0.x` minor and patch releases. `FFMPEG_VERSION` defaults to `7:*`.

Refresh ranged package versions and the base tag by bypassing build cache:

```sh
make build IMAGE=openclaw VERSION=0.1.0 NO_CACHE=1 PULL=1
```

Override versions with Docker build args:

```sh
make build IMAGE=openclaw VERSION=0.1.0 BUILD_ARGS="OPENCLAW_VERSION=2026.4.15 LOSSLESS_CLAW_VERSION=0.9.1 SUMMARIZE_VERSION=0.13.0 CLAWHUB_VERSION=0.9.0 FFMPEG_VERSION=7:5.1.8-0+deb12u1"
```

## Release

```sh
make release IMAGE=openclaw TAGS=latest
```

## Scan

```sh
make scan IMAGE=openclaw VERSION=0.1.0
```
