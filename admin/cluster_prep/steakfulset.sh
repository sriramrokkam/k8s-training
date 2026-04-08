#!/bin/bash
# construct ingress hostname string
GARDENER_PROJECTNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f3)
GARDENER_CLUSTERNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f2)
INGRESS_HOSTNAME=h.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com

HARBOR_USER=admin
HARBOR_PWD=$(kubectl -n harbor-registry get secrets harbor-registry-core -ojson | jq -r .data.HARBOR_ADMIN_PASSWORD | base64 -d)

REPO_DIR=/tmp/steakfulset-controller
#BULDER=steakfulset-controller-builder

## create new builder and switch to it
#docker buildx create --name ${BULDER} --driver docker-container
#docker buildx use ${BULDER}
#docker buildx inspect --bootstrap

## docker login to harbor
#echo -e "\n > Trying to login to Harbor $INGRESS_HOSTNAME using docker login ..."
#docker login -u $HARBOR_USER -p $HARBOR_PWD $INGRESS_HOSTNAME

## clone repo
echo -e "\n\n > Clone steakfulset-controller to /tmp/steakfulset-controller ..."
git clone https://github.com/MrBatschner/steakfulset-controller.git ${REPO_DIR}

## build and push fortune cookies
#echo -e "\n\n > Building Fortune Cookies Docker Image ..."
#docker buildx build --platform linux/amd64 -t $INGRESS_HOSTNAME/library/steakfulset-controller:latest -f ${REPO_DIR}/Dockerfile --push ${REPO_DIR}

## patch helm chart values
#sed -i -e "s/thbb\/steakfulset-controller/${INGRESS_HOSTNAME}\/library\/steakfulset-controller/" ${REPO_DIR}/charts/steakfulset-controller/values.yaml

## push helm chart
echo -e "\n\n > Bundling and pushing helm chart as OCI artifact ..."
helm registry login $INGRESS_HOSTNAME -u $HARBOR_USER -p $HARBOR_PWD
helm package ${REPO_DIR}/charts/steakfulset-controller
helm push steakfulset-controller-0.1.0.tgz oci://${INGRESS_HOSTNAME}/library

## clean up
rm -rf ${REPO_DIR}
#docker logout $INGRESS_HOSTNAME
#docker buildx rm ${BULDER}
rm steakfulset-controller-0.1.0.tgz