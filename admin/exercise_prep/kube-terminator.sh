#!/bin/bash
# construct ingress hostname string
GARDENER_PROJECTNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f3)
GARDENER_CLUSTERNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f2)
INGRESS_HOSTNAME=h.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com

HARBOR_USER=participant
HARBOR_PWD='2r4!rX6u5-qH'

## create new builder and switch to it
docker buildx create --name kube-terminator-builder --driver docker-container
docker buildx use kube-terminator-builder
docker buildx inspect --bootstrap

## docker login to harbor
echo -e "\n > Trying to login to Harbor $INGRESS_HOSTNAME using docker login ..."
docker login -u $HARBOR_USER -p $HARBOR_PWD $INGRESS_HOSTNAME

## build and push kube-terminator container image
echo -e "\n\n > Building kube-terminator Docker mage ..."
docker buildx build --platform linux/amd64 -t $INGRESS_HOSTNAME/training/kube-terminator:v1 --push ../../kubernetes/demo/demo-chart/kube-terminator

## push kube-terminator helm chart
echo -e "\n\n > Bundling and pushing helm chart as OCI artifact ..."
helm registry login $INGRESS_HOSTNAME -u $HARBOR_USER -p $HARBOR_PWD
helm package ../../kubernetes/demo/demo-chart/chart/
helm push kube-terminator-0.1.0.tgz oci://${INGRESS_HOSTNAME}/training

## clean up
docker logout $INGRESS_HOSTNAME
docker buildx rm kube-terminator-builder
rm kube-terminator-0.1.0.tgz
