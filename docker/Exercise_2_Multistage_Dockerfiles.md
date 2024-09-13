# Exercise 2 - Dockerfiles Extended: Multi-stage build

In this exercise, you will create a Dockerfile consisting of two stages. Within a build stage you will compile a go-based web app. Next, copy the binary to run stage, which consists of a minimal set of libs only. (and yes, you could also link everything statically and have an image with the binary only).

The app is a minimal "echo" webserver printing the source IP of any incoming request to both, its HTTP response and its stdout.

## Step 0: Setting up your build context

Create an empty directory on your VM that will be your build context. From your cloned training repository copy the [echo-server files](./res/echo-server) into the build context directory.

```bash
cp <path-to-cloned-repository>/docker/res/echo-sever/* <path-to-build-context-directory>
```

## Step 1: Creating the Dockerfile

Create a new Dockerfile that starts with `FROM golang:1.23-alpine AS builder`. Note, the `AS builder` extension - it allows you to reference files present at this stage and copy them over to another stage.
To prepare for the build:
- `COPY` the files `echo-server.go` and `go.mod` to `/go/src/`.
- change the `WORKDIR` to `/go/src`

## Step 2: Compiling

The next step should be to compile the go binary as part of the first docker stage - so everything we do here still goes into the Dockerfile.

`RUN go build echo-server.go`

The result should be will be binary called `echo-server` to be created inside the container.

## Step 3: Add another stage

Multi-stage in the context of Docker means, you are allowed to have more than one line with a `FROM` keyword. Let's make use of this to create a new stage:

`FROM alpine:latest`

This will set up a completely new image which is independent from the previous. Since you want to get some credit for what you are doing, put a `LABEL maintainer="<some name>"` in there.

## Step 4: Prepare runtime

Let's create an environment that allows us to run the app with minimal privileges. Create a new `appuser` with this command:

`adduser -S -D -H -h /app appuser`

## Step 5: Get the executable

Data from earlier stages can be consumed with `COPY --from=<previous stage name>` commands. Move the `echo-server` executable to the runtime stage and place it directly in the `/app/` directory.

## Step 6: Adapt the environment

So far all directories / files are owned by the `root` user. Time to change that and grant the `appuser` access to the required parts of the filesystem. Since everything relevant is stored within `/app` you can `RUN` this command to do the changes: `chown -R appuser /app`

Now you can use the `USER` directive to change to `appuser`. Also, the wiki expects to find files relative to its location. So you have to set the `WORKDIR` accordingly.

What's still missing? Of course your image should `EXPOSE` a port and should have `CMD` that is invoked upon container start.
The `echo-server` is listening on port 8080.

## Step 7: Build the images

Use the `docker build` command to build your image. Tag it along the way so you can find it easily.

## Step 8: Run your image

Run the image in detached mode, create a port forwarding from port 8080 in the container to some port on your host and connect with your web browser to it. Port-forwarding will be explained in detail in chapter 4. For the time being, please add the `-P` parameter to your `docker run` command. It should look like this:

```shell
# run the image
$ docker run -d -P <image ID>
>> ac40672a5efc676a6b88a753fb42e7346f24a44c6b664621f95374149f578345

# query running containers to get the port your traffic is forwarded to (55000 in this case)
$ docker ps
CONTAINER ID   IMAGE          COMMAND              CREATED         STATUS         PORTS                     NAMES
0d9ecd4ff885   9663ef71d178   "/app/echo-server"   2 seconds ago   Up 2 seconds   0.0.0.0:55000->8080/tcp   bold_torvalds
```
