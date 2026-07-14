# Containers Practice Guide — i310202
> Linux primitives that make containers work  
> **Run everything inside a Ubuntu Docker container** — works on macOS, Windows, Linux  
> Reference scripts in the repo: `container-demos/demo-0*.sh`

## Setup — Your Linux Environment

All Linux primitive demos run inside a Ubuntu container. Docker is your Linux machine.

```bash
# Pull Ubuntu and get a shell — this IS your Linux environment
docker pull ubuntu:24.04
docker run -it --privileged ubuntu:24.04 /bin/bash

# Install tools needed for the demos (inside the container)
apt-get update && apt-get install -y \
  procps \
  iproute2 \
  util-linux \
  libcap2-bin \
  pax-utils \
  tree
```

> **Why `--privileged`?** The chroot, mount, unshare, and cgroup demos need kernel-level  
> access. `--privileged` gives the container full host capabilities — fine for local  
> learning, never use in production.

> **Two terminals tip:** open a second terminal and run  
> `docker exec -it $(docker ps -lq) /bin/bash` to get a second shell into the same  
> container — useful for side-by-side before/after comparisons.

---

## 0. Why Containers? — The Mental Model

> **Concept:** A container is NOT a VM. It is a normal Linux process that has been  
> isolated using three kernel features: **namespaces** (what it can see),  
> **cgroups** (how much it can use), and **overlayfs** (its layered filesystem).  
> Docker/containerd are just convenient wrappers around these primitives.

```
VM                            Container
┌─────────────────────┐       ┌──────────────────────┐
│  Guest OS kernel    │       │  Host OS kernel       │
│  ┌───────────────┐  │       │  ┌────────┐ ┌──────┐  │
│  │  App process  │  │       │  │ proc A │ │proc B│  │
│  └───────────────┘  │       │  │(ns-1)  │ │(ns-2)│  │
└─────────────────────┘       └──────────────────────┘
Separate kernel = heavy        Shared kernel = fast, lightweight
```

---

## 1. chroot — Isolating the Filesystem Root

> **Concept:** `chroot` changes what a process sees as `/` (the root of the filesystem).  
> This is the foundation of container images — the image is just a directory tree  
> that becomes the root for the container process.

> All commands below run **inside the Ubuntu container** you started in Setup.

### BEFORE chroot — record the baseline

```bash
# Inside ubuntu:24.04 container — this is the full Ubuntu filesystem
pwd          # → /

ls /
# → bin  boot  dev  etc  home  lib  lib64  media  mnt  opt
#   proc  root  run  sbin  srv  sys  tmp  usr  var

# All processes
ps -ef | wc -l   # → several processes

# Our PID
echo $$          # → e.g. 7
```

### BUILD the minimal "container" directory

```bash
# Use /tmp as working space — it always exists
mkdir -p /tmp/container-101 && cd /tmp/container-101
mkdir -p bin lib/aarch64-linux-gnu

# ── Step 1: copy bash ────────────────────────────────────────────
cp /bin/bash ./bin/

# Step 2: find out which shared libraries bash needs
ldd /bin/bash
# output looks like (Apple Silicon / ARM64):
#   linux-vdso.so.1 (0x...)                  ← virtual, skip
#   libtinfo.so.6 => /lib/aarch64-linux-gnu/libtinfo.so.6
#   libc.so.6 => /lib/aarch64-linux-gnu/libc.so.6
#   /lib/ld-linux-aarch64.so.1               ← the dynamic linker
# Note: libdl.so.2 no longer exists separately on glibc 2.34+ — merged into libc

# Step 3: copy each library preserving the directory path
cp /lib/aarch64-linux-gnu/libtinfo.so.6  lib/aarch64-linux-gnu/
cp /lib/aarch64-linux-gnu/libc.so.6      lib/aarch64-linux-gnu/
cp /lib/ld-linux-aarch64.so.1            lib/

# ── Step 4: same for ls ──────────────────────────────────────────
cp /bin/ls ./bin/
ldd /bin/ls
# notably needs libselinux.so.1 and libpcre2-8.so.0 on Ubuntu 24.04
cp /lib/aarch64-linux-gnu/libselinux.so.1  lib/aarch64-linux-gnu/
cp /lib/aarch64-linux-gnu/libpcre2-8.so.0  lib/aarch64-linux-gnu/

# ── Step 5: same for ps ──────────────────────────────────────────
cp /bin/ps ./bin/
ldd /bin/ps
# copy any NEW libs it shows

# ── Step 6: mount /proc so ps can read process info ─────────────
mkdir proc && mount -t proc proc proc

# Verify the container directory — this is the entire "image"
find /tmp/container-101 | wc -l  # → ~30-40 files
ls /tmp/container-101/
# → bin  lib  proc
```

> **Why copy the libs?** A binary is just instructions. At runtime the kernel loads  
> the binary then hands off to `ld-linux` (the dynamic linker) to find and load each  
> `.so` file. If any `.so` is missing, the binary won't start — you get  
> `error while loading shared libraries`. The image is the binary + its libs, nothing more.
>
> **Troubleshooting:** if `ls` fails with a missing lib error, run `ldd /bin/ls` again  
> and copy the missing `.so` into `lib/aarch64-linux-gnu/`.

### AFTER chroot — verify isolation with the same commands

```bash
# No sudo needed — already root inside the Ubuntu container
chroot /tmp/container-101 /bin/bash
```

```bash
# Verify 1 — filesystem is isolated
pwd          # → /

ls /
# → bin  lib  lib64  proc     ← ONLY what we copied, /etc /home /usr /var GONE ✅

cd /etc      # → bash: cd: /etc: No such file or directory  ✅
cd /home     # → No such file or directory  ✅
cd ../../..  # → still at /  — cannot escape  ✅

# Verify 2 — "I have no name!" in the prompt is expected
# No /etc/passwd inside the chroot, so the shell can't resolve the username.
# This is exactly what a container image without passwd would look like.

# Verify 3 — the gotcha: processes are NOT isolated
ps -ef       # → shows ALL processes from the Ubuntu container  ← no PID isolation
echo $$      # → same PID as before entering chroot — NOT 1  ← no PID namespace

exit         # back to the Ubuntu container shell
```

### Before vs After — side by side

| Command | BEFORE chroot | AFTER chroot |
|---------|--------------|--------------|
| `ls /` | 20+ directories | 4 dirs only |
| `cd /etc` | works | **No such file** |
| `cd ../../..` | goes to real `/` | **stays at fake `/`** |
| `ps -ef` | host processes | **still host processes** ← not isolated |
| `echo $$` | high PID | **same high PID** ← not isolated |

### What chroot isolates vs what it does not

```
chroot DOES isolate:   ✅ filesystem  (can't see /etc, /home, /var)
chroot does NOT:       ❌ processes   (ps shows everything)
                       ❌ network     (same interfaces)
                       ❌ users       (still root on the host)

→ This is why namespaces (demo-02) exist.
  A real container = chroot + namespaces + cgroups together.
```

### Run the full training demo script

```bash
# Ctrl+S to pause, Ctrl+Q to continue
bash container-demos/demo-01-chroot.sh
```

**Key insight:**
```
What you see as "ubuntu" or "alpine" in a container image is NOT a full OS.
It is a directory tree (bins + libs) that your process gets chrooted into.
The kernel is always the HOST kernel — the image just provides userland.
```

---

## 2. Namespaces — Isolating What a Process Can See

> **Concept:** Linux namespaces make a process think it is alone.  
> Each namespace type isolates a different aspect of the system.  
> chroot only isolated the filesystem — namespaces complete the picture.
>
> | Namespace | Isolates |
> |-----------|---------|
> | **PID**   | Process tree — container thinks its process is PID 1 |
> | **NET**   | Network interfaces, routing, ports |
> | **MNT**   | Filesystem mounts |
> | **UTS**   | Hostname and domain name |
> | **IPC**   | Inter-process communication |
> | **USER**  | User and group IDs |

### BEFORE namespace — the chroot gotcha revisited

```bash
# Inside chroot, ps still showed ALL processes from the Ubuntu container
# and echo $$ showed the same PID — because chroot has no PID namespace.

# Inside the Ubuntu container — record the baseline
ps -ef | wc -l   # → a few processes
echo $$          # → e.g. 7
hostname         # → some container ID like 3f2a1b...
```

### AFTER — add a PID namespace with unshare

```bash
# unshare creates a new namespace and runs bash inside it
# No sudo needed — already root inside Ubuntu container
unshare --pid --fork --mount-proc bash

# Verify — same commands, completely different results:
ps -ef           # → only 2 processes: bash + ps  ✅ isolated
echo $$          # → 1  ✅ we ARE PID 1 now
ps -ef | wc -l   # → 2  vs several on the outer container

exit             # back to the Ubuntu container
ps -ef | wc -l   # → original count again
```

### UTS namespace — isolate hostname

```bash
# BEFORE: hostname is the container's ID
hostname         # → 3f2a1b... (Docker-assigned)

# AFTER: isolated hostname inside a UTS namespace
unshare --uts bash
hostname my-container    # set a new hostname inside this namespace
hostname                 # → my-container  ✅
exit
hostname                 # → 3f2a1b...  ✅ outer container unchanged
```

### See all namespaces a Docker container uses

```bash
# Run a container
docker run -d --name ns-test nginx:mainline

# Find its PID on the host
docker inspect ns-test --format '{{.State.Pid}}'   # → e.g. 4821

# List all its namespaces — Docker sets up ALL of them automatically
ls -la /proc/4821/ns/
# → cgroup  ipc  mnt  net  pid  user  uts  (one file per namespace)

# Compare: host bash vs container process — different namespace inodes
ls -la /proc/$$/ns/pid          # host PID namespace
ls -la /proc/4821/ns/pid        # container PID namespace  ← different!

docker stop ns-test && docker rm ns-test
```

### Before vs After — side by side

| Command | Host (no namespace) | Inside PID namespace |
|---------|--------------------|--------------------|
| `ps -ef \| wc -l` | 25 processes | **2 processes** |
| `echo $$` | 1234 (high) | **1 (thinks it's PID 1)** |
| `hostname` | host name | **isolated name** (UTS ns) |

### Run the full training demo script

```bash
bash container-demos/demo-02-unshare.sh
```

---

## 3. cgroups — Limiting What a Process Can Use

> **Concept:** Control Groups (cgroups) set resource limits on processes.  
> Without cgroups, one container could consume all CPU/RAM and starve others.  
> This is how `docker run --memory 128m --cpus 0.5` works under the hood.

### BEFORE cgroups — no limits, process can use everything

```bash
# Spawn a CPU-burning process
yes > /dev/null &
YES_PID=$!

# Watch it consume 100% of one CPU core
top -p $YES_PID    # → ~100% CPU, no limit
# Press q to exit top

kill $YES_PID
```

### AFTER cgroups — throttle the same process

```bash
# Spawn the CPU burner again
yes > /dev/null &
YES_PID=$!

# Create a cgroup and set a CPU limit (cgroups v2)
# Already root inside the Ubuntu container — no sudo needed
mkdir /sys/fs/cgroup/demo-limit
echo "10000 100000" > /sys/fs/cgroup/demo-limit/cpu.max
# 10000/100000 = 10% CPU max

# Put the process into the cgroup
echo $YES_PID > /sys/fs/cgroup/demo-limit/cgroup.procs

# Watch it now — CPU usage drops to ~10%
top -p $YES_PID    # → ~10% CPU  ← throttled by cgroup
# Press q

kill $YES_PID
rmdir /sys/fs/cgroup/demo-limit
```

### See cgroups in action via Docker

```bash
# Start a container with a memory limit
docker run -d --name cg-test --memory=64m nginx:mainline

# See the actual cgroup limit on the host filesystem
cat /sys/fs/cgroup/system.slice/docker-$(docker inspect --format '{{.Id}}' cg-test).scope/memory.max
# → 67108864  (= 64 MB in bytes)

# Try to exceed the limit — container gets OOMKilled
docker run --rm --memory=32m alpine sh -c \
  "cat /dev/zero | head -c 100m | tail"
# → container exits with error

docker events --since 1m | grep -i oom   # → OOM kill event logged

docker stop cg-test && docker rm cg-test
```

### Before vs After — side by side

| | No cgroup | With cgroup (10% limit) |
|--|-----------|------------------------|
| `yes > /dev/null` CPU | ~100% | **~10%** |
| `--memory=32m` exceeding | process keeps running | **OOMKilled** |
| Docker `--cpus 0.5` | no effect without cgroup | **enforced by kernel** |

### Run the full training demo script

```bash
bash container-demos/demo-03-cgroup_v2.sh   # modern systems (cgroups v2)
# or
bash container-demos/demo-03-cgroup.sh      # older systems (cgroups v1)
```

---

## 4. Capabilities — Fine-grained Privilege Control

> **Concept:** Linux breaks root's privileges into ~40 individual capabilities.  
> Containers run with a reduced set — they can't do things like load kernel modules  
> or change system time, even if they run as root inside the container.

### BEFORE — root on the host can do anything

```bash
# On the host, root has all capabilities
# Already root inside the Ubuntu container
cat /proc/self/status | grep CapEff
# → CapEff: 000001ffffffffff   (all bits set = all capabilities when --privileged)

# Root can add a network interface
ip link add dummy0 type dummy
ip link show dummy0     # → works ✅
ip link del dummy0
```

### AFTER — root inside a container is limited

```bash
# Container runs as root but with reduced capabilities
docker run --rm alpine cat /proc/self/status | grep CapEff
# → CapEff: 00000000a80425fb   (much fewer bits set)

# Decode what capabilities it DOES have
capsh --decode=00000000a80425fb

# Try NET_ADMIN operation — blocked even though we're root inside
docker run --rm alpine ip link add dummy0 type dummy
# → ip: RTNETLINK answers: Operation not permitted  ← blocked!

# Explicitly ADD the capability — now it works
docker run --rm --cap-add NET_ADMIN alpine ip link add dummy0 type dummy
# → success

# Drop ALL capabilities — most locked down
docker run --rm --cap-drop ALL alpine id
# → uid=0(root) — still "root" by name, but zero actual privileges
```

### Before vs After — side by side

| Action | Host root | Container root (default) | `--cap-drop ALL` |
|--------|-----------|--------------------------|-----------------|
| `ip link add` | works | **blocked** | blocked |
| `mount` | works | **blocked** | blocked |
| `CapEff bits` | all set | ~12 bits | **0** |

### Run the full training demo script

```bash
bash container-demos/demo-04-capabilities.sh
```

---

## 5. OverlayFS — Layered Container Filesystems

> **Concept:** Container images are built in layers (each Dockerfile instruction = one layer).  
> OverlayFS stacks these read-only layers, then adds a thin read-write layer on top.  
> When you write a file, it goes into the RW layer — the image layers are never touched.
>
> ```
> RW layer  ← your container's writes go here (lost on container delete)
> ─────────
> Layer 3   ← COPY app.jar (from Dockerfile)
> Layer 2   ← RUN apt-get install java
> Layer 1   ← FROM ubuntu:22.04
> ```

### BEFORE — pull an image and inspect its layers

```bash
docker pull nginx:mainline

# See every layer and what instruction created it
docker history nginx:mainline
# → each line = one image layer with its size

# How many layers total?
docker inspect nginx:mainline | grep -A5 '"Layers"'
# → list of sha256 hashes, one per layer

# Disk usage — layers are SHARED between images that share a base
docker images
docker system df -v    # "Shared size" shows how much is reused
```

### AFTER — run a container and observe copy-on-write

```bash
docker run -d --name ofs-test nginx:mainline

# Find the UpperDir (RW layer) and LowerDir (read-only image layers)
docker inspect ofs-test | grep -A10 GraphDriver
# → UpperDir: /var/lib/docker/overlay2/<hash>/diff   ← your writes go here
# → LowerDir: /var/lib/docker/overlay2/<hash>/diff:... ← image layers (read-only)

UPPER=$(docker inspect ofs-test --format '{{.GraphDriver.Data.UpperDir}}')

# UpperDir is empty — nothing written yet
ls $UPPER    # → (empty)

# Write a file inside the container
docker exec ofs-test touch /hello.txt

# Now the file appears in UpperDir (copy-on-write)
ls $UPPER    # → hello.txt  ← only the diff, not the whole filesystem

# Delete the container — UpperDir is gone
docker stop ofs-test && docker rm ofs-test
ls $UPPER    # → No such file or directory  ← writes lost!

# Image layers are still there — unaffected
docker images nginx:mainline   # → still present
```

### Before vs After — side by side

| | Before (image) | Container running | After `docker rm` |
|--|----------------|-------------------|-------------------|
| Image layers | read-only | **still read-only** | still on disk |
| UpperDir (RW) | doesn't exist | exists, captures writes | **deleted** |
| Written files | n/a | visible inside container | **gone** |
| Shared layers | shared with other images | shared | **still shared** |

### Run the full training demo script

```bash
bash container-demos/demo-06-overlayfs.sh
```

---

## 6. Bind Mounts — Injecting Host Files into a Container

> **Concept:** A bind mount maps a host directory into the container.  
> The container sees the host files at that path — live, no copy.  
> This is how you inject configs, source code, or SSH keys without rebuilding the image.

### BEFORE bind mount — container uses its own baked-in files

```bash
# Default nginx container serves its own built-in page
docker run -d --name no-mount -p 8080:80 nginx:mainline
curl http://localhost:8080
# → "Welcome to nginx!" (nginx's default page baked into the image)

docker stop no-mount && docker rm no-mount
```

### AFTER bind mount — inject your own content from host

```bash
# Create a directory with custom content on the HOST
mkdir -p /tmp/webroot
echo "<h1>Hello from bind mount!</h1>" > /tmp/webroot/index.html

# Mount it over nginx's webroot — no image rebuild
docker run -d --name with-mount -p 8081:80 \
  --mount type=bind,source=/tmp/webroot,target=/usr/share/nginx/html \
  nginx:mainline

curl http://localhost:8081
# → Hello from bind mount!  ← your file, not nginx's default

# Edit the file LIVE on the host — container sees it instantly, no restart
echo "<h1>Updated live — no restart!</h1>" > /tmp/webroot/index.html
curl http://localhost:8081
# → Updated live — no restart!

docker stop with-mount && docker rm with-mount
```

### Before vs After — side by side

| | No bind mount | With bind mount |
|--|--------------|----------------|
| `curl localhost` | nginx default page | **your custom page** |
| Edit host file | no effect | **instant update, no restart** |
| Image content | unchanged | **hidden/overridden at mount path** |
| File persists after `rm` | n/a | **yes — it's on the host** |

### Security demo — verify the risk of unrestricted bind mounts

```bash
# WARNING: demonstration only — never do this in production
# Mounting /etc into a container exposes host secrets
docker run -it --rm \
  --mount type=bind,source=/etc,target=/hostetc \
  alpine cat /hostetc/shadow
# → can read host shadow file from inside the container!

# Lesson: always use :ro (read-only) for config mounts
docker run -d \
  --mount type=bind,source=/tmp/webroot,target=/usr/share/nginx/html,readonly \
  nginx:mainline
# → container can read but NOT write to the mounted path
```

### Run the full training demo script

```bash
bash container-demos/demo-07-bind-mount.sh
```

---

## Quick Reference — Linux Primitives

| Primitive     | Isolates / Controls       | Docker equivalent |
|---------------|---------------------------|-------------------|
| `chroot`      | Filesystem root           | Container image (rootfs) |
| `namespaces`  | PID, NET, MNT, UTS…       | `docker run` (automatic) |
| `cgroups`     | CPU, memory, I/O          | `--cpus`, `--memory` |
| `capabilities`| Root privilege slices     | `--cap-add/drop` |
| `overlayfs`   | Layered image filesystem  | Image layers, `docker history` |
| `bind mount`  | Host path → container path| `--mount type=bind` |

---

## Learning Path

- [ ] `01` chroot — understand rootfs = just a directory  
- [ ] `02` namespaces — process isolation (PID, NET)  
- [ ] `03` cgroups — resource limits  
- [ ] `04` capabilities — fine-grained privilege  
- [ ] `05` overlayfs — layered images, copy-on-write  
- [ ] `06` bind mounts — inject host files  
