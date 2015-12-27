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

#
# TODO:
#
# 1- Include support for generating Xen XL files for QCoWs (libvirt ?);
# 2- Create small functions where needed;


for i in "$@"
do
case $i in

        --base-os=*)

                BASE_OS="${i#*=}"
                shift
                ;;


	--base-os-upgrade)

		BASE_OS_UPGRADE="yes"
		shift
		;;

	# --roles will deprecate: product, product-variant and labify (probably).
        --roles=*)

                ALL_ROLES="${i#*=}"
		ROLES="$( echo $ALL_ROLES | sed s/,/\ /g )"
                shift
                ;;

        --product=*)

                PRODUCT="${i#*=}"
                shift
                ;;

        --version=*)

		VERSION="${i#*=}"
		shift
		;;

        --product-variant=*)

		PRODUCT_VARIANT="${i#*=}"
		shift
		;;

	--release=*)

		RELEASE="${i#*=}"
		shift
		;;

	--versioned-repo)

		VERSIONED_REPO="yes"
		shift
		;;

	--experimental-repo)

		EXPERIMENTAL_REPO="yes"
		shift
		;;

	--vm-xml)

		VM_XML="yes"
		shift
		;;

	--qcow2)

		QCOW2="yes"
		shift
		;;

	--vmdk)

		VMDK="yes"
		shift
		;;

	--ovf)

		OVF="yes"
		shift
		;;

	--ova)

		OVF="yes"
		OVA="yes"
		shift
		;;

	--vhd)

		VHD="yes"
		shift
		;;

	--vhdx)

		VHDX="yes"
		shift
		;;

	--vdi)

		VDI="yes"
		shift
		;;

	--sha1sum)

		SHA1SUM="yes"
		shift
		;;

	--md5sum)

		MD5SUM="yes"
		shift
		;;

	--labify)

		LABIFY="yes"
		shift
		;;

	--dry-run)

		DRY_RUN="yes"
		shift
		;;

esac
done


BUILD_RAND=$(openssl rand -hex 4)


if [ "$LABIFY" == "yes" ]
then
	PACKER_FILES=build-lab-$PRODUCT-$BUILD_RAND-packer-files
	OUTPUT_DIR=build-lab-$PRODUCT-$BUILD_RAND-output-dir
else
	PACKER_FILES=build-$PRODUCT-$BUILD_RAND-packer-files
	OUTPUT_DIR=build-$PRODUCT-$BUILD_RAND-output-dir
fi


echo
echo "Starting SVAuto Image Factory!"


echo
echo "Your Ansible roles for this build are:"
echo "Roles: "$ALL_ROLES"."


case "$BASE_OS" in

        ubuntu14)
		OS_LABEL="trusty"
		;;

        ubuntu16)
		OS_LABEL="xenial"
		;;

	centos6*)
		OS_LABEL="centos6"
		;;

	centos7*)
		OS_LABEL="centos7"
		;;

        *)
		echo
		echo $"Usage: $0 --base-os={ubuntu14|ubuntu16|centos67|centos72}"
		exit 1
		;;

esac


if [ ! -z $PRODUCT_VARIANT ]; then
	PACKER_VM_NAME=$PRODUCT-$VERSION-$PRODUCT_VARIANT-$OS_LABEL-amd64
else
	PACKER_VM_NAME=$PRODUCT-$VERSION-$OS_LABEL-amd64
fi


echo
echo "Preparing Packer build temp dir (packer/"$PACKER_FILES")..."

# Creating temp dirs to host Packer yaml file, Ansible inventory and xml files
mkdir packer/$PACKER_FILES


# Defining the auto-generated Packer file to build the image
PACKER_FILE="packer/$PACKER_FILES/$PACKER_VM_NAME-packer.yaml"

# Defining the dynamic Ansible Playbook file location
PLAYBOOK_FILE="packer/$PACKER_FILES/$PACKER_VM_NAME-inventory.yaml"
PLAYBOOK_FILE_SED="packer\/$PACKER_FILES\/$PACKER_VM_NAME-inventory.yaml"


# Coping the template to Packer files subdir
case "$BASE_OS" in

        ubuntu14)
		cp packer/ubuntu14-template.yaml $PACKER_FILE
		;;

	ubuntu16)
                cp packer/ubuntu16-template.yaml $PACKER_FILE
		;;

	centos67)
		cp packer/centos67-template.yaml $PACKER_FILE
		;;

	centos72)
		cp packer/centos72-template.yaml $PACKER_FILE
		;;

        *)
		echo
		echo $"Usage: $0 --base-os={ubuntu14|ubuntu16|centos67|centos72}"
		exit 1
		;;

esac


if [ "$OVF" == "yes" ]
then

	echo
	echo "Creating "$PACKER_VM_NAME" VM OVF file for "$PACKER_VM_NAME"..."

	if [ "$PRODUCT" == "svpts" ]; then
		cp packer/ovf-template-4nic.ovf packer/$PACKER_FILES/"$PACKER_VM_NAME".ovf
	else
		cp packer/ovf-template-2nic.ovf packer/$PACKER_FILES/"$PACKER_VM_NAME".ovf
	fi

	sed -i -e 's/{{vm_name}}/'"$PACKER_VM_NAME"'/g' packer/$PACKER_FILES/"$PACKER_VM_NAME".ovf

	case "$BASE_OS" in

	        ubuntu*)
			sed -i -e 's/{{ovf_id}}/94/g' packer/$PACKER_FILES/"$PACKER_VM_NAME".ovf
			sed -i -e 's/{{vmw_ostype}}/ubuntu64Guest/g' packer/$PACKER_FILES/"$PACKER_VM_NAME".ovf
			;;

		centos*)
			sed -i -e 's/{{ovf_id}}/107/g' packer/$PACKER_FILES/"$PACKER_VM_NAME".ovf
			sed -i -e 's/{{vmw_ostype}}/centos64Guest/g' packer/$PACKER_FILES/"$PACKER_VM_NAME".ovf
			;;

	        *)
			echo
			echo $"Usage: $0 --base-os={ubuntu14|ubuntu16|centos67|centos72}"
			exit 1
			;;

	esac

fi


if [ "$VM_XML" == "yes" ]
then

	echo
	echo "Creating "$PACKER_VM_NAME" VM XML file for "$PACKER_VM_NAME"..."

	case "$BASE_OS" in

	        ubuntu*)
			if [ "$PRODUCT" == "svpts" ]; then
				cp packer/libvirt-ubuntu-4nic.xml packer/$PACKER_FILES/"$PACKER_VM_NAME".xml
			else
				cp packer/libvirt-ubuntu-2nic.xml packer/$PACKER_FILES/"$PACKER_VM_NAME".xml
			fi
			sed -i -e 's/{{vm_name}}/'"$PACKER_VM_NAME"'/g' packer/$PACKER_FILES/"$PACKER_VM_NAME".xml
			;;

		centos*)
			if [ "$PRODUCT" == "svpts" ]; then
				cp packer/libvirt-centos-4nic.xml packer/$PACKER_FILES/"$PACKER_VM_NAME".xml
			else
				cp packer/libvirt-centos-2nic.xml packer/$PACKER_FILES/"$PACKER_VM_NAME".xml
			fi
			sed -i -e 's/{{vm_name}}/'"$PACKER_VM_NAME"'/g' packer/$PACKER_FILES/"$PACKER_VM_NAME".xml
			;;

	        *)
			echo
			echo $"Usage: $0 --base-os={ubuntu14|ubuntu16|centos67|centos72}"
			exit 1
			;;

	esac

fi


# Build extra_vars "nicely"!
EXTRA_VARS="base_os="$BASE_OS" release="$RELEASE""

if [ "$EXPERIMENTAL_REPO" == "yes" ] ; then
	EXTRA_VARS="$EXTRA_VARS is_experimental="yes""
fi

if [ "$BASE_OS_UPGRADE" == "yes" ]; then
	EXTRA_VARS="$EXTRA_VARS base_os_upgrade="yes""
fi

case "$PRODUCT" in

        *svsde)
		EXTRA_VARS=""$EXTRA_VARS" sde_version="$VERSION""

		if [ "$VERSIONED_REPO" == "yes" ]
		then
			EXTRA_VARS=""$EXTRA_VARS" sde_versioned=true"
		else
			EXTRA_VARS=""$EXTRA_VARS" sde_versioned=false"
		fi
		;;

        *svpts)
		EXTRA_VARS=""$EXTRA_VARS" pts_version="$VERSION""

		if [ "$VERSIONED_REPO" == "yes" ]
		then
			EXTRA_VARS=""$EXTRA_VARS" pts_versioned=true"
		else
			EXTRA_VARS=""$EXTRA_VARS" pts_versioned=false"
		fi
		;;

        *svspb)
		EXTRA_VARS=""$EXTRA_VARS" spb_version="$VERSION""

		if [ "$VERSIONED_REPO" == "yes" ]
		then
			EXTRA_VARS=""$EXTRA_VARS" spb_versioned=true"
		else
			EXTRA_VARS=""$EXTRA_VARS" spb_versioned=false"
		fi
		;;

	svcs)
		;;

	centos)
		;;

	ubuntu)
		;;

        *)
		echo
		echo $"Usage: $0 --product={svpts|svsde|svspb|svcs|centos|ubuntu}"
		exit 1
		;;

esac


# Updating Packer VM build template yaml file
sed -i -e 's/"output_directory": "",/"output_directory": "packer\/'"$OUTPUT_DIR"'",/g' $PACKER_FILE
sed -i -e 's/"vm_name": "",/"vm_name": "'"$PACKER_VM_NAME.raw"'",/g' $PACKER_FILE
sed -i -e 's/"playbook_file": "",/"playbook_file": "'"$PLAYBOOK_FILE_SED"'",/g' $PACKER_FILE
sed -i -e 's/"inventory_groups": ""/"inventory_groups": "'"$PRODUCT"'-servers"/g' $PACKER_FILE
sed -i -e 's/"--extra-vars \\"\\""/"--extra-vars  \\"'"$EXTRA_VARS"'\\""/g' $PACKER_FILE


# Creating Ansible Inventory file dinamically
echo "- hosts: $PRODUCT-servers"	> $PLAYBOOK_FILE
echo "  user: root"			>> $PLAYBOOK_FILE
echo "  roles:"				>> $PLAYBOOK_FILE

for X in $ROLES; do
	echo "  - role: "$X""		>> $PLAYBOOK_FILE
done

if [ "$LABIFY" == "yes" ]
then
	echo
	echo "WARNING!!! Labifying the image on its playbook..."
	echo "  - role: labify" >> $PLAYBOOK_FILE
fi


echo
echo "Packer is now building: "$PACKER_VM_NAME" with Ansible..."


if [ "$DRY_RUN" == "yes" ]
then

	echo
	echo "Dry run called, not running Packer, to run it manually, you can type:"

	echo packer build packer/$PACKER_FILES/$PACKER_VM_NAME-packer.yaml

else

	if packer build packer/$PACKER_FILES/$PACKER_VM_NAME-packer.yaml
	then
	        echo
	        echo "Packer build okay, proceeding..."
	else
		echo
	        echo "WARNING!!!"
		echo
	        echo "Packer build failed! ABORTING!!!"
	        exit 1
	fi

fi


if [ ! "$DRY_RUN" == "yes" ]
then

	[ "$OVF" == "yes" ] && mv packer/$PACKER_FILES/"$PACKER_VM_NAME".ovf packer/$OUTPUT_DIR

	[ "$VM_XML" == "yes" ] && mv packer/$PACKER_FILES/"$PACKER_VM_NAME".xml packer/$OUTPUT_DIR

	if [ "$QCOW2" == "yes" ]; then
		echo
		echo "Converting "$PACKER_VM_NAME" RAW image to Compressed QCoW2..."
		qemu-img convert -p -f raw -O qcow2 -c packer/$OUTPUT_DIR/"$PACKER_VM_NAME".raw packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.qcow2c

		if [ "$MD5SUM" == "yes" ]; then
			echo
			echo "Creating "$PACKER_VM_NAME"-disk1.qcow2c.md5 MD5SUM file"
			md5sum packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.qcow2c | sed -e 's/packer\/'"$OUTPUT_DIR"'\///g' > packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.qcow2c.md5
		fi

		if [ "$SHA1SUM" == "yes" ]; then
			echo
			echo "Creating "$PACKER_VM_NAME"-disk1.qcow2c.sha1 SHA1SUM file"
			sha1sum packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.qcow2c | sed -e 's/packer\/'"$OUTPUT_DIR"'\///g' > packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.qcow2c.sha1
		fi
	fi


	if [ "$OVA" == "yes" ]; then
		echo
		echo "Creating "$PACKER_VM_NAME".ova file"

		vboxmanage convertfromraw packer/$OUTPUT_DIR/"$PACKER_VM_NAME".raw packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vmdk --format vmdk --variant Stream

		cd packer/$OUTPUT_DIR

		dd if="$PACKER_VM_NAME"-disk1.vmdk of="$PACKER_VM_NAME"-disk1.descriptor bs=1 skip=512 count=1024 &>/dev/null

		sed -i -e 's/ide/lsilogic/g' "$PACKER_VM_NAME"-disk1.descriptor

		dd conv=notrunc,nocreat if="$PACKER_VM_NAME"-disk1.descriptor of="$PACKER_VM_NAME"-disk1.vmdk bs=1 seek=512 count=1024 &>/dev/null

		OVF_SIZE=`wc -c "$PACKER_VM_NAME"-disk1.vmdk | cut -d \  -f 1`
		OVF_POPULATEDSIZE=$(( $OVF_SIZE * 3))

		sed -i -e 's/{{ovf_size}}/'"$OVF_SIZE"'/g' "$PACKER_VM_NAME".ovf
		sed -i -e 's/{{ovf_populatedSize}}/'"$OVF_POPULATEDSIZE"'/g' "$PACKER_VM_NAME".ovf

		VMDK_SHA1=`sha1sum "$PACKER_VM_NAME"-disk1.vmdk | xargs | cut -d \  -f 1`
		OVF_SHA1=`sha1sum "$PACKER_VM_NAME".ovf | xargs | cut -d \  -f 1`

		echo "SHA1("$PACKER_VM_NAME"-disk1.vmdk)= "$VMDK_SHA1"" > "$PACKER_VM_NAME".mf
		echo "SHA1("$PACKER_VM_NAME".ovf)= "$OVF_SHA1"" >> "$PACKER_VM_NAME".mf

		tar -cf "$PACKER_VM_NAME".ova "$PACKER_VM_NAME".ovf "$PACKER_VM_NAME".mf "$PACKER_VM_NAME"-disk1.vmdk

		cd - &>/dev/null

		if [ "$MD5SUM" == "yes" ]; then
			echo
			echo "Creating "$PACKER_VM_NAME".ova.md5 MD5SUM file"
			md5sum packer/$OUTPUT_DIR/"$PACKER_VM_NAME".ova | sed -e 's/packer\/'"$OUTPUT_DIR"'\///g' > packer/$OUTPUT_DIR/"$PACKER_VM_NAME".ova.md5
		fi

		if [ "$SHA1SUM" == "yes" ]; then
			echo
			echo "Creating "$PACKER_VM_NAME".ova.sha1 SHA1SUM file"
			sha1sum packer/$OUTPUT_DIR/"$PACKER_VM_NAME".ova | sed -e 's/packer\/'"$OUTPUT_DIR"'\///g' > packer/$OUTPUT_DIR/"$PACKER_VM_NAME".ova.sha1
		fi
	fi


	if [ "$VMDK" == "yes" ]; then
		echo
		echo "Converting "$PACKER_VM_NAME" RAW image to VMDK format..."
		qemu-img convert -p -f raw -O vmdk -o adapter_type=lsilogic packer/$OUTPUT_DIR/"$PACKER_VM_NAME".raw packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vmdk

		if [ "$MD5SUM" == "yes" ]; then
			echo
			echo "Creating "$PACKER_VM_NAME"-disk1.vmdk.md5 MD5SUM file"
			md5sum packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vmdk | sed -e 's/packer\/'"$OUTPUT_DIR"'\///g' > packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vmdk.md5
		fi

		if [ "$SHA1SUM" == "yes" ]; then
			echo
			echo "Creating "$PACKER_VM_NAME"-disk1.vmdk.sha1 SHA1SUM file"
			sha1sum packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vmdk | sed -e 's/packer\/'"$OUTPUT_DIR"'\///g' > packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vmdk.sha1
		fi
	fi


	if [ "$VHD" == "yes" ]; then
		echo
		echo "Converting "$PACKER_VM_NAME" RAW image to VHD format..."
		qemu-img convert -p -f raw -O vpc -o subformat=dynamic packer/$OUTPUT_DIR/"$PACKER_VM_NAME".raw packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vhd

		if [ "$MD5SUM" == "yes" ]; then
			echo
			echo "Creating "$PACKER_VM_NAME"-disk1.vhd.md5 MD5SUM file"
			md5sum packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vhd | sed -e 's/packer\/'"$OUTPUT_DIR"'\///g' > packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vhd.md5
		fi

                if [ "$SHA1SUM" == "yes" ]; then
                        echo
                        echo "Creating "$PACKER_VM_NAME"-disk1.vhd.sha1 SHA1SUM file"
                        sha1sum packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vhd | sed -e 's/packer\/'"$OUTPUT_DIR"'\///g' > packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vhd.sha1
                fi
	fi


	if [ "$VHDX" == "yes" ]; then
		echo
		echo "Converting "$PACKER_VM_NAME" RAW image to VHDX format..."
		qemu-img convert -p -f raw -O vhdx -o subformat=dynamic packer/$OUTPUT_DIR/"$PACKER_VM_NAME".raw packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vhdx

		if [ "$MD5SUM" == "yes" ]; then
			echo
			echo "Creating "$PACKER_VM_NAME"-disk1.vhdx.md5 MD5SUM file"
			md5sum packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vhdx | sed -e 's/packer\/'"$OUTPUT_DIR"'\///g' > packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vhdx.md5
		fi

                if [ "$SHA1SUM" == "yes" ]; then
                        echo
                        echo "Creating "$PACKER_VM_NAME"-disk1.vhdx.sha1 SHA1SUM file"
                        sha1sum packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vhdx | sed -e 's/packer\/'"$OUTPUT_DIR"'\///g' > packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vhdx.sha1
                fi
	fi


	if [ "$VDI" == "yes" ]; then
		echo
		echo "Converting "$PACKER_VM_NAME" RAW image to VDI format..."
		qemu-img convert -p -f raw -O vdi packer/$OUTPUT_DIR/"$PACKER_VM_NAME".raw packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vdi

		if [ "$MD5SUM" == "yes" ]; then
			echo
			echo "Creating "$PACKER_VM_NAME"-disk1.vdi.md5 MD5SUM file"
			md5sum packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vdi | sed -e 's/packer\/'"$OUTPUT_DIR"'\///g' > packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vdi.md5
		fi

                if [ "$SHA1SUM" == "yes" ]; then
                        echo
                        echo "Creating "$PACKER_VM_NAME"-disk1.vdi.sha1 SHA1SUM file"
                        sha1sum packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vdi | sed -e 's/packer\/'"$OUTPUT_DIR"'\///g' > packer/$OUTPUT_DIR/"$PACKER_VM_NAME"-disk1.vdi.sha1
                fi
	fi


	if [ "$PACKER_TO_OS" == "yes" ]
	then

		if [ ! -f ~/admin-openrc.sh ]
		then
			echo
			echo "OpenStack Credentials for "admin" account not found, aborting!"
			exit 1
		else
			echo
			echo "Loading OpenStack credentials for "admin" account..."
			source ~/admin-openrc.sh

			echo
			echo "Importing PTS on CentOS 6 into Glance..."
			glance image-create --file packer/$OUTPUT_DIR/"$PACKER_VM_NAME".qcow2c --name "$PACKER_VM_NAME-$TODAY" --is-public true --container-format bare --disk-format qcow2
			#glance image-update --property hw_scsi_model=virtio-scsi --property hw_disk_bus=scsi "$PACKER_VM_NAME-$TODAY"
		fi

	fi

fi
