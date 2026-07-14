# Docker Practice Guide — i310202
> Training exercises: `docker/Exercise_1_Dockerfiles.md`, `Exercise_2_Multistage_Dockerfiles.md`, `Exercise_3_Ports_Volumes.md`  
> Demo scripts: `docker/demo/demos.md`  
> Solutions: `docker/solutions/`

---

## 0. Docker Basics — Image & Container Lifecycle

> **Concept:** An **image** is a read-only template (like a class).  
> A **container** is a running instance of an image (like an object).  
> Images are built from Dockerfiles, stored in registries, and run as containers.
>
> ```
> Dockerfile  ──build──▶  Image  ──run──▶  Container (running process)
>                             └──push──▶  Registry (Docker Hub / ghcr.io)
>                             └──pull──◀  Registry
> ```

```bash
# Orient yourself
docker version
docker info

# Pull an image and run a container
docker pull nginx:mainline
docker run nginx:mainline         # foreground, Ctrl+C to stop
docker run -d nginx:mainline      # detached (background), prints container ID

# List running containers
docker ps
docker ps -a                      # includes stopped containers

# Logs and inspect
docker logs <container-name-or-id>
docker inspect <container-name-or-id>

# Stop and remove
docker stop <name>
docker rm <name>

# List images and clean up
docker images
docker rmi nginx:mainline         # only if no container uses it
docker system prune               # remove all stopped containers + dangling images
```

---

## 1. Exercise 1 — Build a Custom Nginx Image

> **Concept:** `FROM` starts from a base image. `COPY` bakes files into the image at  
> build time. `EXPOSE` documents which port the container uses. `docker build` creates  
> the image layer by layer — each instruction = one layer.

### Setup your build context

```bash
# Create a working directory
mkdir -p ~/docker-ex1 && cd ~/docker-ex1

# Copy the ready-made assets from the training repo
cp <path-to-repo>/docker/res/evil.html index.html
cp <path-to-repo>/docker/res/evil.jpg .
# Or write your own index.html
```

### Create docker-nginx.conf (nginx on port 8080)

```nginx
# file: docker-nginx.conf
server {
    listen       8080;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}
```

### Write the Dockerfile

```dockerfile
FROM nginx:mainline

# Bake the custom website into the image
COPY index.html /usr/share/nginx/html/index.html
COPY evil.jpg   /usr/share/nginx/html/evil.jpg

# Replace default nginx config so it listens on 8080
COPY docker-nginx.conf /etc/nginx/conf.d/nginx.conf

# Document the port (doesn't actually publish — that's -p at run time)
EXPOSE 8080
```

### Build and run

```bash
# Build — note the image ID printed at the end
docker build .
docker build -t my-nginx:v1 .     # with a name and tag

# Inspect what was created
docker history my-nginx:v1        # see the layers you just added

# Run it — no port yet, just check it starts without error
docker run my-nginx:v1
docker logs <container-id>        # should show nginx startup logs

# Clean up
docker rm <container-id>
```

### What to verify
- `docker history my-nginx:v1` shows your 3 new layers on top of nginx base
- `docker logs` shows no startup error
- Image size is slightly larger than `nginx:mainline` due to your added files

---

## 2. Exercise 2 — Multi-Stage Dockerfile (Go echo-server)

> **Concept:** Multi-stage builds use multiple `FROM` instructions in one Dockerfile.  
> Stage 1 (builder) compiles the code — it can be huge (Go SDK = ~300 MB).  
> Stage 2 (runtime) copies only the compiled binary — tiny final image (~10 MB).  
> Build tools, source code, and intermediate artifacts never reach production.
>
> ```
> Stage 1: golang:alpine  (300 MB)  →  compiles  →  binary
>                                                       ↓  COPY --from=builder
> Stage 2: alpine:latest  (~7 MB)   →  binary only  →  final image (~12 MB)
> ```

### Setup your build context

```bash
mkdir -p ~/docker-ex2 && cd ~/docker-ex2
cp <path-to-repo>/docker/res/echo-server/echo-server.go .
cp <path-to-repo>/docker/res/echo-server/go.mod .
```

### Write the Dockerfile

```dockerfile
# ── Stage 1: Build ────────────────────────────────────────────────
FROM golang:1.24-alpine AS builder

COPY echo-server.go go.mod /go/src/
WORKDIR /go/src

RUN go build echo-server.go
# Binary is now at /go/src/echo-server

# ── Stage 2: Runtime (no Go toolchain) ───────────────────────────
FROM alpine:latest

LABEL maintainer="i310202"

RUN mkdir -p /app && adduser -S -D -H -h /app appuser

COPY --from=builder /go/src/echo-server /app/echo-server

RUN chown -R appuser /app
USER appuser
WORKDIR /app

EXPOSE 8080
CMD ["/app/echo-server"]
```

### Build and run

```bash
docker build -t echo-server:i310202 .

# Compare image sizes — the point of multi-stage
docker images | grep -E "golang|echo-server"
# golang:1.24-alpine  ~  300 MB
# echo-server:i310202 ~  12 MB  ← only binary + alpine libs

# Run in detached mode, let Docker pick a random host port (-P uses EXPOSE)
docker run -d -P echo-server:i310202

# Find which host port was assigned
docker ps
# PORTS: 0.0.0.0:55xxx->8080/tcp

# Hit the echo server — it returns your source IP
curl localhost:<port>
# → Source IP: 172.17.0.1:55xxx

# Verify it runs as non-root
docker exec <container-id> whoami
# → appuser

docker stop <container-id> && docker rm <container-id>
```

### What to verify
- Final image is ~10-15 MB, not ~300 MB
- `docker exec <id> whoami` returns `appuser`, not `root`
- curl returns your source IP

---

## 3. Exercise 3 — Ports and Volumes

> **Concept:**  
> **Ports** — by default containers are isolated from the host network.  
> `-p <host-port>:<container-port>` punches a hole to reach the container.  
> `-P` auto-maps all EXPOSE'd ports to random host ports.  
>
> **Volumes / Bind mounts** — container filesystems are ephemeral (destroyed on `rm`).  
> Bind mounts map a host directory into the container — live, no copy needed.  
> Named volumes are managed by Docker and persist across container restarts.

### Step 0: Port forwarding with -P (random port)

```bash
# Use the image you built in Exercise 1
docker run -d -P my-nginx:v1

docker ps
# PORTS: 0.0.0.0:55001->80/tcp, 0.0.0.0:55002->8080/tcp
# Both ports from EXPOSE are forwarded to random host ports

# Connect to both — they show the same custom page
curl http://localhost:55001
curl http://localhost:55002

docker stop <name> && docker rm <name>
```

### Step 1: Port forwarding with -p (specific port)

```bash
# Map container port 80 explicitly to host port 8080
docker run -d -p 8080:80 my-nginx:v1

curl http://localhost:8080     # → your custom page

# Inspect the port mapping
docker inspect <name> | grep -A5 ExposedPorts
docker port <name>             # quick summary

docker stop <name> && docker rm <name>
```

### Step 2: Bind mount — inject a custom website without rebuilding

```bash
# Create a directory with a custom HTML file
mkdir -p ~/nginx-html
cat << 'EOF' > ~/nginx-html/index.html
<html><body>
  <h1>Served from a bind mount!</h1>
  <p>No image rebuild needed — the file lives on the host.</p>
</body></html>
EOF

# Mount the directory into nginx's webroot
docker run -d -p 8081:80 \
  --mount type=bind,source=~/nginx-html,target=/usr/share/nginx/html \
  --name vol-test nginx:mainline

curl http://localhost:8081    # → Served from a bind mount!

# Edit live — no restart needed
echo "<h1>Updated live!</h1>" > ~/nginx-html/index.html
curl http://localhost:8081    # → Updated live!

docker stop vol-test && docker rm vol-test
```

### Named volumes (persist across container restarts)

```bash
# Named volume — Docker manages the storage location
docker run -d -P \
  --mount source=jenkins_home,target=/var/jenkins_home \
  --name jenkins jenkins/jenkins:lts

docker ps                       # get port
docker logs jenkins | grep -A2 "Please use the following password"
# → setup token is here

# Stop and DELETE the container — volume persists
docker stop jenkins && docker rm jenkins

# Start a NEW container with the SAME volume — data survives
docker run -d -P \
  --mount source=jenkins_home,target=/var/jenkins_home \
  --name jenkins2 jenkins/jenkins:lts
# Login with same credentials — proves persistence

# Inspect the volume
docker volume inspect jenkins_home
docker volume ls

docker stop jenkins2 && docker rm jenkins2
docker volume rm jenkins_home   # explicit cleanup needed for named volumes
```

---

## 4. Docker Networking

> **Concept:** Every container gets its own network namespace (its own virtual NIC).  
> The default **bridge** network connects containers to the host but DNS resolution  
> between containers only works on **custom** bridge networks (not the default one).
>
> ```
> Host
> ├── docker0 (default bridge) — no DNS between containers
> └── custom-net (user bridge)  — containers reach each other by name ✅
> ```

```bash
# List available networks
docker network ls
# bridge (default), host, none

# Default bridge: containers can't find each other by name
docker run -d --name c1 nginx:mainline
docker run -it --rm alpine sh
# Inside: ping c1       → fails (no DNS on default bridge)
# Inside: ping <c1-ip>  → works (IP still reachable)
exit
docker stop c1 && docker rm c1

# Create a custom bridge network — enables DNS by container name
docker network create mynet

docker run -d --name nginx --network mynet nginx:mainline
docker run -it --rm --name helper --network mynet alpine sh
# Inside:
nslookup nginx    # → resolves! DNS works on custom networks
wget nginx        # → downloads nginx's default page
cat index.html    # → nginx welcome page content
exit

docker stop nginx && docker rm nginx
docker network rm mynet

# Run nginx and access from host
docker run -d -p 8081:80 nginx:mainline
# Open http://localhost:8081
docker stop $(docker ps -q)
```

---

## 5. Dockerfile Best Practices

> **Concept:** Layer order matters — Docker caches layers from the top.  
> Put things that change rarely (base image, OS packages) FIRST.  
> Put things that change often (your source code) LAST.

```dockerfile
# BAD — copies source code before installing deps
# Any code change invalidates the pip install layer
FROM python:3.12-slim
COPY . /app                       # ← changes every time
RUN pip install -r /app/requirements.txt

# GOOD — deps cached unless requirements.txt changes
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .           # ← rarely changes
RUN pip install -r requirements.txt
COPY . .                          # ← changes often, but only invalidates this layer
```

```bash
# Observe cache hits vs misses
docker build -t cache-test .      # first build — all layers built
docker build -t cache-test .      # second build — "Using cache" for unchanged layers
# touch app.py                    # simulate a code change
docker build -t cache-test .      # only layers from COPY . . onward are rebuilt

# Use .dockerignore to keep build context small
cat << 'EOF' > .dockerignore
.git
*.log
__pycache__
node_modules
EOF
docker build -t lean-build .      # .dockerignore keeps context small
```

---

## 6. Troubleshooting Containers

```bash
# Container won't start
docker logs <name>                # what did the process print?
docker logs --follow <name>       # tail logs live
docker inspect <name>             # full JSON metadata

# Container starts then exits immediately
docker ps -a                      # shows exit code in STATUS column
docker logs <name>                # error in the app itself
# Common cause: CMD fails, wrong entrypoint, missing env var

# Get a shell inside a running container
docker exec -it <name> sh         # use sh not bash for alpine-based images
docker exec -it <name> bash       # for ubuntu/debian-based images

# Get a shell in a fresh container without running the image's CMD
docker run -it --entrypoint sh <image>

# Check resource usage
docker stats                      # live CPU/mem for all running containers
docker stats <name>               # single container

# Inspect networking
docker exec <name> ip addr        # container's network interfaces
docker exec <name> cat /etc/hosts # container's hosts file
docker exec <name> env            # all environment variables

# Disk usage overview
docker system df                  # images, containers, volumes
docker system prune -a            # nuclear cleanup (removes ALL unused)
```

---

## Quick Reference Card

| Concept | Command | One-liner |
|---------|---------|-----------|
| Build image | `docker build -t name:tag .` | Runs Dockerfile top to bottom |
| Run container | `docker run -d -p 8080:80 name` | Detached, port forwarded |
| Logs | `docker logs <name>` | stdout/stderr of process |
| Shell | `docker exec -it <name> sh` | Get inside running container |
| Port map | `-p host:container` | Explicit; `-P` = random |
| Bind mount | `--mount type=bind,source=<host>,target=<ctr>` | Live host path |
| Named volume | `--mount source=vol,target=<ctr>` | Persists across restarts |
| Custom network | `docker network create net` | Enables DNS by name |
| Multi-stage | Two `FROM` in one Dockerfile | Small runtime image |
| Cleanup | `docker system prune` | Remove stopped containers + dangling images |

---

## Learning Path (matches training modules)

- [ ] `00` Docker basics — pull, run, ps, logs, rm  
- [ ] `01` Exercise 1 — Dockerfile, COPY, EXPOSE, build  
- [ ] `02` Exercise 2 — Multi-stage build, compare image sizes  
- [ ] `03` Exercise 3 — Port forwarding (-p, -P), bind mounts, named volumes  
- [ ] `04` Networking — bridge vs custom network, DNS resolution  
- [ ] `05` Best practices — layer caching, .dockerignore  
- [ ] `06` Troubleshooting — logs, exec, stats, inspect  
