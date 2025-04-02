# Kube Terminator

A small utility to terminate pods in a Kubernetes cluster.

Parameters:
- `--namespace` (required): The namespace to target.
- `--kubeconfig` (optionsl): The path to the kubeconfig file to use. If not provided, it will attempt to build an in-cluster kubeconfig.
- `--interval` (optional): The time to wait between pod terminations. Defaults to `1m`.
- `--dry-run` (optional): Just print which pods would be terminated without actually deleting them. Defaults to `true`.
- `--selector` (optional): A label selector to filter the pods to terminate. Use something like `foo=bar`.
