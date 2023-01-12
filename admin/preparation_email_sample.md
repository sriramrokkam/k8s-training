# Template for invitation and preperation email

It is good practice to send out an email to all participants of the training to welcome them and ask them to prepare for the training. The following template has proven its purpose over the years.

## TODO for trainers

Before sending this mail, adapt the __<< place-holders >>__ accordingly


## Mail content

**Subject:** [Action required]: Welcome to the ``Docker`` and Kubernetes Fundamentals Training in << date >>

```
Dear colleagues,

We are preparing the last bits and pieces of content for our upcoming training on Docker & Kubernetes Fundamentals next week.  
To make sure we are all ready to start, we would like to share a few pieces of information with you upfront and ask you for a little bit of preparation.  
  
This training is meant to be a hands-on training (we do have PowerPoint Slides though). Since you will be typing a lot, we are asking you set up a working environment that you will use during the training.  
  
To have a smooth start, please carry out the following steps:  

1. EITHER (for Windows and Mac users)

We prepared a VM image for VMware Player that contains all the tools and programs that you will need for the training. If you want to use it, you can...

- (Windows): Install VMware Player from Software Center
- (Mac): download the trial-version of VMware Fusion from https://www.vmware.com/de/products/fusion/fusion-evaluation.html

and finally download the VM image as described on this page: https://github.wdf.sap.corp/cloud-native-dev/Cloud-Curriculum-VM/blob/master/Getting_Started_Running_KubernetesVM.md (this requires VPN access)

Important: you can download the VM from the link given on the Wiki-page above. However, you will get a certificate error on the way. You may safely ignore that error, or you can download the VM image from here (which is actually preferred).

2. OR (for Mac users only sorry)

If you are on a Mac, you may install Docker Desktop (requires a paid license that will be automatically issued to you if the software is detected on your Mac) and kubectl directly on your system.

3. (optional) Please take a look at the links here to familiarize yourself a bit with some Linux basics: https://github.tools.sap/kubernetes/docker-k8s-training/blob/master/preparation.md.


Some more pieces of information for you:

For the Kubernetes exercises we will use a Kubernetes Cluster provided by SAP’s Gardener project. We will grant you access to it during the training.

If you already want to have a look at our training material, you can browse to SAP's GitHub at https://github.tools.sap/kubernetes/docker-k8s-training/. 
We will use this material throughout the training. You will also find the detailed agenda in that repository.

The training will take place from << start date >> till << end date >> starting each day at << start time >> until << end time >>. We will have a one hour lunch break in between every day. Please be reminded that this training takes place in the << your time-zone >> time-zone and all times are in << your time-zone >>.

This is a virtual Zoom meeting, its URL is << zoom link - delete this paragraph if your meeting is not virtual >>


One last piece of info (we have to mention it, sorry):

If you are registered to this training and cannot make it, please let us know by Friday so that we can make room for other people on the waiting list. Please be reminded that this training imposes a no-show fee for everyone registered and not showing up.

We’re looking forward to meeting you all next week.

Best regards,
<< trainers >>
```
