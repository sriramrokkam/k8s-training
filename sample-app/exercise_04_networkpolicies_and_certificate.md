# Exercise 4 - Secure your connections

## Scope

- Increase the level security by **establishing network policies** for the traffic of the app and database.  
- **Enable TLS** (https) for the **Ingress** 

## Step 1: Network policy the database

Purpose: control traffic to and from *db* pods

- Specify a **NetworkPolicy** for the **database**, with name `db-access` and with proper labels and selector for component and module. 

- We want the database to accept traffic only from the fortune cookies app. Configure the network policy accordingly. 

You can check the [network policy exercise](/kubernetes/exercise_09_network_policy.md) and [this reference](https://kubernetes.io/docs/concepts/services-networking/network-policies/) on how to write a network policy.

Also, we want to block all outgoing traffic by denying egress traffic. Have a look at the [documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/#default-deny-all-egress-traffic) to learn how to configure it.

- Save the **Networkpolicy** under the filename `db-networkpolicy.yaml` and apply it with `kubectl apply -f db-networkpolicy.yaml`

<details> <summary>If you need further hints here is a skeleton network policy!</summary>
<p>

```yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: db-access
  labels:
    <proper-component-module-labels>
spec:
  podSelector:
    matchLabels:
      <labels-for-targeted-entities>
  policyTypes:
  - Ingress
  - Egress  
  ingress:
  - from:
    - podSelector:
        matchLabels:
        <incoming pods labels>
  egress: []
```

</p>
</details>

### Testing of the implemented policy

To test the ingress rule, open the app in a browser. If you can get a quote, the connection app -> postgres is still working as expected.

Another way to test would be to create a temporary pod with psql installed (e.g. a postgres:13-alpine image like our DB). Use psql from this pod to connect to the DB. First we will use the right labels:

```bash
kubectl run helper -it --restart=Never --rm --image=postgres:13-alpine --labels="component=fortune-cookies,module=app" --env="PGCONNECT_TIMEOUT=5" --command -- ash
```

A prompt with root@... should come up. You are now connected to the pod, here we can use psql to try to connect to our postgres Pod:
`psql -h <name-of-headless-service> -p 5432 -U postgres -W postgres`. You will be asked for the password, which you stored in the Secret `db-credentials`. After this you should connect to the database, a prompt `postgres=>` will ask you for the next command. Type `\q` to quit psql since we only wanted to test that we can connect. Also exit the pod with the `exit` command.

To test that no one else can connect, change the labels in the kubectl command to anything different (or just leave them out) and repeat the steps above:

```bash
kubectl run helper -it --restart=Never --rm --image=postgres:13-alpine --env="PGCONNECT_TIMEOUT=5" --command -- ash
```
Again you should get a root prompt, execute `psql -h <name-of-headless-service> -p 5432 -U postgres -W postgres` which, after you entered the password, should return with `timeout expired` after 5 seconds.

To test the egress `kubectl exec -it postgres-0 -- ash` and try to "ping" any page/pod e.g. `wget google.de`.
It should fail.
If `wget` is not there, try e.g. `apt-get update`.
This will also timeout.

## Step 2: Network policy for the fortune cookies app

Purpose: control traffic to and from the fortune cookies pods, learn how to select a pod in a different namespace in your policy

- Specify a **NetworkPolicy** with name `app-access` and with proper labels and selector for component and module. 

- We want to allow traffic from the ingress-controller. Configure the network policy accordingly. 
The ingress controller is in the `kube-system` namespace, so you will have to configure the network policy to allow traffic from specific pods in this namespace. To get the namespace's label, run `kubectl get ns kube-system --show-labels`. The ingress controller itself has the following labels, which you have to use as well: 
```yaml
app: nginx-ingress 
component: controller 
origin: gardener
```

Before we continue with the egress traffic, let us apply the ingress restriction.

- Save the **Networkpolicy** under the filename `app-networkpolicy.yaml` apply it with `kubectl apply -f app-networkpolicy.yaml`

- Test that everything still works fine.

Furthermore, we want to restrict the egress traffic to certain pods only. This would be the database as well as the DNS server in our cluster.
  - The DNS server is also in the `kube-system` namespace and has a label `k8s-app: kube-dns`. However, there is an additional DNS cache on each node, which we have to allow traffic to as well ([see: node-local-dns](https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns/)).
  - The database pod was labeled earlier by ourselves

Restrict the egress traffic to allow only the necessary connections mentioned above. You may use the following snippet to enable DNS queries:

```yaml
# allow traffic to core DNS pods running in kube-system namespace
  - to:
    - podSelector:
        matchLabels:
          k8s-app: kube-dns
      namespaceSelector:
        matchLabels:
          gardener.cloud/purpose: kube-system
    ports:
    - port: 8053
      protocol: UDP
    - port: 8053
      protocol: TCP
# allow traffic to node-local-dns pods. Since they run within the host network, we have to allow this as well
  - to:
    - namespaceSelector:
        matchLabels:
          gardener.cloud/purpose: kube-system
      podSelector:
        matchLabels:
          k8s-app: node-local-dns
    - ipBlock:
        # if you knew the CIDR ranges for the cluster nodes, you could make this more specific
        cidr: 0.0.0.0/0
    ports:
    - port: 53
      protocol: UDP
    - port: 53
      protocol: TCP
```

Again test the app, if everything still works.

## Step 3: TLS

We also want to enable TLS for our communication with the fortune cookies app. Therefore, we activate TLS on our ingress service. 

To secure an ingress we need to configure the ingress resource and provide a secret containing the certificate. 
Gardener has implemented a controller which is automatically looking for ingress resources certain annotations, creates trusted certificates for them using `Let'sEncrypt` and puts those into secrets.
The only thing we have to do configure the ingress and wait for the controller to do its work.

To learn more about the cert manager, take a look at this [Gardener tutorial](https://gardener.cloud/docs/extensions/others/gardener-extension-shoot-cert-service/usage/request_cert/#using-an-ingress-resource).

This feature is limited to URLs with 64 characters or fewer. Or, to be more precise, we need at least one URL which fits into the 64 characters of the common name field of the certificate request. Any URL with more characters may be added to the certificate request via the subject alternative name field.
To construct a URL of suitable length, let us use a four letter hostname pattern: A `fc` for "fortune cookies" and the last two digits of your participant number.
So we get for example `fc40.ingress.cw43.k8s-train.shoot.canary.k8s-hana.ondemand.com` when your participant number is `part-0040` and the cluster name is `cw43`.

To check the length of such a string, run this command:
```bash
echo fc40.ingress.cw43.k8s-train.shoot.canary.k8s-hana.ondemand.com | wc -c
```

Now configure the yaml accordingly. For the secret-name you can choose anything you like, the controller will pick it up and generate the required secret with the given name. But be careful with the order of elements in the hosts array. The `short-hostname` constructed above will be used for the annotation only.
Finally, don't forget to put in the necessary label!

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name:fortune-cookies
  labels:
    ...
  annotations:
    cert.gardener.cloud/purpose: managed
    cert.gardener.cloud/commonname: <short-name>.ingress.<your-trainings-cluster>.<your-project-name>.shoot.canary.k8s-hana.ondemand.com
    cert.gardener.cloud/dnsnames: <long-hostname>.ingress.<your-trainings-cluster>.<your-project-name>.shoot.canary.k8s-hana.ondemand.com
spec:
  rules:
  - host: <long-hostname>.ingress.<your-trainings-cluster>.<your-project-name>.shoot.canary.k8s-hana.ondemand.com
    http:
      paths:
      - path: /
        backend:
          serviceName: fortune-cookies
          servicePort: app-port
  tls:
    - hosts:
      - <long-hostname>.ingress.<your-trainings-cluster>.<your-project-name>.shoot.canary.k8s-hana.ondemand.com
      secretName: <secret-name>
```

### Test the updated ingress
Usually, it takes around 1-2 minutes for the certificates to be requested, validated and added to the ingress. The best way to check the ingress' status is to `describe` it. The responsible cert-manager will post events just like all the other controllers we've seen so far.
Once the certificate has been provisioned, check both ingress hosts. They should point to the same backend target (`fortune-cookies`) and default to a https connection. Take a look at the certificate in your browser, go to the details and check the subject alternative name, which should contain the additional DNS name.
