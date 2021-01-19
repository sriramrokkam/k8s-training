# Setup a monitoring with promethes and grafana

In this folder you find scripts & yaml files to deploy a **monitoring system** based on [**Prometheus**](https://prometheus.io/) & **visualization** based on [**Grafana**](https://grafana.com/). We use the `prometheus-community/kube-prometheus-stack` ([details](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)) helm chart and install it with custom values.

**Prometheus** collects metrics from various endpoints such as the API server or kubelet. Data is stored as time series and can be queried via `prometheus-server`.

**Grafana** is used to run queries and visualize the results. Upon deployment we also import 2 predefined dashboards: 'Kubernetes cluster monitoring (via Prometheus)' and 'TrainingStats'. One provides information about the cluster state like memory or CPU usage. The other is more specific to the training. It shows the deployments, services or pod status per namespace or across all namespaces.

Grafana is exposed via an `ingress` resource, so make sure your cluster has a running ingress controller. When running with Gardener this prerequisite is already fulfilled.  

In it's current version, the helm chart values will be set in a way to instruct Gardener to provision a let's encrypt certificate for the ingress. Due to the long URL (more than 64 characters), there will be 2 hostnames. The first one has to have less than 64 characters to fit into the CN field and the 2nd will be written into the SAN field when requesting the certificates. Details can be found [here](https://gardener.cloud/050-tutorials/content/howto/x509_certificates/).

## step-by-step setup

### preparation
* check, that `kubectl` works with the cluster you intend to install the stack into
* If not yet done - setup `helm`. Use the `helm_init.sh` [script](../helm_init.sh) to carry out all required steps.

### Run the setup script
run `setup_monitoring.sh

The script will
  * construct a URL for Gardener ingress
  * create a namespace `monitoring`
  * deploy the chart `prometheus-community/kube-prometheus-stack` into the new namespace
  * request a let's encrypt certificate for the grafana ingress
  * create a configmap with the dashboard json files and import it to grafana

To access Prometheus, use port-forwarding e.g. `kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090`

To access Grafana use the hostname of the ingress and login with `admin`:`1noipsuNwfAxJAUV6Pns`.