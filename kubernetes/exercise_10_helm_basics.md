# Exercise 10: Happy Helming

In this exercise, you will be dealing with **_Helm_**.

Helm is a tool to manage complex deployments of multiple components belonging to the same application stack. In this exercise, you will install the helm client locally. Once this is working you will deploy your first chart into your namespace.
For further information, visit the official docs pages (<https://docs.helm.sh/>)

**Note:** This exercise does not build on any of the previous exercises.

## Step 0: get the helm tool

Install the `helm` binary using one of the ways described here: <https://helm.sh/docs/intro/install/>

To verify your installation, run the commands below. The 1st command should return the location of the helm binary. The 2nd command should return the version of the client.

```bash
which helm
helm version
```

## Step 1: no need to initialize helm (anymore)

The helm client uses the information stored in .kube/config to talk to the kubernetes cluster. This includes the user, its credentials but also the target namespace. Restrictions such as RBAC or pod security policies, which apply to your user, also apply to everything you try to install using helm.

**And that's it - `helm` is ready to use!**

## Step 2: looking for charts?

Helm organizes applications in so-called charts, which contain templates and parameters you can set during installation. You can develop and store charts locally, but also in remote locations. By default, helm is not configured to search any remote repository for charts though.

The largest aggregation of charts is available at [helm/artifact hub](https://artifacthub.io/). Here, you can search for charts and find many common applications, but please be aware that they might be served from different repositories.

So as a first step, visit the [artifact hub](https://artifacthub.io/) and take a look around. Can you find a chart for an application you are using or interested in?

## Step 3: install a helm chart

While the artifact hub is a great place to search for charts, another way of distributing them is via OCI registries. In fact, you can push a helm chart to a registry just like you would do with a container image. Both are OCI compliant artefacts and can be served from our training's harbor registry. This way you don't have to worry about the repository "magic" within helm. Quite often, OCI references to helm charts are attached to release notes of projects and can be consumed directly.

In this exercise, you will install a chart from the harbor registry. The chart is called `kube-terminator` and is used to randomly delete pods in your kubernetes cluster. This is useful to test an application for resilience.

Before you can install it, you need to locate the chart in the harbor registry. Logon to the web UI through `h.ingress.<cluster-name>.<project-name>.shoot.canary.k8s-hana.ondemand.com` with user `participant` and password `2r4!rX6u5-qH`. Navigate to the `library` project and locate the `kube-terminator`. There should be two artifacts - a docker image as well as a helm chart. Click on the helm chart and take a look at the details.

Harbor renders a README file as well as the default values for the chart. 

To install the chart you need its location. You can copy the location from the harbor UI by clicking the "Copy" button on next to the tag or use the commands below:

```bash
GARDENER_PROJECTNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f3)
GARDENER_CLUSTERNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f2)
INGRESS_HOSTNAME=h.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com

helm install terminator oci://${INGRESS_HOSTNAME}/library/kube-terminator --version 0.1.0
```

## Step 4: inspect your kube-terminator

The installation command should have created a helm release called `terminator`. Run the commands below to verify that the release was created successfully.

```bash
# check for releases, use --failed to see failed releases as well
helm list --failed
# check the status of the release
helm status terminator
# check the resources created by the release and the values used
helm get all terminator
```

Of course, there should also be a pod running. Check the logs of it (`kubectl logs ...`)  to see, what it is doing.

## Step 5: remove the dry-run flag

The kube-terminator is running in dry-run mode by default. This means it will not delete any pods, but only log the names of the pods it would delete. To change this, you need to set the `talkToTheHand` parameter to `false`. You can do this by using the `--set` flag and upgrade the chart.

```bash
GARDENER_PROJECTNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f3)
GARDENER_CLUSTERNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f2)
INGRESS_HOSTNAME=h.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com

helm upgrade terminator oci://${INGRESS_HOSTNAME}/library/kube-terminator --version 0.1.0 --set "configuration.talkToTheHand=false"
```

Again, you can use `helm list --failed` and `helm status terminator` to check, if the upgrade was successful. By running `helm get values terminator` you should see the `talkToTheHand` parameter set to `false` and listed as "user supplied value".

## Step 5.5 (optional): give the terminator something to chew on

If your namespace doesn't contain any pods besides the kube-terminator itself, deploy a few by creating a `Deployment`:

```bash
kubectl create deployment nginx --image=nginx --replicas=3
```

You can see the labels the pods have been created with by running `kubectl get pods --show-labels`.
Because they are managed by a `Deployment`, they will be re-created whenever the terminator kills them.
You can keep an eye on your pods in a second terminal:

```bash
watch kubectl get pods
```

## Step 6: specify labels and re-use values

To avoid the `kube-terminator` to terminate itself, you could specify labels to select pods to delete. Instead of using  the `--set` flag, you can also use a values file. This is useful, if you have many parameters to set.

Firstly, check which labels are used by pods running in your namespace by running `kubectl get pods --show-labels`. Next, create a file called `terminator-values.yaml` and add the following content while adapting the label selector to your needs:

```yaml
configuration:
  labelSelector: "<key>=<value>"
```

You can now use this file to set the label selector for the kube-terminator. You can also use the `--reuse-values` flag to re-use the values from the previous installation. This way you don't have to set all parameters again.

```bash
GARDENER_PROJECTNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f3)
GARDENER_CLUSTERNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f2)
INGRESS_HOSTNAME=h.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com

helm upgrade terminator oci://${INGRESS_HOSTNAME}/library/kube-terminator --version 0.1.0 -f terminator-values.yaml --reuse-values
```

Instead of using `--reuse-values` you could also add your configuration to the values file. This way you can keep all your configuration in one place. Both way are possible, and it is helpful to know they exist.

## Step 7: clean up

Finally, clenup your resources by running the command below. This will remove the helm release and all resources created by it.

```bash
helm delete terminator
```
