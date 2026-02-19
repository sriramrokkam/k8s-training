FROM golang:1.26 AS builder

COPY . /go/src
WORKDIR /go/src
RUN CGO_ENABLED=0 GOOS=linux go build -o kube-terminator main.go

FROM scratch
COPY --from=builder --chown=1001:1001 --chmod=550 /go/src/kube-terminator /kube-terminator
ENTRYPOINT ["/kube-terminator"]
