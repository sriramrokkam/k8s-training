# Exercise 6 - ConfigMaps and Secrets

In this exercise, you will be dealing with _Pods_, _Deployments_, _Services_, _Labels & Selectors_, **_ConfigMaps_** and **_Secrets_**.

ConfigMaps and secrets bridge the gap between the requirements to build generic images but run them with a specific configuration in a secured environment.
In this exercise you will move credentials and configuration into the Kubernetes cluster and make them available to your pods.

This exercise does not build on any previous exercise - you will create all the necessary resources during the course of this exercise.

## Step 0: Create an `htpasswd` file

In this exercise you will spin up another webserver but this time, it won't be open to everyone. Instead, it will use [HTTP basic auth](https://en.wikipedia.org/wiki/Basic_access_authentication) to hide (almost) everything bedind a login.

Create an empty file which you call `htpasswd` (with no extension) and paste the following content into it:

```htpasswd
training:$apr1$HR4pfg44$jsreGaf2LA2h/LEhw4eVa.
```

With this line, you will add a user `training` with the _super-secret_ password `kubernetes` to the nginx configuration.

## Step 1: Store the `htpasswd` file in Kubernetes

In order to use the password file with your nginx webserver, you will need to add it to Kubernetes and store it in a `secret` resource of type `generic` (or opaque) in your namespace.

`kubectl create secret generic nginx-basic-auth --from-file=htpasswd`

Check, if the secret is present by running `kubectl get secret nginx-basic-auth`.

Run `kubectl describe secret nginx-basic-auth` to get more detailed information. The result should look like this:

```bash-output
Name:         nginx-basic-auth
...

Type:  Opaque

Data
====
htpasswd:  47 bytes
```

## Step 2: Create an _nginx_ configuration

Once the basic auth secret is prepared, you will have to create an _nginx_ configuration and store it to Kubernetes as well. It will tell nginx to puth an HTTP basic auth in front of the webpage it serves.

Create a file `default.conf` with the following content (or take it from the [solutions](./solutions/06_default.conf)):

```nginx
server {
        listen 80 default_server;
        listen [::]:80 default_server ipv6only=on;

        root /usr/share/nginx/html;
        index index.html;
        server_name localhost;

        location / {
                try_files $uri $uri/ =404;
                auth_basic "Restricted Area";
                auth_basic_user_file auth.d/htpasswd;
        }

        location /healthz {
          access_log off;
          return 200 'OK';
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
}
```

Make sure that the value for `auth_basic_user_file` is `auth.d/htpasswd` - it is the name of the file you created in step 1, prefixed with a directory name `auth.d`. This line tells nginx to load the credentials for HTTP basic auth from the file `htpasswd` which is located in the directory `auth.d`.

With this configuration, _nginx_ will expect the following directory structure:

```plain
|- conf.d
|  \- default.conf
\- auth.d
   \- htpasswd
```

Once the deployment for nginx gets crafted in step 4, the `volumeMount` directive will be used to set up this directory structure.

Also note, that there is a location for a healthcheck which is explicitly defined and which must not require any kind of authentication. The endpoint `/healthz` will just return a `200` status code to satisfy a liveness probe.

## Step 3: Upload the configuration to Kubernetes

Run `kubectl create configmap nginxconf --from-file=<path/to/your/>default.conf` to create a configMap resource with the corresponding content from default.conf.

Verify the configmap exists with `kubectl get configmap`.

## Step 4: Combine everything into a deployment

Now it is time to combine the secret and the configMap with a new deployment. As a result, nginx should display its default `index.html` page but will require you to log in first. It will still serve standard, unencrypted HTTP so this is certainly not how you would set up a production environment but for this training, it will suffice.

For the new setup to work, use `app: auth-nginx` as label/selector combination.

The following snippet contains some blanks to be filled in: we provide you with the basic structure of a deployment but the relevant parts which mount the configMap and secret into the Pods needs to be filled in by yourself (i.e. everywhere you see a `???`).

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-auth-deployment
  labels:
    tier: application
spec:
  replicas: 1
  selector:
    matchLabels:
      app: auth-nginx
  template:
    metadata:
      labels:
        app: auth-nginx
    spec:
      volumes:
      - name: htpasswd-secret
        secret:
          secretName: nginx-basic-auth
      - name: nginxconf
        configMap:
          name: nginxconf
      containers:
      - name: nginx
        image: nginx:mainline
        ports:
        - containerPort: 80
          name: http
        livenessProbe:
          httpGet:
            path: /healthz
            port: http
          initialDelaySeconds: 3
          periodSeconds: 5
        volumeMounts:
        - mountPath: /etc/nginx/auth.d
          name: ??? # fill in which volume needs to be used
          readOnly: true
        - mountPath: /etc/nginx/conf.d
          name: ??? # fill in which volume needs to be used
```

Use `kubectl apply` to create the new `nginx-auth-deployment`. Verify that the newly created Pods use the configMap and secret by running `kubectl describe pod <pod-name>`.

## Step 5: create a Service

Finally, you have to create a new Service to expose your `nginx-auth-deployment`.

Create a simple `service.yaml` - you can use the following YAML snippet to get you started. Since your nginx is still plain HTTP, you need to expose port `80`.

 to create the Service, but you need to fill in the `ports` section yourself. Remember that this is a list...

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-basic-auth
spec:
  selector:
    ???: ??? # fill in on which Pod label to select
  type: LoadBalancer
  ports:
  - name: http
    port: ??? # fill in on which port the LoadBalancer should listen
    protocol: TCP
    targetPort: ??? # fill in which port on the Pod to target
```

Once the Service has an external IP, try to call it. You will probably probably get asked by your browser for a username and a password. Do you still remember them? After all, you created them yourself in step 0...

## Troubleshooting

The deployment should have two volumes specified as part of `deployment.spec.template.spec.volumes` (a configMap & a secret). Each item of the volumes list defines a (local/pod-internal) name and references the actual K8s object. Also these two volumes should be used and mounted to a specific location within the container (defined in `deployment.spec.template.spec.containers.volumeMount`). The local/pod-internal name is used for the `name` field.

When creating the Service double check the used selector. It should match the labels given to any Pod created by the new deployment. The value can be found at `deployment.spec.template.metadata.labels`. In case your Service is not routing traffic properly, run `kubectl describe service <service-name>` and check, if the list of `Endpoints` contains at least 1 IP address. The number of addresses should match the replica count of the deployment it is supposed to route traffic to.

Also check, if the IP addresses point to the Pods created during this exercise. In case of doubt check the correctness of the label - selector combination by running the query manually. Firstly, get the selector from the Service by running `kubectl get service <service-name> -o yaml`. Use the `<key>: <value>` pairs stored in `service.spec.selector` to get all Pods with the corresponding label set: `kubectl get pods -l <key>=<value>`. These Pods are what the Service is selecting / looking for. Quite often the selector used within Service is the same selector that is used within the deployment.

Finally, there might be some caching on various levels of the used infrastructure. To break caching on corporate proxy level and display the custom page, request index.html directly: `http:<LoadBalancer IP>/index.html`.

## Further information & references

- [secrets in k8s](https://kubernetes.io/docs/concepts/configuration/secret/)
- [options to use a configMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
