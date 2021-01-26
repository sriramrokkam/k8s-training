#!/bin/bash

## check prerequisites
NAMESPACE="monitoring"
HELM_PROMETHEUS_RELEASE_NAME="monitoring"
HELM_LOKI_RELEASE_NAME="logging"
ADMIN_PASSWD="1noipsuNwfAxJAUV6Pns"

# check if we have a working kubectl ready
[ -z "$KUBECTL" ] && KUBECTL=`which kubectl`
if [ -z "$KUBECTL" -o ! -x "$KUBECTL" ]; then
	echo "Cannot find or execute kubectl. Download it from https://kubernetes.io/docs/tasks/tools/install-kubectl/."
	exit 3
fi

# try to access the cluster, if it is not working, we exit
${KUBECTL} get nodes &> /dev/null
RC=$?
if [ $RC -ne 0 ]; then
	echo "ERROR: Unable to get the nodes of your cluster ('kubectl get nodes' returned with RC $RC)."
	echo "       Check that your kube.config is correct and points to the corrent cluster."
	exit 4
fi

# check if we have a working helm ready
[ -z "$HELM" ] && HELM=`which helm`
if [ -z "$HELM" -o ! -x "$HELM" ]; then
	echo "Cannot find or execute helm. Download it from https://helm.sh/docs/intro/install/."
	exit 3
fi

# try to access the cluster, if it is not working, we exit
${HELM} list &> /dev/null
RC=$?
if [ $RC -ne 0 ]; then
	echo "ERROR: helm does not work currently."
	echo "       Please make sure tiller is installed & has required premissions."
	exit 4
fi

# construct ingress hostname string
GARDENER_PROJECTNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f3)
GARDENER_CLUSTERNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f2)
INGRESS_HOSTNAME_SHORT=m.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com
INGRESS_HOSTNAME_LONG=training-monitoring.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com

if [ $(echo $INGRESS_HOSTNAME_SHORT | wc -m) -gt 64 ]; then
	echo "The short hostname for monitoring is longer than 64 chars!"
	echo "Certification of url will not work, please use a shorter cluster name!"
	exit 5
fi

## add chart repo
${HELM} repo add prometheus-community https://prometheus-community.github.io/helm-charts
${HELM} repo add grafana https://grafana.github.io/helm-charts
${HELM} repo update

# create a namespace for the monitoring
${KUBECTL} create ns $NAMESPACE

## prepare for grafana
${KUBECTL} -n $NAMESPACE create configmap monitoring-dashboards --from-file=./dashboards/loki.json --from-file=./dashboards/training_stats.json
${KUBECTL} -n $NAMESPACE label configmap monitoring-dashboards grafana_dashboard=1

# install Loki stack chart
echo "installing Loki helm chart and waiting until all pods are up and running..."
${HELM} install $HELM_LOKI_RELEASE_NAME grafana/loki-stack \
	--wait -n $NAMESPACE \
	--set loki.enabled=true \
	--set promtail.enabled=true \
	--set fluent-bit.enabled=false \
	--set grafana.enabled=false \
	--set grafana.sidecar.datasources.enabled=true \
	--set prometheus.enabled=false \
	--set filebeat.enabled=false \
	--set logstash.enabled=false

# install prometheus chart
echo "installing Prometheus helm chart and waiting until all pods are up and running..."

${HELM} install $HELM_PROMETHEUS_RELEASE_NAME prometheus-community/kube-prometheus-stack \
	--wait -n $NAMESPACE \
	-f prom-stack-values.yaml \
	--set grafana.adminPassword=$ADMIN_PASSWD \
	--set grafana.ingress.hosts[0]=$INGRESS_HOSTNAME_SHORT \
	--set grafana.ingress.hosts[1]=$INGRESS_HOSTNAME_LONG \
	--set grafana.ingress.tls[0].hosts[0]=$INGRESS_HOSTNAME_SHORT \
	--set grafana.ingress.tls[0].hosts[1]=$INGRESS_HOSTNAME_LONG

echo "Grafana Ingress Host: ${INGRESS_HOSTNAME_LONG}"

