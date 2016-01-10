
# SVAuto - The Sandvine Automation

SVAuto is a set of Open Source tools, that brings together, a series of external tools for building immutable servers images and for Data Center Automation.

With SVAuto, you can create QCoWs, VMDKs, OVAs, and much more, with Packer and Ansible! Using only official Linux distribution ISO files as a base.

Also, you can deploy Sandvine's RPM Packages on top of any supported CentOS 6 or 7, be it bare-metal, Cloud-based images, regular KVM, VMWare, Xen, Hyper-V and etc.

Looking forward to add support for Linux Containers (LXD and Docker).

It uses the following Open Source projects:

* Ubuntu Xenial 16.04
* Ansible
* Packer
* QEmu
* VirtualBox
* Vagrant
* Docker
* LXD

It contains Ansible Playbooks for Automated deployments of:

* Ubuntu
* CentOS
* Sandvine Platform RPM Packages
* OpenStack on Ubuntu LTS

*NOTE: For using Ansible against remore locations, make sure you can ssh to your instances using key authentication.*

*SVAuto was designed for Ubuntu Xenial 16.04 (latest LTS), server or desktop. But, parts of Ansible automation, are designed CentOS.*

## Downloading

Download SVAuto into your home directory (Designed for Ubuntu LTS):

    cd ~
    bash <(curl -s https://raw.githubusercontent.com/tmartinx/svauto/raw/dev/misc/svauto-install.sh)

## Installing SVAuto dependencies

You'll need to install all the dependencies for running SVAuto.


To install everything, run:

    cd ~/svauto
    ./svauto.sh --install-dependencies

## SVAuto script usage example

Resource to build Sandvine's Cloud Services 15.12 Official Images (production quality version).

    # To build Cloud Services 15.12
    ./svauto.sh --packer-build-cs --release

*NOTE: To build it, you'll need a Sandvine's customer account for ftp.support.sandvine.com.*

This is a resource used to build Sandvine Official Images (development build).

    # To build Sandvine's Stock Images
    ./svauto.sh --packer-build-official

    # To build Sandvine's Images with Cloud Services
    ./svauto.sh --packer-build-cs

*NOTE: It depends on a very specific Yum Repository structure. Available on the Internet for Sandvine's customers with an account to access ftp.support.sandvine.com. However, to build development images, you have to options, be a Sandvine employee or mirror the ftp.support.sandvine.com in your own small FTP Server. Scripts to help build your mirror will be available soon!*

    # To clean it up
    ./svauto.sh --clean-all

## Using Image Factory directly

Resource to build a clean Ubuntu or CentOS images, without Ansible roles, just Packer and upstream ISO media.

    # Ubuntu Trusty 14.04.3 - Blank server
    ./image-factory.sh --release=dev --base-os=ubuntu14 --base-os-upgrade --product=svserver --version=14.04 --product-variant=r1 --qcow2 --vm-xml --md5sum --sha1sum
    
    # Ubuntu Xenial 16.04 - Blank server
    ./image-factory.sh --release=dev --base-os=ubuntu16 --base-os-upgrade --product=svserver --version=16.04 --product-variant=r1 --qcow2 --vm-xml --md5sum --sha1sum
    
    # CentOS 6.7 - Blank server - Old Linux 2.6
    ./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=centos --version=6.7 --product-variant=sv-1 --qcow2 --vm-xml --md5sum --sha1sum
    
    # CentOS 7.2 - Blank server - Old Linux 3.10
    ./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=centos --version=7.1 --product-variant=sv-1 --qcow2 --vm-xml --md5sum --sha1sum
    
Resource to build a clean Ubuntu or CentOS images, with Packer and Ansible, plus upstream ISO media.

    # CentOS 6.7 - Blank server - Old Linux 2.6
    ./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=centos --version=6.7 --product-variant=sv-1 --qcow2 --vm-xml --md5sum --sha1sum --roles=bootstrap,cloud-init,grub-conf
    
    # CentOS 6.7 - Blank server - Linux 3.18 from Xen 4.4 CentOS Repo - Much better KVM / Xen support
    ./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=centos --version=6.7 --product-variant=sv-1 --qcow2 --vm-xml --md5sum --sha1sum --roles=centos-xen,bootstrap,cloud-init,grub-conf
    
    # CentOS 7.2 - Blank server - Old Linux 3.10
    ./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=centos --version=7.1 --product-variant=sv-1 --qcow2 --vm-xml --md5sum --sha1sum --roles=bootstrap,cloud-init
    
    # CentOS 7.2 - Blank server - Linux 3.18 from Xen 4.6 CentOS Repo - Much better KVM / Xen support
    ./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=centos --version=7.1 --product-variant=sv-1 --qcow2 --vm-xml --md5sum --sha1sum --roles=centos-xen,bootstrap,cloud-init

### AWS (TODO)

In order to setup your environment prior to running ansible, start a new
bash using `ssh-agent` and add your keys to it:

    ssh-agent bash -l
    ssh-add ~/.ssh/my-aws-key.pem

Then use the playbook normally:

    ansible-playbook -u root site.yml
