# Helm Demo

## Preparations

Run the [script](../../../admin/exercise_prep/kube-terminator.sh) to build the container image and push both image and helm chart to harbor.

Create a few pods in the target namespace with a deployment.

## Values

In order to deploy the helm chart, you need to provide the following values in a `custom-values.yaml` file.

```yaml
serviceAccountName: chaoskube
rbac:
  create: false # set to true when using a namespace that was not prepared for the training
```

## Deploy

Install the chart using the oci reference.

```bash
GARDENER_PROJECTNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f3)
GARDENER_CLUSTERNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f2)
INGRESS_HOSTNAME=h.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com

helm install terminator  oci://${INGRESS_HOSTNAME}/library/kube-terminator --version 0.1.0 -f custom-values.yaml
```