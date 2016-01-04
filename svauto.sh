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


TODAY=$(date +"%Y%m%d")


for i in "$@"
do
case $i in

	--os-project=*)

		OS_PROJECT="${i#*=}"
		shift
		;;

	--stack=*)

		STACK="${i#*=}"
		shift
		;;

	--freebsd-pts=*)

		FREEBSD_PTS="${i#*=}"
		shift
		;;

	--labify)

		LABIFY="yes"
		shift
		;;

	--packer-build-official)

		PACKER_BUILD_OFFICIAL="yes"
		shift
		;;

	--packer-build-cs)

		PACKER_BUILD_OFFICIAL="yes"
		PACKER_BUILD_CS="yes"
		shift
		;;

	--packer-to-openstack)

		PACKER_TO_OS="yes"
		shift
		;;

	--release)

		RELEASE="yes"
		shift
		;;

	--clean-all)

		echo
		echo "Cleaning it up..."

		git checkout ansible/hosts ansible/site.yml ansible/group_vars/all

		rm -rf packer/build*
		[ -d packer_cache ] && rmdir packer_cache

		echo
		exit 0

		shift
		;;

	--dry-run)

		DRYRUN="yes"
		shift
		;;

esac
done



if [ "$PACKER_BUILD_CS" == "yes" ] && [ "$RELEASE" == "yes" ]
then

	echo
	echo "Enter your Sandvine's FTP (ftp.support.sandvine.com) account details:"
	echo
	echo -n "Username: "
	read FTP_USER
	echo -n "Password: "
	read -s FTP_PASS

        sed -i -e 's/ftp_username:.*/ftp_username: '$FTP_USER'/g' ansible/group_vars/all
        sed -i -e 's/ftp_password:.*/ftp_password: '$FTP_PASS'/g' ansible/group_vars/all

	# SDE 7.20 on CentOS 6 + Cloud Services SDE + Cloud Services Daemon (back / front)
	./image-factory.sh --release=prod --base-os=centos67 --base-os-upgrade --product=cs-svsde --version=15.10 --product-variant=r2 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=bootstrap,cloud-init,grub-conf,sde,svusagemanagement,svsubscribermapping,cs-sde,csd,vmware-tools,cleanrepo

	# SDE 7.20 on CentOS 6 + Cloud Services SDE + Cloud Services Daemon (back / front) - Labified
	./image-factory.sh --release=prod --base-os=centos67 --base-os-upgrade --product=cs-svsde --version=15.10 --product-variant=r2 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
		--roles=bootstrap,cloud-init,grub-conf,sde,svusagemanagement,svsubscribermapping,cs-sde,csd,vmware-tools,cleanrepo --labify

	# SPB 6.60 on CentOS 6 + Cloud Services customizations
	./image-factory.sh --release=prod --base-os=centos67 --base-os-upgrade --product=cs-svspb --version=15.10 --product-variant=r2 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=bootstrap,cloud-init,grub-conf,spb,svreports,cs-spb,vmware-tools,cleanrepo

	# SPB 6.60 on CentOS 6 - Cloud Services customizations - Labified
	./image-factory.sh --release=prod --base-os=centos67 --base-os-upgrade --product=cs-svspb --version=15.10 --product-variant=r2 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
		--roles=bootstrap,cloud-init,grub-conf,spb,svreports,cs-spb,vmware-tools,cleanrepo --labify

	exit 0

fi



if [ "$PACKER_BUILD_OFFICIAL" == "yes" ]
then

	if [ "$DRYRUN" == "yes" ]; then
		export DRY_RUN_OPT="--dry-run"
	fi


	if [ "$PACKER_BUILD_CS" == "yes" ]
	then

		#
		# STABLE
		#

		# SDE 7.20 on CentOS 6 + Cloud Services SDE + Cloud Services Daemon (back / front)
		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.20 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=bootstrap,cloud-init,grub-conf,sde,svusagemanagement,svsubscribermapping,cs-sde,csd,vmware-tools $DRY_RUN_OPT

		# SDE 7.20 on CentOS 6 + Cloud Services SDE + Cloud Services Daemon (back / front) - Labified
		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.20 --product-variant=cs-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
			--roles=bootstrap,cloud-init,grub-conf,sde,svusagemanagement,svsubscribermapping,cs-sde,csd,vmware-tools $DRY_RUN_OPT --labify

		# SPB 6.60 on CentOS 6 + Cloud Services
		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svspb --version=6.60 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=bootstrap,cloud-init,grub-conf,spb,svreports,cs-spb,vmware-tools $DRY_RUN_OPT

		# SPB 6.60 on CentOS 6 + Cloud Services - Labified
		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svspb --version=6.60 --product-variant=cs-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
			--roles=bootstrap,cloud-init,grub-conf,spb,svreports,cs-spb,vmware-tools $DRY_RUN_OPT --labify

		# SDE 7.20 on CentOS 6 + Cloud Services SDE only - No Cloud Services daemon here!
		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.20 --product-variant=cs-sde-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=bootstrap,cloud-init,grub-conf,sde,svusagemanagement,svsubscribermapping,cs-sde,vmware-tools $DRY_RUN_OPT

		# Cloud Services Daemon 7.40 (back / front) on CentOS 6 - No SDE here!
		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svcs --version=7.40 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=centos-xen,bootstrap,cloud-init,grub-conf,csd,vmware-tools $DRY_RUN_OPT

#		# SPB 6.60 on CentOS 6 + Cloud Services - Without NDS / svreports
#		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svspb --version=6.60 --product-variant=no-nds-cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#			--roles=bootstrap,cloud-init,grub-conf,spb,cs-spb,vmware-tools $DRY_RUN_OPT

		# PTS 7.20 on CentOS 6 + Cloud Services - Linux 2.6, old DPDK 1.8, requires igb_uio
		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svpts --version=7.20 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=bootstrap,cloud-init,grub-conf,pts,svusagemanagementpts,cs-pts,vmware-tools $DRY_RUN_OPT

		# PTS 7.20 on CentOS 7 + Cloud Services - Linux 3.10, old DPDK 1.8, requires igb_uio
		./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svpts --version=7.20 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=bootstrap,cloud-init,pts,svusagemanagementpts,cs-pts,vmware-tools $DRY_RUN_OPT

		# PTS 7.20 on CentOS 7 + Cloud Services - Linux 3.10, old DPDK 1.8  requires igb_uio - Labified
		./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svpts --version=7.20 --product-variant=cs-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
			--roles=bootstrap,cloud-init,pts,svusagemanagementpts,cs-pts,vmware-tools $DRY_RUN_OPT --labify

		#
		# EXPERIMENTAL
		#

		# SDE 7.45 on CentOS 7
		./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svsde --version=7.45 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=centos-xen,bootstrap,cloud-init,sde,vmware-tools $DRY_RUN_OPT

	       	# SDE 7.45 on CentOS 6
		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.45 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=bootstrap,cloud-init,grub-conf,sde,svusagemanagement,svsubscribermapping,vmware-tools $DRY_RUN_OPT --versioned-repo

		# SPB 7.00 on CentOS 6
		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svspb --version=7.00 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=bootstrap,cloud-init,grub-conf,spb,vmware-tools $DRY_RUN_OPT --versioned-repo

	else

		#
		# Examples
		#

#		# Ubuntu Trusty 14.04.3 - Blank server
#		./image-factory.sh --release=dev --base-os=ubuntu14 --base-os-upgrade --product=svserver --version=14.04 --product-variant=r1 --qcow2 --md5sum --sha1sum

#		# Ubuntu Xenial 16.04 - Blank server
#		./image-factory.sh --release=dev --base-os=ubuntu16 --base-os-upgrade --product=svserver --version=16.04 --product-variant=r1 --qcow2 --md5sum --sha1sum

#		# CentOS 6.7 - Blank server - Old Linux 2.6
#		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=centos --version=6.7 --product-variant=sv-1 --qcow2 --vm-xml --md5sum --sha1sum \
#			--roles=bootstrap,cloud-init,grub-conf $DRY_RUN_OPT

#		# CentOS 6.7 - Blank server - Linux 3.18 from Xen 4.4 CentOS Repo - Much better KVM / Xen support
#		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=centos --version=6.7 --product-variant=sv-1 --qcow2 --vm-xml --md5sum --sha1sum \
#			--roles=centos-xen,bootstrap,cloud-init,grub-conf $DRY_RUN_OPT

#		# CentOS 7 - Blank server - Old Linux 3.10
#		./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=centos --version=7.1 --product-variant=sv-1 --qcow2 --vm-xml --md5sum --sha1sum \
#			--roles=bootstrap,cloud-init $DRY_RUN_OPT

#		# CentOS 7 - Blank server - Linux 3.18 from Xen 4.6 CentOS Repo - Much better KVM / Xen support
#		./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=centos --version=7.1 --product-variant=sv-1 --qcow2 --vm-xml --md5sum --sha1sum \
#			--roles=centos-xen,bootstrap,cloud-init $DRY_RUN_OPT

		#
		# STABLE
		#

		# PTS 7.20 on CentOS 6 - Linux 2.6, old DPDK 1.8, requires igb_uio
		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svpts --version=7.20 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=bootstrap,cloud-init,grub-conf,pts,vmware-tools $DRY_RUN_OPT

		# PTS 7.20 on CentOS 7 - Linux 3.10, old DPDK 1.8, requires igb_uio
		./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svpts --version=7.20 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=bootstrap,cloud-init,pts,vmware-tools $DRY_RUN_OPT

		# SDE 7.20 on CentOS 6
		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.20 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=bootstrap,cloud-init,grub-conf,sde,vmware-tools $DRY_RUN_OPT

		# SDE 7.45 on CentOS 7
		./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svsde --version=7.45 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=centos-xen,bootstrap,cloud-init,sde,vmware-tools $DRY_RUN_OPT

	       	# SDE 7.45 on CentOS 6
		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.45 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=bootstrap,cloud-init,grub-conf,sde,svusagemanagement,svsubscribermapping,vmware-tools $DRY_RUN_OPT --versioned-repo

		# SPB 6.60 on CentOS 6
		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svspb --version=6.60 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=bootstrap,cloud-init,grub-conf,spb,vmware-tools $DRY_RUN_OPT

		# SPB 7.00 on CentOS 6
		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svspb --version=7.00 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=bootstrap,cloud-init,grub-conf,spb,vmware-tools $DRY_RUN_OPT --versioned-repo

		#
		# EXPERIMENTAL
		#

		# PTS 7.30 on CentOS 6 - Linux 2.6, old DPDK 1.8, requires igb_uio
		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svpts --version=7.30 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=bootstrap,cloud-init,grub-conf,pts,vmware-tools $DRY_RUN_OPT --versioned-repo

		# PTS 7.30 on CentOS 7 - Linux 3.10, old DPDK 1.8, requires igb_uio
		./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svpts --version=7.30 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=bootstrap,cloud-init,pts,vmware-tools $DRY_RUN_OPT --versioned-repo

		# PTS 7.30 on CentOS 6 - Linux 3.18 from Xen 4.4 Repo + DPDK 2.2 with Xen Support, no igb_uio
		./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svpts --version=7.30 --product-variant=dpdk22-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=centos-xen,bootstrap,cloud-init,grub-conf,pts,vmware-tools $DRY_RUN_OPT --versioned-repo --experimental-repo

		# PTS 7.30 on CentOS 7 - Linux 3.18 from Xen 4.6 Repo + DPDK 2.2 with Xen Support, no igb_uio
		./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svpts --version=7.30 --product-variant=dpdk22-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
			--roles=centos-xen,bootstrap,cloud-init,pts,vmware-tools $DRY_RUN_OPT --versioned-repo --experimental-repo

	fi

	exit 0

fi


if [ ! "$LABIFY" == "yes" ]
then

	if [ ! -f ~/demo-openrc.sh ]
	then
		echo
		echo "OpenStack Credentials for "demo" account not found, aborting!"
		exit 1
	else
		echo
		echo "Loading OpenStack credentials for "demo" account..."
		source ~/demo-openrc.sh
	fi


	if [ -z $STACK ]
	then
		echo
		echo "You did not specified the destination Stack to deploy Sandvine's RPM Packages."
		echo "However, the following Stack(s) was detected under your account:"
		echo
		heat stack-list
		echo
		echo "You must run this script passing the \"Stack Name\" as an argument, like this:"
		echo
		echo "Assuming you downloaded it under ~/svauto:"
		echo
		echo "cd ~/svauto ; ./svauto.sh --stack=demo"
		echo
		echo
		echo "If you don't have a Sandvine compatible Stack up and running, you can start one"
		echo "right now by running:"
		echo
		echo "heat stack-create demo -f ~/svauto/misc/os-heat-templates/sandvine-stack-0.1-centos.yaml"
		echo
		echo "And re-run the \`cd ~/svauto ; ./svauto.sh\` script again, passing \"--stack=demo\""
		echo "as an argument to it."
		echo
		echo "Aborting!"
		exit 1
	fi


	if heat stack-show $STACK 2>&1 > /dev/null
	then
		echo
		echo "Stack found, proceeding..."
	else
		echo
		echo "Stack not found! Aborting..."
		exit 1
	fi


	PTS_FLOAT=$(nova floating-ip-list | grep `nova list | grep $STACK-pts | awk $'{print $2}'` | awk $'{print $4}')
	SDE_FLOAT=$(nova floating-ip-list | grep `nova list | grep $STACK-sde | awk $'{print $2}'` | awk $'{print $4}')
	SPB_FLOAT=$(nova floating-ip-list | grep `nova list | grep $STACK-spb | awk $'{print $2}'` | awk $'{print $4}')
	#CSD_FLOAT=$(nova floating-ip-list | grep `nova list | grep $STACK-csd | awk $'{print $2}'` | awk $'{print $4}')


	if [ -z $PTS_FLOAT ] || [ -z $SDE_FLOAT ] || [ -z $SPB_FLOAT ] #|| [ -z $CSD_FLOAT ]
	then
		echo
		echo "Warning! No compatible Instances was detected on your \"$STACK\" Stack!"
		echo "Possible causes are:"
		echo
		echo " * Missing Floating IP for one or more Sandvine's Instances."
		echo " * You're running a Stack that is not compatbile with Sandvine's rquirements."
		echo
		exit 1
	fi


	echo
	echo "The following Sandvine-compatible Instances (their Floating IPs) was detected on"
	echo "your \"$STACK\" Stack:"
	echo
	echo Floating IPs of:
	echo
	echo PTS: $PTS_FLOAT
	echo SDE: $SDE_FLOAT
	echo SPB: $SPB_FLOAT
	#echo CSD: $CSD_FLOAT

fi


echo
echo "Preparing the Ansible Playbooks to deploy Sandvine's RPM Packages..."


if [ ! "$LABIFY" == "yes" ]
then

	if [ "$FREEBSD_PTS" == "yes" ]
	then
		sed -i -e 's/^#FREEBSD_PTS_IP/'$PTS_FLOAT'/g' ansible/hosts
	else
		sed -i -e 's/^#PTS_IP/'$PTS_FLOAT'/g' ansible/hosts
	fi
	sed -i -e 's/^#SDE_IP/'$SDE_FLOAT'/g' ansible/hosts
	sed -i -e 's/^#SPB_IP/'$SPB_FLOAT'/g' ansible/hosts
	#sed -i -e 's/^#CSD_IP/'$CSD_FLOAT'/g' ansible/hosts

fi


if [ ! "$LABIFY" == "yes" ]
then

	if [ "$FREEBSD_PTS" == "yes" ]
	then

		if [ "$DRYRUN" == "yes" ]
		then
			echo
			echo "Not preparing FreeBSD! Skipping this step..."
		else
			echo
			echo "FreeBSD PTS detected, preparing it, by installing Python 2.7 sane version..."
			ssh -oStrictHostKeyChecking=no cloud@$PTS_FLOAT 'sudo pkg_add http://ftp-archive.freebsd.org/pub/FreeBSD-Archive/old-releases/amd64/8.2-RELEASE/packages/python/python27-2.7.1_1.tbz'
			sed -i -e 's/- role: pts.*/- role: pts-freebsd/g' ansible/site.yml
			echo "done."
		fi

	fi

fi

if [ "$LABIFY" == "yes" ]
then

	echo
	echo "Labfying the playbook, so it can work against lab's instances..."

	echo
	echo "You'll need to copy and paste each hostname here, after running profilemgr..."
	echo
	echo -n "Type the PTS hostname: "
	read PTS_HOSTNAME
	echo -n "Type the PTS Service IP: "
	read PTS_SRVC_IP
	echo
	echo -n "Type the SDE hostname: "
	read SDE_HOSTNAME
	echo -n "Type the SDE Service IP: "
	read SDE_SRVC_IP
	echo
	echo -n "Type the SPB hostname: "
	read SPB_HOSTNAME
	echo -n "Type the SPB Service IP: "
	read SPB_SRVC_IP
	echo -n "Type the Subscriber IPv4 Subnet/Mask (for subnets.txt on the PTS): "
	read INT_SUBNET


	LAB_DOMAIN="phaedrus.sandvine.com"

	PTS_FQDN=$PTS_HOSTNAME.$LAB_DOMAIN
	SDE_FQDN=$SDE_HOSTNAME.$LAB_DOMAIN
	SPB_FQDN=$SPB_HOSTNAME.$LAB_DOMAIN

	PTS_CTRL_IP=`host $PTS_FQDN | awk $'{print $4}'`
	SDE_CTRL_IP=`host $SDE_FQDN | awk $'{print $4}'`
	SPB_CTRL_IP=`host $SPB_FQDN | awk $'{print $4}'`
	#CSD_CTRL_IP=`host $PTS_FQDN | awk $'{print $4}'`


	echo
	echo "Configuring group_vars/all..."
	sed -i -e 's/int_subnet:.*/int_subnet: '$INT_SUBNET'/g' ansible/group_vars/all

	sed -i -e 's/pts_ctrl_ip:.*/pts_ctrl_ip: '$PTS_CTRL_IP'/g' ansible/group_vars/all
	sed -i -e 's/pts_srvc_ip:.*/pts_srvc_ip: '$PTS_SRVC_IP'/g' ansible/group_vars/all

	sed -i -e 's/sde_ctrl_ip:.*/sde_ctrl_ip: '$SDE_CTRL_IP'/g' ansible/group_vars/all
	sed -i -e 's/sde_srvc_ip:.*/sde_srvc_ip: '$SDE_SRVC_IP'/g' ansible/group_vars/all

	sed -i -e 's/csd_ctrl_ip:.*/csd_ctrl_ip: '$SDE_CTRL_IP'/g' ansible/group_vars/all
	sed -i -e 's/csd_srvc_ip:.*/csd_srvc_ip: '$SDE_SRVC_IP'/g' ansible/group_vars/all

	sed -i -e 's/spb_ctrl_ip:.*/spb_ctrl_ip: '$SPB_CTRL_IP'/g' ansible/group_vars/all
	sed -i -e 's/spb_srvc_ip:.*/spb_srvc_ip: '$SPB_SRVC_IP'/g' ansible/group_vars/all

	sed -i -e 's/ga_srvc_ip:.*/ga_srvc_ip: '$SDE_SRVC_IP'/g' ansible/group_vars/all


	echo
	echo "Configuring hosts..."
	if [ "$FREEBSD_PTS" == "yes" ]
	then
		sed -i -e 's/^#FREEBSD_PTS_IP/'$PTS_CTRL_IP'/g' ansible/hosts
	else
		sed -i -e 's/^#PTS_IP/'$PTS_CTRL_IP'/g' ansible/hosts
	fi
	sed -i -e 's/^#SDE_IP/'$SDE_CTRL_IP'/g' ansible/hosts
	sed -i -e 's/^#SPB_IP/'$SPB_CTRL_IP'/g' ansible/hosts
	#sed -i -e 's/^#CSD_IP/'$CSD_CTRL_IP'/g' ansible/hosts


	echo
	echo "FreeBSD PTS detected, preparing site-svqcow.yml file..."
	sed -i -e 's/- role: pts.*/- role: pts-freebsd/g' ansible/site-svqcow.yml

fi


if [ "$DRYRUN" == "yes" ]
then
	echo
	echo "Not running Ansible! Just preparing the environment variables and site.yml..."
else
	if [ ! "$LABIFY" == "yes" ]
	then
		echo
		echo "Deploying Sandvine's RPM Packages plus Cloud Services with Ansible..."

		echo
		cd ansible
		ansible-playbook site-cs.yml
	else
		echo
		echo "Configuring Sandvine Platform with Ansible..."

		echo
		cd ansible
		ansible-playbook site-svqcow.yml
	fi
fi


if [ ! "$LABIFY" == "yes" ]
then

	echo
	echo "If no errors reported by Ansible, then, well done!"
	echo
	echo "Your brand new Sandvine's Stack is reachable through SSH:"
	echo
	echo "ssh sandvine@$PTS_FLOAT # PTS"
	echo "ssh sandvine@$SDE_FLOAT # SDE"
	echo "ssh sandvine@$SPB_FLOAT # SPB"
	#echo "ssh sandvine@$CSD_FLOAT # CSD"
	echo

fi
