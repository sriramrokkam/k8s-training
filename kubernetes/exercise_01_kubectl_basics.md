# Exercise 1 - kubectl basics

In this exercise you will learn how the command line interface (CLI) `kubectl` can be used to communicate with the Kubernetes cluster ([kubectl documentation](https://kubernetes.io/docs/reference/kubectl/overview/)).

## Step 0: check your environment

### Scenario 1 - use the training VM

**This is highly recommended for Windows users**

Login to your VM and locate the kubectl binary by running `which kubectl`. The result should return the path to the binary.

Run the following commands, to download your personal `kubeconfig`. Replace _<training_id>_ , _<participant_id>_ and _\<password>_ with the values that have been given to you by your trainer.

```bash
~/setup/get_kube_config.sh <training_id> <participant_id> <password>
```

Run `kubectl config get-contexts` to ensure a configuration file is available and/or `kubectl version` to test you can connect to the cluster. If you face any issue try to re-run the script and make sure the file `~/.kube/config` exist and is not empty.

In case you are running things locally on your machine (without the VM): The `get_kube_config.sh` script is also part of the training repository which you have cloned. When executing it, the script will check, if `~/.kube/config` already exists and if this is the case create a new file `<training_name>.config` in your `~/.kube` directory (to prevent overwriting any existing configuration).

### Scenario 2 - use a local environment

**This will work only with a local bash environment like on MacOS or WSL**

While using the VM makes life for your trainers easier (one standardized environment), it is very well possible to do the Kubernetes exercises on you local machine.
In case you want to go this way, please install `kubectl` for your platform as [described here](https://kubernetes.io/de/docs/tasks/tools/install-kubectl/) and clone the training repository locally.

```bash
cd <some_path_you_want_to_clone_to>
git clone https://github.tools.sap/kubernetes/docker-k8s-training.git
```

To download the credentials file to access the cluster, please run the `get_kube_config.sh` script located in our [repository](./get_kube_config.sh).
Run the following commands, to download your personal `kubeconfig`. Replace _<training_id>_, _<participant_id>_ and _\<password>_ with the values that have been given to you by your trainer.

```bash
cd <cloned_training_repository>/kubernetes
./get_kube_config.sh <training_id> <participant_id> <password>
```

Run `kubectl config get-contexts` to ensure a configuration file is available and/or `kubectl version` to test you can connect to the cluster. If you face any issue try to re-run the script and make sure the file `~/.kube/config` exist and is not empty.

## Step 1: check the nodes

Use the `kubectl get nodes` command to get the basic information about the clusters' nodes. Try to find out, how the output can be modified. Hint: use the `-o <format>` switch. More information can be found by appending `--help` to your command.

## Step 2: get detailed information about a node

Now that you know the cluster's node names, query more information about a specific node by running `kubectl describe node <node-name>`. What is the `kubelet` version running on this node and which pods are running on this node?

## Step 3: kubectl proxy

The `kubectl proxy` command allows you to open a tunnel to the API server and make it available locally - usually on `localhost:8001` / `127.0.0.1:8001`. When you want to explore the API, this is an easy way to gain access.

Run the proxy command in a new terminal window and open `localhost:8001/api/v1` in your (VM's) browser. The API path is important here, since you are only allowed to access certain parts of the API. Just opening `localhost:8001` will return an error. Traverse through the `api/v1/` tree and search for the cluster nodes.

## Step 4: api-versions & api-resources

Dealing with the API directly can be cumbersome. If you want to get an overview of existing APIs, `kubectl` offers the `api-versions` command. Give it a try and compare the output with APIs you found in step 3.

Next, run `kubectl api-resources`. It is even more convenient and lets you discover resource types available in your cluster. In addition, the output contains short names for various resources. Can you find the short name for the `nodes` resource? And can you `describe` a node using the short name notation?

## optional Step 5: if it is an API, I can curl it

There will be scenarios, where you want to interact with the Kubernetes API directly from within your application. Instead of compiling `kubectl` into everything, you can simply send HTTP requests to the cluster's API server. Of course, there are SDKs and client libraries available, but in the end everything boils down to an HTTP request.
In this step of the exercise, you will send an HTTP request directly to the cluster asking for the available nodes. Instead of `kubectl` you will use the program `curl`.

To figure out, how `kubectl` converts your query into HTTP requests, run the command from step 1 again and add a `-v=9` flag to it. This increases the verbosity of `kubectl` drastically, showing you all the information you need. Go through the command's output and find the correct curl request.

Before you continue, make sure `kubectl proxy` is running and serving on `localhost:8001`. Now modify the request to be sent via the proxy. Since the proxy has already taken care of authentication, you can omit the bearer token in your request.

Hint: if the output is not as readable as you expect it, consider changing the accepted return format to `application/yaml`.

## optional Step 6 - learn some tricks

There is a forum-like page hosted by K8s with lots of information around `kubectl` and how to use it best. If you are curious, take a look at <https://discuss.kubernetes.io/t/kubectl-tips-and-tricks/>.

## Further information & references

* Manage multiple clusters and multiple config files: <https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/ >
* kubectl command documentation: <https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands>
* a small [gist](https://github.wdf.sap.corp/gist/D051945/3f3daf9f71f7e012c1e25a48c1c6e8da) with bash function to manage multiple config files
* shell autocompletion (should work for the VM already): <https://kubernetes.io/docs/tasks/tools/install-kubectl/#enabling-shell-autocompletion>
* kubectl cheat sheet: <https://kubernetes.io/docs/reference/kubectl/cheatsheet/>
* jsonpath in kubectl: <https://kubernetes.io/docs/reference/kubectl/jsonpath/>
