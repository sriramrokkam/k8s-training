# Solution to Exercise 2 - Dockerfiles Extended: Multi-stage build

In this exercise, you will create a Dockerfile consisting of two stages. Within a *build* stage you will compile a golang application. Next, copy the binary to the *run* stage, which consists of a minimal set of libs only. (and yes, you could also link everything statically and have an image with the binary only).

The app is a simple webserver "echoing" the source IP of any incoming request to both, its HTTP response and its stdout. It listens on port 8080.

## Step 0: Setting up your build context

Create an empty directory on your VM that will be your build context. From your cloned training repository copy the `echo-server.go` and `go.mod` files into this new directory.

```bash
cp <path-to-cloned-repository>/docker/res/echo-sever/* <path-to-build-context-directory>
```

## Steps 1 to 6: Create the Dockerfile

Create the following Dockerfile in your build context.

```Dockerfile
# builder stage - based on golang image
FROM golang:1.23-alpine AS builder

# copy the code into the image
COPY . /go/src

# change current directory to go source path
WORKDIR /go/src

# build the binary
RUN go build echo-server.go

# app exec stage based on small alpine image
####################################
# separate & new image starts here!#
####################################
FROM alpine:latest

# prepare file system & create a new user
RUN mkdir -p /app && adduser -S -D -H -h /app appuser

# copy the compiled binary from the previous stage into current stage
COPY --from=builder /go/src/echo-server /app/echo-server

# change ownership of everything in /app
RUN chown -R appuser /app

# change from root to appuser
USER appuser

# the app expects to find directories & files relative to the current directory
WORKDIR /app

# expose app port 
EXPOSE 8080

# set default command to launch the wiki application upon container start
CMD ["/app/echo-server"]
```

## Step 9: Build the images

Build and tag the image. Again, use your participant-ID as release tag.

```bash
docker build -t echo-server:part-0001 .
```

## Step 10: Run your image

Run the image in detached mode and let Docker create a port forwarding to port `8080` on the container. Since port `8080` is exposed through the image, Docker can "discover" it.

```bash
docker run -d -P echo-server:part-0001
```

Query the running containers and identify the correct port (the port on your machine may vary - look for somthing like this: `0.0.0.0:55000->8080/tcp`):
```bash
docker ps
```

And finally, connect to the container:
```bash
curl localhost:<port> # e.g. 55000
```
