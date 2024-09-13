# Docker and Kubernetes Fundamentals  

This is the repo for the "Docker & Kubernetes Fundamentals" course. Gain basic Docker knowledge and learn to orchestrate your containers with Kubernetes. Get started with Docker and run your first container as well as build custom Docker images. When working with Kubernetes you will get to know the common entities in Kubernetes and apply your knowledge during exercises.
For an overview of topics see the agenda pages on top level.

## How to Register

- Check for [available classes in SuccessMap Learning](https://performancemanager5.successfactors.eu/sf/learning?destUrl=https%3A%2F%2Fsap%2eplateau%2ecom%2Flearning%2Fuser%2Fdeeplink%5fredirect%2ejsp%3FlinkId%3DITEM%5fDETAILS%26componentID%3DDEV%5fCC%5fPA%5fKuber%5f1803%5fILT%26componentTypeID%3DCOURSE%26revisionDate%3D1521715320000%26fromSF%3DY&company=SAP)
- If there is no class that matches your region or available dates, [register in the interest group](https://fiorilaunchpad.sap.com/sites#my-events&/ig=10301003) to get notified when new classes get scheduled

**Cancellation Policy:**
Cancellation is possible until 1 week (5 working days) before training start. If later, a clear reason must be provided. No shows will be charged EUR 1000. Incomplete attention (missing parts of 4-16 hours) will be charged EUR 300. Missing more than 50% will be considered a no-show.

## Course Outline
High level topics are:

### [Why Docker & Kubernetes?](./00_why_docker_k8s.pptx)

### [Docker](./docker) (day 1)
- Linux building blocks: containers under the hood ([slides](./docker/01_Basics_of_containers.pptx))
- Container lifecycle ([slides incl. exercises](./docker/02_Container_Lifecycle.pptx))
- Image lifecycle and Dockerfiles: ([slides](./docker/03_Image_Lifecycle.pptx), [exercise 1](./docker/Exercise_1_Dockerfiles.md) & [exercise 2](./docker/Exercise_2_Multistage_Dockerfiles.md))
- Working locally ([slides](./docker/04_Working_locally.pptx) & [exercise 3](./docker/Exercise_3_Ports_Volumes.md))

### [Kubernetes](./kubernetes) (day 2+3+4)
- Introduction ([slides](./kubernetes/00_intro.pptx))
- Components of a Kubernetes cluster ([slides](./kubernetes/01_k8s_core_components.pptx) & [exercise 1](./kubernetes/exercise_01_kubectl_basics.md))
- Scheduling of workloads with
    - `Pods` ([slides](./kubernetes/02_pods.pptx) & [exercise 2](./kubernetes/exercise_02_create_pod.md))
    - `Deployments`  ([slides](./kubernetes/03_labels_and_deployments.pptx) & [exercise 3](./kubernetes/exercise_03_deployment.md))
- Networking in Kubernetes with services ([slides](./kubernetes/04_networking_services.pptx) & [exercise 4](./kubernetes/exercise_04_services.md))
- Storage API in Kubernetes ([slides](./kubernetes/05_persistence.pptx) & [exercise 5](./kubernetes/exercise_05_persistence.md))
- Basic troubleshooting ([slides](./kubernetes/06_troubleshooting.pptx))
- Configure applications with `ConfigMaps` and `Secrets` ([slides](./kubernetes/07_configmap_secrets.pptx) & [exercise 6](./kubernetes/exercise_06_configmaps_secrets.md))
- Expose applications via `Ingress` ([slides](./kubernetes/09_ingress.pptx) & [exercise 7](./kubernetes/exercise_07_ingress.md))
- Run stateful applications with `StatefulSets` ([slides](./kubernetes/10_statefulset.pptx) & [exercise 8](./kubernetes/exercise_08_statefulset.md))
- Service accounts, RBAC, resource consumption, security policies, network policies ([slides part 1](./kubernetes/11_1_accessControll_and_resourceConsumption.pptx), ([slides part 2](./kubernetes/11_2_security.pptx), & [exercise 9](./kubernetes/exercise_09_network_policy.md))
- Introduction to jobs, scheduling, image pulling and extensibility concepts in K8s [slides](./kubernetes/11_3_morePods_Sheduling.pptx)
- Introduction to Gardener ([slides](./kubernetes//11_4_Gardener.pptx)
- Deploy packaged applications with Helm ([slides](./kubernetes/12_helm.pptx) & [exercise 10](./kubernetes/exercise_10_helm_basics.md))
- [fortune cookies](./sample-app/README.md) - apply the learned concepts and build + deploy a sample application

## Preparation and Setup

Follow the instructions on the page [Prerequisites and Environment Setup](preparation.md).

## Alternative Learning Resources

Classroom training is not your cup of tea? Check out the [list of alternative learning resources](./alternative_learning_resources.md).

## Trainers and Course developers

* As trainer please check out the [Trainer Guide](./admin/trainer-guide.md) in advance to the training.
* Check out our [trainer badges](./admin/badges.md)
* The VM to be used by participants is built here: https://github.wdf.sap.corp/cloud-native-dev/Cloud-Curriculum-VM

**Interested in becoming a trainer as well?** 

Check out this [page](./admin/becoming_a_trainer.md) to find out more :bulb:
