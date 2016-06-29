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

packer_build_official()
{

	if [ "$DRY_RUN" == "yes" ]; then
		export DRY_RUN_OPT="--dry-run"
	fi


	#
	# STABLE
	#

	# PTS 7.30 on CentOS 7 - Linux 3.10, DPDK 16.04, requires igb_uio
	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svpts --version=7.30 --qcow2 --ova --vhd --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,sandvine-auto-config,vmware-tools,post-cleanup-image $DRY_RUN_OPT --operation=sandvine \
		--packer-max-tries=3

	# SDE 7.45 on CentOS 7
	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svsde --version=7.45 --qcow2 --ova --vhd --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,sandvine-auto-config,vmware-tools,post-cleanup-image $DRY_RUN_OPT --operation=sandvine \
		--packer-max-tries=3

       	# SDE 7.45 on CentOS 6
	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svsde --version=7.45 --qcow2 --ova --vhd --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,sandvine-auto-config,vmware-tools,post-cleanup-image $DRY_RUN_OPT --operation=sandvine \
		--packer-max-tries=3

	# SPB 6.60 on CentOS 6 - No NDS
	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svspb --version=6.60 --qcow2 --ova --vhd --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svspb,sandvine-auto-config,vmware-tools,post-cleanup-image,power-cycle $DRY_RUN_OPT --operation=sandvine \
		--packer-max-tries=3


	#
	# EXPERIMENTAL
	#

	# PTS 7.30 on CentOS 6 - Linux 3.18 from Xen 4.6 Repo + DPDK 16.04 with Xen Support, no igb_uio needed
	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svpts --version=7.30 --qcow2 --ova --vhd --vm-xml --sha256sum \
		--roles=centos-xen,cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup-image $DRY_RUN_OPT --operation=sandvine \
		--packer-max-tries=3


	# PTS 7.40 on CentOS 6 - Linux 2.6, old DPDK 1.8, requires igb_uio
#	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svpts --version=7.40 --qcow2 --ova --vhd --vm-xml --sha256sum \
#		--roles=cloud-init,bootstrap,grub-conf,svpts,sandvine-auto-config,vmware-tools,post-cleanup-image $DRY_RUN_OPT --versioned-repo --operation=sandvine

	# PTS 7.40 on CentOS 7 - Linux 3.10, DPDK 16.04, requires igb_uio
	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svpts --version=7.40 --qcow2 --ova --vhd --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,sandvine-auto-config,vmware-tools,post-cleanup-image $DRY_RUN_OPT --versioned-repo --operation=sandvine \
		--packer-max-tries=3

	# PTS 7.40 on CentOS 6 - Linux 3.18 from Xen 4.6 Repo + DPDK 16.04 with Xen Support, no igb_uio needed
	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svpts --version=7.40 --product-variant=xen-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
		--roles=centos-xen,cloud-init,bootstrap,grub-conf,svpts,sandvine-auto-config,vmware-tools,post-cleanup-image $DRY_RUN_OPT --versioned-repo --experimental-repo --operation=sandvine \
		--packer-max-tries=3

	# PTS 7.40 on CentOS 7 - Linux 3.18 from Xen 4.6 Repo + DPDK 16.04 with Xen Support, no igb_uio needed
#	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svpts --version=7.40 --product-variant=xen-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
#		--roles=centos-xen,cloud-init,bootstrap,grub-conf,svpts,sandvine-auto-config,vmware-tools,post-cleanup-image $DRY_RUN_OPT --versioned-repo --experimental-repo --operation=sandvine


	# SDE 7.45 on CentOS 6 - Linux 3.18
#	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svsde --version=7.45 --product-variant=xen-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
#		--roles=centos-xen,cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,sandvine-auto-config,vmware-tools,post-cleanup-image $DRY_RUN_OPT --operation=sandvine

	# SDE 7.45 on CentOS 7 - Linux 3.18
#	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svsde --version=7.45 --product-variant=xen-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
#		--roles=centos-xen,cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,sandvine-auto-config,vmware-tools,post-cleanup-image $DRY_RUN_OPT --operation=sandvine

	# SDE 7.45 on CentOS 7
#	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svsde --version=7.45 --qcow2 --ova --vhd --vm-xml --sha256sum \
#		--roles=centos-xen,cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,sandvine-auto-config,vmware-tools,post-cleanup-image --versioned-repo $DRY_RUN_OPT --operation=sandvine

       	# SDE 7.45 on CentOS 6
#	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svsde --version=7.45 --qcow2 --ova --vhd --vm-xml --sha256sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,sandvine-auto-config,vmware-tools,post-cleanup-image --versioned-repo $DRY_RUN_OPT --operation=sandvine


	# SPB 7.00 on CentOS 6 - No NDS
	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svspb --version=7.00 --qcow2 --ova --vhd --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svspb,sandvine-auto-config,vmware-tools,post-cleanup-image $DRY_RUN_OPT --versioned-repo --operation=sandvine \
		--packer-max-tries=3


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
			sed -i -e 's/{{sde_image}}/svsde-7.45-1-centos6-amd64/g' tmp/sv/*.yaml
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

			find packer/build* -name "*.sha256" -exec mv {} $WEB_ROOT_STOCK \;
			find packer/build* -name "*.xml" -exec mv {} $WEB_ROOT_STOCK \;
			find packer/build* -name "*.qcow2c" -exec mv {} $WEB_ROOT_STOCK \;
#			find packer/build* -name "*.vmdk" -exec mv {} $WEB_ROOT_STOCK \;
			find packer/build* -name "*.vhd*" -exec mv {} $WEB_ROOT_STOCK \;
			find packer/build* -name "*.ova" -exec mv {} $WEB_ROOT_STOCK \;


			echo
			echo "Merging SHA256SUMS files together..."

			cd $WEB_ROOT_STOCK

			cat *.sha256 > SHA256SUMS
			rm -f *.sha256

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

				sed -i -e 's/{{sandvine_release}}/'$SANDVINE_RELEASE'/g' sandvine-helper.sh_template

				cat sandvine-helper.sh_template sandvine-helper.sh_tail > sandvine-helper.sh

				chmod +x sandvine-helper.sh

				cd - &>/dev/null

				cp tmp/sv/sandvine-helper.sh $WEB_ROOT_STOCK

			fi


			# Free the way for subsequent builds:
			rm -rf packer/build*

		fi

	fi

}
