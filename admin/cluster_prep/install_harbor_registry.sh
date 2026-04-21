#!/bin/bash

HELM_RELEASE_NAME=harbor-registry
REGISTRY_USER=harbor
REGISTRY_PASS="GkPxKfTMse83TEcZhZe4qjaH"
PARTICIPANT_PASS="2r4!rX6u5-qH"
ADMIN_PASSWD="82rUHSy98xbZztm5MjLJ7Nf6"
OWN_DIR="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")"

CURL_WAIT=5

# check if we have a working kubectl ready
[ -z "$KUBECTL" ] && KUBECTL=$(which kubectl 2> /dev/null)
if [ -z "$KUBECTL" -o ! -x "$KUBECTL" ]; then
        echo "kubectl could not be found, download it from https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl"
        exit 3
fi

# try to access the cluster, if it is not working, we exit
${KUBECTL} get nodes &> /dev/null
RC=$?
if [ $RC -ne 0 ]; then
        echo "ERROR: Unable to get the nodes of your cluster ('kubectl get nodes' returned with RC $RC)."
        echo "       Check that your kube.config is correct and points to the correct cluster."
        exit 4
fi

# check if we have a working helm ready
[ -z "$HELM" ] && HELM=$(which helm)
if [ -z "$HELM" -o ! -x "$HELM" ]; then
        echo "Cannot find or execute helm. Download it from https://helm.sh/docs/intro/install/."
        exit 3
fi

# try to access the cluster, if it is not working, we exit
${HELM} list &> /dev/null
RC=$?
if [ $RC -ne 0 ]; then
        echo "ERROR: helm does not work currently."
        echo "       Please make sure helm is installed & has required permissions to access the cluster."
        exit 4
fi

# check if we have htpasswd installed
if [ -z "$(which htpasswd)" ]; then
        echo "htpasswd could not be found. Please install it with 'apt install apache2-utils'.".
        exit 5
fi

# construct ingress hostname string
GARDENER_PROJECTNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f3)
GARDENER_CLUSTERNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f2)

INGRESS_HOSTNAME=h.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com

echo -e "\n > Using ingress hostname $INGRESS_HOSTNAME..."
echo -e "\n >> Deploying Harbor with custom values (this can take up to 5 minutes)...\n"

_passwd=$(htpasswd -nbBC10 $REGISTRY_USER $REGISTRY_PASS)
REGISTRY_URL=$(echo $INGRESS_HOSTNAME | tr [:upper:] [:lower:])

kubectl create ns harbor-registry

helm repo add harbor https://helm.goharbor.io
helm upgrade -i --wait -n harbor-registry -f $OWN_DIR/harbor-values.yaml \
	--set expose.ingress.hosts.core=$REGISTRY_URL \
        --set-string 'expose.ingress.annotations.dns\.gardener\.cloud/dnsnames'="$REGISTRY_URL" \
	--set externalURL="https://${REGISTRY_URL}" \
	--set registry.credentials.username=$REGISTRY_USER \
	--set registry.credentials.password=$REGISTRY_PASS \
	--set registry.credentials.htpasswd=$_passwd \
	--set harborAdminPassword=$ADMIN_PASSWD \
	$HELM_RELEASE_NAME harbor/harbor

echo -e "\n >> Waiting for Harbor API to become ready...\n"
HARBOR_READY_MAX_RETRIES=30
HARBOR_READY_RETRY_INTERVAL=10

for ((i=1; i<=HARBOR_READY_MAX_RETRIES; i++)); do
        if curl --insecure --silent --show-error --fail "https://$REGISTRY_URL/api/v2.0/ping" > /dev/null; then
                echo "Harbor API is reachable and ready for configuration."
                break
        fi

        if [ $i -eq $HARBOR_READY_MAX_RETRIES ]; then
                echo "ERROR: Harbor API at https://$REGISTRY_URL did not become ready after $((HARBOR_READY_MAX_RETRIES * HARBOR_READY_RETRY_INTERVAL)) seconds."
                exit 1
        fi

        echo "Harbor API not ready yet (attempt $i/$HARBOR_READY_MAX_RETRIES). Retrying in ${HARBOR_READY_RETRY_INTERVAL}s..."
        sleep $HARBOR_READY_RETRY_INTERVAL
done

AUTH_TOKEN=$(echo -n "admin:$ADMIN_PASSWD" | base64)

# create user participant
curl --insecure -X POST "https://$REGISTRY_URL/api/v2.0/users" -H "Authorization: Basic $AUTH_TOKEN" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"username\": \"participant\", \"password\": \"$PARTICIPANT_PASS\", \"realname\": \"participant\", \"admin_role_in_auth\": false, \"sysadmin_flag\": false, \"email\": \"participant@training.sap\" }"

sleep $CURL_WAIT

# create project training
curl --insecure -X POST "https://$REGISTRY_URL/api/v2.0/projects" -H "Authorization: Basic $AUTH_TOKEN" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"project_name\": \"training\", \"storage_limit\": 0, \"public\": false }"

sleep $CURL_WAIT

# get project ID
TRAINING_PROJECT_ID=`curl --insecure -s -X GET "https://$REGISTRY_URL/api/v2.0/projects" -H "Authorization: Basic $AUTH_TOKEN"  -H "accept: application/json"  | jq '.[] | select(.name == "training") | .project_id'`

sleep $CURL_WAIT

# assign user 'participant' to project 'training' with developer role
curl --insecure -X POST "https://$REGISTRY_URL/api/v2.0/projects/${TRAINING_PROJECT_ID}/members" -H "Authorization: Basic $AUTH_TOKEN" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"role_id\": 2, \"member_user\": {\"username\": \"participant\" }}"

sleep $CURL_WAIT

# create project demo
curl --insecure -X POST "https://$REGISTRY_URL/api/v2.0/projects" -H "Authorization: Basic $AUTH_TOKEN" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"project_name\": \"demo\", \"storage_limit\": 0, \"public\": false }"

sleep $CURL_WAIT

# get project ID
DEMO_PROJECT_ID=`curl --insecure -s -X GET "https://$REGISTRY_URL/api/v2.0/projects" -H "Authorization: Basic $AUTH_TOKEN"  -H "accept: application/json"  | jq '.[] | select(.name == "demo") | .project_id'`

sleep $CURL_WAIT

# assign user 'participant' to project 'demo' with limited guest role
curl --insecure -X POST "https://$REGISTRY_URL/api/v2.0/projects/${DEMO_PROJECT_ID}/members" -H "Authorization: Basic $AUTH_TOKEN" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"role_id\": 5, \"member_user\": {\"username\": \"participant\" }}"


# Adding nginx image to the registry for the image pull secret demo
docker pull --platform linux/amd64 nginx:latest
docker tag nginx:latest $REGISTRY_URL/demo/nginx:latest
docker login $REGISTRY_URL -u admin -p $ADMIN_PASSWD
docker push $REGISTRY_URL/demo/nginx:latest --platform linux/amd64
docker logout $REGISTRY_URL

echo -e "\n\nRegistry is available at https://$REGISTRY_URL"
echo -e "Login as admin:$ADMIN_PASSWD\n"
echo -e "Participant username: participant\n"
echo -e "Participant password: $PARTICIPANT_PASS\n"
