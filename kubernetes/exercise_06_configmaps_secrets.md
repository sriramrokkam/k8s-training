# Exercise 6 - ConfigMaps and Secrets

In this exercise, you will be dealing with _Pods_, _Deployments_, _Services_, _Labels & Selectors_, **_ConfigMaps_** and **_Secrets_**.

ConfigMaps and secrets bridge the gap between the requirements to build generic images but run them with a specific configuration in a secured environment.
In this exercise you will move credentials and configuration into the Kubernetes cluster and make them available to your pods.

This exercise does not build on any previous exercise - you will create all necessary resources during the course of this exercise.

## Step 0: Create a certificate

In the first exercises you ran a webserver with plain HTTP. Now you are going to recreate this whole setup from scratch and add HTTPS to your nginx.

Start by creating a new self-signed certificate (MacOS and Linux):

`openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/nginx.key -out /tmp/nginx.crt -subj "/CN=nginxsvc/O=nginxsvc"`


## Step 1: Store the certificate in Kubernetes

In order to use the certificate with our nginx, you need to add it to kubernetes and store it in a `secret` resource of type `tls` in your namespace. 
**Note:** Kubernetes changes the names of the certificate files to a standardized string (`tls.key` and `tls.crt`) when the secret is created. For example, `nginx.crt` will become `tls.crt`.

`kubectl create secret tls nginx-sec --cert=/tmp/nginx.crt --key=/tmp/nginx.key`

Check, if the secret is present by running `kubectl get secret nginx-sec`.

Run `kubectl describe secret nginx-sec` to get more detailed information. The result should look like this:

```bash-output
Name:         nginx-sec
...

Type:  kubernetes.io/tls

Data
====
tls.crt:  1143 bytes
tls.key:  1708 bytes
```

**Important: remember the file names in the data section of the output. They are relevant for the next step.**

## Step 2: Create a nginx configuration

Once the certificate secret is prepared, create a configuration and store it to Kubernetes as well. It will enable nginx to serve HTTPS traffic on port 443 using a certificate located at `/etc/nginx/ssl/`.

Download from the [GitHub Training Repo](./solutions/06_default.conf) or create a file `default.conf` with the following content. In any case, ensure the file's name is `default.conf`.

```nginx
server {
        listen 80 default_server;
        listen [::]:80 default_server ipv6only=on;

        listen 443 ssl;

        root /usr/share/nginx/html;
        index index.html;

        server_name localhost;
        ssl_certificate /etc/nginx/ssl/tls.crt;
        ssl_certificate_key /etc/nginx/ssl/tls.key;

        location / {
                try_files $uri $uri/ =404;
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

Make sure, the values for `ssl_certificate` and `ssl_certificate_key` match the names of the files within the secret - their filenames must be `tls.crt` and `tls.key`. Their actual location in the container's filesystem will be set via the `volumeMount` property when you later mount the TLS secret into your deployment.
Also note, that there is a location explicitly defined for a healthcheck. If called, `/healthz` will return a status code `200` to satisfy a liveness probe.

## Step 3: Upload the configuration to kubernetes

Run `kubectl create configmap nginxconf --from-file=<path/to/your/>default.conf` to create a configMap resource with the corresponding content from default.conf.

Verify the configmap exists with `kubectl get configmap`.

## Step 4: Combine everything into a deployment

Now it is time to combine the persistentVolumeClaim, secret and configMap in a new deployment. As a result nginx should display the custom index.html page, serve HTTP traffic on port 80 and HTTPS on port 443. In order for the new setup to work, use `app: nginx-https` as label/selector for the "secured" nginx.

Complete the snippet below by inserting the missing parts (look for `???` blocks):

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-https-deployment
  labels:
    tier: application
spec:
  replicas: 1
  selector:
    matchLabels:
      ???: ???
  template:
    metadata:
      labels:
        app: nginx-https
    spec:
      volumes:
      - name: tls-secret
        secret:
          secretName: nginx-sec
      - name: nginxconf
        configMap:
          name: nginxconf
      containers:
      - name: nginx
        image: nginx:mainline
        ports:
        - containerPort: 80
          name: http
        - containerPort: 443
          name: https
        livenessProbe:
          httpGet:
            path: ???
            port: http
          initialDelaySeconds: 3
          periodSeconds: 5
        volumeMounts:
        - mountPath: /etc/nginx/ssl
          name: ???
          readOnly: true
        - mountPath: /etc/nginx/conf.d
          name: ???
```

Verify that the newly created Pods use the configMap and secret by running `kubectl describe pod <pod-name>`.

## Step 5: create a Service

Finally, you have to create a new Service to expose your https-deployment.

Derive the ports you have to expose and create a `service.yaml`. You need to expose ports `80` and `443`.  You can use the following YAML snippet to create the Service, but you need to fill in the `ports` section yourself. Remember that this is a list...

```
apiVersion: v1
kind: Service
metadata:
  name: nginx-https-service
spec:
  selector:
    ???: ???
  type: LoadBalancer
  ports:
  - name: http
    port: ???
    protocol: TCP
    targetPort: ???
  - ...
```

Once the Service has an external IP, try to call it with an HTTPS prefix. You will probably receive an error from your browser that the connection is not secure - this is ok because we used a self-signed certificate. Just ignore that error and continue to the website.


## Troubleshooting

The deployment should have two volumes specified as part of `deployment.spec.template.spec.volumes` (a configMap & a secret). Each item of the volumes list defines a (local/pod-internal) name and references the actual K8s object. Also these two volumes should be used and mounted to a specific location within the container (defined in `deployment.spec.template.spec.containers.volumeMount`). The local/pod-internal name is used for the `name` field.

When creating the Service double check the used selector. It should match the labels given to any Pod created by the new deployment. The value can be found at `deployment.spec.template.metadata.labels`. In case your Service is not routing traffic properly, run `kubectl describe service <service-name>` and check, if the list of `Endpoints` contains at least 1 IP address. The number of addresses should match the replica count of the deployment it is supposed to route traffic to. 

Also check, if the IP addresses point to the Pods created during this exercise. In case of doubt check the correctness of the label - selector combination by running the query manually. Firstly, get the selector from the Service by running `kubectl get service <service-name> -o yaml`. Use the `<key>: <value>` pairs stored in `service.spec.selector` to get all Pods with the corresponding label set: `kubectl get pods -l <key>=<value>`. These Pods are what the Service is selecting / looking for. Quite often the selector used within Service is the same selector that is used within the deployment.

Finally, there might be some caching on various levels of the used infrastructure. To break caching on corporate proxy level and display the custom page, request index.html directly: `http:<LoadBalancer IP>/index.html`.

## Further information & references

- [secrets in k8s](https://kubernetes.io/docs/concepts/configuration/secret/)
- [options to use a configMap](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)
