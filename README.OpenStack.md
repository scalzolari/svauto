# Ansible Playbook for OpenStack Deployments

# svauto

Ansible playbooks for `OpenStack` deployments.  http://openstack.org

# Overview

You'll need an `Ubuntu Xenial` up and running, fully upgraded, before deploying `OpenStack` on top of it.

Our `Ansible` playbooks provides two ways to deploy `OpenStack`, first and quick mode, is by running it on your local computer, the second mode is a bit more advanced, where you'll be deploying `OpenStack` on remote computers.

This procedure will deploy `OpenStack` (bare metal highly recommended, server or laptop) in a fashion called `all-in-one`. It follows `OpenStack` official documentation `http://docs.openstack.org/developer/openstack-ansible/developer-docs/quickstart-aio.html`.

The `default` setup builds an `all-in-one` environment, it might be used mostly for demonstration purposes. Only a few environments can use this topology in production.

To begin with, and to reduce the learning curve, we're using `Linux Bridges`, instead of `Open vSwitch`. Because it is very easy to fully understand `OpenStack Neutron` internals with `Linux Bridges`, it is easier to debug and simpler (`KISS Principle`).

Nevertheless, for a future `multi-node` deployments, `Open vSwitch` will be preferred. Specially for higly performance networks, when we'll be using `Open vSwitch` with `DPDK`.

In the next version of our `Ansible` playbooks, `Open vSwitch` will be supported for the `default` `all-in-one` deployments.

## Before start, keep in mind that:

A- A fresh installation and fully upgraded `Ubuntu Xenial` is required.

B- Make sure you can use `sudo` without password.

C- Your `/etc/hostname` file must contains ONLY the hostname itself, not the FQDN.

D- Your `IP + FQDN + hostname + aliases` should be configured in your `/etc/hosts` file.

# Installation Procedure (Linux Bridges)

## 1- Install Ubuntu 16.04 (Server or Desktop), details:

* Hostname: "mitaka-1"
* User: "administrative"
* Password: "whatever"

## 2- Upgrade Ubuntu to the latest version, by running:

    sudo apt update
    sudo apt -y full-upgrade
    sudo reboot

## 3- Basic requirements:

Install `curl` and `ssh`:

    sudo apt install ssh curl -y

Allow members of `sudo` group to become `root` without requiring password promt:

    sudo visudo

The line that starts with `%sudo` must contains:

    %sudo   ALL=NOPASSWD:ALL

## 4- Configure /etc/hostname and /etc/hosts files, like this:

One line in `/etc/hostname`:

    mitaka-1

First two lines of `/etc/hosts` (do not touch IPv6 lines):

    127.0.0.1 localhost.localdomain localhost
    127.0.1.1 mitaka-1.yourdomain.com mitaka-1 mitaka

*NOTE: If you have fixed IP (v4 or v6), you can use it here (recommended).*

Make sure it is working:

    hostname # Must returns ONLY your Hostname, nothing more.
    hostname -d # Must returns ONLY your Domain.
    hostname -f # Must returns your FQDN.
    hostname -i # Must returns your IP (can be 127.0.1.1).
    hostname -a # Must returns your aliases.

## 5- Deploy OpenStack Mitaka

Then, you'll be able to deploy `OpenStack` by running:

    bash <(curl -s https://raw.githubusercontent.com/sandvine-eng/svauto/dev/scripts/os-install-lbr.sh)

Well done! Your Openstack environment is now up and running.

## 6- Iptables configuration

Make sure you have a proper iptables rule in order to NAT traffic using the server IP address (obtained using DHCP):

You can use the following command to add the iptables rule to the host (replace eth0 with the interface of your host):

    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

## 7- Configure Data Interfaces (PTS subscriber/internet data ports)

At this point we have everything setup for our instances to be able to access the internet from within the openstack environment we just created. Now we need to configure two additional interfaces on the host that will be used for the PTS linux bridges.

Let's find out the available interfaces on the your server:

root@mitaka-1:~# dmesg |grep eth
[    7.079752] bnx2 0000:05:00.0 eth0: Broadcom NetXtreme II BCM5716 1000Base-T (C0) PCI Express found at mem c0000000, IRQ 16, node addr d4:ae:52:d2:c5:19
[    7.080589] bnx2 0000:05:00.1 eth1: Broadcom NetXtreme II BCM5716 1000Base-T (C0) PCI Express found at mem c2000000, IRQ 17, node addr d4:ae:52:d2:c5:1a
[    9.587152] igb 0000:03:00.0: added PHC on eth2
[    9.587154] igb 0000:03:00.0: eth2: (PCIe:2.5Gb/s:Width x4) 90:e2:ba:78:60:78
[    9.587155] igb 0000:03:00.0: eth2: PBA No: Unknown
[    9.776994] igb 0000:03:00.1: added PHC on eth3
[    9.776996] igb 0000:03:00.1: eth3: (PCIe:2.5Gb/s:Width x4) 90:e2:ba:78:60:79
[    9.776998] igb 0000:03:00.1: eth3: PBA No: Unknown
[    9.972991] igb 0000:04:00.0: added PHC on eth4
[    9.972993] igb 0000:04:00.0: eth4: (PCIe:2.5Gb/s:Width x4) 90:e2:ba:78:60:7c
[    9.972994] igb 0000:04:00.0: eth4: PBA No: Unknown
[   10.169075] igb 0000:04:00.1: added PHC on eth5
[   10.169077] igb 0000:04:00.1: eth5: (PCIe:2.5Gb/s:Width x4) 90:e2:ba:78:60:7d
[   10.169079] igb 0000:04:00.1: eth5: PBA No: Unknown
[   10.712041] bnx2 0000:05:00.0 eno1: renamed from eth0
[   11.501077] bnx2 0000:05:00.1 eno2: renamed from eth1
[   12.200914] igb 0000:03:00.0 enp3s0f0: renamed from eth2
[   12.344923] igb 0000:04:00.0 enp4s0f0: renamed from eth4
[   12.564876] igb 0000:03:00.1 enp3s0f1: renamed from eth3
[   12.724885] igb 0000:04:00.1 enp4s0f1: renamed from eth5

Let's pick the following two interfaces:
    enp4s0f0 --> subscribers
    enp4s0f1 --> internet

Now let's configure the interfaces on the host OS level:

root@mitaka-1:~# cat /etc/network/interfaces.d/enp4s0f0.cfg
# Subscriber
auto enp4s0f0
iface enp4s0f0 inet manual
    up ip link set dev $IFACE up
    down ip link set dev $IFACE down
    
root@mitaka-1:~# cat /etc/network/interfaces.d/enp4s0f1.cfg
# Internet
auto enp4s0f1
iface enp4s0f1 inet manual
    up ip link set dev $IFACE up
    down ip link set dev $IFACE down



# Advanced Procedure

1- Add the following entries to your `/etc/network/interfaces` file:

    # Fake External Interface
    allow-hotplug dummy0
    iface dummy0 inet static
      address 172.31.254.129
      netmask 25

    # VXLAN Data Path
    allow-hotplug dummy1
    iface dummy1 inet static
      mtu 1550
      address 10.0.0.1
      netmask 24

*NOTE: Dummy interfaces can be managed by ansible (hardcoded settings)*

## For local deployments:

1- Install Ansible to deploy your `OpenStack`:

    sudo apt -y install git ansible

    git clone -b dev https://github.com/sandvine-eng/svauto.git

    cd svauto

    ./svauto.sh --operation-openstack

## For remote deployments:

1- Make sure you can ssh to your servers using key authentication.

2- Install Ansible to deploy your `OpenStack`:

    sudo apt -y install git ansible

    git clone -b dev https://github.com/sandvine-eng/svauto.git

    cd svauto

Configure the file `group_vars/all` according to your remote computer.

Pay an extra attention to the templates: `nova.conf`, `cinder.conf` and `ml2_conf.ini`, reconfigure those if required.

Add your remote computer `FQDN` or `IP Address` to the `hosts` file, within group `all-in-one`, for example.

Then, run `Ansible`:

    ansible-playbook site-openstack.yml

**NOTE:** You can take a look at the script `svauto.sh --operation-openstack` to see what needs to be changed before running `Ansible`.

# Extra info

There is a few assumptions here, like for example:

A- Your remote server have its *default / primary* interface named `eth0`, the **my_ip** config option at `nova.conf` and `cinder.conf`;

B- The `br-ex` `Neutron` interface is bridged against the `dummy0` interface (`ml2_conf.ini`), it have the subnet `172.31.254.128/25`, so, it is the *default gateway* of ALL `Neutron Namespaces` of this deployment. Usually, we must use a real interface for `br-ex`, where the IP 172.31.254.129 should be configured in an `Upstream Router`, outside of `OpenStack`, and NOT here, at the `dummy0` interface.

Details:

    http://docs.openstack.org/liberty/install-guide/install/apt/content/ch_basic_environment.html#basics-neutron-networking-network-node

C- Because the `br-ex` is bridged against the `dummy0` interface, you'll need to create a `iptables masquerade` rule, so your `Instances` can reach the Internet through real `eth0`.

Example:

    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

D- The `vxlan` `Neutron` data network, will be created on top of a `dummy1`, it is really fast but, only works for our `all-in-one` deplyments (`ml2_conf.ini`).

TODO:

- Automate the Network Interfaces management with Ansible.

- Create a "setup / install" script, which will prompt some questions for the user, about local / remote setups, to simplify the instructions presented here.
