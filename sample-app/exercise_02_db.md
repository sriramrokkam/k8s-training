# Exercise 2 - Setting up a database

## Scope

- In this second exercise we will focus on the **setup of a database**, where some quotes can be stored.
- To get a disk easily and be able to scale up later, we will use a `StatefulSet` with only one instance (replica count=1).
- We will use Postgresql with the official [PostgreSQL Docker image](https://hub.docker.com/_/postgres/).
- The PostgreSQL Docker image gives us the possibility to override several default values via **environment variables** for e.g. the location for the database files (`PGDATA`) and the superuser password (`POSTGRES_PASSWORD`).
- In order to make the database `Pod` available we have to set up a **"Headless" Service** to allow the app to talk to the database instance reliably.

## Labels

We make use of labels on **all** entities, so they can be easier selected/searched for with kubectl. 

The structure for **Labels** (and hence for **Selectors** as well) is rather simple:
- all entities share a common **Label** `component` with value `fortune-cookies`.
- On a second level we separate database and application. Here we introduce the **Label** `module` with value `app` or `db`. 

This hierarchy allows us to retrieve various combinations of entities. E.g. select things belonging to the databases via a `kubectl get deploy,sts,pods,cm,secrets,svc -l module=db`, or to the component in general with `kubectl get deploy,sts,pods,cm,secrets,svc -l component=fortune-cookies`.

## Step 0: Preparation

**Please, before you start with these exercises, clean up your namespace from what you did the previous days by deleting all deployments, StatefulSets, PVCs, Services etc.** This helps you by easier finding the entities in your namespace and us by reducing the load on the cluster!

Create a folder `fortune-cookies` in a suitable location to store all the various yaml-files that you will create during the exercises.

## Step 1: Secret for Postgres Superuser Password

Purpose: Create a **Secret** with password for Postgres superuser
 
You can take any string as a password. If you want a random string you could do e.g. `openssl rand -base64 15`, which will already give you a random password (the `-base64` option is used to only have alphanumerics (almost) in the password).

To create the yaml-file for the secret with the password use `kubectl create secret generic db-credentials --from-literal=<key>=<password> --dry-run=client -o yaml > db-secret.yaml`. Next, open the file and add proper labels.

Before actually creating the secret, there is one more thing to do: make the secret immutable. [Check out the documentation](https://kubernetes.io/docs/concepts/configuration/secret/#secret-immutable) how to do it and to learn about the benefits.

- Now apply it to the cluster `kubectl apply -f db-secret.yaml`

## Step 2: StatefulSet & "Headless" Service

Purpose: Create the **StatefulSet**, which uses the Secret, together with a **"headless" Service**, required to access the pod, created by the StatefulSet.

We will describe both resources in the same file called `db-statefulset.yaml`.

- Start with a **"headless" Service** named `db` with proper labels and listening on port `5432`.

We make use of the feature to describe multiple K8s entities in just one YAML file, therefore, we start our `db-statefulset.yaml` with the Service description:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: <name-of-headless-service>
  labels:
    component: <name-of-component>
    module: <name-of-module>
spec:
```

The Service should target the Pods of the StatefulSet but we do not know which labels to use for the selector yet. Therefore we defer our work on the Service for a bit head on to the StatefulSet first.

_Hint: In the following sections we will provide you yaml-snippets of the StatefulSet specification. Just substitute the placeholders `<...>` by proper values !_

- Specify a **StatefulSet** for the Postgres database with name `postgres` with proper labels and selector for [component and module](exercise_02_db.md#labels). 

Once again, this goes into the same `db-statefulset.yaml` just right after the Service - a `---` separator will make sure that Kubernetes will find two different entities in this file.

```yaml
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: <name-of-StatefulSet>
  labels:
    component: <name-of-component>
    module: <name-of-module>
```

- Refer to the "Headless" Service by name and make sure that only one DB pod gets created. 

```yaml
spec:
  serviceName: <name-of-headless-service>
  replicas: <#-of-DB-pods>
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
      containers:
      - name: db-container
        image: postgres:13-alpine
        ports:
        - containerPort: 5432
          name: db-port
        volumeMounts:
        - name: db-volume
          mountPath: /var/lib/postgresql/data/
        env:
        - name: PGDATA
          value: "/var/lib/postgresql/data/pgdata"
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              key: <key-in-the-secret>
              name: db-credentials
```

- For the creation of the PVC we are using the volumeClaimTemplates mechanism. Here just make sure you are using proper labels for [component and module](exercise_02_db.md#labels). 

```yaml
  volumeClaimTemplates:
  - metadata:
      name: db-volume
      labels:
        component: <name-of-component>
        module: <name-of-module>
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```

- Now continue with the Service by using a selector for the `component` and `module`-labels of the pods of the StatefulSet. Use a named port (name it `db-port`) to reference the port of the pod. It should be the port given by the Docker image (port `5432` as depicted by the description on [Docker Hub](https://hub.docker.com/_/postgres/)).

> [Hint](https://github.tools.sap/kubernetes/docker-k8s-training/blob/master/kubernetes/exercise_08_statefulset.md#step-0-create-a-headless-service)

- Now save your changes and call `kubectl apply -f db-statefulset.yaml` to create the **StatefulSet** and the **"headless" Service**.

- After successful creation of the **StatefulSet** check, whether the **Pod** `postgres-0` got created properly via `kubectl get pod postgres-0` or in more detail via `kubectl describe pod postgres-0`. Also check whether the database is ready to be connected via `kubectl logs postgres-0`. There should be the line: `LOG:  database system is ready to accept connections` in the logs. 

- In case you are getting stuck, revert to the well-known debugging patterns with `kubectl describe` to get events & resource information or `kubectl logs` to spot application errors. Only the last resort would be the `kubectl diff` [command](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#diff) to detect differences between a solution file and the deployed version.

## Optional - Step 3: Detailed Check whether Pod with Postgres DB is running properly

Purpose: check whether the database is running and accepting connections. Use either a temporary postgresql pod with sql or the [**pgadmin tool**](https://www.pgadmin.org/) for that.

Here are two different ways how you could test if the StatefulSet is configured correctly and the db initialized with the right user and password:

### Using a temporary postgres pod and psql

Create a temporary pod with psql installed (e.g. a `postgres:13-alpine` image like our DB) and use psql from this pod to connect to the DB.

```bash
kubectl run tester -it --restart=Never --rm --image=postgres:13-alpine --env="PGCONNECT_TIMEOUT=5" --command -- ash
```

A prompt with root@... should come up. You are now connected to the pod, here we can use psql to try to connect to our postgres Pod:
`psql -h postgres-0.db -p 5432 -U postgres -W postgres`. You should be prompted for the password of the database, which was specified in the secret. After this you should connect to the postgres db, a prompt `postgres=>` will ask you for the next command. If this does, all is correctly set up!  
Type `\q` to quit psql since we only wanted to test that we can connect. Also exit the pod with the `exit` command. The pod should be removed after this automatically.
