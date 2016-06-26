
# SVAuto - The Sandvine Automation

SVAuto is a set of Open Source tools, that brings together, a series of external tools for building immutable servers images and for Data Center Automation.

With SVAuto, you can create QCoWs, VMDKs, OVAs, and much more, with Vagrant or Packer, both with Ansible! Using only official Linux distribution ISO files as a base.

Also, you can deploy Sandvine's RPM Packages on top of any supported CentOS 6 or 7, be it bare-metal, Cloud-based images, regular KVM, VMWare, Xen, Hyper-V and etc.

Looking forward to add support for Linux Containers (LXD and Docker).

It uses the following Open Source projects:

* Ubuntu Xenial 16.04
* Ansible 2.0
* Packer 0.10.0
* QEmu 2.5
* VirtualBox 5.0
* Vagrant 1.8
* Docker 1.10
* LXD 2.0
* Amazon EC2 AMI & API Tools

It contains Ansible Playbooks for Automated deployments of:

* Ubuntu
* CentOS
* Sandvine Platform RPM Packages
* OpenStack on Ubuntu LTS

*NOTE: For using Ansible against remore locations, make sure you can ssh to your instances using key authentication.*

*SVAuto was designed for Ubuntu Xenial 16.04 (latest LTS), Server or Desktop. But, a few Ansible roles works on CentOS too.*

## Downloading

Download SVAuto into your home directory (Designed for Ubuntu LTS):

    cd ~
    bash <(curl -s https://raw.githubusercontent.com/sandvine-eng/svauto/dev/scripts/install-svauto.sh)

## Bootstrapping boxes with "curl pipe bash"

Bootstrap Ubuntu 16.04 Server and configure Grub, while upgrading it:

    curl -L https://raw.githubusercontent.com/sandvine-eng/svauto/dev/scripts/svauto-deployments.sh | bash -s -- --base-os=ubuntu16 --roles=bootstrap,grub-conf --extra-vars="base_os_upgrade=yes"

Bootstrap Ubuntu 16.04 Desktop, while upgrading and installing Google Chrome:

    curl -L https://raw.githubusercontent.com/sandvine-eng/svauto/dev/scripts/svauto-deployments.sh | bash -s -- --base-os=ubuntu16 --roles=bootstrap,grub-conf,hyper_kvm,google-chrome,scudcloud,sublime,ccollab-client --extra-vars="base_os_upgrade=yes"

Bootstrap Ubuntu 16.04 Desktop, while configuring Grub, upgrading it and installing Google Chrome:

    curl -L https://raw.githubusercontent.com/sandvine-eng/svauto/dev/scripts/svauto-deployments.sh | bash -s -- --base-os=ubuntu16 --roles=bootstrap,grub-conf,google-chrome --extra-vars="base_os_upgrade=yes"

Bootstrap CentOS 6, while configuring Grub

    curl -L https://raw.githubusercontent.com/sandvine-eng/svauto/dev/scripts/svauto-deployments.sh | bash -s -- --base-os=centos6 --roles=bootstrap,grub-conf --extra-vars="base_os_upgrade=yes"

Bootstrap CentOS 7, while configuring Grub

    curl -L https://raw.githubusercontent.com/sandvine-eng/svauto/dev/scripts/svauto-deployments.sh | bash -s -- --base-os=centos7 --roles=bootstrap,grub-conf --extra-vars="base_os_upgrade=yes"

## Installing SVAuto dependencies

You'll need to install all the dependencies for running SVAuto.

To install everything, run on your Ubuntu 16.04 Server or Desktop, the following command:

    curl -L https://raw.githubusercontent.com/sandvine-eng/svauto/dev/scripts/svauto-deployments.sh | bash -s -- --base-os=ubuntu16 --roles=bootstrap,apache2,hyper_kvm,hyper_lxd,hyper_virtualbox,docker,vagrant,amazon_ec2_tools,redhat_tools_ubuntu,os_clients,packer,vsftpd --extra-vars="base_os_upgrade=yes"

## SVAuto script usage example

Resource to build Sandvine's Cloud Services 16.02 Official Images (production quality version).

    # To build Cloud Services 16.02
    ./svauto.sh --packer-build-cs --release

*NOTE: To build it, you'll need a Sandvine's customer account for ftp.support.sandvine.com.*

This is a resource used to build Sandvine Official Images (development build).

    # To build Sandvine's Stock Images
    ./svauto.sh --packer-build-official

    # To build Sandvine's Images with Cloud Services
    ./svauto.sh --packer-build-cs

    # To build Sandvine stock images without any level of auto-configuration
    ./svauto --packer-build-sandvine

*NOTE: It depends on a very specific Yum Repository structure. Available on the Internet for Sandvine's customers with an account to access ftp.support.sandvine.com. However, to build development images, you have to options, be a Sandvine employee or mirror the ftp.support.sandvine.com in your own small FTP Server. Scripts to help build your mirror will be available soon!*

    # To clean it up
    ./svauto.sh --clean-all

## Using Image Factory directly

Resource to build a clean Ubuntu or CentOS images, without Ansible roles, just Packer and upstream ISO media.

    # Ubuntu Trusty 14.04 - Blank server
    ./image-factory.sh --release=dev --base-os=ubuntu14 --base-os-upgrade --product=ubuntu --version=14.04 --product-variant=r1 --qcow2 --vm-xml --sha256sum
    
    # Ubuntu Xenial 16.04 - Blank server
    ./image-factory.sh --release=dev --base-os=ubuntu16 --base-os-upgrade --product=ubuntu --version=16.04 --product-variant=r1 --qcow2 --vm-xml --sha256sum
    
    # CentOS 6 - Blank server - Old Linux 2.6
    ./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=centos --version=6 --product-variant=sv-1 --qcow2 --vm-xml --sha256sum
    
    # CentOS 7 - Blank server - Old Linux 3.10
    ./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=centos --version=7.1 --product-variant=sv-1 --qcow2 --vm-xml --sha256sum
    
Resource to build a clean Ubuntu or CentOS images, with Packer and Ansible, plus upstream ISO media.

    # Ubuntu Trusty 14.04 - Blank server - Bootstrapped
    ./image-factory.sh --release=dev --base-os=ubuntu14 --base-os-upgrade --product=ubuntu --version=14.04 --product-variant=r1 --qcow2 --vm-xml --sha256sum --roles=bootstrap,cloud-init,grub-conf,post-cleanup
    
    # Ubuntu Xenial 16.04 - Blank server - Bootstrapped
    ./image-factory.sh --release=dev --base-os=ubuntu16 --base-os-upgrade --product=ubuntu --version=16.04 --product-variant=r1 --qcow2 --vm-xml --sha256sum --roles=bootstrap,cloud-init,grub-conf,post-cleanup

    # CentOS 6 - Blank server - Old Linux 2.6 - Bootstrapped
    ./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=centos --version=6 --product-variant=sv-1 --qcow2 --vm-xml --sha256sum --roles=bootstrap,cloud-init,grub-conf,post-cleanup
    
    # CentOS 6 - Blank server - Linux 3.18 from Xen 4.4 CentOS Repo - Much better KVM / Xen support - Bootstrapped
    ./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=centos --version=6 --product-variant=sv-1 --qcow2 --vm-xml --sha256sum --roles=centos-xen,bootstrap,grub-conf,cloud-init,grub-conf,post-cleanup
    
    # CentOS 7 - Blank server - Old Linux 3.10 - Bootstrapped
    ./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=centos --version=7.1 --product-variant=sv-1 --qcow2 --vm-xml --sha256sum --roles=bootstrap,grub-conf,cloud-init,post-cleanup
    
    # CentOS 7 - Blank server - Linux 3.18 from Xen 4.6 CentOS Repo - Much better KVM / Xen support - Bootstrapped
    ./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=centos --version=7.1 --product-variant=sv-1 --qcow2 --vm-xml --sha256sum --roles=centos-xen,bootstrap,grub-conf,cloud-init,post-cleanup

### AWS (TODO)

In order to setup your environment prior to running ansible, start a new
bash using `ssh-agent` and add your keys to it:

    ssh-agent bash -l
    ssh-add ~/.ssh/my-aws-key.pem

Then use the playbook normally:

    ansible-playbook -u root site-sandvine.yml
