# Further Reading/Watching

If you would like to get some more information on Docker and/or Kubernetes inside and outside of SAP, we would like to share some links with you.

## Docker & Containers

- Old - but still valid: Our talk about the absolute container basics at SAP's *devX* event: [Container 101](https://video.sap.com/media/t/1_gxz1oox7/84675141)

- The Dockerfile reference can be found on Docker's website: [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/) and [Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

- Read about [containerd](https://containerd.io/).

- Container runtime details: <https://iximiuz.com/en/posts/conman-the-container-manager-inception/>

- Docker [security](https://docs.docker.com/engine/security/) and [cgroups v2 in runC](https://github.com/opencontainers/runc/blob/43186447b99c81d7e12876dc8277e2f6fd538850/docs/cgroup-v2.md)

- building images without docker is possible with [kaniko](https://github.com/GoogleContainerTools/kaniko)

- mutli-arch images with [docker buildx](https://github.com/docker/buildx)

- resource management with Docker - [how to limit a container's resources](https://docs.docker.com/config/containers/resource_constraints)

- If you are looking for incredibly slim container base images, have a look at Google's [distroless images](https://github.com/GoogleContainerTools/distroless).

- [sap-tech-docker on Slack](https://sap-ti.slack.com/archives/C86FTS4DN) covering Docker-related topics

### Alternatives

- Colima: <https://github.com/abiosoft/colima>
- Podman: <https://podman.io>

### SAP specific

- Internal Artifactory Repository Services: <https://pages.github.tools.sap/Common-Repository/Artifactory-Corp/>
- External Artifactory Repository Services: <https://pages.github.tools.sap/Common-Repository/Artifactory-Internet-Facing/contactSupport/>

## Kubernetes

### @SAP: Gardener

- First of all: SAP offers an internal Kubernetes platform offering that is called Project Gardener. If you need a Kubernetes environment, this is the place to go: [Gardener](https://https://gardener.cloud.sap/)
- Getting started with Gardener: <https://pages.github.tools.sap/kubernetes/gardener/docs/getting-started/>
- Gardener is an open source project and can be found on [github.com](https://github.com/gardener/gardener/).
- What the heck is Gardener? [Part 1](https://sap.sharepoint.com/:v:/r/sites/201292/Recordings/What%20the%20Heck%20is%20Gardener_Part%201.mp4?csf=1&web=1&e=2NQvJ1) & [Part 2](https://sap.sharepoint.com/:v:/s/201292/EUtYrZ-9EQ1BrTN8awFHS6IBUDpo457A_bdDW697gnFWrQ?e=n3lANA)
- [My workloads failed - a Kubernetes murder mystery](https://video.sap.com/media/t/1_9y1u6rf1) (advanced)

### Slack Channels at SAP

- [sap-tech-gardener](https://sap-ti.slack.com/archives/C9CEBQPGE)
- [sap-tech-kubernetes](https://sap-ti.slack.com/archives/C8R3WAGKB)
- [sap-k8s-operators](https://sap-ti.slack.com/archives/CGULAG57C)

### in general

- Do you want to watch Kelsey Hightower, one of the big brains behind Kubernetes play Tetris on the Jumbotron at d-Kom 2018 at SAP Arena? Check out [his keynote](https://broadcast.co.sap.com/event/dkom/2018#!video%2F18106).

- the Cloud Native Computing Foundation publishes KubeCon talks on their [youtube channel](https://www.youtube.com/channel/UCvqbFHwN-nwalWPjPUKpvTA)

- The Kubernetes API reference can be found here: [Kubernetes API reference Documentation](https://kubernetes.io/docs/reference/).

- getting started locally - with [minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/), [k3s](https://k3s.io/) or [kind](https://kind.sigs.k8s.io/)

### kubectl

- Running `kubectl completion` guides you how to setup shell completion.

- [kubectl plugins](https://kubernetes.io/docs/tasks/extend-kubectl/kubectl-plugins/) can be managed with [krew](https://krew.sigs.k8s.io). It is a convenient way to get essentials like [oidc support](https://github.com/int128/kubelogin) or a [command](https://github.com/corneliusweig/ketall) that actually perfoms a `get all`.

To work with multiple namespaces or even clusters, [kubectx and kubens](https://github.com/ahmetb/kubectx) get you started. Other tools like [kubeswitch](https://github.com/danielfoehrKn/kubeswitch) offer similar solutions.

- If you need to gather and combine the logs from several pods belonging to a deployment, you might want to have a look at [kubetail](https://github.com/johanhaleby/kubetail).

- [kubectl efficiency](https://www.youtube.com/watch?v=vVAFctQP1Vg&list=PLj6h78yzYM2NDs-iu8WU5fMxINxHXlien&index=12&t=0s)

### networking

- More on details about networking? The [Life of a Packet](https://www.youtube.com/watch?v=0Omvgd7Hg1I) talk by Google's Michael Rubin at KubeCon EU '17 can be found [here on YouTube](https://www.youtube.com/watch?v=0Omvgd7Hg1I).

- If you are more into doing things - there is a [kubeCon2020 tutorial](https://www.youtube.com/watch?v=InZVNuKY5GY&list=PLj6h78yzYM2O1wlsM-Ma-RYhfT5LKq0XC&index=16&t=0s) digging into it.

- SE radio: [container networking talk](http://www.se-radio.net/2018/10/se-radio-episode-341-michael-hausenblas-on-container-networking/)

- [Envoy](https://kubernetespodcast.com/episode/033-envoy/), with Matt Klein

### Writing your own controllers

- [kubebuilder](https://github.com/kubernetes-sigs/kubebuilder) is a tool which helps creating API extensions including their controller/reconcile loops. There is also a pretty [detailed example](https://book.kubebuilder.io/introduction.html) how to use it.

- [Controllers at scale](https://medium.com/@timebertt/kubernetes-controllers-at-scale-clients-caches-conflicts-patches-explained-aa0f7a8b4332) explains in more details, how the internals of a controller work and what you should have in mind, when writing your own controller.

- [Kubernetes Clients in Gardener](https://github.com/gardener/gardener/blob/master/docs/development/kubernetes-clients.md) - is a great overview / introduction to the various clients and their capabilities. It's also something that has to proven to work :)

- The [kubelet pattern](https://github.tools.sap/NewHorizon/LifecycleManagement/blob/master/KubeletPattern.md) gives an outlook, how a Kubernetes based architecture could evolve.

- [Programming Kubernetes](https://programming-kubernetes.info/) is an awesome book, if you really want to get started. There is also [sample code on github](https://github.com/programming-kubernetes).

### Security

- [SAPwned: SAP AI vulnerabilities expose customers’ cloud environments and private AI artifacts](https://www.wiz.io/blog/sapwned-sap-ai-vulnerabilities-ai-security)

- [Three Years of Lessons Running Potentially Malicious Code Inside Containers](https://www.youtube.com/watch?v=kbPEE33HEHw) - Ben Hall, Katacoda

- [root container](https://www.youtube.com/watch?v=ltrV-Qmh3oY&feature=youtu.be) @KubeCon by Liz Rice

- secret management with [sealed-secrets](https://github.com/bitnami-labs/sealed-secrets) or [vault](https://www.vaultproject.io/docs/what-is-vault/index.html).

- [Identity federation with OIDC in Kubernetes](https://community.sap.com/t5/open-source-blogs/kubernetes-cross-cluster-communication-ditching-long-lived-credentials/ba-p/13550286)

### SAP Kubernetes Summits

- Slides and recordings from all the sessions at SAP's first Kubernetes Summit 2019 in Walldorf/Rot, Germany can be found in [Jam](https://jam4.sapjam.com/blogs/show/rW4XILnu81NbcUpiMQWWuu)

## Helm

- overview of available charts: https://artifacthub.io
- legacy charts: <https://github.com/kubernetes/charts/tree/master/stable>
- official documentation: <https://docs.helm.sh/>
  - Cheat Sheet: https://helm.sh/docs/intro/cheatsheet/
  - Writing a chart: https://helm.sh/docs/chart_template_guide/getting_started/
- Alternative: https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/

## SAP specific security aspects

- [container reference architecture security procedure](https://wiki.wdf.sap.corp/wiki/x/HkxOcQ)
- [Docker security procedure](https://wiki.wdf.sap.corp/wiki/x/Uk8GcQ)
- [Security approved container base images](https://wiki.wdf.sap.corp/wiki/x/UYYRd)
- [Kubernetes Container Orchestration - Hardening](https://wiki.wdf.sap.corp/wiki/x/KCNfc)

## General

- Brendan Burns, Distinguished Engineer at Microsoft and Chief Architect behind the container infrastructure within Azure released one of his books on distributed software design for free: [Designing Distributed Systems](https://azure.microsoft.com/en-us/resources/designing-distributed-systems/)

- [katacoda learning platform](https://www.katacoda.com/learn) offers browser-based tutorials around docker & kubernetes  

- [CTO Circle – Container Delivery Guidance](https://sap.sharepoint.com/sites/60001485/Shared%20Documents/01_Communication/CTO%20Circle%20%26%20Technology%20Board%20Meetings/CTO%20Circle/Container%20Delivery_RELEASED.pdf?csf=1&e=THkcxG)

- [Cross Product Architecture - Containerization & Application Runtimes](https://sap.sharepoint.com/teams/CPAInfrastructure/Shared%20Documents/WG%20Containerization%20and%20Application%20Runtimes/20_Docs_and_Material/Containerization_and_Application_Runtimes_Vision_v1.0.pdf?cid=018cde89-49bc-4307-9cc8-623283c9e99e)

- [Cross Product Architecture - Business Technology Platform go-to runtimes](https://sap.sharepoint.com/:b:/r/teams/CPADeveloperExperience/Shared%20Documents/WG%20Cloud%20Development/20_Docs_and_Material/BTP%20Go-To%20Runtimes/SAP%20BTP%20Go-To%20Runtimes.pdf?csf=1&web=1&e=MxCS7I)
