#! /bin/bash

packer_build_cs_release()
{

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
	./image-factory.sh --release=prod --base-os=centos68 --base-os-upgrade --product=cs-svsde --version=$RELEASE --qcow2 --ova --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,svcs-svsde,svcs,vmware-tools,cleanrepo,post-cleanup $DRY_RUN_OPT

	# SDE 7.45 on CentOS 6 + Cloud Services SDE + Cloud Services Daemon (back / front) - Labified
#	./image-factory.sh --release=prod --base-os=centos68 --base-os-upgrade --product=cs-svsde --version=$RELEASE --qcow2 --vmdk --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,svusagemanagement,svsubscribermapping,svcs-svsde,svcs,vmware-tools,cleanrepo,post-cleanup --labify $DRY_RUN_OPT

	# SPB 6.60 on CentOS 6 + Cloud Services customizations
	./image-factory.sh --release=prod --base-os=centos68 --base-os-upgrade --product=cs-svspb --version=$RELEASE --qcow2 --ova --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svspb,svmcdtext,svreports,svcs-svspb,vmware-tools,cleanrepo,post-cleanup $DRY_RUN_OPT

	# SPB 6.60 on CentOS 6 - Cloud Services customizations - Labified
#	./image-factory.sh --release=prod --base-os=centos68 --base-os-upgrade --product=cs-svspb --version=$RELEASE --qcow2 --vmdk --vm-xml --md5sum --sha1sum \
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

}
