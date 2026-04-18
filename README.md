# Dockerfiles

A personal Docker image workspace for keeping many Dockerfiles organized and pushing versioned images to Docker Hub.

## Layout

```text
.
├── images/
│   ├── alpine-tools/
│   │   ├── Dockerfile
│   │   ├── .dockerignore
│   │   ├── image.env
│   │   └── README.md
│   └── _template/
├── scripts/
├── Makefile
└── .env.example
```

Each image lives in `images/<image>/` and carries its own Dockerfile, context files, and image metadata.

## Setup

```sh
cp .env.example .env
```

Edit `.env` and set `DOCKERHUB_NAMESPACE` to your Docker Hub username or organization.

Log in once before pushing:

```sh
docker login
```

## Common Commands

Create a new image folder:

```sh
make new IMAGE=my-image BASE=alpine:latest
```

Build one image locally:

```sh
make build IMAGE=alpine-tools VERSION=0.1.0
```

Build and push a version to Docker Hub:

```sh
make release IMAGE=alpine-tools
```

Push an extra tag at the same time:

```sh
make release IMAGE=alpine-tools TAGS=latest
```

Preview the tags that would be used:

```sh
make tags IMAGE=alpine-tools TAGS=latest
```

List available images:

```sh
make list
```

Scan a built image for vulnerabilities:

```sh
make scan IMAGE=alpine-tools VERSION=0.1.0
```

Fail the command when findings match the configured severity:

```sh
make scan IMAGE=alpine-tools VERSION=0.1.0 SCAN_EXIT_CODE=1
```

By default, scanning uses Trivy with `SEVERITY=HIGH,CRITICAL` and `IGNORE_UNFIXED=1`. JSON reports are written under `tmp/scans/`.

## Image Metadata

Every image has an `image.env` file:

```sh
IMAGE_NAME=alpine-tools
CONTEXT=images/alpine-tools
DOCKERFILE=images/alpine-tools/Dockerfile
PLATFORMS=linux/amd64,linux/arm64
DEFAULT_TAGS=
BUILD_ARGS=
```

`IMAGE_NAME` controls the Docker Hub repository name. For example, with `DOCKERHUB_NAMESPACE=ben`, `IMAGE_NAME=alpine-tools`, and `VERSION=0.1.0`, the pushed image is:

```text
ben/alpine-tools:0.1.0
```

`DEFAULT_TAGS` can hold tags that should always be pushed with a release. `TAGS` is for one-off tags supplied at the command line.

`BUILD_ARGS` accepts space-separated Docker build arguments, such as:

```sh
BUILD_ARGS="NODE_VERSION=22 APP_ENV=prod"
```

The scripts also pass `IMAGE_VERSION=<VERSION>` automatically.

## Recommended Versioning

Each image has a `VERSION` file containing the last successfully pushed version. `make release` and `make push` auto-increment the patch version when `VERSION` is omitted, then update the file only after Docker push succeeds.

For a new image with `VERSION` set to `0.0.0`, this pushes `0.0.1`:

```sh
make release IMAGE=my-image
```

You can still push an explicit version when needed:

```sh
```

Use `latest` only as a convenience pointer:

```sh
make release IMAGE=my-image TAGS=latest
```
