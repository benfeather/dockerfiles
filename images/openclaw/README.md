# openclaw

OpenClaw runtime image with `ffmpeg` installed.

## Build

```sh
make build IMAGE=openclaw VERSION=0.1.0
```

Override package versions with Docker build args:

```sh
make build IMAGE=openclaw VERSION=0.1.0 BUILD_ARGS="LOSSLESS_CLAW_VERSION=0.9.1 SUMMARIZE_VERSION=0.13.0 CLAWHUB_VERSION=0.9.0 FFMPEG_VERSION=7:5.1.8-0+deb12u1"
```

## Release

```sh
make release IMAGE=openclaw TAGS=latest
```
