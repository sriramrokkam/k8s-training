# Exercise 3 - Setting up the Fortune Cookies App

## Scope

In this exercise we will focus on the **setup of fortune cookie frontend** itself (`module: app`):

- Of course, we need to write a Deployment for this.
- Additionally, we want to connect it with the database set up in the previous exercise.
- And finally, make it available within a K8s cluster via a **Service** and publish externally via an **Ingress**.

- For the configuration part we need some environment variables set: 
  - `SPRING_DATASOURCE_URL` containing the URI to the database along with
  - `SPRING_DATASOURCE_PASSWORD` containing the password for the database.

- The structure for **Labels** (and with this for **Selectors**) has 2 levels as in exercise 2: To separate the frontend/application resources from the database we use a **Label** with the key `module` with value `app` or `db`.

## Step 1: ConfigMap

Purpose: Create a **ConfigMap** containing the value for the environment variable `SPRING_DATASOURCE_URL`.

- Specify a **ConfigMap** with name `app-configmap`, with one key-value pair and with proper labels for component and module.
- The datasource url given through the headless-service is `jdbc:postgresql://<name-of-headless-service>:5432/postgres`.
- Remember the keys you use for these values. You need them in yaml-file for the **Deployment** in the next step.
- Save your **ConfigMap** under the filename `app-configmap.yaml`.
- Now apply the configmap to the cluster `kubectl apply -f app-configmap.yaml`

> [Hint](/kubernetes/exercise_06_configmaps_secrets.md)

## Step 2: Deployment

Purpose: Create the **Deployment**, which is dependent on the **Configmap** created in step 1 and the **Secret** containing the database password from the previous exercise.
Also, the **Secret** `training-registry` is needed to pull the image.

_Hint: In the following sections we will provide several yaml-snippets of the deployment specification. Just substitute the placeholders `<...>` by proper values !_

- Specify a **Deployment** with 2 instances, with name `fortune-cookies` and with proper labels and selector for component and module. 

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fortune-cookies
  labels:
    component: <name-of-component>
    module: <name-of-module>
spec:
  replicas: <#-of-instances>
  selector:
    matchLabels:
      component: <name-of-component>
      module: <name-of-module>
  template:
    metadata:
      labels:
        component: <name-of-component>
        module: <name-of-module>
    spec:
      imagePullSecrets:
      - name: <name-of-secret>
      containers:
      - name: app
        image: <image pushed to training registry>
        ports:
        - containerPort: 8080
          name: app-port
        env:
        - name: "???"
          valueFrom:
            <reference to configmap/secret>
        - name: "???"
          valueFrom:
            <reference to configmap/secret>
        - name: SPRING_DATASOURCE_USERNAME
          value: postgres
        resources:
          limits:
            memory: 1Gi
          requests:
            memory: 800Mi
```

- The missing environment variables in the snippet are `SPRING_DATASOURCE_URL` and `SPRING_DATASOURCE_PASSWORD`.

- We also add a specific resource request for this app. The default memory-limit in each namespace is 500Mi which is not enough for a spring boot application. We request 800Mi and allow an increase to 1G of Memory to be consumed by each pod. 

- When you are ready with the specification of the **Deployment** save it under the filename `fortune-cookies.yaml` and call `kubectl apply -f fortune-cookies.yaml` to create the **Deployment** `fortune-cookies`.

- After successful creation of the **Deployment** check, if the Pod starts properly and runs without issues. You can use `kubectl get | describe | logs` commands.

## Step 3: Service & Ingress

Purpose: Make **fortune cookies** available within your K8s Cluster via **Service** and "publish" externally into via an **Ingress**.

_Hint: In the following sections we will provide you yaml-snippets of the Service specification. Just substitute the placeholders `<...>` by proper values !_

### Service

- Specify a **Service** with name `fortune-cookies` using the named targetPort of the Deployment (`app-port`) and proper labels + selector for component and module. 
- The service should accept traffic on port `80` and forward incoming requests to port `8080` of the target pods.

```yaml
---
apiVersion: v1
kind: Service
metadata:
  name: fortune-cookies
  labels:
    component: <name-of-component>
    module: <name-of-module>
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: app-port
    name: http
  selector:
    component: <name-of-component>
    module: <name-of-module>
  type: ClusterIP
```

- When you are ready with the specification of the **Service** save it under the filename `fortune-cookies-service.yaml` and call `kubectl apply -f fortune-cookies-service.yaml` to create the **Service**.

### Ingress

- Additional specify an **Ingress** with the name `fortune-cookies` and proper labels for component and module. 

- As the host URL has to be unique across the whole K8s Cluster, add `-<number-of-your-namespace>` as suffix to the hostname 'fortune-cookies', so if your namespace were *part-0040* the host URL would look like: `fortune-cookies-0040.ingress.<clustername>.k8s-train.shoot.canary.k8s-hana.ondemand.com`.

- Refer to the above created **Service** `fortune-cookies` in field `service.name` and `port.name` (Section '- backend').

```yaml
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fortune-cookies
  labels:
    component: <name-of-component>
    module: <name-of-module>
spec:
  rules:
  - host: fortune-cookies-<your-namespace-number>.ingress.<your-trainings-cluster>.k8s-train.shoot.canary.k8s-hana.ondemand.com
    http:
      paths: 
      - path: /
        pathType: Prefix
        backend:
          service:
            name: <name-of-fortune-cookies-service>
            port:
              name: <name-of-fortune-cookies-port>
```

- When you are ready with the specification of the **Ingress** save it under the filename `fortune-cookies-ingress.yaml` and call `kubectl apply -f fortune-cookies-ingress.yaml` to create the **Ingress**.

- Check the **Ingress** and make sure it is properly created via `kubectl describe ingress fortune-cookies`.

- Additional check whether you can call application via the **Ingress** URL with a browser.
