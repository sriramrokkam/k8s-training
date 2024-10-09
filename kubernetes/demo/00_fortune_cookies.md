# Fortune Cookies Demo

**Note** The previously used sock shop demo is unmaintained and fairly old. Therefore, using the fortune cookies app seems to be more appropriate for the time being.

## Prepare the demo in advance

### Build the image
Building and uploading the image in advance will save some time and make the demo less complex / focus on the important part.

Run [fortune-cookies.sh](../../admin/exercise_prep/fortune-cookies.sh) to build and upload the image. Detailed information are available [here](../../admin/exercise_prep/README.md).

### Adapt the manifests 

Go to the solutions for the [sample app exercises](../../sample-app/solutions) and substitute the placeholders with actual labels:

- [image reference](../../sample-app/solutions/app-deployment.yaml)
- [cluster & project name for image pulling](../../sample-app/solutions/image-pull-secret.yaml)
- [hostname, cluster & project name for ingress](../../sample-app/solutions/app-ingress.yaml)

## Demo


### Deployment

Apply all the manifests at once: 

```shell
cd ./sample-app/solutions
kubectl apply -R -f .
```

### Things to show

There are quite a few things to highlight:

- running pods in a sense of "this is the app"
- the hostname of the ingress
- connect to the ingress URL
  - show the certificate in a browser (or run something like `openssl s_client -connect <hostname>.ingress.<cluster-name>.<project-name>.shoot.canary.k8s-hana.ondemand.com:443 -showcerts  | openssl x509 -text -noout`)
  - show defaulting to `https`
- describe the ingress resource, show the events and highlight different controllers acting to establish the desired state

### Cleanup

Deletion of everything is as simple as the creation of resources. Run the following command to dismantle the demo:

```shell
kubeclt delete -R -f .
```