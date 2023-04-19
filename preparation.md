# Environment Setup and Prerequisites

This page describes the necessary **preparation steps** before the course and as well what you should fulfill as **prerequisites** before taking this course - with points to sources for that information.

## Environment setup

During this course we will ask you to work with different tools using command line interfaces. To make this as easy as possible, we offer 2 paths:
- Using a prepared Linux VM (VMware based) - recommended option for Windows user
- Installing tools locally - recommended option for MacOS (mostly in cases where you have started using these tools already)

#### Option A - Using a VM
We prepared a Linux VM (Ubuntu based) that contains all the required tools.

Follow the instructions on the [Getting Started with the k8s training VM Image](https://github.wdf.sap.corp/cloud-native-dev/Cloud-Curriculum-VM/blob/master/Getting_Started_Running_KubernetesVM.md) page to install VMWare (VirtualBox= Blacklisted !) and download and configure the VM image.

Download the latest VM image from [here](https://objectstore-3.eu-de-2.cloud.sap:443/v1/AUTH_3c8352cd3ffd4aa1945d50133b40bef0/k8s-vm/k8s-trainings-vm-20230418-150102.ova).


#### Option B - Using your local machine
Please make to sure to have the following tools present and usable on your machine in order to prepare for the training:
- [docker desktop for MacOS](https://sap.sharepoint.com/sites/125351/SitePages/Docker.aspx) (get a license via Ariba Guided Buying)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)


### Clone
Please clone the training repository to you VM/lcoal machine.

Due to SAP's security restrictions, you cannot simply clone the repository anonymously or with username/password. You have to create a personal access token instead. Please follow these [instructions](https://docs.github.com/en/enterprise-server@2.22/github/authenticating-to-github/creating-a-personal-access-token) and enter the token as password when prompted during cloning.

```
git clone https://github.tools.sap/kubernetes/docker-k8s-training.git
```

## Kubernetes cluster
For regular classroom trainings a Kubernetes cluster will be provided & configured centrally. However, if you wish to look into the training material on your own, you may check the Gardener [trial cluster](https://github.wdf.sap.corp/pages/kubernetes/gardener/documentation/015-tutorials/content/howto/trial-account/) offering.

If you prefer to run everything locally, there is also a way to install [microk8s](https://microk8s.io/) within the VM. Check the [README](./microk8s/README.md) for details.

## Cheat Sheets
We have prepared a collection of basic commands which may be helpful during the training. Feel free to print the cheat-sheets for [docker](docker/Docker%20Cheat%20Sheet.docx) and [Kubernetes](kubernetes/cheat-sheet.md) and bring them along.

## Prerequisite knowledge

- **Linux:** You should have a basic knowledge of Linux. If you are not familiar with Unix/Linux, you can check out [Learn Unix in 10 Minutes](https://web.archive.org/web/20170704205748/https://FREEENGINEER.ORG/learnUNIXin10minutes.html) or [Introduction to Linux](http://tldp.org/LDP/intro-linux/html/index.html) or with a little more detail [Learn Linux in 5 Days](https://linuxtrainingacademy.com/wp-content/uploads/2016/08/learn-linux-in-5-days.pdf) (it actually takes a lot less time). There is also a very good [Linux Commandline Cheat Sheet](https://www.linuxtrainingacademy.com/wp-content/uploads/2016/12/LinuxCommandLineCheatSheet.pdf).
- **bash**: We will occasionally work with shell scripts, bash in particular, or at least have to read them. You can look e.g. look at this [Bash Scripting Tutorial](https://linuxconfig.org/bash-scripting-tutorial). 
- **vi**: Sometimes you will have to SSH into a container / remote machine where there is only vi available as editor. If you not familiar or rusty with vi, you can check out the [vi cheat sheet](https://github.tools.sap/kubernetes/docker-k8s-training/blob/master/resources/vi_cheat_sheet.pdf). We highlighted the most important commands.
- **yaml**: YAML (YAML Ain't Markup Language) is a human-readable data serialization language that is commonly used for configuration files. It is THE notation used in Kubernetes. See the [wikipedia article](https://en.wikipedia.org/wiki/YAML) or this [YAML cheat sheet](https://lzone.de/cheat-sheet/YAML).
- **small tools to know**: It would be good to know some small tools that we may use: apt-get, curl, wget, ...
- **networking basics**: You should know what IP addresses are, how subnetting works, what routes are good for and what happens if you forward a port. We started to prepare an overview [here](./resources/BasicNetworkKnowhow.md).
