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

packer_build_cs_lab()
{

	if [ "$DRY_RUN" == "yes" ]; then
		export DRY_RUN_OPT="--dry-run"
	fi


	#
	# STABLE
	#

	# SDE 7.45 on CentOS 6 + Cloud Services SDE + Cloud Services Daemon (back / front) - Labified
	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svsde --version=7.45 --product-variant=cs-1 --operation=cloud-services --qcow2 --vmdk --vhd --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,svcs-svsde,svcs,sandvine-auto-config,vmware-tools,labify,post-cleanup-image $DRY_RUN_OPT \
		--packer-max-tries=3

	# SPB 6.60 on CentOS 6 + Cloud Services - Labified
	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svspb --version=6.60 --product-variant=cs-1 --operation=cloud-services --qcow2 --vmdk --vhd --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svspb,svmcdtext,svreports,svcs-svspb,sandvine-auto-config,vmware-tools,labify,post-cleanup-image,power-cycle $DRY_RUN_OPT \
		--packer-max-tries=3

	# PTS 7.30 on CentOS 7 + Cloud Services - Linux 3.10, DPDK 16.04, requires igb_uio - Labified
	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svpts --version=7.30 --product-variant=cs-1 --operation=cloud-services --qcow2 --vmdk --vhd --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,svusagemanagementpts,svcs-svpts,sandvine-auto-config,vmware-tools,labify,post-cleanup-image $DRY_RUN_OPT \
		--setup-default-interface-script --packer-max-tries=3


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

			sed -i -e 's/{{sde_image}}/svsde-7.45-cs-1-centos6-amd64/g' tmp/cs/libvirt-qemu.hook

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

			find packer/build* -name "*.sha256" -exec mv {} $WEB_ROOT_CS_LAB \;
			find packer/build* -name "*.xml" -exec mv {} $WEB_ROOT_CS_LAB \;
			find packer/build* -name "*.qcow2c" -exec mv {} $WEB_ROOT_CS_LAB \;
			find packer/build* -name "*.vmdk" -exec mv {} $WEB_ROOT_CS_LAB \;
			find packer/build* -name "*.vhd*" -exec mv {} $WEB_ROOT_CS_LAB \;
			find packer/build* -name "*.ova" -exec mv {} $WEB_ROOT_CS_LAB \;


			echo
			echo "Merging SHA256SUMS files together (lab)..."

			cd $WEB_ROOT_CS_LAB

			cat *.sha256 > SHA256SUMS
			rm -f *.sha256

			cd - &>/dev/null


        	        echo
        	        echo "Updating symbolic link \"current\" to point to \"$BUILD_DATE\"..."

			cd $WEB_ROOT_CS_MAIN

			rm -f current
			ln -s $BUILD_DATE current

			cd - &>/dev/null


			# Free the way for subsequent builds:
			rm -rf packer/build*

		fi

	fi

}
