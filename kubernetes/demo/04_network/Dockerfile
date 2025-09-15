FROM golang:1.25-alpine AS builder
COPY . /go/src
WORKDIR /go/src
RUN go build -o echo-server main.go

FROM scratch AS echo-server
COPY --from=builder /go/src/echo-server /echo-server
EXPOSE 8080
ENTRYPOINT ["/echo-server"]
