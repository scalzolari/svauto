#! /bin/bash

# Copyright 2016, Sandvine Incorporated.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Get options, both Linux Bridges and Open vSwitch (default) are supported.
# You can also use --dry-run to NOT run Ansible in the end, just prepare the
# configuration files.

for i in "$@"
do
case $i in

        --br-mode=*)

	        BR_MODE="${i#*=}"
        	shift
		;;

        --base-os=*)

                BASE_OS="${i#*=}"
                shift
                ;;

	--base-os-upgrade)

		BASE_OS_UPGRADE="yes"
		shift
		;;

        --use-dummies)

	        USE_DUMMIES="yes"
		shift
        	;;

        --ovs-hybrid-firewall)

	        OVS_HYBRID_FW="yes"
		shift
		;;

        --no-security-groups)

	        NO_SEC="yes"
		shift
        	;;

        --openstack-release=*)

	        OPENSTACK_RELEASE="${i#*=}"
		shift
        	;;

        --deployment-mode)

	        DEPLOYMENT_MODE="yes"
		shift
        	;;

        --dry-run)

	        DRY_RUN="yes"
		shift
		;;

esac
done


# Validade the BR_MODE variable.
if ! [[ "$BR_MODE" = "OVS" || "$BR_MODE" = "LBR" ]]
then
	echo
	echo "Aborting!!!"
	echo "You need to correctly specify the Bridge Mode for your OpenStack."
	echo
	echo "For Open vSwitch based deployments:"
	echo "./os-deploy.sh --br-mode=OVS --base-os=ubuntu16 --base-os-upgrade=yes --openstack-release=mitaka --deployment-mode"
	echo
	echo "For Linux Bridges based deployments:"
	echo "./os-deploy.sh --br-mode=LBR --base-os=ubuntu16 --base-os-upgrade=yes --openstack-release=mitaka --deployment-mode"

	exit 1
fi


# Doing CPU checks
if [ "$DRY_RUN" == "yes" ]
then

	echo
        echo "Not running CPU checks on --dry-run..."

else
 
	# Verifying if you have enough CPU Cores.
	echo
	echo "Verifying if you have enough CPU Cores..."
	
	CPU_CORES=$(grep -c ^processor /proc/cpuinfo)
	
	if [ $CPU_CORES -lt 4 ]
	then
		echo
	        echo "WARNING!!!"
		echo
		echo "You do not have enough CPU Cores to run this system!"
	
		exit 1
	else
	        echo
		echo "Okay, good, you have enough CPU Cores, proceeding..."
	fi


	# Verifying if host have Virtualization enabled, abort it if doesn't have.
	echo
	echo "Verifying if your CPU supports Virtualization..."
	
	sudo apt -y install cpu-checker 2>&1 > /dev/null
	
	if /usr/sbin/kvm-ok 2>&1 > /dev/null
	then
		echo
	        echo "OK, Virtualization supported, proceeding..."
	else
	        echo "WARNING!!!"
		echo
		echo "Virtualization NOT supported on this CPU or it is not enabled on your BIOS"
	
		exit 1
	fi

fi


# Detect some of the local settings:
WHOAMI=$(whoami)
HOSTNAME=$(hostname)
FQDN=$(hostname -f)
DOMAIN=$(hostname -d)


# If the hostname and hosts file aren't configured according, abort.
if [ -z $HOSTNAME ]; then
        echo "Hostname not found... Configure the file /etc/hostname with your hostname. ABORTING!"

        exit 1
fi

if [ -z $DOMAIN ]; then
        echo "Domain not found... Configure the file /etc/hosts with your \"IP + FQDN + HOSTNAME\". ABORTING!"

        exit 1
fi

if [ -z $FQDN ]; then
        echo "FQDN not found... Configure your /etc/hosts according. ABORTING!"

        exit 1
fi


# Display local configuration
echo
echo "The detected local configuration are:"
echo
echo -e "* Username:"'\t'$WHOAMI
echo -e "* Hostname:"'\t'$HOSTNAME
echo -e "* FQDN:"'\t''\t'$FQDN
echo -e "* Domain:"'\t'$DOMAIN


# Message about ansible/group_vars/all configuration
echo
echo "Configuring your ansible/group_vars/all file, as follows:"

# Configuring Bridge Mode on group_vars/all
echo
echo "* The Bridge Mode is set to "$BR_MODE"..."

# http://docs.openstack.org/networking-guide/scenario_legacy_lb.html
if [ "$BR_MODE" = "LBR" ]
then
	sed -i -e 's/br_mode:.*/br_mode: "LBR"/' ansible/group_vars/all
	sed -i -e 's/linuxnet_interface_driver:.*/linuxnet_interface_driver: "nova.network.linux_net.LinuxBridgeInterfaceDriver"/' ansible/group_vars/all
	sed -i -e 's/neutron_interface_driver:.*/neutron_interface_driver: "neutron.agent.linux.interface.BridgeInterfaceDriver"/' ansible/group_vars/all
	sed -i -e 's/mechanism_drivers:.*/mechanism_drivers: "linuxbridge"/' ansible/group_vars/all
	sed -i -e 's/firewall_driver:.*/firewall_driver: "neutron.agent.linux.iptables_firewall.IptablesFirewallDriver"/' ansible/group_vars/all
fi

# http://docs.openstack.org/networking-guide/scenario_legacy_ovs.html
if [ "$BR_MODE" = "OVS" ]
then 
	sed -i -e 's/br_mode:.*/br_mode: "OVS"/' ansible/group_vars/all
	sed -i -e 's/linuxnet_interface_driver:.*/linuxnet_interface_driver: "nova.network.linux_net.LinuxOVSInterfaceDriver"/' ansible/group_vars/all
	sed -i -e 's/neutron_interface_driver:.*/neutron_interface_driver: "neutron.agent.linux.interface.OVSInterfaceDriver"/' ansible/group_vars/all
	sed -i -e 's/mechanism_drivers:.*/mechanism_drivers: "openvswitch"/' ansible/group_vars/all

	if [ "$OVS_HYBRID_FW" = "yes" ]
	then
		sed -i -e 's/firewall_driver:.*/firewall_driver: "neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver"/' ansible/group_vars/all
	else
		sed -i -e 's/firewall_driver:.*/firewall_driver: "openvswitch"/' ansible/group_vars/all
	fi
fi


# Disabling Security Groups entirely
if [ "$NO_SEC" = "yes" ]
then
	echo
	echo "* WARNING! Disabling Security Groups (null firewall_driver) for your entire Cloud environment!"

	sed -i -e 's/firewall_driver:.*/firewall_driver: "neutron.agent.firewall.NoopFirewall"/' ansible/group_vars/all
fi


# Configuring FQDN and Domain on group_vars/all
echo
echo "* The detected settings like OpenStack release, Ubuntu, hostnames, etc..."

sed -i -e 's/openstack_release:.*/openstack_release: "'$OPENSTACK_RELEASE'"/' ansible/group_vars/all

sed -i -e 's/base_os:.*/base_os: "ubuntu16"/' ansible/group_vars/all
sed -i -e 's/base_os_upgrade:.*/base_os_upgrade: "yes"/' ansible/group_vars/all

sed -i -e 's/ubuntu_network_setup:.*/ubuntu_network_setup: "yes"/' ansible/group_vars/all

sed -i -e 's/controller-1.yourdomain.com/'$FQDN'/g' ansible/group_vars/all
sed -i -e 's/yourdomain.com/'$DOMAIN'/g' ansible/group_vars/all


# Configuring site-openstack.yml and some roles
echo
echo "* Your current \"$WHOAMI\" user..."

sed -i -e 's/ubuntu_user:.*/ubuntu_user: "'$WHOAMI'"/g' ansible/group_vars/all


echo
echo "* Enabling \"localhost\" host on ansible/hosts..."

sed -i -e 's/^#localhost/localhost/g' ansible/hosts


# Configuring the default interface
PRIMARY_INTERFACE=$(ip r | grep default | awk '{print $5}')

echo 
echo "Your primary network interface is:"
echo "dafault route via:" $PRIMARY_INTERFACE

echo
echo "* Preparing Ansible variable based on current default primary interface..."

sed -i -e 's/primary_interface_name:.*/primary_interface_name: "'$PRIMARY_INTERFACE'"/' ansible/group_vars/all


if [ "$DRY_RUN" == "yes" ]
then
        echo
        echo "Not running Ansible on --dry-run!"
	echo "Just preparing the environment variables, so you can run Ansible manually, like:"
	echo
	echo "cd ~/svauto/ansible"
	echo "ansible-playbook site-openstack.yml --extra-vars \"deployment_mode=yes\""
	echo
	echo "And a second run after a successful deployment:"
	echo
	echo "ansible-playbook site-openstack.yml"
	echo
else
	echo
	echo "Running Ansible, deploying OpenStack:"

	if [ "$DEPLOYMENT_MODE" == "yes" ];
	then
		cd ~/svauto/ansible
		ansible-playbook site-openstack.yml --extra-vars "deployment_mode=yes"
	else

		cd ~/svauto/ansible
        	ansible-playbook site-openstack.yml
	fi
fi
