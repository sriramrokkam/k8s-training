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

Compared to the previous v2 setup procedure, this is a significant improvement. The server-side component `tiller` has been removed completely.

## Step 2: looking for charts?

Helm organizes applications in so-called charts, which contain parameters you can set during installation. By default, helm (v3) is not configured to search any remote repository for charts.

Until recently, there was repository called `stable` on [github.com](https://github.com/helm/charts/tree/master/stable) where most of the relevant community helm charts where maintained.
However it was moved to a `deprecated` status and over time, most charts migrated to custom repositories and can be found on [helm/artifact hub](https://artifacthub.io/).

So as a first step, visit the [artifact hub](https://artifacthub.io/) and take a look around. For this exercise, we are looking for a chart called `chaoskube`. Go ahead and look it up.

Found it? Check the GitHub [page](https://github.com/linki/chaoskube) for a detailed description of the tool.

## Step 3: install a chart

The [chart's page on artifact hub](https://artifacthub.io/packages/helm/cloudnativeapp/chaoskube) gives you all the information you need, in order to install the chart.

To fulfill the prerequisites, you have to add the chart's repository to your local helm's repository list. The commands can be found, when you click the `install` button in the right upper corner of the page. They look like this:

```bash
helm repo add cloudnativeapp https://cloudnativeapp.github.io/charts/curated/
```

Next, run the following command to install the chaoskube chart. It installs everything that is associated with the chart into your namespace. Note the `--set` flags, which specify parameters of the chart.

```bash
helm install <release-name> cloudnativeapp/chaoskube --set namespaces=<your-namespace> --set rbac.serviceAccountName=chaoskube --debug
```

The parameter `namespaces` defines in which namespaces the chaoskube will delete pods. `rbac.serviceAccountName` specifies which serviceAccount the scheduled chaoskube pod will use. Here we give it the `chaoskube` account, which has been created as part of the cluster setup already. This is mainly because chaoskube wants to query pods across all namespaces - which requires a `ClusterRoleBinding` to the `ClusterRole  training:cluster-view`.  

To learn more about the configuration options the chaoskube chart provides, check again the chart's page mentioned above.

## Step 4: inspect your chaoskube

Next, check your installation by running `helm list`. It returns all installed releases including your chaoskube. You can reference it by its name.
Get more information by running `helm status <your-releases-name>`

Also check the pods running inside your kubernetes namespace. Don't forget to look into the logs of the chaoskube to see what would have happened without the dry-run flag set.
`kubectl logs -f pod/<your chaoskube-pod-name>`

## Step 5 (optional): remove the dry-run flag

To make the chaoskube actually do something, you can upgrade your release and set the dry-run flag to false.

```bash
helm upgrade <release-name> cloudnativeapp/chaoskube --reuse-values --set dryRun=false
```

Note, that you have to use `--reuse-values` to keep the non-default parameter you specified upon installation of the chart.

## Step 6: clean up

Clean up by deleting the chaoskube release:

```bash
helm delete <your-releases-name>
```

Now run `helm list` again to verify there are no leftovers.
