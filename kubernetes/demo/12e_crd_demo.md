# `CustomResourceDefinition` Demo

## Prerequisites

Build the controller and publish both the image and the helm chart to harbor.
Use the script [steakfulset.sh](../../admin/exercise_prep/steakfulset.sh) for this.

## Install the helm chart to deploy the controller and CRDS

You can use the following snippet or fetch the instructions from Harbor's UI.

```bash
GARDENER_PROJECTNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f3)
GARDENER_CLUSTERNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f2)
INGRESS_HOSTNAME=h.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com

helm install steakfulset-controller  oci://${INGRESS_HOSTNAME}/library/steakfulset-controller --version 0.1.0
```

## Show the CRDs

```bash
kubectl get crd steakfulsets.food.k8s.training
kubectl get crd steaks.food.k8s.training
```

## Create a SteakfulSet Resource

Take the following snippet, adjust the number of guests and the variant to your preferences and deploy it.

```yaml
cat << EOF | kubectl apply -f -
apiVersion: food.k8s.training/v1alpha1
kind: SteakfulSet
metadata:
  name: team-barbecue
spec:
  guests: 3
  steak:
    spec:
      cookLevel: medium
      fat: lean
      variant: angus-rump
      weight: 250
EOF
```

## Show the result

By now, you should find a `steakfulset` resource as well as a certain number of `steaks` in your namespace. Show the `ownerReference` field.
Explain how the `ownerReference` field works and how the controller uses it to delete the steaks when the `steakfulset` is deleted.

Of course, the steakfulset-controller is just a pun on the well-known `StatefulSet` resource. But it helps to explain that K8s is extensible, and your controller defines the semantic meaning of a resource and what it represents to you.
