# Setup an OCI registry in K8s

In this folder you find scripts & yaml files to deploy an OCI registry into the K8s cluster used for the training.
We use [Harbor](https://goharbor.io/), installed via a [helm chart](https://github.com/goharbor/harbor-helm), which comes with a registry, chartmuseum and a nice UI.

The participants should use this registry for the docker exercises, where they push their own images to. Additionally, the registry can host helm charts.

The registry is exposed via `ingress` resource, so make sure your cluster has a running ingress controller. When running with Gardener this prerequisite is already fulfilled.  

In it's current version, the helm chart values will be set in a way to instruct Gardener to provision a let's encrypt certificate for the ingress. 

## Harbor in this training
Harbor is an open source project combining multiple tools related to the distribution of OCI artefacts. At its core, it contains an OCI registry and a graphical user interface. Additionally, tools like trivy or notary can be installed and integrated.

For the training, we don't install scanning or signing tools but add the chart museum. Participants will be using the portal to access our Harbor installation. 
While an integration to LDAP or OIDC would be possible, we keep it simple and use one generic user `participant` for all participants. As a trainer, you will also have an admin user to harbor (see below).

Harbor organizes artefacts in so called projects. For the training the script creates a private project called `training` and assigns the `participant` user to it.

To push images to the registry, you have to use the project as part of the host string (e.g. `https://h.ingress.<cluster-name>.k8s-train.shoot.canary.k8s-hana.ondemand.com/training/<image-repo>:<tag>`). For the sake of convenience, the harbor UI has hints for tagging & pushing. You can display by navigating to the project's details (projects -> training) and click on the "push command" in the right upper corner.

## step-by-step setup

### preparation
* check, that `kubectl` works with your cluster
* If not yet done - setup `helm`. Use the `helm_init.sh` [script](../helm_init.sh) to carry out all required steps. 

### Install the registry
run `install_harbor_registry.sh`. The script will find the name of your Gardener project as well as the cluster name from the helm configuration file.

The script will
  * construct a URL for Gardener ingress
  * create a namespace `harbor-registry`
  * deploy the chart `harbor/harbor` into the new namespace
  * request a let's encrypt certificate for the ingress
  * create a new harbor project `training`
  * create a new harbor user `participant` with password `2r4!rX6u5-qH` (also mentioned in the respective exercise)
  * assign the harbor user to the `training` project with role `developer`

Finally, test your registry by opening the ingress URL (e.g. `https://h.ingress.<cluster-name>.k8s-train.shoot.canary.k8s-hana.ondemand.com/`).

As a trainer, you have two sets of credentials - user `participant` limited to the `training` project and user `admin` for global management of the harbor installation (password is printed out at the end of the script's run but can be found in the script too). 
