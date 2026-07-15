# Docker Practice Guide — i310202
> Training exercises: `docker/Exercise_1_Dockerfiles.md`, `Exercise_2_Multistage_Dockerfiles.md`, `Exercise_3_Ports_Volumes.md`  
> Demo scripts: `docker/demo/demos.md`  
> Solutions: `docker/solutions/`

---

## 7. End-to-End Demo — Build, Push, Pull, Modify, Understand Layers

> **Story:** Trainer builds and publishes a "Hello World" Python app.  
> Students pull it, modify it, rebuild, and push their own version.  
> Everyone sees layers, caching, and the registry in action.

---

### Step 1 — Create the app and Dockerfile (in your editor / GUI)

Create a folder `hello-docker/` and add these two files inside it:

**`main.py`**
```python
print("Hello World!")
```

**`Dockerfile`**
```dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y python3

WORKDIR /app

COPY main.py .

CMD ["python3", "main.py"]
```

Then open a terminal and navigate to the folder:
```bash
cd ~/hello-docker
```

> **Why ubuntu?** We start from a bare Ubuntu image and install Python ourselves.
> This makes each layer visible — you can literally see `apt-get install` as its own layer.
> A slimmer approach (`python:3.12-slim`) hides this inside the base image.

---

### Step 2 — Build the image

```bash
docker build -t <your-dockerhub-username>/hello-docker:v1 .
```

**Watch the output — each line in Dockerfile = one layer:**
```
[1/4] FROM ubuntu:24.04                              <- pulls base Ubuntu image
[2/4] RUN apt-get update && apt-get install python3  <- installs Python (big layer ~60MB)
[3/4] WORKDIR /app                                   <- creates /app directory
[4/4] COPY main.py .                                 <- copies your file (tiny)
```

```bash
# See the image
docker images

# See every layer and its size
docker history <your-dockerhub-username>/hello-docker:v1
# CREATED BY                                    SIZE
# CMD ["python3" "main.py"]                    0B      <- metadata only
# COPY main.py .                               tiny    <- your file
# WORKDIR /app                                 0B
# RUN apt-get install python3                  ~60MB   <- python install layer
# ubuntu:24.04 base layers                     ~80MB
```

---

### Step 3 — Run it locally

```bash
docker run <your-dockerhub-username>/hello-docker:v1
# output: Hello World!

# Run with a name so you can reference it
docker run --name hello-test <your-dockerhub-username>/hello-docker:v1
docker logs hello-test
# output: Hello World!

docker rm hello-test
```

---

### Step 4 — Build for both platforms and Push to Docker Hub

> Use `docker buildx` to build for **both AMD64 (Linux) and ARM64 (Mac Apple Silicon)**  
> in one command and push directly to Docker Hub. No platform mismatch errors.

```bash
# First time only — create a multi-platform builder
docker buildx create --name multibuilder --use
docker buildx inspect --bootstrap

# Build for both platforms AND push in one command
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t <your-dockerhub-username>/hello-docker:v1 \
  --push \
  .
```

> `--platform linux/amd64,linux/arm64` — builds two images (one per architecture)  
> `--push` — pushes directly to Docker Hub (no separate `docker push` needed)  
> Docker Hub stores both under the same tag — the right one is pulled automatically per machine.

**What happens during push:**
```
The push refers to repository [docker.io/<username>/hello-docker]

[linux/amd64] -> building and pushing amd64 image
[linux/arm64] -> building and pushing arm64 image

Manifest list pushed — tag v1 now works on both Linux (amd64) and Mac (arm64)
Only your NEW layer is uploaded — the base layers are already in Docker Hub.
```

> After push, your image is public at:  
> `https://hub.docker.com/r/<username>/hello-docker`

---

### Step 5 — Pull and run on the MacBook (or any machine)

> Switch to the **MacBook** (or any other machine — Linux, Windows).  
> No code, no Dockerfile needed — just pull and run.  
> Docker automatically picks the right architecture (arm64 on Mac, amd64 on Linux).

```bash
# Pull the image — Docker selects the right platform automatically
docker pull <your-dockerhub-username>/hello-docker:v1

# Run it
docker run <your-dockerhub-username>/hello-docker:v1
# output: Hello World!

# See what layers came down
docker history <your-dockerhub-username>/hello-docker:v1
```

**What the pull looks like on the MacBook:**
```
v1: Pulling from <username>/hello-docker
ubuntu layers ...           → "Pull complete"   (base image pulled)
RUN apt-get install layer   → "Pull complete"   (python install layer)
COPY main.py layer          → "Pull complete"   (your file)

Status: Downloaded newer image
```

**Key insight — built on Linux, runs on Mac:**
```
Linux machine                     MacBook
  docker build                      docker pull
  docker push  →  Docker Hub  →   docker run
                                    output: Hello World!  ✓

Same image, different hardware, different OS — works identically.
This is the portability promise of containers.
```

Status: Downloaded newer image
```

---

### Step 6 — Students create their own version and push

Each student creates their own `hello-docker/` folder with two files (in their editor):

**`main.py`** — change the message to something personal:
```python
print("Hello from <your-name>!")
```

**`Dockerfile`** — same structure as trainer's:
```dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y python3

WORKDIR /app

COPY main.py .

CMD ["python3", "main.py"]
```

Then build, run, and push:

```bash
cd ~/hello-docker

# Build — notice which layers are CACHED vs rebuilt
docker build -t hello-docker:v1 .
```

**Cache in action — ubuntu and python layers are already on disk:**
```
[1/4] FROM ubuntu:24.04                → CACHED  (already pulled when you ran trainer's image)
[2/4] RUN apt-get install python3      → CACHED  (same command = same layer hash)
[3/4] WORKDIR /app                     → CACHED
[4/4] COPY main.py .                   → rebuilt (your file is different)

Build time: a few seconds — only the last layer was actually built
```

```bash
# Run your version
docker run hello-docker:v1
# output: Hello from <your-name>!

# Tag with your Docker Hub username and push
docker tag hello-docker:v1 <your-dockerhub-username>/hello-docker:v1
docker push <your-dockerhub-username>/hello-docker:v1
```

**Push is fast — only the changed layer is uploaded:**
```
ubuntu layers              → "Layer already exists"  (same as trainer's — SHARED in registry)
RUN apt-get install layer  → "Layer already exists"  (same layer hash)
COPY main.py layer         → "Pushed"                (only your diff = tiny upload)
```

---

### Step 7 — Compare trainer vs student layers

```bash
# Compare the two images side by side
docker history <trainer>/hello-docker:v1
docker history <your-name>/hello-docker:v1

# They share ALL layers except the last COPY layer
# ubuntu:24.04 and the python install layer are on disk ONCE even though two images use it
docker system df -v
# "Shared size" shows how much is reused across images
```

**What to observe:**
```
trainer/hello-docker:v1              your-name/hello-docker:v1
├── ubuntu:24.04 base    ←────────── SHARED (same layer hash)
├── RUN apt-get install  ←────────── SHARED (same command = same hash)
├── WORKDIR /app         ←────────── SHARED
└── COPY main.py . (v1)             COPY main.py . (student)  ← only this differs
     "Hello World!"                  "Hello from <name>!"
```

---

### The full picture — what we learned

```
Write code  →  Dockerfile  →  docker build  →  Image (layers)
                                                    │
                                              docker push
                                                    │
                                            Docker Hub registry
                                                    │
                                              docker pull
                                                    │
                                         Student laptop (layers reused)
                                                    │
                                           Modify + rebuild
                                           (cache hits = fast)
                                                    │
                                              docker push
                                           (only diff uploaded)
```

| What we did | What it showed |
|-------------|----------------|
| `docker build` | Each Dockerfile line = one layer, built top to bottom |
| `docker history` | Layers stacked — base at bottom, your changes at top |
| `docker push` | Only NEW layers uploaded — base shared in registry |
| `docker pull` | Only layers you don't have are downloaded |
| Rebuild after edit | Unchanged layers are CACHED — only changed layer rebuilds |
| Two images, shared base | One copy of ubuntu:24.04 + python install on disk serves both images |

---

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

## Learning Path

- [ ] `01` Create `main.py` + `Dockerfile` in editor (GUI)
- [ ] `02` `docker build` — watch 4 layers form including `apt-get install`
- [ ] `03` `docker run` — verify output locally
- [ ] `04` `docker push` — trainer publishes to Docker Hub
- [ ] `05` `docker pull` + run — students get the trainer's image
- [ ] `06` Students create own `main.py` + `Dockerfile`, build — observe cache hits
- [ ] `07` `docker push` — students publish their version
- [ ] `08` `docker history` + `docker system df -v` — compare shared layers  
