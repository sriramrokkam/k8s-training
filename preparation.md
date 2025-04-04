# Environment Setup and Prerequisites

This page describes the necessary **preparation steps** before the course and as well what you should fulfill as **prerequisites** before taking this course - with points to sources for that information.

## Environment setup

During this course we will ask you to work with different tools using command line interfaces. You may refer to below opetions:

### Option A - use your local machine

#### Windows

Since Windows 10 (ish), there is a possibility of enabling the Windows Subsystem for Linux (WSL2).

- For SAP specifics about WSL, please see the related [IT support KB article](https://itsupportportal.services.sap/itsupport?id=kb_article_view&sysparm_article=IKB0013525&sysparm_published=true) (There used to be a problem with WSL and SAP's McAfee, but we are not using McAfee anymore...)
- Follow [this guide](https://documentation.ubuntu.com/wsl/en/latest/howto/install-ubuntu-wsl2/) to enable WSL2 and install Ubuntu
- Follow [this guide](https://docs.docker.com/desktop/features/wsl/) to install Docker Desktop on top of WSL2 (requires a paid license that will be automatically issued to you if the software is detected on your PC). 
  - You may also install only the Docker Engine (community edition) for free directly on the Linux OS (see [Docker documentation](https://docs.docker.com/engine/install/)). 
  - You can also try [Podman Desktop](https://podman-desktop.io/) which is free and open-source. Even though Podman is a drop-in replacement for Docker, Docker is preferred as the exercises are based on it. Installation instructions for Podman on Windows are [here](https://github.com/containers/podman/blob/main/docs/tutorials/podman-for-windows.md),
- Run [this script](training-vm.md#if-you-are-running-a-wsl-on-windows-11) in WSL to install some basics binaries. You may instead install the binaries manually (and on Windows if you want)
  - [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
  - [helm](https://helm.sh/docs/intro/install/)
- Install [Visual Studio Code](https://code.visualstudio.com/) on Windows 11

#### Mac

No matter the your CPU (ARM64 Mac (Apple Silicon) or Intel), you will need to install the following

- A text editor: use the editor that you feel most comfortable with (please do not consider Notepad) - if you do not have favorite text editor yet, you might want to give [Visual Studio Code](https://code.visualstudio.com/) a try
- A container runtime: 
  - You can get Docker Desktop Business (it requires a paid license that must be purchased from Ariba) 
  - Or you can try [Podman Desktop](https://podman-desktop.io/) which is free and open-source. Installation instructions for MacOS are [here](https://podman.io/docs/installation#macos). Even though Podman is a drop-in replacement for Docker, Docker is preferred as the exercises are based on it.
- Some binaries
  - [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
  - [helm](https://helm.sh/docs/intro/install/)

### Option B -  Use a virtual machine

You can use a Linux virtual machine to run kubectl and a container runtime. Use the Linux distribution of your preferred choice and set up the VM yourself. 

|  Host OS|   Description |Reference  | 
| :---         | :---     | :---     |
|Windows| You may installVMware Player / workspace. However, if you want to use it, you'll have to request a licence. | See [this documentation](./training-vm.md#about-vmware-workstationplayer) |
|MacOS| Run an open-source [UTM app](https://getutm.app/):<br>- `docker community edition`: install on UTM VM<br>- `kubectl` commandline tool: install on UTM VM<br>- `vscode`: install on UTM VM |1. Refer to [this document](training-vm.md#mac) for UTM installation & Virtual Machine deployment<br>2. Run [this script](training-vm.md#if-you-are-running-an-utm-vm-on-macos) in UTM VM for `docker community edition`, `kubectl` commandline tool & `Visual Studio Code` installation on UTM VM|

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
