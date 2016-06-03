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

# First version of vagrant-builder.sh, still very basic but, fully functional!

# Golang and NodeJS on CentOS 6 and 7:
# ./vagrant-builder.sh --base-os=centos6 --product=svcs-build
# ./vagrant-builder.sh --base-os=centos7 --product=svcs-build

# Build SDE + Cloud Services box:
# ./vagrant-builder.sh --base-os=centos6 --product=svsde

#VAGRANT_DEFAULT_PROVIDER=libvirt

RAND_PORT=`awk -v min=1025 -v max=9999 'BEGIN{srand(); print int(min+rand()*(max-min+1))}'`


for i in "$@"
do
case $i in

        --base-os=*)

                BASE_OS="${i#*=}"
                shift
                ;;

        --product=*)

                PRODUCT="${i#*=}"
                shift
                ;;

	--dry-run)

		DRY_RUN="yes"
		shift
		;;

esac
done


case "$BASE_OS" in

	ubuntu14)
		VBOX="ubuntu/trusty64"
		;;

	ubuntu16)
		VBOX="ubuntu/xenial64"
		;;

	centos6)
		VBOX="centos/6"
		;;

	centos7)
		VBOX="centos/7"
		;;

	*)
                echo
                echo "Usage: $0 --base-os={ubuntu14|ubuntu16|centos6|centos7}"
                exit 1
                ;;

esac


case "$PRODUCT" in

	svpts)

		VM_NAME="svpts_1"
		PLAYBOOK_NAME="svpts-vagrant"
		;;

	svspb)

		VM_NAME="svspb_1"
		PLAYBOOK_NAME="svspb-vagrant"
		;;

	svsde)

		VM_NAME="svsde_1"
		PLAYBOOK_NAME="svsde-vagrant"
		;;

	svcs-build)

		VM_NAME="svcs_build_1"
		PLAYBOOK_NAME="svcs-build-vagrant"
		;;

	*)
		echo
		echo "You must select a product to boot it up..."
		exit 1
		;;

esac


mkdir -p vagrant/$VM_NAME

cp vagrant/Vagrantfile_template vagrant/$VM_NAME/Vagrantfile


sed -i -e 's/vagrant_run:.*/vagrant_run: "yes"/' ansible/group_vars/all


VBOX_SANITIZED=$(echo $VBOX | sed -e 's/\//\\\//g')


sed -i -e 's/{{base_os}}/'$BASE_OS'/g' vagrant/$VM_NAME/Vagrantfile
sed -i -e 's/{{vm_box}}/'$VBOX_SANITIZED'/g' vagrant/$VM_NAME/Vagrantfile
sed -i -e 's/{{vm_name}}/'$VM_NAME'/g' vagrant/$VM_NAME/Vagrantfile
sed -i -e 's/{{ssh_local_port}}/'$RAND_PORT'/g' vagrant/$VM_NAME/Vagrantfile
sed -i -e 's/{{playbook_name}}/'$PLAYBOOK_NAME'/g' vagrant/$VM_NAME/Vagrantfile


if [ "$DRY_RUN" == "yes" ]
then

	echo
	echo "Not running \"vagrant up\"!"
	echo "Just creating the Vagrantfile for you, under vagrant/\"vagrant/$VM_NAME\" subdir..."
	echo

else

	echo
	echo "Entering into: vagrant/$VM_NAME subdir and runnig \"vagrant up\" for you!"

	cd vagrant/$VM_NAME

	echo
	vagrant up --provider libvirt

fi
