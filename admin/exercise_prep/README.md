# Scripts to prepare exercises

## fortune-cookies.sh
For the day 4 exercises, you will need to build and push the container image for the fortune-cookies app.. This can be done automatically using this [script](./fortune-cookies.sh). 

**Important: this script requires a connection and credentials to work with github.tools.sap!**

It will:
- run `docker login` to the harbor registry using the `participant` credentials
- clone cloud-platforms-java-k8s to `/tmp`
- build the Docker image for x86 architecture since the training cluster's nodes are based on this
- push the image to the `training` project in Harbor

## kube-terminator.sh

To demo and explain helm charts, there is a [small chart + application in this repo](../../kubernetes/demo/demo-chart).

The script will:
- run `docker login` to the harbor registry using the `participant` credentials
- build an image with x86 architecture for the kube-terminator app and push it to the `training` project in Harbor.
- package and upload the helm chart as an OCI artifact to the `training` project in Harbor.