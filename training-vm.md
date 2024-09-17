# Using a VM for the training

You can use a Linux virtual machine to run kubectl and a container runtime. While we provided a dedicated VM image in the past, we nowadays encourage you to use the Linux distribution of your preferred choice. If you do not know which one to choose, just go with [Ubuntu Desktop](https://ubuntu.com/desktop).

## Running and setting up the VM

### Windows

#### WSL2
For this training, we recommend using WSL2 as you can install the community edition of Docker and do not need to purchase any licenses. If you plan to use Docker on a daily basis, you might want to switch to the Docker Desktop version.

Checkout the official guide to setup your environment: https://learn.microsoft.com/en-gb/windows/wsl/install

WSL2 gets a virtual NIC and a different IP address, just like a regular Virtual Machine. In SAP this situation causes the blockage of communication from the client-side. Therefore, McAfee/Trellix Endpoint Protect recognizes the WSL2 machine as a separate device.

Checkout [This IT Knowledge Base document](https://itsupportportal.services.sap/itsupport?id=kb_article_view&sys_kb_id=2f71b3feeb714e94d707fe56cad0cdf5) for detailed information and make your environment workable. 

Next, continue with the preparation steps below.

#### VMware Player

Unfortunately, since VMware was purchased by Broadcom, VMware Player as a free product has been discontinued. Therefore, if you do not happen to have a license for VMware Workstation or are not willing to purchase one, this is not for you.

#### WMware Workstation

VMware Workstation requires a paid license that must be purchased through Ariba. If you already have one or are considering to get one, you can follow these steps here.

You will need to download the x86_64/AMD64 image of your operating system. For Ubuntu, that would be this ISO file: <https://releases.ubuntu.com/22.04/ubuntu-22.04.5-desktop-amd64.iso>

Create a new VM in VMware workstation, assign at least two CPU cores and 4GB of memory to it and boot it from the Ubuntu Live-CD. If you want to, you can install the CD on your VMs disk but the live system will also be ok if you just want to do the exercises.

### Mac

On Mac, the open-source [UTM app](https://getutm.app/) is the easiest way to get a virtual machine up and running. It uses Apples virtualization framework that is integrated into every version of MacOS and offers unbeatable performance. Install UTM from the sources given on <https://docs.getutm.app/installation/macos/>.

#### Apple Silicon

**Important:** You need to download an aarch64/ARM64 image of the operating system. For Ubuntu, that would be this ISO file: <https://cdimage.ubuntu.com/jammy/daily-live/current/jammy-desktop-arm64.iso>.
There might be cases, where the daily build fails to boot. Follow https://docs.getutm.app/guides/ubuntu/ as a fallback option and install the desktop environment separately.

In UTM, chose "*Create a New Virtual Machine*", next chose "*Virtualize*", chose "*Linux*" and finally make sure you leave "*Use Apple Virtualization*" unchecked. Do not enable "*Enable Rosetta (x86_64 emulation)*". For "*Boot ISO Image*", browse to the OS image you just downloaded. On the next page, assign two CPU cores and 4096MiB of memory to the virtual machine. Chose a small disk size (20GB is more than enough) and select no "*Shared Directories*". After reviewing your settings, DO check "*Open VM settings*" then save. In popup window, select "*Network*", in Network Mode area, select "*Emulated VLAN*", in Emulated Network Card area, select "*Intel Gigabit Ethernet (e1000)*". Save and start the VM.

**Known Workarounds** In case the VM hangs upon rebooting after installation, try unmounting the ISO and reboot the image. The workaround is "documented" here: https://github.com/utmapp/UTM/issues/4173#issuecomment-1179718559

#### Apple Intel 

You will need to download the x86_64/AMD64 image of your operating system. For Ubuntu, that would be this ISO file: <https://releases.ubuntu.com/22.04/ubuntu-22.04.5-desktop-amd64.iso>

In UTM, chose "*Create a New Virtual Machine*", next chose "*Virtualize*", chose "*Linux*" and finally make sure you leave "*Use Apple Virtualization*" unchecked. Do not enable "*Enable Rosetta (x86_64 emulation)*". For "*Boot ISO Image*", browse to the OS image you just downloaded. On the next page, assign two CPU cores and 4096MiB of memory to the virtual machine. Chose a small disk size (20GB is more than enough) and select no "*Shared Directories*". After reviewing your settings, DO check "*Open VM settings*" then save. In popup window, select "*Network*", in Network Mode area, select "*Emulated VLAN*", in Emulated Network Card area, select "*Intel Gigabit Ethernet (e1000)*". Save and start the VM.

## Preparing the VM for the Docker/Kubernetes training

Once you have a VM up and running, you may want to customize it. The following bash script will download all necessary tools (i.e. Docker CE, `kubectl` und Visual Studio Code) and set them up for you. The script requires you are connected to VPN.

**Important:** This script was developed for Ubuntu. If you use it for a different distribution, you need to adapt it.

```bash
#!/usr/bin/env bash

username=$(whoami)
homedir=$(eval echo ~$username)

# general
sudo apt-get update
sudo apt-get remove --purge -y gnome-initial-setup tracker-extract
sudo apt autoremove -y
sudo apt-get upgrade -y
sudo apt-get install -y curl wget ca-certificates apt-transport-https vim spice-vdagent

# ca
pushd /usr/local/share/ca-certificates
sudo curl -O https://aia.pki.co.sap.com/aia/SAP%20Global%20Root%20CA.crt
sudo curl -O https://aia.pki.co.sap.com/aia/SAPNetCA_G2.crt
sudo update-ca-certificates
popd

# docker
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd -f docker
sudo usermod -a -G docker $username
newgrp docker

# kubectl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

cat << '__EOF' >> $homedir/.bashrc
# make working with kubectl easier
source <(kubectl completion bash)
alias k=kubectl
complete -o default -F __start_kubectl k
__EOF

# vscode
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
rm -f packages.microsoft.gpg
sudo apt-get update
sudo apt-get install -y code
```

Restart the terminal session afterwards for the docker group to become active or run `newgrp docker`.

## How to find key combinations for your VM

The translation of host keyboard keys to guest VM keyboard keys might be a bit tricky at times and can result in a lot of frustration while trying to type. The best option is to check your individual mappings within the VM.

As indicated by the screenshot, open the settins -> keyboard -> view keyboard layout. Now, when you start hitting keys on your keyboard, the mapped keys will be highlighted. For example, if you want to type `~` character you need to find the key triggering `Level3 S...`.

![keyboard](https://media.github.tools.sap/user/1107/files/d555b218-7b71-49d1-be0f-fa6805e1d7ca)
