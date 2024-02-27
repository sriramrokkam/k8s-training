# Exercise 7 - Ingress

In this exercise, you will be dealing with _Pods_, _Deployments_, _Services_, _Labels & Selectors_, **_Init Containers_** and **_Ingresses_**.

Ingress resources allow us to expose services through a URL. In addition, it is possible to configure an Ingress so that traffic can be directed to different services - depending on the URL that is used for a request. In this exercise, you will set up a simple Ingress resource.

In addition to all that, you will use Init-Containers to initialize your nginx Deployment and load the application's content.

This exercise does not build on any previous exercise - you will create all necessary resources during the course of this exercise.

## Step 0 - obtain necessary detail information

Since the ingress controller is specific to the cluster, you need some information to construct a valid URL processable by the controller.

You need to know the training's **_cluster name_** and the **_project name_**. Your trainer should have given them to you but in case that did not happen, you find them out yourself by running the following bash command:

```bash
echo "Clustername: $(kubectl config view -o json | jq  ".clusters[0].cluster.server" | cut -d. -f2)"; echo "Projectname: $(kubectl config view -o json | jq  ".clusters[0].cluster.server" | cut -d. -f3)"
```

If there are any issues, please check with your trainer.

## Step 1 - init: prepare pods and services

For this exercise we start over again and do not build upon the Deployments, Services or PVCs created before. Please continue to use an nginx webserver as backend application. For the sake of resource consumption, please use `replica: 1` for your new Deployment.

When you create a new Deployment you could also try to add an [init container](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/). The init container should write a string like the hostname or "hello world" to an `index.html` file on an [`emptyDir`](https://kubernetes.io/docs/concepts/storage/volumes/#emptydir) volume. Use this volume in the nginx container as well to get a customized `index.html` page.

The snippets below might give an idea, how to create a cache volume and pass an appropriate command to a busybox running as init container.

```yaml
volumes:
- name: index-html
  emptyDir: {}
```

```yaml
command:
- /bin/sh
- -c
- echo HelloWorld! > /work-dir/index.html
```

More details about init containers can be found [here](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-initialization/) and [here](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/).

## Step 2 - write a simple Ingress and deploy it

To expose your application via an Ingress, you need to construct a valid URL. Within the Gardener environment you have to use the following schema: `<your-custom-endpoint>.ingress.<CLUSTER-NAME>.<PROJECT-NAME>.shoot.canary.k8s-hana.ondemand.com`. `CLUSTER-NAME` and `PROJECT-NAME` are those pieces of information you should have received in step 0 above.

For `<your-custom-endpoint>` it is recommended to use your namespace number (run `kubectl config view` and look for the namespace). Please use just the number, strip the leading `part-` from it.

As you are going to expose the URL to public internet you certainly don't want to publish information like your D/I-user there, so please use your namespace/participant number.

Write the ingress yaml file and reference to your service. Use the following skeleton and check the [kubernetes API reference](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/ingress-v1/) for details and further info.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: <ingress resource name>
# annotations are optional at this stage! 
  annotations:
    <annotations-key>: <annotations-value>
  labels:
    <label-key>: <label-value>
spec:
  rules:
  - host: <host string>
    http:
      paths:
      - path: <URI relative to the host>
        pathType: Prefix
        backend:
          service: 
            name: <string>
            port:
              number : <int>
```

Finally, deploy your ingress and test the URL.

## Step 3 - Annotate!

Besides the labels, K8s uses also a concept called "[annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)". Annotations are part of the metadata section and can be written directly to the yaml file as well as added via `kubectl annotate ...`. Similar to the labels, annotations are also key-value pairs.
Most commonly annotations are used to store additional information, describing a resource more detailed or tweak it's behavior.

In our case, the used ingress controller knows several annotations and reacts to them in a predefined way. The known annotations and their effect are described [here]( https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/).

So let's assume, you want to change the timeout behavior of the nginx exposed via the ingress. Check the list of [annotations](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/) for the `proxy-connect-timeout` and apply a suitable configuration to your ingress. Of course don't forget to test the URL.

## optional step 4 - rewrite target

Now that you know how an annotation works and how it affects your ingress, lets move on to the fanout scenario. Assume you want your ingress to serve something different at its root level `/` and you want to move your application to `/my-app`. Your URL would look like this `<your-custom-endpoint>.ingress.<GARDENER-CLUSTER-NAME>.<GARDENER-PROJECT-NAME>.shoot.canary.k8s-hana.ondemand.com/my-app`.

In a first step, you need to add `path: /my-app(.*)` to your backend configuration within the ingress. Take a look at the [fanout demo](./demo/09b_fanout_and_virtual_host_ingress.yaml), if you need inspiration. Once you applied the change, go to your URL and test the different paths. But don't be surprised, if you don't see the expected pages.

The ingress is forwarding traffic to `/my-app` and also to `/my-app` at the backend. So unless you configured your nginx pods to serve at `/my-app` there is no valid endpoint available. You can solve the issue by rewriting the target to `/$1` of the backend pods. Check the `rewrite-target` [annotation](https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/annotations/#rewrite) for details and apply it accordingly. The documentation features an [example](https://kubernetes.github.io/ingress-nginx/examples/rewrite/) as well.

## Troubleshooting

In addition to the checking of service <> deployment connection via labels and selectors, there is another entity which holds relevant information - the actual ingress router running in `kube-system` namespace.

Get the full name of the `addons-nginx-ingress-controller` pod running in `kube-system` and check the last 50 log entries for occurrences of your ingress name or host name and related errors. Increase the number (--tail=100), when your resource is not part of the output:

```bash
kubectl -n kube-system get pods | grep addons-nginx-ingress-controller

kubectl -n kube-system logs --tail=50 addons-nginx-ingress-controller-<some ID>
```

## Further information & references

- [annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)
- [init containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
- [debugging of init containers](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-init-containers/)
- [ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [list of ingress controllers](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
- [nginx ingress controller](https://www.nginx.com/products/nginx/kubernetes-ingress-controller)
