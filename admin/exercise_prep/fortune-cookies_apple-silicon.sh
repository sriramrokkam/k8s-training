#!/bin/bash
echo -e " > IMPORTANT: This script requires access to github.tools.sap!"

# construct ingress hostname string
GARDENER_PROJECTNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f3)
GARDENER_CLUSTERNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f2)
INGRESS_HOSTNAME=h.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com

HARBOR_USER=participant
HARBOR_PWD='2r4!rX6u5-qH'

## create new builder and switch to it
docker buildx create --name fortunecookiesbuilder
docker buildx use fortunecookiesbuilder
docker buildx inspect --bootstrap

## docker login to harbor
echo -e "\n > Trying to login to Harbor $INGRESS_HOSTNAME using docker login ..."
docker login -u $HARBOR_USER -p $HARBOR_PWD $INGRESS_HOSTNAME

## clone repo
echo -e "\n\n > Clone Fortune Cookies to /tmp/cloud-platforms-java-k8s ..."
git clone --branch cloud-platforms https://github.tools.sap/cloud-curriculum/exercise-code-java.git /tmp/cloud-platforms-java-k8s

## build and push fortune cookies
echo -e "\n\n > Building Fortune Cookies Docker Image ..."
docker buildx build --platform linux/amd64 -t $INGRESS_HOSTNAME/training/fortune-cookies:v1 -f ../../sample-app/solutions/Dockerfile --push /tmp/cloud-platforms-java-k8s

## clean up
rm -rf /tmp/cloud-platforms-java-k8s
docker logout $INGRESS_HOSTNAME
docker buildx rm fortunecookiesbuilder