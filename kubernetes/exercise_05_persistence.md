# Exercise 5: Persistence

In this exercise, you will be dealing with _Pods_, _Deployments_, _Services_, _Labels & Selectors_, **_Persistent&nbsp;Volumes_**, **_Persistent&nbsp;Volume&nbsp;Claims_** and **_Storage Classes_**.

After you exposed your webserver to the network in the previous exercise, we will now add some custom content to it which resides on persistent storage outside of pods and containers.

**Note**: This exercise loosely builds upon the previous exercise. If you did not manage to finish the previous exercise successfully, you can use the YAML file [04_service.yaml](solutions/04_service.yaml) in the _solutions_ folder to create a service. Please use this file only if you did not manage to complete the previous exercise.

## Step 0: Prepare and check your environment

Firstly, remove the deployment you created in the earlier exercise. Check the cheat sheet for the respective command.

Next, take a look around: `kubectl get persistentvolume` and `kubectl get persistentvolumeclaims`. Are there already resources present in the cluster?
Inspect the resources you found and try to figure out how they are related (hint - look for `status: bound`).

By the way, you don't have to type `persistentvolume` all the time. You can abbreviate it with `pv` and similarly use `pvc` for the claim resource.

## Step 1: Create a PersistentVolume and a corresponding claim

Instead of creating a PersistentVolume (PV) first and then bind it to a PersistentVolumeClaim (PVC), you will directly request storage via a PVC using the default storage class.
This is not only convenient, but also helps to avoid confusion. PVC's are bound to a namespace, PV resources are not. When there is a fitting PV, it can be bound to any PVC in any namespace. So there is some conflict potential, if your colleagues always claim your PV's :)
The concept of the storage classes overcomes this problem. The tooling masked by the storage class auto-provisions PV's of a defined volume type for each requested PVC.

Use the resource stored in the [repository](./solutions/05_pvc.yaml) or copy the snippet from below to your VM:

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: nginx-pvc
spec:
  storageClassName: default
  accessModes:
    - ReadWriteOncePod
  resources:
    requests:
      storage: 1Gi
```

Create the resource: `kubectl apply -f pvc.yaml` and verify that your respective claim has been created.

Given the policy of the storage class, a PV might not be provisioned immediately and the PVC is "stuck" in status `Pending`. This is perfectly fine, but take a closer look with `kubectl describe pvc <pvc-name>`.

## Step 2: Attach the PVC to a pod

Expand the deployment used in the previous exercise and make use of the PVC as a volume. Fill in the volumeMounts section to get access to your PVC within the actual container. The snippet below is not complete, so fill in the `???` with the corresponding values.

```yaml
spec:
  volumes:
  - name: content-storage
    persistentVolumeClaim:
      claimName: ???
  containers:
  - name: nginx
    image: nginx:mainline
    ports:
    - containerPort: 80
    volumeMounts:
    - mountPath: "/usr/share/nginx/html"
      name: content-storage
```

**Important**: The PVC's access mode is `ReadWriteOncePod`. Hence, reduce the number of replicas in your deployment to 1.

Once you re-created the deployment, make sure to check that the pod has status `Running` before you continue. You can also have a look at the PVC again. It should be backed by PV by now.

## Step 3: create custom content

If you would try to access the nginx running in your pod, you would probably get an error message `403 Forbidden`. This is expected since you are hiding the original `index.html` with a bind-mount. So let's move on and create some content on the volume we have available.

Locate the nginx pod and open a shell session into it: `kubectl exec -it <pod-name> -- bash`.
Navigate to the directory mentioned in the `volumeMounts` section and create a custom `index.html`. You can re-use the code you used in the docker exercises the other day. Once you are done, disconnect from the pod and close the shell session.

<details><summary>__Hint__</summary>

You can you use heredocs to create a custom index page without installing vi.

```html
cat << __EOF > index.html
<html>
<head>
        <title>Containers on the run...</title>
</head>
<body>
        <h1>Welcome to Containers...</h1>
        <p>You successfully managed to add a hello world page.</p>
</body>
</html>
__EOF
```

</details>

With the index page in place, try to access the webserver via the service you created in the previous exercise. It should bring up the new page now.

## Step 4: Scaling does not work, does it?

In the previous step, the deployment was deliberately created with only one replica since the access mode "ReadWriteOnce" does not allow multiple consumers. In this section we will take a closer look at the implications of the access mode.

Firstly, try to bring up more pods by increasing the deployment's replica count to 5. Use `kubectl get pods -o wide` to monitor on which nodes pods are scheduled and on which node copies actually transition to status "Running".  

Is there a node, where multiple pods successfully started?

If a pod stays in status `Pending` or `ContainerCreating` you could use `kubectl describe pod <pod-name>` to check the events logged for this pod. They give a first idea, of what is actually happening (or not working).

Finally, scale the deployment back to a replica count of 1.

**Important:** Do not delete the deployment,service or PVC!

## Troubleshooting

In case the pods of the deployment stay in status `Pending` or `ContainerCreation` for quite some time, check the events of one of the pods by running `kubectl describe pod <pod-name>`.

### How to check if a disk is mounted

You can try to see if the storage device is unmounted by:

1. Use `kubectl get pvc <pcv-name>` to get the name of the bounded persistent volume.
1. Use `kubectl get pv <pv-name> -o json | jq ".spec.csi.volumeHandle"` to get the name of the physical disk used by the persistent volume.
1. Use `kubectl get nodes -o yaml | grep <physical-disk-name>` to see if the physical disk is still connected to a node? If it is you get  3 lines per connected node.

### Service Problems

In case your service is not routing traffic properly, run `kubectl describe service <service-name>` and check, if the list of `Endpoints` contains at least 1 IP address. The number of addresses should match the replica count of the deployment it is supposed to route traffic to.

### Caching issues

Finally, there might be some caching on various levels of the used infrastructure. To break caching on corporate proxy level and display the custom page, append a URL parameter with a random number (like 15): `http:<LoadBalancer IP>/?random=15`.

## Further information & references

- description of the [volumes API](https://kubernetes.io/docs/concepts/storage/volumes/)
- how to use [PV & PVC](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [storage classes](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- [volume snapshots](https://kubernetes.io/docs/concepts/storage/volume-snapshots/)
