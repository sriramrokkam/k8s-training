# Environment Setup and Prerequisites

This page describes the necessary **preparation steps** before the course and as well what you should fulfill as **prerequisites** before taking this course - with points to sources for that information.

## Environment setup

During this course we will ask you to work with different tools using command line interfaces. You may refer to below opetions:

### Option A - Use your local machine

#### Windows

Since Windows 10, there is a possibility of enabling the Windows Subsystem for Linux (WSL2).

- **Install WSL2** : Follow [this guide](https://documentation.ubuntu.com/wsl/en/latest/howto/install-ubuntu-wsl2/) to enable WSL2 and install Ubuntu
- **Install a container engine**: Follow [this guide](https://docs.docker.com/desktop/features/wsl/) to install Docker Desktop on top of WSL2 (requires a paid license that should be automatically issued to you if the software is detected on your PC). You can also buy the licence from [Ariba](https://s1-eu.ariba.com/gb/itemDetail/0090919184%2524%2524ALM_001088/catalog?realm=SAPGLOBAL) if you want to be sure.
  - You may also install only the Docker Engine (community edition) for free directly in WSL (aka Ubuntu) (see [Docker documentation](https://docs.docker.com/engine/install/)).
  - You can also try [Podman Desktop](https://podman-desktop.io/) which is free and open-source. Even though Podman is a drop-in replacement for Docker, Docker is preferred as the exercises are based on it.
- **Install required binaries**: Run [this script](training-vm.md#if-you-are-running-a-wsl-on-windows-11) in WSL to install some basics binaries. You may instead install the binaries manually (and on Windows if you want)
  - [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
  - [helm](https://helm.sh/docs/intro/install/)
  - [git](https://git-scm.com/downloads)
- **Install a text editor**: We recommend installing [Visual Studio Code](https://code.visualstudio.com/) on your Windows machine. However, feel free to install / use any text editor of your choosing.
  - Make sure you can open files from your Ubuntu (using the `code .` command for VScode, see [this documentation](https://code.visualstudio.com/docs/remote/wsl) for precise steps).
  - This class involves creating / editing a lot of files. Understanding how your text editor works before the class starts will benefit you.
- **Confirm that everything is installed**: Run the following commands to confirm that your setup is ready to go. As long as you don't get any errors, you should be good to go. If you have a problem that you can't seem to solve, contact your trainer(s).
  - `docker run hello-world` (or `podman run hello-world` if you installed podman)
  - `git --version`
  - `kubectl version`
  - `helm version`
- (Optional) **Install the Windows Terminal**: For a better experience with CLI in Windows, you might want to install the [Windows Terminal](https://learn.microsoft.com/en-us/windows/terminal/)
  - Run `wsl -d Ubuntu` to start a shell in the Ubuntu image that you previously installed.
- **Continue to [Clone the material](#clone-the-material)**

#### Mac (both CPU architectures (ARM or Intel) should work)

- **A text editor**: We recommend installing [Visual Studio Code](https://code.visualstudio.com/) on your machine. However, feel free to install / use any text editor of your choosing.
  - We recommand installing the `code` binary in order to open files/folders directly from your terminal. Follow [this documentation](https://code.visualstudio.com/docs/setup/mac#_launch-vs-code-from-the-command-line) to install the binary
  - This class involves creating / editing a lot of files. Understanding how your text editor works before the class starts will benefit you.
- **Install a container engine**: Follow [this guide](https://docs.docker.com/desktop/setup/install/mac-install/) to install Docker Desktop (requires a paid license that should be automatically issued to you if the software is detected on your PC). You can also buy the licence from [Ariba](https://s1-eu.ariba.com/gb/itemDetail/0090919184%2524%2524ALM_001088/catalog?realm=SAPGLOBAL) if you want to be sure.
  - You may also install only the Docker Engine (community edition, without GUI) for free (see [Docker documentation](https://docs.docker.com/engine/install/)). We recommend using [brew](https://brew.sh/) to install it: `brew install docker docker-buildx docker-compose`
  - You can also try [Podman Desktop](https://podman-desktop.io/) which is free and open-source. Even though Podman is a drop-in replacement for Docker, Docker is preferred as the exercises are based on it.
- **Install required binaries**
  
  We recommand using [brew](https://brew.sh/) to install and manage your packages
  - [kubectl](https://formulae.brew.sh/formula/kubernetes-cli) ([official doc](https://kubernetes.io/docs/tasks/tools/#kubectl))
  - [helm](https://formulae.brew.sh/formula/helm)  ([official doc](https://helm.sh/docs/intro/install/))
  - [git](https://formulae.brew.sh/formula/git) ([official doc](https://git-scm.com/downloads))
- **Confirm that everything is installed**: Run the following commands to confirm that your setup is ready to go. As long as you don't get any errors, you should be good to go. If you have a problem that you can't seem to solve, contact your trainer(s).
  - `docker run hello-world` (or `podman run hello-world` if you installed podman)
  - `git --version`
  - `kubectl version`
  - `helm version`
- (Optional) **Install the iterm2 terminal**: For a better experience with CLI in mac, you might want to install [iTerm2](https://iterm2.com/)
- **Continue to [Clone the material](#clone-the-material)**

### Option B -  Use a virtual machine

You can use a Linux virtual machine to run kubectl and a container runtime. Use the Linux distribution of your preferred choice and set up the VM yourself.

|  Host OS|   Description |Reference  | 
| :---         | :---     | :---     |
|Windows| You may install VMware Player / workspace. However, if you want to use it, you'll have to request a licence. | See [this documentation](./training-vm.md#about-vmware-workstationplayer) |
|MacOS| Run an open-source [UTM app](https://getutm.app/):<br>- `docker community edition`: install on UTM VM<br>- `kubectl` command line tool: install on UTM VM<br>- `vscode`: install on UTM VM |1. Refer to [this document](training-vm.md#mac) for UTM installation & Virtual Machine deployment<br>2. Run [this script](training-vm.md#if-you-are-running-an-utm-vm-on-macos) in UTM VM for `docker community edition`, `kubectl` commandline tool, `helm`, `git` & `Visual Studio Code` installation on UTM VM|

Run the following commands in your vm to confirm that your setup is ready to go. As long as you don't get any errors, you should be good to go. If you have a problem that you can't seem to solve, contact your trainer(s).

- `docker run hello-world` (or `podman run hello-world` if you installed podman)
- `git --version`
- `kubectl version --client`
- `helm version`

You can now continue to [Clone the material](#clone-the-material)

## Clone the material

Please clone the training repository to your VM/local machine/WSL.

Due to SAP's security restrictions, you cannot simply clone the repository anonymously or with username/password. You have to create a personal access token instead. Please follow these [instructions](https://docs.github.com/en/enterprise-server@2.22/github/authenticating-to-github/creating-a-personal-access-token) and enter the token as password when prompted during cloning.

```bash
git clone --filter=blob:none https://github.tools.sap/kubernetes/docker-k8s-training.git
```

## Kubernetes cluster

For regular classroom trainings, a preconfigured Kubernetes cluster will be provided. However, if you wish to look into the training material on your own, you may use a Gardener [trial cluster](https://pages.github.tools.sap/kubernetes/gardener/docs/guides/sap-internal/scp-starting-with-k8s/before-start/get-account/). However, the hand-on exercices might be more complex to do.

If you prefer to run everything locally, there is also a way to install [microk8s](https://microk8s.io/) within the VM. Check the [README](./microk8s/README.md) for details. However, the hand-on exercices might be more complex to do.

## Cheat Sheets

We have prepared a collection of basic commands which may be helpful during the training. Feel free to print the cheat-sheets for [docker](docker/Docker%20Cheat%20Sheet.docx) and [Kubernetes](kubernetes/cheat-sheet.md) and bring them along.

## Prerequisite knowledge

- **Linux:** You should have a basic knowledge of Linux. If you are not familiar with Unix/Linux, you can check out [Learn Unix in 10 Minutes](https://web.archive.org/web/20170704205748/https://FREEENGINEER.ORG/learnUNIXin10minutes.html) or [Introduction to Linux](http://tldp.org/LDP/intro-linux/html/index.html) or with a little more detail [Learn Linux in 5 Days](https://linuxtrainingacademy.com/wp-content/uploads/2016/08/learn-linux-in-5-days.pdf) (it actually takes a lot less time). There is also a very good [Linux Commandline Cheat Sheet](https://www.linuxtrainingacademy.com/wp-content/uploads/2016/12/LinuxCommandLineCheatSheet.pdf).
- **bash**: We will occasionally work with shell scripts, bash in particular, or at least have to read them. You can look e.g. look at this [Bash Scripting Tutorial](https://linuxconfig.org/bash-scripting-tutorial).
- **vi**: Sometimes you will have to SSH into a container / remote machine where there is only vi available as editor. If you not familiar or rusty with vi, you can check out the [vi cheat sheet](https://github.tools.sap/kubernetes/docker-k8s-training/blob/master/resources/vi_cheat_sheet.pdf). We highlighted the most important commands.
- **yaml**: YAML (YAML Ain't Markup Language) is a human-readable data serialization language that is commonly used for configuration files. It is THE notation used in Kubernetes. See the [wikipedia article](https://en.wikipedia.org/wiki/YAML) or this [YAML cheat sheet](https://lzone.de/cheat-sheet/YAML).
- **small tools to know**: It would be good to know some small tools that we may use: apt-get, curl, wget, ...
- **networking basics**: You should know what IP addresses are, how subnetting works, what routes are good for and what happens if you forward a port. We started to prepare an overview [here](./resources/BasicNetworkKnowhow.md).
