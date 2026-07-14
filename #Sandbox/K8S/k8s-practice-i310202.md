# Kubernetes Practice Guide — i310202
> Cluster: blr29.k8s-train.shoot.canary.k8s-hana.ondemand.com  
> Your namespace: `i310202`  
> App used: **Fortune Cookies** (frontend Java app + PostgreSQL backend)

---

## 0. Setup — Your Namespace & Context

> **Concept:** Every team/user in Kubernetes gets isolated within a **Namespace**.  
> It's like a virtual cluster inside the real cluster. Resources in one namespace  
> don't interfere with others.

```bash
# Step 1: Check current context and cluster
kubectl config current-context
kubectl cluster-info

# Step 2: Create YOUR namespace (use your SAP user ID)
kubectl create namespace i310202

# Step 3: Set it as default so you don't need -n every time
kubectl config set-context --current --namespace=i310202

# Step 4: Verify
kubectl config get-contexts
kubectl get namespaces | grep i310202
```

---

## 1. Explore the Cluster — kubectl Basics

> **Concept:** `kubectl` is the CLI that talks to the Kubernetes API server.  
> Every command is an HTTP request under the hood. The API server is the brain of K8s.

```bash
# See all nodes in the cluster
kubectl get nodes
kubectl get nodes -o wide        # more details (IP, OS, kernel)

# Describe a specific node (replace <node-name> with one from above)
kubectl describe node <node-name>

# What APIs does this cluster support?
kubectl api-resources             # lists all resource types with short names
kubectl api-versions              # lists all API groups/versions

# Open a proxy tunnel to the API server
kubectl proxy &
# Now open: http://localhost:8001/api/v1/namespaces
# Kill when done: kill %1

# Check what YOU are allowed to do in your namespace
kubectl auth can-i --list -n i310202
```

---

## 2. Your First Pod — nginx

> **Concept:** A **Pod** is the smallest deployable unit in Kubernetes.  
> It wraps one (or more) containers. Pods are ephemeral — if they crash, they're gone  
> (Deployments fix this). Think of a pod like a "wrapper" around your container.

Save this as `01-nginx-pod.yaml` in your sandbox folder, then apply it.

```yaml
# File: 01-nginx-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  namespace: i310202
  labels:
    app: nginx
    owner: i310202
spec:
  containers:
  - name: nginx
    image: nginx:mainline
    ports:
    - containerPort: 80
      name: http-port
    livenessProbe:
      httpGet:
        path: /
        port: http-port
      initialDelaySeconds: 3
      periodSeconds: 30
```

```bash
# Dry-run first (safe preview without creating anything)
kubectl apply -f 01-nginx-pod.yaml --dry-run=client

# Create the pod
kubectl apply -f 01-nginx-pod.yaml

# Watch it come up
kubectl get pods -w

# Get logs
kubectl logs nginx-pod

# Shell into the pod
kubectl exec -it nginx-pod -- bash
# Inside: curl localhost / ls / cat /etc/nginx/nginx.conf
# Exit: exit

# Port-forward to test it locally
kubectl port-forward pod/nginx-pod 8080:80
# Open http://localhost:8080 in browser, then Ctrl+C

# Clean up
kubectl delete pod nginx-pod
```

---

## 3. Deployment — Self-healing & Scaling

> **Concept:** A **Deployment** manages a set of identical pods (via a ReplicaSet).  
> If a pod crashes, the Deployment creates a new one automatically.  
> This is how real apps run — never as bare pods.

```yaml
# File: 02-nginx-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: i310202
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
        owner: i310202
    spec:
      containers:
      - name: nginx
        image: nginx:mainline
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
```

```bash
kubectl apply -f 02-nginx-deployment.yaml

# Watch pods being created (notice 2 replicas)
kubectl get pods -l app=nginx -w

# See the ReplicaSet that Deployment created
kubectl get replicasets

# Scale up to 4 replicas
kubectl scale deployment nginx-deployment --replicas=4
kubectl get pods

# Delete one pod manually — watch it get recreated (self-healing!)
kubectl delete pod <one-of-the-pod-names>
kubectl get pods -w

# Rolling update: change image version
kubectl set image deployment/nginx-deployment nginx=nginx:stable
kubectl rollout status deployment/nginx-deployment

# View rollout history
kubectl rollout history deployment/nginx-deployment

# Rollback to previous version
kubectl rollout undo deployment/nginx-deployment

# Scale back down
kubectl scale deployment nginx-deployment --replicas=2
```

---

## 4. Services — Networking Inside the Cluster

> **Concept:** Pods get random IPs that change on restart. A **Service** gives a  
> stable DNS name and IP to reach a group of pods (selected by labels).  
> - **ClusterIP**: only reachable inside the cluster  
> - **NodePort**: exposed on every node's IP  
> - **LoadBalancer**: creates an external IP (cloud only)

```yaml
# File: 03-nginx-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: i310202
spec:
  selector:
    app: nginx          # matches pods with this label
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  type: ClusterIP
```

```bash
kubectl apply -f 03-nginx-service.yaml

# See the service and its ClusterIP
kubectl get svc nginx-service
kubectl describe svc nginx-service

# See which pod IPs it points to (endpoints)
kubectl get endpoints nginx-service

# Test the service from inside the cluster
kubectl run test-pod --image=busybox -it --rm -- sh
# Inside: wget -qO- http://nginx-service
# Exit: exit

# Port-forward via service
kubectl port-forward service/nginx-service 8080:80
```

---

## 5. ConfigMaps & Secrets

> **Concept:** Never bake config or credentials into your container image.  
> - **ConfigMap**: non-sensitive config (URLs, feature flags, config files)  
> - **Secret**: sensitive data (passwords, tokens) — stored base64-encoded in etcd
> - **env**: injects config/secret as environment variables
> - **volume**: mounts config/secret as files inside the container, typically under `/etc/config` for ConfigMaps and `/etc/secret` for Secrets

```yaml
# File: 04-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fortune-config
  namespace: i310202
data:
  APP_COLOR: "blue"
  GREETING: "Hello from the training cluster!"
  app.properties: |
    max.cookies=10
    refresh.interval=30s
```

```yaml
# File: 05-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
  namespace: i310202
type: Opaque
stringData:                  # stringData auto-encodes to base64
  DB_USER: fortuneuser
  DB_PASSWORD: supersecret123
```

```yaml
# File: 06-pod-with-config.yaml
apiVersion: v1
kind: Pod
metadata:
  name: fortune-config-demo
  namespace: i310202
spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "echo Color=$APP_COLOR, Greeting=$GREETING, User=$DB_USER && sleep 3600"]
    # METHOD 1: env — pulls values from ConfigMap/Secret and injects as environment variables ($APP_COLOR, $DB_USER etc.)
    # App reads via: System.getenv("APP_COLOR") / os.environ["APP_COLOR"] / process.env.APP_COLOR
    env:
    - name: APP_COLOR
      valueFrom:
        configMapKeyRef:
          name: fortune-config
          key: APP_COLOR
    - name: GREETING
      valueFrom:
        configMapKeyRef:
          name: fortune-config
          key: GREETING
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: DB_USER
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: DB_PASSWORD
    # METHOD 2: volumeMounts — mounts ConfigMap keys as files inside the container at /etc/config/
    # App reads via: readFile("/etc/config/APP_COLOR") — auto-updates when ConfigMap changes, no restart needed
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: fortune-config
```

```bash
kubectl apply -f 04-configmap.yaml
kubectl apply -f 05-secret.yaml
kubectl apply -f 06-pod-with-config.yaml

# Check the config was injected
kubectl logs fortune-config-demo

# See config mounted as files
kubectl exec fortune-config-demo -- ls /etc/config
kubectl exec fortune-config-demo -- cat /etc/config/app.properties

# Decode a secret value
kubectl get secret db-credentials -o jsonpath='{.data.DB_PASSWORD}' | base64 --decode

# Clean up
kubectl delete pod fortune-config-demo
```

### How to Verify ConfigMaps & Secrets Inside the Pod

> **Note:** `busybox` does not have `bash` — always use `sh` to exec in.

```bash
# Exec into the pod
kubectl exec -it fortune-config-demo -n i310202 -- sh
```

**Inside the pod — verify ConfigMap volume files:**
```sh
# List files mounted from ConfigMap (each key = a file)
ls /etc/config

# Read individual files
cat /etc/config/APP_COLOR
cat /etc/config/GREETING
cat /etc/config/app.properties
```

**Inside the pod — verify env variables (ConfigMap + Secret):**
```sh
# Check individual variables
echo $APP_COLOR
echo $GREETING
echo $DB_USER
echo $DB_PASSWORD

# Or see all at once
env | grep -E "APP_COLOR|GREETING|DB_"
```

**Outside the pod — decode secret values from cluster:**
```bash
kubectl get secret db-credentials -n i310202 \
  -o jsonpath='{.data.DB_USER}' | base64 --decode

kubectl get secret db-credentials -n i310202 \
  -o jsonpath='{.data.DB_PASSWORD}' | base64 --decode
```

> **Key insight:** Secrets are base64-encoded in etcd (cluster storage),  
> but Kubernetes automatically **decodes** them when injecting into pods —  
> so `echo $DB_PASSWORD` inside the pod shows the plain value.

### ConfigMap & Secret injection works the same in Deployments

> When using `kind: Deployment` instead of `kind: Pod`, the `env` and `volumeMounts`  
> are defined inside the **pod template** (`spec.template.spec`) — so every replica  
> gets the same config injected automatically.

```
Deployment (replicas: 3)
    ├── Pod-1  → APP_COLOR=blue, /etc/config/APP_COLOR exists
    ├── Pod-2  → APP_COLOR=blue, /etc/config/APP_COLOR exists
    └── Pod-3  → APP_COLOR=blue, /etc/config/APP_COLOR exists
```

> **Important — ConfigMap update behaviour:**
>
> | Injection method | Updates automatically when ConfigMap changes? |
> |-----------------|----------------------------------------------|
> | `env` (valueFrom/envFrom) | No — pod must restart to pick up new value |
> | `volume` mount | Yes — files update automatically within ~1 min |
>
> This is why volume mounting is preferred for config that changes — no restart needed.

---

## 5b. Persistence Warm-up — PV & PVC (Do This Before Fortune Cookies)

> **Concept:** Containers are stateless by default, so data is lost on restart.
> Before deploying the app stack, quickly practice persistent storage.
> - **PersistentVolume (PV)**: actual storage provisioned in the cluster
> - **PersistentVolumeClaim (PVC)**: your app's storage request

```yaml
# File: 11-pvc-demo.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: demo-pvc
  namespace: i310202
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: pvc-demo-pod
  namespace: i310202
spec:
  containers:
  - name: writer
    image: busybox
    command: ["sh", "-c", "echo 'Hello persistent world!' > /data/hello.txt && sleep 3600"]
    volumeMounts:
    - name: my-storage
      mountPath: /data
  volumes:
  - name: my-storage
    persistentVolumeClaim:
      claimName: demo-pvc
```

```bash
kubectl apply -f 11-pvc-demo.yaml

kubectl get pvc
kubectl get pv

# Read the file written by the pod
kubectl exec pvc-demo-pod -- cat /data/hello.txt

# Delete the pod and recreate — data survives!
kubectl delete pod pvc-demo-pod
kubectl apply -f 11-pvc-demo.yaml
kubectl exec pvc-demo-pod -- cat /data/hello.txt   # still there!

# Optional cleanup before moving to app deployment
kubectl delete pod pvc-demo-pod
kubectl delete pvc demo-pvc
```

---

## 6. Fortune Cookies App — Putting It All Together

> **Concept:** This is the sample app used throughout the training.  
> It has a Java frontend + PostgreSQL backend — just like a real microservice app.  
> We use a public image: `ghcr.io/cloud-native-dev-journey/fortune-cookies:latest`

---

### Key Design Decisions Before We Start

**Why two separate pods — not one?**
```
Frontend Pod (Java)  →  talks to  →  Database Pod (PostgreSQL)
```
- Scale them independently — 3 app pods, 1 DB pod
- Restart app without touching DB
- DB needs StatefulSet, app needs Deployment — can't mix in one pod

---

**Deployment vs StatefulSet — when to use which:**

| | Deployment | StatefulSet |
|--|--|--|
| Use for | Stateless apps (Java, Node, Python) | Stateful apps (PostgreSQL, MySQL, MongoDB, Kafka) |
| Pod names | Random (`fortune-cookies-abc123`) | Stable, ordered (`postgres-0`, `postgres-1`) |
| Pod IP | Changes on restart | Changes on restart — but DNS name stays stable |
| Storage | Shared or none | Each pod gets its **own PVC** (own disk) |
| Startup order | Random | Ordered — `postgres-0` starts first |
| Scale freely? | Yes | No — DB should always be `replicas: 1` |

> **Important:** StatefulSet gives stable **DNS names** (not IPs).  
> Pod IP still changes on restart, but `postgres-0.postgres-headless` DNS always resolves to `postgres-0`.  
> This is why apps connect via service DNS name, never by IP.

---

**Why database should always be `replicas: 1`:**

```
replicas: 2  →  postgres-0 (disk-0) + postgres-1 (disk-1)
                 ↑ two separate databases, data NOT in sync!
                 ↑ app hits postgres-0 sometimes, postgres-1 other times
                 ↑ data corruption / missing data!

replicas: 1  →  postgres-0 (disk-0) — single source of truth ✅
```

Multiple frontend pods all write to the **same single DB pod** — that is correct and safe:
```
Frontend Pod-1 ──┐
Frontend Pod-2 ──┼──→ postgres-0 (single DB pod) ──→ disk
Frontend Pod-3 ──┘
```

> For real HA PostgreSQL (primary + replica in sync), you need a PostgreSQL operator  
> like **Patroni** or **CloudNativePG** — not just setting `replicas: 2`.

---

**Why `ghcr.io` image for the Java app?**

`ghcr.io` = GitHub Container Registry (like Docker Hub but on GitHub).  
The Fortune Cookies app is pre-built and published there — ready to pull and run without building locally.  
Because it is stateless, you can set `replicas: 2, 5, 10` and scale instantly.

---

### 6a. Database (PostgreSQL as StatefulSet)

> **Concept:** **StatefulSet** is like a Deployment but for stateful apps (databases).  
> Pods get stable names (postgres-0, postgres-1) and persistent storage.
> It uses the same PVC idea you practiced in section 5b, but auto-creates claims via `volumeClaimTemplates`.

```yaml
# File: 07-postgres-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
  namespace: i310202
type: Opaque
stringData:
  POSTGRES_DB: fortunedb
  POSTGRES_USER: fortuneuser
  POSTGRES_PASSWORD: fortunepass123
```

```yaml
# File: 08-postgres-statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
  namespace: i310202
spec:
  serviceName: postgres-headless
  replicas: 1
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
        envFrom:
        - secretRef:
            name: postgres-secret
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: postgres-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-headless
  namespace: i310202
spec:
  clusterIP: None          # headless — no load balancing, direct pod DNS
  selector:
    app: postgres
  ports:
  - port: 5432
    targetPort: 5432
```

```bash
kubectl apply -f 07-postgres-secret.yaml
kubectl apply -f 08-postgres-statefulset.yaml

# Watch postgres-0 come up
kubectl get pods -l app=postgres -w

# See the PVC that was auto-created
kubectl get pvc

# Connect to postgres (verify it works)
kubectl exec -it postgres-0 -- psql -U fortuneuser -d fortunedb -c "\l"
```

### 6b. Fortune Cookies Frontend (Deployment + Service)

```yaml
# File: 09-fortune-app.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fortune-app-config
  namespace: i310202
data:
  SPRING_DATASOURCE_URL: "jdbc:postgresql://postgres-headless:5432/fortunedb"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fortune-cookies
  namespace: i310202
spec:
  replicas: 2
  selector:
    matchLabels:
      app: fortune-cookies
  template:
    metadata:
      labels:
        app: fortune-cookies
    spec:
      containers:
      - name: fortune-cookies
        image: ghcr.io/sap-samples/cloud-native-dev-journey/fortune-cookies:latest
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_DATASOURCE_URL
          valueFrom:
            configMapKeyRef:
              name: fortune-app-config
              key: SPRING_DATASOURCE_URL
        - name: SPRING_DATASOURCE_USERNAME
          valueFrom:
            secretKeyRef:
              name: postgres-secret
              key: POSTGRES_USER
        - name: SPRING_DATASOURCE_PASSWORD
          valueFrom:
              secretKeyRef:
                name: postgres-secret
                key: POSTGRES_PASSWORD
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 20
          periodSeconds: 10
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: fortune-cookies-svc
  namespace: i310202
spec:
  selector:
    app: fortune-cookies
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
```

```bash
kubectl apply -f 09-fortune-app.yaml

# Watch everything come up
kubectl get all -n i310202

# Test the app from inside the cluster
kubectl run curl-test --image=curlimages/curl -it --rm -- \
  curl http://fortune-cookies-svc/cookies

# Port-forward to your laptop
kubectl port-forward service/fortune-cookies-svc 8080:80
# Open http://localhost:8080 in browser
```

---

## 7. Ingress — External Access

> **Concept:** An **Ingress** is a reverse proxy rule that routes external HTTP/HTTPS  
> traffic into your cluster services. One Ingress controller handles many apps.  
> Think of it as an nginx config managed by Kubernetes.

```yaml
# File: 10-ingress.yaml
# Replace i310202 with your actual SAP user ID
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fortune-ingress
  namespace: i310202
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: i310202.ingress.blr29.k8s-train.shoot.canary.k8s-hana.ondemand.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: fortune-cookies-svc
            port:
              number: 80
```

```bash
kubectl apply -f 10-ingress.yaml

kubectl get ingress
kubectl describe ingress fortune-ingress

# Access the app via ingress URL (check ADDRESS column)
curl http://i310202.ingress.blr29.k8s-train.shoot.canary.k8s-hana.ondemand.com/cookies
```

---

## 8. Troubleshooting

> **Concept:** Things break in Kubernetes. Here's the standard debugging flow:  
> `get` → `describe` → `logs` → `exec` → `events`

```bash
# The golden debugging sequence
kubectl get pods                              # is the pod running?
kubectl describe pod <pod-name>              # why is it not running? (check Events)
kubectl logs <pod-name>                      # what did the app print?
kubectl logs <pod-name> --previous           # logs from the crashed container
kubectl exec -it <pod-name> -- sh           # get inside and poke around

# Cluster events (sorted newest first)
kubectl get events --sort-by=.metadata.creationTimestamp -n i310202

# Create a temp debug pod
kubectl run debug --image=busybox -it --rm -- sh

# Check resource usage
kubectl top pods -n i310202
kubectl top nodes

# Common issues to try:
# 1. ImagePullBackOff   → wrong image name or no pull secret
# 2. CrashLoopBackOff  → app is crashing, check logs --previous
# 3. Pending           → not enough resources or no PV available
# 4. OOMKilled         → increase memory limit in resources
```

---

## 9. Cleanup — Tear Everything Down

```bash
# Delete everything in your namespace (keeps the namespace)
kubectl delete all --all -n i310202
kubectl delete pvc --all -n i310202
kubectl delete configmap --all -n i310202
kubectl delete secret --all -n i310202
kubectl delete ingress --all -n i310202

# Or nuclear option — delete the whole namespace
kubectl delete namespace i310202

# Reset context to no default namespace
kubectl config set-context --current --namespace=default
```

---

## Quick Reference Card

| Concept | Kind | One-liner |
|---|---|---|
| Smallest unit | Pod | wraps 1+ containers |
| Self-healing | Deployment | manages ReplicaSet → Pods |
| Stateful apps | StatefulSet | stable name + storage |
| Stable networking | Service | ClusterIP / NodePort / LB |
| External access | Ingress | HTTP routing rules |
| Config injection | ConfigMap | non-sensitive key-value |
| Credentials | Secret | base64-encoded key-value |
| Storage request | PVC | binds to a PV |
| Isolation | Namespace | virtual cluster boundary |

---

## Learning Path (matches training modules)

- [x] `00` Namespace setup  
- [x] `01` kubectl basics — nodes, API  
- [x] `02` Pods — create, logs, exec, delete  
- [x] `03` Deployments — scale, update, rollback  
- [x] `04` Services — ClusterIP, endpoints  
- [x] `05` ConfigMaps & Secrets  
- [x] `05b` Persistence warm-up (PVC/PV)  
- [x] `06` Fortune Cookies app end-to-end  
- [x] `07` Ingress  
- [x] `08` Troubleshooting  
- [ ] `10` RBAC (covered in training Day 2)  
- [ ] `11` Network Policies (covered in sample-app exercise 04)  
- [ ] `12` Helm (covered in kubernetes/exercise_10_helm_basics.md)  
