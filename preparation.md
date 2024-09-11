# Environment Setup and Prerequisites

This page describes the necessary **preparation steps** before the course and as well what you should fulfill as **prerequisites** before taking this course - with points to sources for that information.

## Environment setup

During this course we will ask you to work with different tools using command line interfaces. We recommend you install the tools locally on your machine - continue reading about _Option A_.

### Option A - use your local machine

We actually encourage you to use your local machine directly to follow along with the training. You basically need three things to get along:

1. A text editor: use the editor that you feel most comfortable with (please do not consider Notepad) - if you do not have favorite text editor yet, you might want to give [Visual Studio Code](https://code.visualstudio.com/) a try
2. kubectl: this is the most important tool you need to talk to Kubernetes clusters and you will definitely need it for the training - download it from its website at <https://kubernetes.io/docs/tasks/tools/>
3. A container runtime: you can get Docker Desktop (it requires a paid license that must be purchased from Ariba) or you try [Podman Desktop](https://podman-desktop.io/) which is free and open-source. Installation instructions for Podman on Windows are [here](https://github.com/containers/podman/blob/main/docs/tutorials/podman-for-windows.md), for MacOS are [here](https://podman.io/docs/installation#macos). Even though Podman is a drop-in replacement for Docker, Docker is preferred as the exercises are based on it.

### Option B - use a virtual machine

You can use a Linux virtual machine to run kubectl and a container runtime. While we provided a dedicated VM image in the past, we nowadays encourage you to use the Linux distribution of your preferred choice and set up the VM yourself. Please refer to a the separate [`training-vm.md`](training-vm.md) file for more instructions.

## Clone

Please clone the training repository to your VM/local machine.

Due to SAP's security restrictions, you cannot simply clone the repository anonymously or with username/password. You have to create a personal access token instead. Please follow these [instructions](https://docs.github.com/en/enterprise-server@2.22/github/authenticating-to-github/creating-a-personal-access-token) and enter the token as password when prompted during cloning.

```
git clone --filter=blob:none https://github.tools.sap/kubernetes/docker-k8s-training.git
```

## Kubernetes cluster

For regular classroom trainings a Kubernetes cluster will be provided & configured centrally. However, if you wish to look into the training material on your own, you may check the Gardener [trial cluster](https://pages.github.tools.sap/kubernetes/gardener/docs/guides/sap-internal/scp-starting-with-k8s/before-start/get-account/) offering.

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
