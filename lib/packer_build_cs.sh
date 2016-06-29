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

packer_build_cs()
{

	if [ "$DRY_RUN" == "yes" ]; then
		export DRY_RUN_OPT="--dry-run"
	fi


	#
	# STABLE
	#

	# SDE 7.45 on CentOS 6 + Cloud Services SDE + Cloud Services Daemon (back / front)
	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svsde --version=7.45 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,svcs-svsde,svcs,sandvine-auto-config,vmware-tools,post-cleanup-image $DRY_RUN_OPT --operation=cloud-services \
		--packer-max-tries=3

	# SPB 6.60 on CentOS 6 + Cloud Services
	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svspb --version=6.60 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svspb,svmcdtext,svreports,svcs-svspb,sandvine-auto-config,vmware-tools,post-cleanup-image,power-cycle $DRY_RUN_OPT --operation=cloud-services \
		--packer-max-tries=3

	# PTS 7.30 on CentOS 7 + Cloud Services - Linux 3.10, DPDK 16.04, requires igb_uio
	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svpts --version=7.30 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,svusagemanagementpts,svcs-svpts,sandvine-auto-config,vmware-tools,post-cleanup-image $DRY_RUN_OPT --operation=cloud-services \
		--packer-max-tries=3

	# SDE 7.30 on CentOS 6 + Cloud Services SDE only - No Cloud Services daemon here!
#	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svsde --version=7.30 --product-variant=sde-cs-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,svcs-svsde,vmware-tools,post-cleanup-image $DRY_RUN_OPT --operation=cloud-services \
#		--packer-max-tries=3

	# Cloud Services Daemon 7.40 (back / front) on CentOS 6 - No SDE here!
#	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svcsd --version=7.40 --product-variant=csd-cs-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
#		--roles=centos-xen,cloud-init,bootstrap,grub-conf,svcs,vmware-tools,post-cleanup-image $DRY_RUN_OPT --operation=cloud-services \
#		--packer-max-tries=3


	#
	# EXPERIMENTAL
	#

	# PTS 7.30 on CentOS 6 + Cloud Services - Linux 3.18 from Xen 4.6 official repo, DPDK 16.04, don't requires igb_uio
	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svpts --version=7.30 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
		--roles=centos-xen,cloud-init,bootstrap,grub-conf,svpts,svusagemanagementpts,svcs-svpts,sandvine-auto-config,vmware-tools,post-cleanup-image $DRY_RUN_OPT --operation=cloud-services
#		--packer-max-tries=3

	# SDE 7.50 on CentOS 7
#	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svsde --version=7.50 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
#		--roles=centos-xen,cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,vmware-tools,post-cleanup-image $DRY_RUN_OPT --operation=cloud-services

	# SDE 7.50 on CentOS 7
#	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svsde --version=7.50 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
#		--roles=centos-xen,cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,vmware-tools,post-cleanup-image --versioned-repo $DRY_RUN_OPT --operation=cloud-services

       	# SDE 7.45 on CentOS 6
#	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svsde --version=7.45 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,svcs-svsde,svcs,vmware-tools,post-cleanup-image --versioned-repo $DRY_RUN_OPT --operation=cloud-services

       	# SDE 7.40 on CentOS 6
#	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svsde --version=7.40 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,svcs-svsde,svcs,vmware-tools,post-cleanup-image --versioned-repo $DRY_RUN_OPT --operation=cloud-services

	# SPB 7.00 on CentOS 6
#	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svspb --version=7.00 --product-variant=cs-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
#		--roles=cloud-init,bootstrap,grub-conf,svspb,vmware-tools,post-cleanup-image --versioned-repo $DRY_RUN_OPT --operation=cloud-services

	#
	# BUILD ENVIRONMENT
	#

	# Cloud Services Build Server (back / front) on CentOS 6 (new Golang 1.5)
	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=centos --version=6 --product-variant=build-srv-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
	        --roles=centos-xen,cloud-init,bootstrap,grub-conf,golang-env,nodejs-env,vmware-tools,post-cleanup-image $DRY_RUN_OPT --operation=cloud-services \
		--packer-max-tries=3

	# Cloud Services Build Server (back / front) on CentOS 7 (old Golang 1.4)
	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=centos --version=7 --product-variant=build-srv-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
	        --roles=centos-xen,cloud-init,bootstrap,grub-conf,golang-env,nodejs-env,vmware-tools,post-cleanup-image $DRY_RUN_OPT --operation=cloud-services \
		--packer-max-tries=3


	# Cloud Services Build Server (back) on CentOS 6 (new Golang 1.5)
#	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=centos --version=6 --product-variant=go-build-srv-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
#	        --roles=centos-xen,cloud-init,bootstrap,grub-conf,golang-env,vmware-tools,post-cleanup-image $DRY_RUN_OPT

	# Cloud Services Build Server (front) on CentOS 6 (NodeJS)
#	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=centos --version=6 --product-variant=nodejs-build-srv-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
#	        --roles=centos-xen,cloud-init,bootstrap,grub-conf,nodejs-env,vmware-tools,post-cleanup-image $DRY_RUN_OPT


	# Cloud Services Build Server (back) on CentOS 7 (old Golang 1.4)
#	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=centos --version=7 --product-variant=go-build-srv-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
#	        --roles=centos-xen,cloud-init,bootstrap,grub-conf,golang-env,vmware-tools,post-cleanup-image $DRY_RUN_OPT

	# Cloud Services Build Server (front) on CentOS 7 (NodeJS)
#	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=centos --version=7 --product-variant=nodejs-build-srv-1 --qcow2 --ova --vhd --vm-xml --sha256sum \
#	        --roles=centos-xen,cloud-init,bootstrap,grub-conf,nodejs-env,vmware-tools,post-cleanup-image $DRY_RUN_OPT


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
			sed -i -e 's/{{sde_image}}/svsde-7.45-cs-1-centos6-amd64/g' tmp/cs/*.yaml
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

			find packer/build* -name "*.sha256" -exec mv {} $WEB_ROOT_CS \;
			find packer/build* -name "*.xml" -exec mv {} $WEB_ROOT_CS \;
			find packer/build* -name "*.qcow2c" -exec mv {} $WEB_ROOT_CS \;
#			find packer/build* -name "*.vmdk" -exec mv {} $WEB_ROOT_CS \;
			find packer/build* -name "*.vhd*" -exec mv {} $WEB_ROOT_CS \;
			find packer/build* -name "*.ova" -exec mv {} $WEB_ROOT_CS \;


			echo
			echo "Merging SHA256SUMS files together..."

			cd $WEB_ROOT_CS

			cat *.sha256 > SHA256SUMS
			rm -f *.sha256

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

				sed -i -e 's/{{sandvine_release}}/'$SANDVINE_RELEASE'/g' sandvine-helper.sh_template

				cat sandvine-helper.sh_template sandvine-helper.sh_tail > sandvine-cs-helper.sh

				chmod +x sandvine-cs-helper.sh

				cd - &>/dev/null

				cp tmp/cs/sandvine-cs-helper.sh $WEB_ROOT_CS

			fi


			# Free the way for subsequent builds:
			rm -rf packer/build*

		fi

	fi

}
