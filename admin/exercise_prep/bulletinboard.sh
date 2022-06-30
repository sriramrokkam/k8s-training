#!/bin/bash
echo -e " > IMPORTANT: This script requires access to github.wdf.sap.corp!"

# construct ingress hostname string
GARDENER_PROJECTNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f3)
GARDENER_CLUSTERNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f2)
INGRESS_HOSTNAME=h.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com

HARBOR_USER=participant
HARBOR_PWD='2r4!rX6u5-qH'

## docker login to harbor
echo -e "\n > Trying to login to Harbor $INGRESS_HOSTNAME using docker login ..."
docker login -u $HARBOR_USER -p $HARBOR_PWD $INGRESS_HOSTNAME

## clone reviews
echo -e "\n\n > Clone Bulletinboard Reviews to /tmp/bulletinboard-reviews-nodejs ..."
git clone --branch k8s https://github.tools.sap/cloud-native-bootcamp/bulletinboard-reviews-nodejs/ /tmp/bulletinboard-reviews-nodejs

## build reviews
echo -e "\n\n > Building Bulletinboard Reviews Docker Image ..."
docker build -t $INGRESS_HOSTNAME/training/bulletinboard-reviews:v1 -f /tmp/bulletinboard-reviews-nodejs/Dockerfile /tmp/bulletinboard-reviews-nodejs

## push reviews
echo -e "\n\n > Pushing Bulletinboard Reviews Docker Image ..."
docker push $INGRESS_HOSTNAME/training/bulletinboard-reviews:v1

## clone ads
echo -e "\n\n > Clone Bulletinboard Ads to /tmp/bulletinboard-ads-java ..."
git clone https://github.tools.sap/cloud-native-bootcamp/bulletinboard-ads-java/ /tmp/bulletinboard-ads-java

## build ads
echo -e "\n\n > Building Bulletinboard Ads Docker Image ..."
docker build -t $INGRESS_HOSTNAME/training/bulletinboard-ads:v1 -f ../../sample-app/solutions/ads/Dockerfile /tmp/bulletinboard-ads-java

## push ads
echo -e "\n\n > Pushing Bulletinboard Ads Docker Image ..."
docker push $INGRESS_HOSTNAME/training/bulletinboard-ads:v1 
