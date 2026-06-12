# Post Lunch Quiz

<!-- CLAUDE INSTRUCTIONS
You are a quiz host. Read this file, then quiz the user interactively.

File format:
- Each question is a numbered item with multiple-choice options as bullet points.
- The correct answer(s) are marked [X]; wrong answers are [ ].
- Each question has a blockquote (>) with an explanation — reveal this only after the user answers.

How to run the quiz:
1. Ask the user how many questions they want and whether they want them in order or randomized.
2. Present one question at a time. Show only the question text and the answer options — strip the [X]/[ ] markers so the user cannot see the correct answer.
3. Wait for the user to answer (they can type the option text, a number, or a letter).
4. Reveal whether they were right or wrong, then show the explanation from the blockquote.
5. Keep a running score and show it after each answer (e.g. "3 / 5 correct so far").
6. At the end, print a summary with the final score and list any questions the user got wrong with the correct answer.

Rules:
- Never reveal [X] markers before the user answers.
- For questions with multiple correct answers, tell the user upfront that multiple answers may apply.
- Be encouraging but honest.
-->

## Questions

1. When was Docker founded?
   - [ ] 2011
   - [X] 2013
   - [ ] 2015

   > Docker Inc. was founded in 2013 by Solomon Hykes. It grew out of the dotCloud PaaS project and was first released as open source in March 2013.

2. Which is the oldest feature in the Linux kernel?
   - [ ] namespaces
   - [ ] cgroups
   - [X] chroot

   > `chroot` has been around since Unix Version 7 (1979) and was added to Linux from the start. Namespaces were introduced in Linux 3.8 (2013) and cgroups in Linux 2.6.24 (2008).

3. Which docker command will not work?
   - [ ] `run -d nginx`
   - [ ] `run -it ubuntu`
   - [X] `run -itd nginx`

   > `-it` allocates an interactive TTY and keeps stdin open, which requires a foreground process to attach to. `-d` (detached) starts the process in the background (which ususally doesn't work well with a shell). `-itd` won't work as you can either run something interactively or detacheched.

4. Can you install Ubuntu in a container?
   - [ ] yes
   - [ ] no
   - [X] it depends

   > A container shares the host kernel, so you cannot change the kernel. You *can* run Ubuntu userland (apt, bash, glibc, etc.) in a container on any Linux host but if your host kernel is too old for what Ubuntu expects, things will break. So the answer depends on the host kernel version.

5. What happens when Docker removes a container?
   - [ ] The upstream image reference is removed
   - [X] Container metadata and rw layer are deleted
   - [ ] The rw layer gets reset

   > Each container has a thin read-write layer on top of the image layers. When a container is removed (`docker rm`), that rw layer and the container's metadata are permanently deleted. The underlying image is untouched.

6. The Kube API Server...
   - [ ] Does not support Watches
   - [ ] Performs an observe-analyze-act loop
   - [X] Serializes data into ETCD

   > The API server is the only component that talks to etcd. It serializes resource objects and stores them there. It does support Watches (used by controllers and kubelets). The observe-analyze-act loop describes controllers, not the API server.

7. With kubectl you query the
   - [X] kube-apiserver
   - [ ] etcd
   - [ ] kubelet

   > kubectl is a REST client that talks exclusively to the Kubernetes API server. It never contacts etcd directly (only the API server does) or the kubelet (that is done through the API server for e.g. `exec` and `logs`).

8. Which kubectl command should work?
   - [ ] `kubectl nodes get`
   - [ ] `kubectl get -nodes`
   - [X] `kubectl get nodes`

   > Wait - trick question! None of the first two work, and `kubectl get nodes` is the correct syntax. The verb comes before the resource.

9. What's the difference between `kubectl get` and `kubectl describe`?
   - [X] Describe shows events
   - [ ] Describe shows help text
   - [ ] Describe prints json formatted text

   > `kubectl describe` aggregates the resource's fields *and* fetches related Events from the API, making it the first tool to reach for when debugging. `kubectl get` returns raw resource data (defaulting to a summary table); you can get JSON/YAML with `-o json`/`-o yaml`, but that is not specific to `describe`.

10. What is not in a kubeconfig file?
    - [ ] kube API server address
    - [X] default flags for kubectl commands
    - [ ] call to a plugin for external authentication

    > A kubeconfig contains clusters (API server addresses + CA), users (credentials or exec plugins for external auth), and contexts (cluster+user+namespace combos). Default command flags are not stored there. Those live in shell aliases or kuberc files.

11. The OwnerReference indicates which resource governs another resource. Which reference chain looks correct to you?
    - [ ] Deployment -> Pod
    - [X] Deployment -> ReplicaSet -> Pod
    - [ ] ReplicaSet -> Deployment

    > A Deployment creates and owns ReplicaSets (one per revision). Each ReplicaSet creates and owns Pods. So the owner chain is Deployment -> ReplicaSet -> Pod. The reference always points from the owned resource up to its owner, not the other way around.

12. How does a Deployment record revisions?
    - [ ] by creating a controllerRevision
    - [ ] as an annotation in the metadata section
    - [X] 1 revision = 1 ReplicaSet

    > Each time a Deployment's pod template changes, it creates a new ReplicaSet rather than modifying the existing one. Old ReplicaSets are kept (scaled to 0) to enable rollback. The revision number is tracked via the `deployment.kubernetes.io/revision` annotation on the ReplicaSet. `ControllerRevisions` are used by other workload controllers such as `StatefuleSet` or `Daemonset`.

13. A PersistentVolumeClaim is in status Pending - how can I find out why?
    - [X] `kubectl describe pvc`
    - [ ] `kubectl get pvc`
    - [ ] `kubectl logs <my-pod>`

    > `kubectl describe pvc` shows the Events section, which typically contains the reason a PVC is stuck - e.g. no matching PV, StorageClass not found, or the CSI driver reporting an error. `kubectl get pvc` only shows the status column, and pods don't log PVC binding activity.

14. When setting a finalizer on a resource it...
    - [X] blocks deletion until removed
    - [ ] is a hint to a human operator to clean up manually
    - [ ] indicates a resource should be deleted now

    > A finalizer is a key in `metadata.finalizers`. When you delete a resource that has finalizers, Kubernetes sets `deletionTimestamp` but does not remove the object. The responsible controller must complete its cleanup and then remove the finalizer, after which Kubernetes garbage-collects the object.

15. Which controller actually creates a physical volume backing a PV?
    - [ ] kube-controller-manager
    - [ ] Storage Class
    - [X] CSI Driver

    > The CSI (Container Storage Interface) driver is responsible for provisioning the actual storage backend (e.g. creating an EBS volume, an NFS share, etc.). The kube-controller-manager handles PV/PVC binding and lifecycle, and a StorageClass is just configuration - neither directly provisions storage.

16. Which of the following Secret types does not exist?
    - [ ] generic
    - [X] credentials
    - [ ] opaque
    - [ ] tls

    > Kubernetes has built-in Secret types: `Opaque` (generic), `kubernetes.io/tls`, `kubernetes.io/dockerconfigjson`, `kubernetes.io/service-account-token`, and a few others. There is no `credentials` type - that is not a valid Kubernetes Secret type.

17. Secret data is limited to 500 characters
    - [X] no
    - [ ] yes

    > Secret data is limited to 1 MiB per object (the etcd value size limit). The 500-character figure is simply wrong. Individual values can be much larger as long as the total object stays under 1 MiB.

18. How can an app access configmaps or secrets?
    - [X] environment variables
    - [X] mounted files
    - [ ] nfs

    > Kubernetes supports two native ways to expose ConfigMap and Secret data to a pod: as environment variables (via `envFrom` or `env[].valueFrom`) or as files in a mounted volume (`volumeMounts` with a `configMap`/`secret` volume). NFS is a storage protocol unrelated to this mechanism.

19. My app returns http 500 - what to do?
    - [ ] Panic
    - [X] `kubectl exec`
    - [X] `kubectl logs`

    > `kubectl logs <pod>` is the first step - check what the app itself is reporting. If you need to inspect the running process, filesystem, or environment interactively, `kubectl exec -it <pod> -- sh` lets you get a shell inside the container.

20. A Kubernetes Service of type ClusterIP
    - [X] gets a cluster internal DNS record
    - [ ] is reachable from outside of the cluster
    - [ ] can have only one port

    > kube-dns / CoreDNS automatically creates an A record for every Service in the form `<service>.<namespace>.svc.cluster.local`. ClusterIP services are only reachable within the cluster. A Service can expose multiple ports by listing them in the `ports` array.

21. An Ingress
    - [X] Is reconciled by a dedicated ingress controller
    - [ ] consumes one external IP per Ingress resource
    - [X] contains routing information about exposure and backends

    > An Ingress resource is just configuration - it defines hostnames, paths, and backend services. An Ingress controller (e.g. nginx-ingress, Traefik) watches Ingress objects and programs the actual load balancer. Many Ingress resources can share a single external IP via the same controller.

22. Which authentication method is NOT working with the Kubernetes API Server?
    - [ ] oidc
    - [ ] jwt
    - [X] basic auth

    > Basic authentication (username/password in a static file) was deprecated in Kubernetes 1.16 and removed in 1.19. OIDC and JWT (service account tokens are JWTs) are fully supported authentication strategies.

23. A ClusterRole referenced in a RoleBinding
    - [ ] grants the outlined permissions system-wide
    - [X] grants the outlined permission within a namespace
    - [ ] is not supported, use ClusterRoleBinding instead

    > A RoleBinding always scopes permissions to the namespace it lives in - regardless of whether it references a Role or a ClusterRole. Using a ClusterRole in a RoleBinding is a valid and common pattern to reuse permission definitions without granting cluster-wide access. A ClusterRoleBinding would be needed for system-wide permissions.

24. The Pod Security Standard
    - [X] Is configured on Namespace-level
    - [ ] Is customizable
    - [ ] Is configured per Pod

    > Pod Security Standards (PSS) (`privileged`, `baseline`, `restricted`) are enforced via labels on the Namespace (`pod-security.kubernetes.io/enforce`). They are predefined profiles and are not customizable (that was the old PodSecurityPolicy). Individual pods cannot opt in or out.

25. Network policies can be used to
    - [ ] control bandwidth usage by pods
    - [ ] replace infrastructure security rules
    - [X] segregate the cluster's flat network

    > By default, all pods in a cluster can reach each other across namespaces. NetworkPolicy resources let you restrict ingress and egress traffic between pods/namespaces, effectively segmenting the otherwise flat pod network. They do not control bandwidth and should complement, not replace, infrastructure-level security.

26. The security context
    - [ ] is a ruleset for allowed security settings
    - [X] can specify a user/group ID to start container processes with
    - [ ] specifies if service account token should be mounted

    > A `securityContext` (at pod or container level) lets you set runtime security attributes: `runAsUser`, `runAsGroup`, `fsGroup`, `readOnlyRootFilesystem`, capabilities, seccomp profiles, etc. Whether a service account token is mounted is controlled by `automountServiceAccountToken`, which is a separate field on the Pod/ServiceAccount spec.

27. Which resource has a `.spec`?
    - [ ] Role
    - [ ] ServiceAccount
    - [ ] Secret
    - [X] StatefulSet

    > `spec` is the desired-state field used by workload and infrastructure resources that have a controller reconciling them. `StatefulSet` (and Deployments, Services, PVCs, etc.) all have a `.spec`. `Role` uses `.rules`, `Secret` uses `.data`/`.stringData`, and `ServiceAccount` has no spec - it mainly holds `imagePullSecrets` and `secrets` at the top level.
