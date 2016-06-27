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

packer_build_cs_release()
{

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
	./image-factory.sh --release=prod --base-os=centos6 --base-os-upgrade --product=cs-svsde --version=$SANDVINE_RELEASE --qcow2 --ova --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,svcs-svsde,svcs,sandvine-auto-config,vmware-tools,cleanrepo,post-cleanup $DRY_RUN_OPT --operation=cloud-services

	# SPB 6.60 on CentOS 6 + Cloud Services customizations
	./image-factory.sh --release=prod --base-os=centos6 --base-os-upgrade --product=cs-svspb --version=$SANDVINE_RELEASE --qcow2 --ova --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svspb,svmcdtext,svreports,svcs-svspb,sandvine-auto-config,vmware-tools,cleanrepo,post-cleanup,power-cycle $DRY_RUN_OPT --operation=cloud-services

	# PTS 7.30 on CentOS 7 + Cloud Services customizations
	./image-factory.sh --release=prod --base-os=centos7 --base-os-upgrade --product=cs-svpts --version=$SANDVINE_RELEASE --qcow2 --ova --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,svusagemanagementpts,svcs-svpts,sandvine-auto-config,vmware-tools,cleanrepo,post-cleanup $DRY_RUN_OPT --operation=cloud-services \
		--lock-el7-kernel-upgrade


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

			sed -i -e 's/{{pts_image}}/cs-svpts-'$SANDVINE_RELEASE'-centos7-amd64/g' tmp/cs-rel/*.yaml
			sed -i -e 's/{{sde_image}}/cs-svsde-'$SANDVINE_RELEASE'-centos6-amd64/g' tmp/cs-rel/*.yaml
			sed -i -e 's/{{spb_image}}/cs-svspb-'$SANDVINE_RELEASE'-centos6-amd64/g' tmp/cs-rel/*.yaml
			#sed -i -e 's/{{csd_image}}/cs-svcsd-'$SANDVINE_RELEASE'-centos6-amd64/g' tmp/cs-rel/*.yaml

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

			sed -i -e 's/{{sde_image}}/cs-svsde-'$SANDVINE_RELEASE'-centos6-amd64/g' tmp/cs-rel/libvirt-qemu.hook

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
	
			find packer/build* -name "*.sha256" -exec mv {} $WEB_ROOT_CS_RELEASE \;
			find packer/build* -name "*.xml" -exec mv {} $WEB_ROOT_CS_RELEASE \;
			find packer/build* -name "*.qcow2c" -exec mv {} $WEB_ROOT_CS_RELEASE \;
			find packer/build* -name "*.vmdk" -exec mv {} $WEB_ROOT_CS_RELEASE \;
			find packer/build* -name "*.vhd*" -exec mv {} $WEB_ROOT_CS_RELEASE \;
			find packer/build* -name "*.ova" -exec mv {} $WEB_ROOT_CS_RELEASE \;


			echo
			echo "Merging SHA256SUMS files together..."

			cd $WEB_ROOT_CS_RELEASE

			cat *.sha256 > SHA256SUMS
			rm -f *.sha256

			cd - &>/dev/null


			if [ "$HEAT_TEMPLATES_CS" == "yes" ]
			then

				echo
				echo "Copying Cloud Services Heat Templates for release into public web subdirectory..."

				cp tmp/cs-rel/sandvine-stack-0.1-three-1.yaml $WEB_ROOT_CS_RELEASE/cloudservices-stack-$SANDVINE_RELEASE-1.yaml
				cp tmp/cs-rel/sandvine-stack-0.1-three-flat-1.yaml $WEB_ROOT_CS_RELEASE/cloudservices-stack-$SANDVINE_RELEASE-flat-1.yaml
				cp tmp/cs-rel/sandvine-stack-0.1-three-vlan-1.yaml $WEB_ROOT_CS_RELEASE/cloudservices-stack-$SANDVINE_RELEASE-vlan-1.yaml
				cp tmp/cs-rel/sandvine-stack-0.1-three-rad-1.yaml $WEB_ROOT_CS_RELEASE/cloudservices-stack-$SANDVINE_RELEASE-rad-1.yaml
				cp tmp/cs-rel/sandvine-stack-nubo-0.1-stock-gui-1.yaml $WEB_ROOT_CS_RELEASE/cloudservices-stack-nubo-$SANDVINE_RELEASE-stock-gui-1.yaml
				#cp tmp/cs-rel/sandvine-stack-0.1-four-1.yaml $WEB_ROOT_CS_RELEASE/cloudservices-stack-$SANDVINE_RELEASE-micro-1.yaml

			fi


			if [ "$INSTALLATION_HELPER" == "yes" ]
			then

				echo
				echo "Creating Cloud Services installation helper script..."

				cp misc/self-extract/* tmp/cs-rel/

				cd tmp/cs-rel/

				mv sandvine-stack-0.1-three-1.yaml cloudservices-stack-$SANDVINE_RELEASE-1.yaml
				mv sandvine-stack-0.1-three-flat-1.yaml cloudservices-stack-$SANDVINE_RELEASE-flat-1.yaml
				mv sandvine-stack-0.1-three-vlan-1.yaml cloudservices-stack-$SANDVINE_RELEASE-vlan-1.yaml
				mv sandvine-stack-0.1-three-rad-1.yaml cloudservices-stack-$SANDVINE_RELEASE-rad-1.yaml
				mv sandvine-stack-nubo-0.1-stock-gui-1.yaml cloudservices-stack-nubo-$SANDVINE_RELEASE-stock-gui-1.yaml
				#mv sandvine-stack-0.1-four-1.yaml cloudservices-stack-$SANDVINE_RELEASE-four-1.yaml

				rm sandvine-stack-0.1-four-1.yaml

				mv libvirt-qemu.hook cs-svsde-$SANDVINE_RELEASE-centos6-amd64.hook

				tar -cf sandvine-files.tar *.yaml *.hook *.xml

				cat extract.sh sandvine-files.tar > sandvine-helper.sh_tail

				sed -i -e 's/{{sandvine_release}}/'$SANDVINE_RELEASE'/g' sandvine-helper.sh_template

				cat sandvine-helper.sh_template sandvine-helper.sh_tail > cloudservices-helper.sh

				chmod +x cloudservices-helper.sh

				cd - &>/dev/null

				cp tmp/cs-rel/cloudservices-helper.sh $WEB_ROOT_CS_RELEASE

			fi


			# Free the way for subsequent builds:
			rm -rf packer/build*

		fi

	fi

}
