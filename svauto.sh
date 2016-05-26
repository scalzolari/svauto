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

	--bootstrap-svauto)

		BOOTSTRAP_SVAUTO="yes"
		shift
		;;

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

	--packer-build-sandvine)

		PACKER_BUILD_SANDVINE="yes"
		shift
		;;

	--packer-build-official)

		PACKER_BUILD_OFFICIAL="yes"
		shift
		;;

	--packer-build-cs)

		PACKER_BUILD_CS="yes"
		shift
		;;

	--packer-to-openstack)

		PACKER_TO_OS="yes"
		shift
		;;

	--move2webroot)

		MOVE2WEBROOT="yes"
		shift
		;;

	--heat-templates)

		HEAT_TEMPLATES="yes"
		shift
		;;

	--heat-templates-cs)

		HEAT_TEMPLATES_CS="yes"
		shift
		;;

	--libvirt-files)

		LIBVIRT_FILES="yes"
		shift
		;;

	--installation-helper)

		INSTALLATION_HELPER="yes"
		HEAT_TEMPLATES_CS="yes"
		LIBVIRT_FILES="yes"
		shift
		;;

	--release)

		RELEASE="yes"
		shift
		;;

	--yum-repo-builder)

		YUM_REPO_BUILDER="yes"
		shift
		;;

	--clean-all)

		CLEAN_ALL="yes"
		shift
		;;

	--dry-run)

		DRY_RUN="yes"
		shift
		;;

esac
done


if [ "$CLEAN_ALL" == "yes" ]
then

	echo
	echo "Cleaning it up..."

	[ -f build-date.txt ] && rm -f build-date.txt

	git checkout ansible/hosts ansible/group_vars/all

	rm -rf packer/build*

	rm -f tmp/cs-rel/* tmp/cs/* tmp/sv/*

	echo

	exit 0

fi


if [ "$BOOTSTRAP_SVAUTO" == "yes" ]
then

	echo
	echo "Installing SVAuto dependencies via APT:"
	echo

	sudo ~/svauto/scripts/bootstrap-svauto.sh

	exit 1

fi


if [ "$YUM_REPO_BUILDER" == "yes" ]
then

	#
	# PTS stuff
	#

	./yum-repo-builder.sh --release=dev --base-os=centos72 --product=svpts --version=7.30.0202 --latest
	./yum-repo-builder.sh --release=dev --base-os=centos67 --product=svpts --version=7.30.0035 --latest

	./yum-repo-builder.sh --release=dev --base-os=centos72 --product=svprotocols --version=16.03.2121 --latest
	./yum-repo-builder.sh --release=dev --base-os=centos67 --product=svprotocols --version=16.03.2121 --latest

	# Usage Management

	./yum-repo-builder.sh --release=dev --base-os=centos72 --product=svusagemanagementpts --version=5.20.0050 --latest
	./yum-repo-builder.sh --release=dev --base-os=centos67 --product=svusagemanagementpts --version=5.20.0050 --latest

	# Experimental

	./yum-repo-builder.sh --release=dev --base-os=centos72 --product=svpts --version=7.40.0019 --latest-of-serie
	./yum-repo-builder.sh --release=dev --base-os=centos67 --product=svpts --version=7.40.0019 --latest-of-serie


	#
	# SDE stuff
	#

	./yum-repo-builder.sh --release=dev --base-os=centos67 --product=svsde --version=7.45.0087 --latest

	# Usage Management

	./yum-repo-builder.sh --release=dev --base-os=centos67 --product=svusagemanagement --version=5.20.0050 --latest

	# Subscriber Mapping

	./yum-repo-builder.sh --release=dev --base-os=centos67 --product=svsubscribermapping --version=7.45.0003 --latest


	# Experimental

	./yum-repo-builder.sh --release=dev --base-os=centos72 --product=svsde --version=7.45.0087 --latest
	./yum-repo-builder.sh --release=dev --base-os=centos72 --product=svsde --version=7.50.0019 --latest-of-serie

	./yum-repo-builder.sh --release=dev --base-os=centos67 --product=svsde --version=7.45.0087 --latest-of-serie
	./yum-repo-builder.sh --release=dev --base-os=centos67 --product=svsde --version=7.50.0019 --latest-of-serie

	# Usage Management

	./yum-repo-builder.sh --release=dev --base-os=centos72 --product=svusagemanagement --version=5.20.0050 --latest

	# Subscriber Mapping

	./yum-repo-builder.sh --release=dev --base-os=centos67 --product=svsubscribermapping --version=7.45.0003 --latest-of-serie
#	./yum-repo-builder.sh --release=dev --base-os=centos67 --product=svsubscribermapping --version=7.45.0003 --latest-of-serie

	./yum-repo-builder.sh --release=dev --base-os=centos72 --product=subscriber_mapping --version=7.45-0003 --latest
#	./yum-repo-builder.sh --release=dev --base-os=centos72 --product=subscriber_mapping --version=7.45-0003 --latest-of-serie


	#
	# SPB stuff
	#

	./yum-repo-builder.sh --release=dev --base-os=centos67 --product=svspb --version=6.60.0530 --latest

	# NDS

	./yum-repo-builder.sh --release=dev --base-os=centos67 --product=svreports --version=6.65.0005 --latest


	# Experimental

	./yum-repo-builder.sh --release=dev --base-os=centos67 --product=svspb --version=7.00.0032 --latest-of-serie


	exit 1

fi


if [ "$MOVE2WEBROOT" == "yes" ]
then

        if [ "$DRY_RUN" == "yes" ]
        then
                echo
                echo "Not creating to web root directory structure! Skipping this step..."
        else

		# Create a file that contains the build date
		if  [ ! -f build-date.txt ]; then
			echo $TODAY > build-date.txt
			BUILD_DATE=`cat build-date.txt`
		else
			echo
			echo "Warning! Build Date file found, a clean all is recommended..."
			BUILD_DATE=`cat build-date.txt`
		fi


		# Web Public directory details

		# Apache or NGinx DocumentRoot of a Virtual Host:
		DOCUMENT_ROOT="public_dir"

		# Sandvine Stock images directory:
		WEB_ROOT_STOCK_MAIN=$DOCUMENT_ROOT/images/platform/stock

		WEB_ROOT_STOCK=$WEB_ROOT_STOCK_MAIN/$BUILD_DATE
		WEB_ROOT_STOCK_LAB=$WEB_ROOT_STOCK_MAIN/$BUILD_DATE/lab
		WEB_ROOT_STOCK_RELEASE=$WEB_ROOT_STOCK_MAIN/$BUILD_DATE/to-be-released
#		WEB_ROOT_STOCK_RELEASE_LAB=$WEB_ROOT_STOCK_MAIN/$BUILD_DATE/to-be-released/lab

		# Sandvine Stock mages + Cloud Services directory:
		WEB_ROOT_CS_MAIN=$DOCUMENT_ROOT/images/platform/cloud-services

		WEB_ROOT_CS=$WEB_ROOT_CS_MAIN/$BUILD_DATE
		WEB_ROOT_CS_LAB=$WEB_ROOT_CS_MAIN/$BUILD_DATE/lab
		WEB_ROOT_CS_RELEASE=$WEB_ROOT_CS_MAIN/$BUILD_DATE/to-be-released
#		WEB_ROOT_CS_RELEASE_LAB=$WEB_ROOT_CS_MAIN/$BUILD_DATE/to-be-released/lab


		echo
		echo "Creating web root directory structure..."

		# Creating the Web directory structure:
		mkdir -p $WEB_ROOT_STOCK_LAB
		mkdir -p $WEB_ROOT_STOCK_RELEASE

		mkdir -p $WEB_ROOT_CS_LAB
		mkdir -p $WEB_ROOT_CS_RELEASE

	fi

fi


if [ "$PACKER_BUILD_CS" == "yes" ] && [ "$RELEASE" == "yes" ]
then


	RELEASE="16.02"


        if [ "$DRY_RUN" == "yes" ]
        then
                echo
                echo "Not requesting FTP account details on dry run! Skipping this step..."
        else
		echo
		echo "Enter your Sandvine's FTP (ftp.support.sandvine.com) account details:"
		echo
		echo -n "Username: "
		read FTP_USER
		echo -n "Password: "
		read -s FTP_PASS

        	sed -i -e 's/ftp_username:.*/ftp_username: '$FTP_USER'/g' ansible/group_vars/all
        	sed -i -e 's/ftp_password:.*/ftp_password: '$FTP_PASS'/g' ansible/group_vars/all
	fi


        if [ "$DRY_RUN" == "yes" ]; then
                export DRY_RUN_OPT="--dry-run"
        fi


	#
	# Production ready images for being released to the public
	#

	# SDE 7.45 on CentOS 6 + Cloud Services SDE + Cloud Services Daemon (back / front)
	./image-factory.sh --release=prod --base-os=centos67 --base-os-upgrade --product=cs-svsde --version=$RELEASE --qcow2 --ova --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,svcs-svsde,svcs,vmware-tools,cleanrepo,post-cleanup $DRY_RUN_OPT

	# SDE 7.45 on CentOS 6 + Cloud Services SDE + Cloud Services Daemon (back / front) - Labified
#	./image-factory.sh --release=prod --base-os=centos67 --base-os-upgrade --product=cs-svsde --version=$RELEASE --qcow2 --vmdk --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,svcs-svsde,svcs,vmware-tools,cleanrepo,post-cleanup --labify $DRY_RUN_OPT

	# SPB 6.60 on CentOS 6 + Cloud Services customizations
	./image-factory.sh --release=prod --base-os=centos67 --base-os-upgrade --product=cs-svspb --version=$RELEASE --qcow2 --ova --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svspb,svmcdtext,svreports,svcs-svspb,vmware-tools,cleanrepo,post-cleanup $DRY_RUN_OPT

	# SPB 6.60 on CentOS 6 - Cloud Services customizations - Labified
#	./image-factory.sh --release=prod --base-os=centos67 --base-os-upgrade --product=cs-svspb --version=$RELEASE --qcow2 --vmdk --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svspb,svmcdtext,svreports,svcs-svspb,vmware-tools,cleanrepo,post-cleanup --labify $DRY_RUN_OPT

	# PTS 7.30 on CentOS 7 + Cloud Services customizations
	./image-factory.sh --release=prod --base-os=centos72 --base-os-upgrade --product=cs-svpts --version=$RELEASE --qcow2 --ova --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,svusagemanagementpts,svcs-svpts,vmware-tools,cleanrepo,post-cleanup $DRY_RUN_OPT \
		--lock-el7-kernel-upgrade

	# PTS 7.30 on CentOS 7 + Cloud Services customizations - Labified
#	./image-factory.sh --release=prod --base-os=centos72 --base-os-upgrade --product=cs-svpts --version=$RELEASE --qcow2 --vmdk --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svpts,svusagemanagementpts,svcs-svpts,vmware-tools,cleanrepo,post-cleanup --labify $DRY_RUN_OPT


	if [ "$HEAT_TEMPLATES_CS" == "yes" ]
	then

                if [ "$DRY_RUN" == "yes" ]
                then

                        echo
                        echo "Not copying Heat Templates! Skipping this step..."

                else

			echo
			echo "Copying Cloud Services Heat Templates for release into tmp/cs-rel subdirectory..."

			cp misc/os-heat-templates/sandvine-stack-0.1* tmp/cs-rel
			cp misc/os-heat-templates/sandvine-stack-nubo-0.1* tmp/cs-rel

			sed -i -e 's/{{pts_image}}/cs-svpts-'$RELEASE'-centos7-amd64/g' tmp/cs-rel/*.yaml
			sed -i -e 's/{{sde_image}}/cs-svsde-'$RELEASE'-centos6-amd64/g' tmp/cs-rel/*.yaml
			sed -i -e 's/{{spb_image}}/cs-svspb-'$RELEASE'-centos6-amd64/g' tmp/cs-rel/*.yaml
			#sed -i -e 's/{{csd_image}}/cs-svcsd-'$RELEASE'-centos6-amd64/g' tmp/cs-rel/*.yaml

		fi

	fi


	if [ "$LIBVIRT_FILES" == "yes" ]
	then

                if [ "$DRY_RUN" == "yes" ]
                then

                        echo
                        echo "Not copying Libvirt files! Skipping this step..."

                else

			echo
			echo "Copying Libvirt files for release into tmp/cs-rel subdirectory..."

			cp misc/libvirt/* tmp/cs-rel/

			find packer/build* -name "*.xml" -exec cp {} tmp/cs-rel/ \;

			sed -i -e 's/{{sde_image}}/cs-svsde-'$RELEASE'-centos6-amd64/g' tmp/cs-rel/libvirt-qemu.hook

		fi

	fi


	if [ "$MOVE2WEBROOT" == "yes" ]
	then

                if [ "$DRY_RUN" == "yes" ]
                then
                        echo
                        echo "Not moving to web root! Skipping this step..."
                else

			echo
			echo "Moving all images created during this build, to the Web Root."
			echo "Also, doing some clean ups, to free the way for subsequent builds..."
	
			find packer/build* -name "*.raw" -exec rm -f {} \;
	
#			find packer/build-lab* -name "*.md5" -exec mv {} $WEB_ROOT_CS_RELEASE_LAB \;
			find packer/build* -name "*.md5" -exec mv {} $WEB_ROOT_CS_RELEASE \;

#			find packer/build-lab* -name "*.sha1" -exec mv {} $WEB_ROOT_CS_RELEASE_LAB\;
			find packer/build* -name "*.sha1" -exec mv {} $WEB_ROOT_CS_RELEASE \;

#			find packer/build-lab* -name "*.xml" -exec mv {} $WEB_ROOT_CS_RELEASE_LAB \;
			find packer/build* -name "*.xml" -exec mv {} $WEB_ROOT_CS_RELEASE \;

#			find packer/build-lab* -name "*.qcow2c" -exec mv {} $WEB_ROOT_CS_RELEASE_LAB \;
			find packer/build* -name "*.qcow2c" -exec mv {} $WEB_ROOT_CS_RELEASE \;

#			find packer/build-lab* -name "*.vmdk" -exec mv {} $WEB_ROOT_CS_RELEASE_LAB \;
			find packer/build* -name "*.vmdk" -exec mv {} $WEB_ROOT_CS_RELEASE \;

#			find packer/build-lab* -name "*.vhd*" -exec mv {} $WEB_ROOT_CS_RELEASE_LAB \;
			find packer/build* -name "*.vhd*" -exec mv {} $WEB_ROOT_CS_RELEASE \;

#			find packer/build-lab* -name "*.ova" -exec mv {} $WEB_ROOT_CS_RELEASE_LAB \;
			find packer/build* -name "*.ova" -exec mv {} $WEB_ROOT_CS_RELEASE \;


#			echo
#			echo "Merging MD5SUMS files together..."

#			cd $WEB_ROOT_CS_RELEASE_LAB

#			cat *.md5 > MD5SUMS
#			rm -f *.md5

#			echo
#			echo "Merging SHA1SUMS files together..."

#			cat *.sha1 > SHA1SUMS
#			rm -f *.sha1

#			cd - &>/dev/null


			echo
			echo "Merging MD5SUMS files together..."

			cd $WEB_ROOT_CS_RELEASE

			cat *.md5 > MD5SUMS
			rm -f *.md5

			echo
			echo "Merging SHA1SUMS files together..."

			cat *.sha1 > SHA1SUMS
			rm -f *.sha1

			cd - &>/dev/null


			if [ "$HEAT_TEMPLATES_CS" == "yes" ]
			then

				echo
				echo "Copying Cloud Services Heat Templates for release into public web subdirectory..."

				cp tmp/cs-rel/sandvine-stack-0.1-three-1.yaml $WEB_ROOT_CS_RELEASE/cloudservices-stack-$RELEASE-1.yaml
				cp tmp/cs-rel/sandvine-stack-0.1-three-flat-1.yaml $WEB_ROOT_CS_RELEASE/cloudservices-stack-$RELEASE-flat-1.yaml
				cp tmp/cs-rel/sandvine-stack-0.1-three-vlan-1.yaml $WEB_ROOT_CS_RELEASE/cloudservices-stack-$RELEASE-vlan-1.yaml
				cp tmp/cs-rel/sandvine-stack-0.1-three-rad-1.yaml $WEB_ROOT_CS_RELEASE/cloudservices-stack-$RELEASE-rad-1.yaml
				cp tmp/cs-rel/sandvine-stack-nubo-0.1-stock-gui-1.yaml $WEB_ROOT_CS_RELEASE/cloudservices-stack-nubo-$RELEASE-stock-gui-1.yaml
				#cp tmp/cs-rel/sandvine-stack-0.1-four-1.yaml $WEB_ROOT_CS_RELEASE/cloudservices-stack-$RELEASE-micro-1.yaml

			fi


			if [ "$INSTALLATION_HELPER" == "yes" ]
			then

				echo
				echo "Creating Cloud Services installation helper script..."

				cp misc/self-extract/* tmp/cs-rel/

				cd tmp/cs-rel/

				mv sandvine-stack-0.1-three-1.yaml cloudservices-stack-$RELEASE-1.yaml
				mv sandvine-stack-0.1-three-flat-1.yaml cloudservices-stack-$RELEASE-flat-1.yaml
				mv sandvine-stack-0.1-three-vlan-1.yaml cloudservices-stack-$RELEASE-vlan-1.yaml
				mv sandvine-stack-0.1-three-rad-1.yaml cloudservices-stack-$RELEASE-rad-1.yaml
				mv sandvine-stack-nubo-0.1-stock-gui-1.yaml cloudservices-stack-nubo-$RELEASE-stock-gui-1.yaml
				#mv sandvine-stack-0.1-four-1.yaml cloudservices-stack-$RELEASE-four-1.yaml

				rm sandvine-stack-0.1-four-1.yaml

				mv libvirt-qemu.hook cs-svsde-$RELEASE-centos6-amd64.hook

				tar -cf sandvine-files.tar *.yaml *.hook *.xml

				cat extract.sh sandvine-files.tar > sandvine-helper.sh_tail

				sed -i -e 's/{{sandvine_release}}/'$RELEASE'/g' sandvine-helper.sh_template

				cat sandvine-helper.sh_template sandvine-helper.sh_tail > cloudservices-helper.sh

				chmod +x cloudservices-helper.sh

				cd - &>/dev/null

				cp tmp/cs-rel/cloudservices-helper.sh $WEB_ROOT_CS_RELEASE

			fi


			# Free the way for subsequent builds:
			rm -rf packer/build*

		fi

	fi

	exit 0

fi


if [ "$PACKER_BUILD_CS" == "yes" ]
then

	if [ "$DRY_RUN" == "yes" ]; then
		export DRY_RUN_OPT="--dry-run"
	fi


	#
	# STABLE
	#

	# SDE 7.45 on CentOS 6 + Cloud Services SDE + Cloud Services Daemon (back / front)
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.45 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,svcs-svsde,svcs,vmware-tools,post-cleanup $DRY_RUN_OPT

	# SDE 7.45 on CentOS 6 + Cloud Services SDE + Cloud Services Daemon (back / front) - Labified
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.45 --product-variant=cs-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,svcs-svsde,svcs,vmware-tools,post-cleanup $DRY_RUN_OPT --labify

	# SPB 6.60 on CentOS 6 + Cloud Services
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svspb --version=6.60 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svspb,svmcdtext,svreports,svcs-svspb,vmware-tools,post-cleanup $DRY_RUN_OPT

	# SPB 6.60 on CentOS 6 + Cloud Services - Labified
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svspb --version=6.60 --product-variant=cs-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svspb,svmcdtext,svreports,svcs-svspb,vmware-tools,post-cleanup $DRY_RUN_OPT --labify

	# PTS 7.30 on CentOS 7 + Cloud Services - Linux 3.10, old DPDK 2.2, requires igb_uio
	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svpts --version=7.30 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,svusagemanagementpts,svcs-svpts,vmware-tools,post-cleanup $DRY_RUN_OPT

	# PTS 7.30 on CentOS 7 + Cloud Services - Linux 3.10, old DPDK 2.2  requires igb_uio - Labified - Regular builds, no hack needed
	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svpts --version=7.30 --product-variant=cs-1 --qcow2 --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,svusagemanagementpts,svcs-svpts,vmware-tools,post-cleanup $DRY_RUN_OPT --labify

	# PTS 7.30 on CentOS 7 + Cloud Services - Linux 3.10, old DPDK 2.2  requires igb_uio - Labified - Includes the VMWare hack for the lab
	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svpts --version=7.30 --product-variant=cs-1 --vmdk --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,svusagemanagementpts,svcs-svpts,vmware-tools,post-cleanup $DRY_RUN_OPT --labify \
		--setup-default-interface-script

	# SDE 7.30 on CentOS 6 + Cloud Services SDE only - No Cloud Services daemon here!
#	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.30 --product-variant=sde-cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,svcs-svsde,vmware-tools,post-cleanup $DRY_RUN_OPT

	# Cloud Services Daemon 7.40 (back / front) on CentOS 6 - No SDE here!
#	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svcsd --version=7.40 --product-variant=csd-cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=centos-xen,cloud-init,bootstrap,grub-conf,svcs,vmware-tools,post-cleanup $DRY_RUN_OPT


	#
	# EXPERIMENTAL
	#

	# SDE 7.50 on CentOS 7
#	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svsde --version=7.50 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=centos-xen,cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,vmware-tools,post-cleanup $DRY_RUN_OPT

	# SDE 7.50 on CentOS 7
#	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svsde --version=7.50 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=centos-xen,cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,vmware-tools,post-cleanup --versioned-repo $DRY_RUN_OPT

       	# SDE 7.45 on CentOS 6
#	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.45 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,svcs-svsde,svcs,vmware-tools,post-cleanup --versioned-repo $DRY_RUN_OPT

       	# SDE 7.40 on CentOS 6
#	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.40 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,svcs-svsde,svcs,vmware-tools,post-cleanup --versioned-repo $DRY_RUN_OPT

	# SPB 7.00 on CentOS 6
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svspb --version=7.00 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svspb,vmware-tools,post-cleanup --versioned-repo $DRY_RUN_OPT

	#
	# BUILD ENVIRONMENT
	#

	# Cloud Services Build Server (back / front) on CentOS 6.7 (new Golang 1.5)
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=centos --version=6.7 --product-variant=build-srv-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
	        --roles=centos-xen,cloud-init,bootstrap,grub-conf,golang-env,nodejs-env,vmware-tools,post-cleanup $DRY_RUN_OPT

	# Cloud Services Build Server (back / front) on CentOS 7.2 (old Golang 1.4)
	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=centos --version=7.2 --product-variant=build-srv-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
	        --roles=centos-xen,cloud-init,bootstrap,grub-conf,golang-env,nodejs-env,vmware-tools,post-cleanup $DRY_RUN_OPT


	# Cloud Services Build Server (back) on CentOS 6.7 (new Golang 1.5)
#	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=centos --version=6.7 --product-variant=go-build-srv-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#	        --roles=centos-xen,cloud-init,bootstrap,grub-conf,golang-env,vmware-tools,post-cleanup $DRY_RUN_OPT

	# Cloud Services Build Server (front) on CentOS 6.7 (NodeJS)
#	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=centos --version=6.7 --product-variant=nodejs-build-srv-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#	        --roles=centos-xen,cloud-init,bootstrap,grub-conf,nodejs-env,vmware-tools,post-cleanup $DRY_RUN_OPT


	# Cloud Services Build Server (back) on CentOS 7.2 (old Golang 1.4)
#	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=centos --version=7.2 --product-variant=go-build-srv-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#	        --roles=centos-xen,cloud-init,bootstrap,grub-conf,golang-env,vmware-tools,post-cleanup $DRY_RUN_OPT

	# Cloud Services Build Server (front) on CentOS 7.2 (NodeJS)
#	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=centos --version=7.2 --product-variant=nodejs-build-srv-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#	        --roles=centos-xen,cloud-init,bootstrap,grub-conf,nodejs-env,vmware-tools,post-cleanup $DRY_RUN_OPT


	if [ "$HEAT_TEMPLATES_CS" == "yes" ]
	then

                if [ "$DRY_RUN" == "yes" ]
                then

                        echo
                        echo "Not copying Heat Templates! Skipping this step..."

                else

			echo
			echo "Copying Cloud Services Heat Templates into tmp/cs subdirectory..."

			cp misc/os-heat-templates/sandvine-stack-0.1* tmp/cs
			cp misc/os-heat-templates/sandvine-stack-nubo-0.1* tmp/cs

			sed -i -e 's/{{pts_image}}/svpts-7.30-cs-1-centos7-amd64/g' tmp/cs/*.yaml
			sed -i -e 's/{{sde_image}}/svsde-7.30-cs-1-centos6-amd64/g' tmp/cs/*.yaml
			sed -i -e 's/{{spb_image}}/svspb-6.60-cs-1-centos6-amd64/g' tmp/cs/*.yaml
			#sed -i -e 's/{{csd_image}}/svcsd-7.40-csd-cs-1-centos6-amd64/g' tmp/cs/*.yaml

		fi

	fi


	if [ "$LIBVIRT_FILES" == "yes" ]
	then

                if [ "$DRY_RUN" == "yes" ]
                then

                        echo
                        echo "Not copying Libvirt files! Skipping this step..."

                else

			echo
			echo "Copying Libvirt files for release into tmp/cs subdirectory..."

			cp misc/libvirt/* tmp/cs/

			find packer/build* -name "*.xml" -exec cp {} tmp/cs/ \;

			sed -i -e 's/{{sde_image}}/svsde-7.30-cs-1-centos6-amd64/g' tmp/cs/libvirt-qemu.hook

		fi

	fi


	if [ "$MOVE2WEBROOT" == "yes" ]
	then

                if [ "$DRY_RUN" == "yes" ]
                then
                        echo
                        echo "Not moving to web root! Skipping this step..."
                else

			echo
			echo "Moving all images created during this build, to the Web Root."
			echo "Also, doing some clean ups, to free the way for subsequent builds..."


			find packer/build* -name "*.raw" -exec rm -f {} \;


			find packer/build-lab* -name "*.md5" -exec mv {} $WEB_ROOT_CS_LAB \;
			find packer/build* -name "*.md5" -exec mv {} $WEB_ROOT_CS \;

			find packer/build-lab* -name "*.sha1" -exec mv {} $WEB_ROOT_CS_LAB \;
			find packer/build* -name "*.sha1" -exec mv {} $WEB_ROOT_CS \;

			find packer/build-lab* -name "*.xml" -exec mv {} $WEB_ROOT_CS_LAB \;
			find packer/build* -name "*.xml" -exec mv {} $WEB_ROOT_CS \;

			find packer/build-lab* -name "*.qcow2c" -exec mv {} $WEB_ROOT_CS_LAB \;
			find packer/build* -name "*.qcow2c" -exec mv {} $WEB_ROOT_CS \;

			find packer/build-lab* -name "*.vmdk" -exec mv {} $WEB_ROOT_CS_LAB \;
#			find packer/build* -name "*.vmdk" -exec mv {} $WEB_ROOT_CS \;

			find packer/build-lab* -name "*.vhd*" -exec mv {} $WEB_ROOT_CS_LAB \;
			find packer/build* -name "*.vhd*" -exec mv {} $WEB_ROOT_CS \;

			find packer/build-lab* -name "*.ova" -exec mv {} $WEB_ROOT_CS_LAB \;
			find packer/build* -name "*.ova" -exec mv {} $WEB_ROOT_CS \;


			echo
			echo "Merging MD5SUMS files together (lab)..."

			cd $WEB_ROOT_CS_LAB

			cat *.md5 > MD5SUMS
			rm -f *.md5

			echo
			echo "Merging SHA1SUMS files together (lab)..."

			cat *.sha1 > SHA1SUMS
			rm -f *.sha1

			cd - &>/dev/null


			echo
			echo "Merging MD5SUMS files together..."

			cd $WEB_ROOT_CS

			cat *.md5 > MD5SUMS
			rm -f *.md5

			echo
			echo "Merging SHA1SUMS files together..."

			cat *.sha1 > SHA1SUMS
			rm -f *.sha1

			cd - &>/dev/null


        	        echo
        	        echo "Updating symbolic link \"current\" to point to \"$BUILD_DATE\"..."

			cd $WEB_ROOT_CS_MAIN

			rm -f current
			ln -s $BUILD_DATE current

			cd - &>/dev/null


			if [ "$HEAT_TEMPLATES_CS" == "yes" ]
			then

				echo
				echo "Copying Cloud Services Heat Templates into web public subdirectory..."

				cp tmp/cs/sandvine-stack-0.1-three-1.yaml $WEB_ROOT_CS/cloudservices-stack-0.1.yaml
				cp tmp/cs/sandvine-stack-0.1-three-flat-1.yaml $WEB_ROOT_CS/cloudservices-stack-0.1-flat-1.yaml
				cp tmp/cs/sandvine-stack-0.1-three-vlan-1.yaml $WEB_ROOT_CS/cloudservices-stack-0.1-vlan-1.yaml
				cp tmp/cs/sandvine-stack-0.1-three-rad-1.yaml $WEB_ROOT_CS/cloudservices-stack-0.1-rad-1.yaml
				cp tmp/cs/sandvine-stack-nubo-0.1-stock-gui-1.yaml $WEB_ROOT_CS/cloudservices-stack-nubo-0.1-stock-gui-1.yaml
				#cp tmp/cs/sandvine-stack-0.1-four-1.yaml $WEB_ROOT_CS/cloudservices-stack-0.1-four-1.yaml

			fi


			if [ "$INSTALLATION_HELPER" == "yes" ]
			then

				echo
				echo "Creating Cloud Services installation helper script (dev)..."

				cp misc/self-extract/* tmp/cs/

				cd tmp/cs/

				tar -cf sandvine-files.tar *.yaml *.hook *.xml

				cat extract.sh sandvine-files.tar > sandvine-helper.sh_tail

				sed -i -e 's/{{sandvine_release}}/'$RELEASE'/g' sandvine-helper.sh_template

				cat sandvine-helper.sh_template sandvine-helper.sh_tail > sandvine-cs-helper.sh

				chmod +x sandvine-cs-helper.sh

				cd - &>/dev/null

				cp tmp/cs/sandvine-cs-helper.sh $WEB_ROOT_CS

			fi


			# Free the way for subsequent builds:
			rm -rf packer/build*

		fi

	fi

	exit 0

fi


if [ "$PACKER_BUILD_OFFICIAL" == "yes" ]
then

	if [ "$DRY_RUN" == "yes" ]; then
		export DRY_RUN_OPT="--dry-run"
	fi


	#
	# Examples
	#

	# Ubuntu Trusty 14.04.3 - Blank server
#	./image-factory.sh --release=dev --base-os=ubuntu14 --base-os-upgrade --product=ubuntu --version=14.04 --product-variant=r1 --qcow2 --md5sum --sha1sum

	# Ubuntu Trusty 14.04.3 - SVAuto bootstraped
#	./image-factory.sh --release=dev --base-os=ubuntu14 --base-os-upgrade --product=ubuntu --version=14.04 --product-variant=r1 --qcow2 --md5sum --sha1sum \
#		--roles=bootstrap,post-cleanup $DRY_RUN_OPT

	# Ubuntu Xenial 16.04 - Blank server
#	./image-factory.sh --release=dev --base-os=ubuntu16 --base-os-upgrade --product=ubuntu --version=16.04 --product-variant=r1 --qcow2 --md5sum --sha1sum

	# CentOS 6.7 - SVAuto bootstraped - Old Linux 2.6
#	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=centos --version=6.7 --product-variant=sv-1 --qcow2 --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,post-cleanup $DRY_RUN_OPT

	# CentOS 6.7 - SVAuto bootstraped - Linux 3.18 from Xen 4.4 CentOS Repo - Much better KVM / Xen support
#	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=centos --version=6.7 --product-variant=sv-1 --qcow2 --vm-xml --md5sum --sha1sum \
#		--roles=centos-xen,cloud-init,bootstrap,grub-conf,post-cleanup $DRY_RUN_OPT

	# CentOS 7.2 - SVAuto bootstraped - Old Linux 3.10
#	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=centos --version=7.1 --product-variant=sv-1 --qcow2 --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,post-cleanup $DRY_RUN_OPT

	# CentOS 7.2 - SVAuto bootstraped - Linux 3.18 from Xen 4.6 CentOS Repo - Much better KVM / Xen support
#	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=centos --version=7.1 --product-variant=sv-1 --qcow2 --vm-xml --md5sum --sha1sum \
#		--roles=centos-xen,cloud-init,bootstrap,grub-conf,post-cleanup $DRY_RUN_OPT


	#
	# STABLE
	#

	# PTS 7.30 on CentOS 6 - Linux 2.6, old DPDK 1.8, requires igb_uio
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svpts --version=7.30 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup $DRY_RUN_OPT

	# PTS 7.30 on CentOS 7 - Linux 3.10, DPDK 2.2, requires igb_uio
	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svpts --version=7.30 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup $DRY_RUN_OPT

	# SDE 7.45 on CentOS 6
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.45 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,vmware-tools,post-cleanup $DRY_RUN_OPT

	# SDE 7.45 on CentOS 7
	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svsde --version=7.45 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=centos-xen,cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,vmware-tools,post-cleanup $DRY_RUN_OPT

       	# SDE 7.45 on CentOS 6
#	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.40 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,vmware-tools,post-cleanup $DRY_RUN_OPT --versioned-repo

	# SPB 6.60 on CentOS 6 - No NDS
#	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svspb --version=6.60 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svspb,vmware-tools,post-cleanup $DRY_RUN_OPT


	#
	# EXPERIMENTAL
	#

	# PTS 7.40 on CentOS 6 - Linux 2.6, old DPDK 1.8, requires igb_uio
#	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svpts --version=7.40 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup $DRY_RUN_OPT --versioned-repo

	# PTS 7.40 on CentOS 7 - Linux 3.10, old DPDK 1.8, requires igb_uio
#	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svpts --version=7.40 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup $DRY_RUN_OPT --versioned-repo

	# PTS 7.40 on CentOS 6 - Linux 3.18 from Xen 4.4 Repo + DPDK 2.1 with Xen Support, no igb_uio needed
#	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svpts --version=7.40 --product-variant=xen-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=centos-xen,cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup $DRY_RUN_OPT --versioned-repo --experimental-repo

	# PTS 7.40 on CentOS 7 - Linux 3.18 from Xen 4.6 Repo + DPDK 2.1 with Xen Support, no igb_uio needed
#	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svpts --version=7.40 --product-variant=xen-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=centos-xen,cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup $DRY_RUN_OPT --versioned-repo --experimental-repo

	# SDE 7.45 on CentOS 7
	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svsde --version=7.45 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=centos-xen,cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,vmware-tools,post-cleanup --versioned-repo $DRY_RUN_OPT

       	# SDE 7.45 on CentOS 6
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.45 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,vmware-tools,post-cleanup --versioned-repo $DRY_RUN_OPT

	# SPB 7.00 on CentOS 6 - No NDS
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svspb --version=7.00 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svspb,vmware-tools,post-cleanup $DRY_RUN_OPT --versioned-repo


	if [ "$HEAT_TEMPLATES" == "yes" ]
	then

                if [ "$DRY_RUN" == "yes" ]
                then

                        echo
                        echo "Not copying Heat Templates! Skipping this step..."

                else

			echo
			echo "Copying Sandvine's Heat Templates into tmp/sv subdirectory..."

			cp misc/os-heat-templates/sandvine-stack-0.1* tmp/sv
			cp misc/os-heat-templates/sandvine-stack-nubo-0.1* tmp/sv

			sed -i -e 's/{{pts_image}}/svpts-7.30-1-centos7-amd64/g' tmp/sv/*.yaml
			sed -i -e 's/{{sde_image}}/svsde-7.30-1-centos6-amd64/g' tmp/sv/*.yaml
			sed -i -e 's/{{spb_image}}/svspb-6.60-1-centos6-amd64/g' tmp/sv/*.yaml
			#sed -i -e 's/{{csd_image}}/svcsd-7.40-csd-1-centos6-amd64/g' tmp/sv/*.yaml

		fi

	fi


	if [ "$LIBVIRT_FILES" == "yes" ]
	then

                if [ "$DRY_RUN" == "yes" ]
                then

                        echo
                        echo "Not copying Libvirt files! Skipping this step..."

                else

			echo
			echo "Copying Libvirt files for release into tmp/cs subdirectory..."

			cp misc/libvirt/* tmp/sv/

			find packer/build* -name "*.xml" -exec cp {} tmp/sv/ \;

			sed -i -e 's/{{sde_image}}/svsde-7.30-1-centos6-amd64/g' tmp/sv/libvirt-qemu.hook

		fi

	fi


	if [ "$MOVE2WEBROOT" == "yes" ]
	then

                if [ "$DRY_RUN" == "yes" ]
                then
                        echo
                        echo "Not moving to web root! Skipping this step..."
                else

			echo
			echo "Moving all images created during this build, to the Web Root."
			echo "Also, doing some clean ups, to free the way for subsequent builds..."


			find packer/build* -name "*.raw" -exec rm -f {} \;


#			find packer/build-lab* -name "*.md5" -exec mv {} $WEB_ROOT_STOCK_LAB \;
			find packer/build* -name "*.md5" -exec mv {} $WEB_ROOT_STOCK \;

#			find packer/build-lab* -name "*.sha1" -exec mv {} $WEB_ROOT_STOCK_LAB \;
			find packer/build* -name "*.sha1" -exec mv {} $WEB_ROOT_STOCK \;

#			find packer/build-lab* -name "*.xml" -exec mv {} $WEB_ROOT_STOCK_LAB \;
			find packer/build* -name "*.xml" -exec mv {} $WEB_ROOT_STOCK \;

#			find packer/build-lab* -name "*.qcow2c" -exec mv {} $WEB_ROOT_STOCK_LAB \;
			find packer/build* -name "*.qcow2c" -exec mv {} $WEB_ROOT_STOCK \;

#			find packer/build-lab* -name "*.vmdk" -exec mv {} $WEB_ROOT_STOCK_LAB \;
#			find packer/build* -name "*.vmdk" -exec mv {} $WEB_ROOT_STOCK \;

#			find packer/build-lab* -name "*.vhd*" -exec mv {} $WEB_ROOT_STOCK_LAB \;
			find packer/build* -name "*.vhd*" -exec mv {} $WEB_ROOT_STOCK \;

#			find packer/build-lab* -name "*.ova" -exec mv {} $WEB_ROOT_STOCK_LAB \;
			find packer/build* -name "*.ova" -exec mv {} $WEB_ROOT_STOCK \;


#			echo
#			echo "Merging MD5SUMS files together (lab)..."

#			cd $WEB_ROOT_STOCK_LAB

#			cat *.md5 > MD5SUMS
#			rm -f *.md5

#			echo
#			echo "Merging SHA1SUMS files together (lab)..."

#			cat *.sha1 > SHA1SUMS
#			rm -f *.sha1

#			cd - &>/dev/null


			echo
			echo "Merging MD5SUMS files together..."

			cd $WEB_ROOT_STOCK

			cat *.md5 > MD5SUMS
			rm -f *.md5

			echo
			echo "Merging SHA1SUMS files together..."

			cat *.sha1 > SHA1SUMS
			rm -f *.sha1

			cd - &>/dev/null


                	echo
                	echo "Updating symbolic link \"current\" to point to \"$BUILD_DATE\"..."

			cd $WEB_ROOT_STOCK_MAIN

			rm -f current
			ln -s $BUILD_DATE current

			cd - &>/dev/null


			if [ "$HEAT_TEMPLATES" == "yes" ]
			then

				echo
				echo "Copying Sandvine's Heat Templates into web public subdirectory..."

				cp tmp/sv/sandvine-stack-0.1-three-1.yaml $WEB_ROOT_STOCK/sandvine-stack-0.1-three-1.yaml
				cp tmp/sv/sandvine-stack-0.1-three-flat-1.yaml $WEB_ROOT_STOCK/sandvine-stack-0.1-three-flat-1.yaml
				cp tmp/sv/sandvine-stack-0.1-three-vlan-1.yaml $WEB_ROOT_STOCK/sandvine-stack-0.1-three-vlan-1.yaml
				cp tmp/sv/sandvine-stack-0.1-three-rad-1.yaml $WEB_ROOT_STOCK/sandvine-stack-0.1-three-rad-1.yaml
				cp tmp/sv/sandvine-stack-nubo-0.1-stock-gui-1.yaml $WEB_ROOT_STOCK/sandvine-stack-nubo-0.1-stock-gui-1.yaml
				#cp tmp/sv/sandvine-stack-0.1-four-1.yaml $WEB_ROOT_STOCK/sandvine-stack-0.1-four-1.yaml

			fi


			if [ "$INSTALLATION_HELPER" == "yes" ]
			then

				echo
				echo "Creating Sandvine installation helper script (dev)..."

				cp misc/self-extract/* tmp/sv/

				cd tmp/sv/

				tar -cf sandvine-files.tar *.yaml *.hook *.xml

				cat extract.sh sandvine-files.tar > sandvine-helper.sh_tail

				sed -i -e 's/{{sandvine_release}}/'$RELEASE'/g' sandvine-helper.sh_template

				cat sandvine-helper.sh_template sandvine-helper.sh_tail > sandvine-helper.sh

				chmod +x sandvine-helper.sh

				cd - &>/dev/null

				cp tmp/sv/sandvine-helper.sh $WEB_ROOT_STOCK

			fi


			# Free the way for subsequent builds:
			rm -rf packer/build*

		fi

	fi

	exit 0

fi


if [ "$PACKER_BUILD_SANDVINE" == "yes" ]
then

	if [ "$DRY_RUN" == "yes" ]; then
		export DRY_RUN_OPT="--dry-run"
	fi


	# Linux SVPTS 7.30 on CentOS 7.2
	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svpts --version=7.30.0202 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVPTS 7.30 on CentOS 7.2 - Regular builds
	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svpts --version=7.30.0202 --product-variant=vpl-1 --qcow2 --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify

	# Linux SVPTS 7.30 on CentOS 7.2 - VMWare hack
	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svpts --version=7.30.0202 --product-variant=vpl-1 --vmdk --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify \
		--setup-default-interface-script


	# Linux SVPTS 7.30 on CentOS 6.7
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svpts --version=7.30.0035 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVPTS 7.30 on CentOS 6.7
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svpts --version=7.30.0035 --product-variant=vpl-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify


	# Linux SVSDE 7.45 on CentOS 6.7
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.45.0087 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVSDE 7.45 on CentSO 6.7
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.45.0087 --product-variant=vpl-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify


	# Linux SVSDE 7.40 on CentOS 6.7
#	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.40.0025 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVSDE 7.40 on CentSO 6.7
#	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.40.0025 --product-variant=vpl-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify


	# Linux SVSDE 7.40 on CentOS 7.2
#	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svsde --version=7.40.0025 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVSDE 7.40 on CentSO 7.2
#	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svsde --version=7.40.0025 --product-variant=vpl-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify


	# Linux SVSDE 7.45 on CentOS 7.2
#	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svsde --version=7.45.0078 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVSDE 7.45 on CentSO 7.2
#	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svsde --version=7.45.0078 --product-variant=vpl-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify


	# Linux SVSPB 6.60 on CentOS 6.7
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svspb --version=6.60.0530 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svspb,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVSPB 6.60 on CentSO 6.7
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svspb --version=6.60.0530 --product-variant=vpl-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svspb,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify


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
#	CSD_FLOAT=$(nova floating-ip-list | grep `nova list | grep $STACK-csd | awk $'{print $2}'` | awk $'{print $4}')


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
#	echo CSD: $CSD_FLOAT

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
#	sed -i -e 's/^#CSD_IP/'$CSD_FLOAT'/g' ansible/hosts

fi


if [ ! "$LABIFY" == "yes" ]
then

	if [ "$FREEBSD_PTS" == "yes" ]
	then

		if [ "$DRY_RUN" == "yes" ]
		then
			echo
			echo "Not preparing FreeBSD! Skipping this step..."
		else
			echo
			echo "FreeBSD PTS detected, preparing it, by installing Python 2.7 sane version..."
			ssh -oStrictHostKeyChecking=no cloud@$PTS_FLOAT 'sudo pkg_add http://ftp-archive.freebsd.org/pub/FreeBSD-Archive/old-releases/amd64/8.2-RELEASE/packages/python/python27-2.7.1_1.tbz'
			sed -i -e 's/base_os:.*/base_os: freebsd8/g' ansible/group_vars/all
			sed -i -e 's/deploy_pts_freebsd_pkgs:.*/deploy_pts_freebsd_pkgs: yes/g' ansible/group_vars/all
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
#	CSD_CTRL_IP=`host $PTS_FQDN | awk $'{print $4}'`


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
		echo
		echo "FreeBSD PTS detected, preparing Ansible's group_vars/all & hosts files..."

		sed -i -e 's/base_os:.*/base_os: freebsd8/g' ansible/group_vars/all
		sed -i -e 's/deploy_pts_freebsd_pkgs:.*/deploy_pts_freebsd_pkgs: yes/g' ansible/group_vars/all
		sed -i -e 's/^#FREEBSD_PTS_IP/'$PTS_CTRL_IP'/g' ansible/hosts
	else
		sed -i -e 's/^#PTS_IP/'$PTS_CTRL_IP'/g' ansible/hosts
	fi
	sed -i -e 's/^#SDE_IP/'$SDE_CTRL_IP'/g' ansible/hosts
	sed -i -e 's/^#SPB_IP/'$SPB_CTRL_IP'/g' ansible/hosts
#	sed -i -e 's/^#CSD_IP/'$CSD_CTRL_IP'/g' ansible/hosts


fi


if [ "$DRY_RUN" == "yes" ]
then
	echo
	echo "Not running Ansible! Just preparing the environment variables and site-*.yml..."
else
	if [ ! "$LABIFY" == "yes" ]
	then
		echo
		echo "Deploying Sandvine's RPM Packages plus Cloud Services with Ansible..."

		echo
		cd ansible
		ansible-playbook site-cloudservices.yml
	else
		echo
		echo "Configuring Sandvine Platform with Ansible..."

		echo
		cd ansible
		ansible-playbook site-preinstalled.yml
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
#	echo "ssh sandvine@$CSD_FLOAT # CSD"
	echo

fi
