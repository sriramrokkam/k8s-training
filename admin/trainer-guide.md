# Trainer Guide

## Overview

#### Course Prep steps
These are the logical steps for a trainer to prep for a course (details below):
- Make sure your training is 'officially' requested and scheduled in SuccessMap Learning
- Sent an email with preparation steps to participants
- Request/create a Gardener cluster for your training
- Obtain/Download your trainer `kubeconfig` from Gardener that lets you control the cluster
- Logon to the training-admin server and prepare the cluster according to [this guide](https://github.wdf.sap.corp/D044431/training-admin#usage) (VPN required).

All artifacts / scripts / info needed as trainer is in this admin folder.
You can use the participant VM also for all work as a trainer.

## Course preparation

### Planning
- Make sure the training is officially requested ([Team Request Template](https://jam4.sapjam.com/wiki/show/H8gZq0zBgHoRfttFe6TDyt?_lightbox=true)) and scheduled in SuccessMap Learning.

- If it is done this way, then our Global Coordinator from Cloud Curriculum (Rosemary Berberian) will check the utilization of our Cluster and also organizes/help to organize the room and send the calendar entry to the participants, so you don't have to worry about that.

- The event will then also appear in the [event calendar on the Cloud Curriculum Jam page](https://jam4.sapjam.com/groups/zAfXdXPcJGlCUrBScXSWKP/events).

### K8s cluster in Gardener

- **Contact the [Cloud Curriculum K8s Trainings DevOps Team](mailto:DL_5B2CDDFFECB21162D9000010@global.corp.sap?subject=[Docker%20and%20K8s%20fundamentals%20training]%20Request%20for%20trainings%20cluster%20-%20<Location>-<DateOfYourTraining>) to get a Gardener K8s Cluster** for the training (~ 2 weeks in advance to the training), in case you want to use the Cloud Curriculum Resources in [Gardener](https://github.wdf.sap.corp/pages/kubernetes/gardener/) (incl. Cloud Curriculum Google Account). In the email body please refer to the corresponding event in the [Cloud Curriculum Event Calendar](https://jam4.sapjam.com/groups/zAfXdXPcJGlCUrBScXSWKP/events) (e.g. link/ URL of event).

### Create your trainer .kube/config to access the cluster

On your VM / machine:
- Create a directory `.kube` under `$HOME` (e.g. /home/vagrant on VM) and cd into it.
- Create new file `config` and paste the kubeconfig yaml, you have got from [Cloud Curriculum K8s Trainings DevOps Team](mailto:DL_5B2CDDFFECB21162D9000010@global.corp.sap?subject=[Docker%20and%20K8s%20fundamentals%20training]%20Request%20for%20trainings%20cluster%20-%20<DateOfYourTraining>) for your training.
- run `kubectl get nodes` - this command must complete by giving you a short list of nodes in the cluster

### Generate the kube configs for the participants and prepare the cluster

**Please note, that the process has changed significantly. Please read this section carefully!** :clipboard:

Instead of running things locally, we wrote a small webserver that runs within a Gardener Shoot Cluster on Converged Cloud. 
In a nutshell, the server replaces `kubecfggen.sh` as well as the process of storing, uploading and sharing the results via Jenkins.

To access the "admin server", you need to connect to the office network (via VPN when working remotely): 

https://admin.ingress.trn-admin.k8s-trainings.c.eu-de-2.cloud.sap with username=`admin` and password=`ov9u4Z/#vc[3JuI`

Start preparing a cluster by following the steps outlined [here](https://github.wdf.sap.corp/D044431/training-admin#usage).

**Make sure to note down the training name/id as well as the URL and password displayed at the end of the process. It is displayed only ONCE.**

Those information will be needed by the participants during the training. In case you missed or lost these information, please contact [Cloud Curriculum K8s Trainings DevOps Team](mailto:DL_5B2CDDFFECB21162D9000010@global.corp.sap) for recovery.

**Please note:** The process creates not only the namespaces. It also deploys a ResourceQuota & LimitRange to each namespace. With this, abuse of the training cluster should become harder. The ResourceQuota limits the number of pods accepted by each namespace to 15. Any participant trying to scale a deployment to a hundred pods or more will not harm other participants. The LimitRange assigns default values for memory and CPU requested by a pod. It also give a default limit. If a pod does not specify any of these it will inherit the defaults. In other terms, by specifying a cpu/memory request & limit, the defaults can be overwritten.

**Please also note:** Participant-kubeconfigs will be deleted automatically 3 weeks after they have been created. 

## Sending the preparation mail to participants

You should send a **'preparation mail'** to all participants about a week before the course starts. You should add the below information in your mail:

```
------- adapt & add this info
- Please follow these instructions to download a VM and prep for the course:
  <link to repo>/blob/master/preparation.md
---------- end -----------
```
Also it is recommended to refer to the cheat-sheets for [docker](../docker/Docker%20Cheat%20Sheet.docx) and [Kubernetes](../kubernetes/cheat%20sheet.docx). Ask participants to print and bring them along, if they deem it would be helpful.

An other option would be to take one of our **mail templates**, we have prepared: [Template 1](preparation_email_sample1.txt), [Template 2](preparation_email_sample2.txt)

Technically it would be possible to run most of the exercises also with Docker on Windows/Mac and a local kubectl. **However, we would recommend explicitly exclude support for this setup during the training.**

## Setting you up for the training
**Important: Forking is no longer necessary! But feel free to do so, if you feel more comfortable with it.**

### Clone the repo
There are demo scripts/files for the container, docker and kubernetes parts. Simply clone the repo to your VM and work with this copy:

`git clone https://github.tools.sap/kubernetes/docker-k8s-training.git`

We are referencing stable versions of our repo with a release tag, so you can use one of these for the training as well.

### Get the cluster and project name
You will need the information to setup components like the registry. It is also required for some docker exercises and k8s demos.

Look into your (trainer) kubeconfig. The file contains a URL for the API server of the cluster. You can derive the cluster as well as the project name from this URL.

The URL pattern on Gardener looks like this:

 `[custom-endpoint].ingress.<cluster-name>.<project-name>.shoot.canary.k8s-hana.ondemand.com`

**Example:** If your API server URL were `https://api.ccdev.k8s-train.shoot.canary.k8s-hana.ondemand.com`, the project name would be `k8s-train` and the cluster name would be `ccdev`.

### Adapt the ingress URLs
Gardener deploys an ingress controller to each cluster and allows you to register custom URLs to a specific subdomain. Since the subdomain contains the name of the Gardener project as well as the cluster, you have to adapt the ingress resources locally (on your VM) to match with your setup.

Check the following files for `<cluster-name>` and `<project-name>` placeholders and replace them with the actual cluster/project names:
* [sock-shop](../kubernetes/demo/00_sock-shop.yaml)
* [simple ingress with tls](../kubernetes/demo/09a_tls_ingress.yaml)
* [fanout & virtual host ingress](../kubernetes/demo/09b_fanout_and_virtual_host_ingress.yaml)

### Setup helm
To continue with the setup, you need `helm`. Run the [helm_init](helm_init.sh) script within your VM to download the helm client (if not present) and add some repositories.

### Setup a docker registry (~1 day before course starts)
For the docker exercises you need a private docker registry. Participants will upload their custom images to it during the course. After using a plain docker registry for quite some time, we decided to swith to [Harbor](https://goharbor.io/). It comes with a UI and some more useful features.
In the admin folder of this repo, you find a registry folder with `install_harbor_registry.sh` script. Check the prerequisites and run the script as described [here](./registry/readme.md) to deploy a registry and make it available via an ingress.

### Build and push sample app artefacts
For the day 4 exercises, you will need to build and push the images of bulletinboard-ads and bulletinboard-reviews. This can be done automatically using this [script](./exercise_prep/bulletinboard.sh). It will clone both repositories, build the images and push them to the Harbor registry using the `participant` credentials.

### Setup cluster monitoring & logging (~1 day before course starts)
If you want to keep track of things happening in the cluster, you can use this [script](./monitoring) to setup prometheus/loki based monitoring & logging. Both can be accessed via Grafana.

### (Optional) [Gain access to the Dashboard](accessDashboard.md)

## During the Course

### Assign participants to namespace numbers
Feel free to use any suitable method to assign namespace numbers to participants and hand out the URL to download the kubeconfigs as well as training name and password to logon.

### Use the "master" kube.config 
For all demos to work properly (especially the RBAC demo), you have to use an "admin" user when talking to the cluster. When you use the `kube.config` you got along with the cluster details, you are on the save side. However if you use a participant user / namespace, the RBAC demo will fail due to missing authorization. 

Of course, you can create a separate namespace (!= `default`) and add it to the `kube.config` context definition to send requests to it by default.

### Add nodes to K8s cluster
In exceptional cases it might happen that your cluster needs more resources to deal with all the participants pods because autoscaler configuration is not sufficient high. In order to scale the cluster up, get in contact with [Cloud Curriculum K8s Trainings DevOps Team](mailto:DL_5B2CDDFFECB21162D9000010@global.corp.sap?subject=[Docker%20and%20K8s%20fundamentals%20training]%20Request%20for%20trainings%20cluster%20-%20<DateOfYourTraining>).

## After the course

- Contact the [Cloud Curriculum K8s Trainings DevOps Team](mailto:DL_5B2CDDFFECB21162D9000010@global.corp.sap?subject=[Docker%20and%20K8s%20fundamentals%20training]%20Request%20for%20trainings%20cluster%20-%20<DateOfYourTraining>) to let destroy the Gardener cluster, you used for the training. If needed you can request to keep the cluster for one additional week, so participants can rework on their exercises.
- If you ask for one additional week please run [Cleanup Script](cluster_cleanup.sh) `cluster_cleanup.sh all` after the last day of training on the trainings cluster to help us save some money. In all but kube-system and logging namespace it
  - scales statefulsets and deployments down to one replica
  - removes unused pvcs
  - demotes LoadBalancer Services to NodePorts