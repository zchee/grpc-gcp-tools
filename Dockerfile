# syntax=docker.io/docker/dockerfile-upstream:1-labs

FROM --platform=$BUILDPLATFORM cgr.dev/chainguard/go:latest-musl AS builder
WORKDIR /root/go/src/github.com/GoogleCloudPlatform/grpc-gcp-tools

COPY --link go.* .
RUN --mount=type=cache,target=/root/go/pkg/mod --mount=type=cache,target=/root/.cache \
	go mod download

COPY --link proto ./proto
COPY --link dp_check ./dp_check

RUN ls -la .
RUN --mount=type=cache,target=/root/go/pkg/mod --mount=type=cache,target=/root/.cache \
	CGO_ENABLED=0 go build -v -o /dp_check -trimpath -tags='osusergo,netgo,static' -ldflags='-s -w -d -buildid= "-extldflags=-static"' ./dp_check

FROM --platform=$BUILDPLATFORM cgr.dev/chainguard/static:latest AS dp_check
COPY --link --from=builder /dp_check /
ENTRYPOINT ["/dp_check"]
