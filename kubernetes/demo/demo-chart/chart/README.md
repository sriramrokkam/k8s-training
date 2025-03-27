# Helm Chart Values

The following values are available for configuration:

```yaml
image:
  # the repository where the image is stored
  repository: ""
  # specify the image pull behavior
  pullPolicy: IfNotPresent
  # use the tag to pull a specific image
  tag: ""
  # use the digest to pull a specific image, if both are specified, the digest will be used
  digest: ""

# reference a secret to use for image pulling
imagePullSecrets: []
# - name: secretName

# specify which service account to use
serviceAccountName: chaoskube
# the chart contains RBAC roles & bindings, set this to true to create them
rbac:
  create: false

# kube-terminator configuration
configuration:
  # dry run mode
  talkToTheHand: true
  # interval to check for pods to delete
  interval: "1m"
  # select specific pods by their labels e.g. foo=bar
  labelSelector: ""
```

