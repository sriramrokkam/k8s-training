# Scripts to prepare The training cluster

## Ingress controller

Both for the demos and the exercices, the cluster need an ingress controller. You should use the default ingress controller provided by Gardener (nginx). However, since ingress-nginx is deprecated since March 2026, the class will eventially be adapted to use Traefik instead.

Sinnce you're likely using a Gardener cluster for the training, should you have access to automation in order to manage Let's encrypt certificates and a DNS domain like `[endpoint].ingress.[cluster-name].[project-name].shoot.canary.k8s-hana.ondemand.com`. Those can be easily defined and managed via `annotations` to the ingress/service resource. See https://pages.github.tools.sap/kubernetes/gardener/docs/guides/networking/certificate-extension-default-domain/ for more details.

## install_harbor_registry.sh

For day 1 or the training, the final exercice is to push a docker image to a registry. For this, we will use the Harbor registry (OCI), that will be part of the training cluster.

You also need this registry to push the images / helm charts below for the demo and the helm exercices on day 4.

The registry is exposed via `ingress` resource, so make sure your cluster has a running ingress controller (eg. nginx via Gardener or Traefik).

In it's current version, the helm chart values will be set in a way to instruct Gardener to provision a let's encrypt certificate for the ingress.

To push images to the registry, you have to use the project as part of the host string (e.g. `https://h.ingress.<cluster-name>.k8s-train.shoot.canary.k8s-hana.ondemand.com/training/<image-repo>:<tag>`). For the sake of convenience, the harbor UI has hints for tagging & pushing. You can display by navigating to the project's details (projects -> training) and click on the "push command" in the right upper corner.

### preparation

- Check, that `kubectl` works with your cluster
- Make sure that you have the htpasswd binary on your local machine. Otherwise install it (`brew install pass` for MacOS, `apt install apache2-utils` on debian based systems, ...)

### Install the registry

The script will

- Construct a URL for Gardener ingress
- Create a namespace `harbor-registry`
- Deploy the chart `harbor/harbor` into the new namespace
- Wait for the server to be up and running
- Create a new harbor project `training`
- Create a new harbor user `participant` with password `2r4!rX6u5-qH` (also mentioned in the respective exercise)
- Assign the user to the `training` project with role `developer`

Finally, test your registry by opening the ingress URL (e.g. `https://h.ingress.<cluster-name>.k8s-train.shoot.canary.k8s-hana.ondemand.com/`).

As a trainer, you have two sets of credentials - user `participant` limited to the `training` project and user `admin` for global management of the harbor installation (password is printed out at the end of the script's run but can be found in the script too).

## fortune-cookies.sh

For the day 4 exercises, you will need to build and push the container image for the fortune-cookies app. This can be done automatically using this [script](./fortune-cookies.sh).

**Important: this script requires a connection and credentials to work with github.tools.sap!**

It will:

- run `docker login` to the harbor registry using the `participant` credentials
- clone cloud-platforms-java-k8s to `/tmp`
- build the Docker image for x86 architecture since the training cluster's nodes are based on this
- push the image to the `training` project in Harbor

## kube-terminator.sh

To demo and explain helm charts, there is a [small chart + application in this repo](../../kubernetes/demo/demo-chart).

The script will:

- run `docker login` to the harbor registry using the `admin` credentials
- build an image with x86_64 architecture for the kube-terminator app and push it to the `library` project in Harbor.
- package and upload the helm chart as an OCI artifact to the `library` project in Harbor.

## steakfulset.sh

To demo and explain `CustomResourceDefinitions` and controllers reconciling them, we use the [steakfulset-controller](https://github.com/MrBatschner/steakfulset-controller). It contains a CRD for a `SteakfulSet` and a `Steak` as well as a small controller that reconciles the `SteakfulSet` and creates `Steak` resources.

The script will:

- clone the repository to `/tmp`
- build an image with x86_64 architecture for the steakfulset-controller app and push it to the `library` project in Harbor.
- package and upload the helm chart as an OCI artifact to the `library` project in Harbor.

## Adapt the URLs to use the correct cluster name and project name in the harbor registry

Since the registry is exposed via an ingress resource, the URL contains the cluster name and project name. You need to adapt the URLs in the exercises to be able to push and pull images from the registry.

We created a simple script to do this for you. It will replace the placeholder `<cluster-name>` and `<project-name>` in the exercises with the actual values from your cluster and harbor registry.
To run the script, execute the following command in the terminal:

```bash
./replace_ingress_urls.sh
```
