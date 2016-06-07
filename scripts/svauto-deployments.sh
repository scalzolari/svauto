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


clear


for i in "$@"
do
case $i in

	--base-os=*)

	        BASE_OS="${i#*=}"
	        shift
	        ;;

	--roles=*)

	        ALL_ROLES="${i#*=}"
	        ROLES="$( echo $ALL_ROLES | sed s/,/\ /g )"
	        shift
	        ;;

	--extra-vars=*)

	        ALL_EXTRA_VARS="${i#*=}"
	        EXTRA_VARS="$( echo $ALL_EXTRA_VARS | sed s/,/\ /g )"
	        shift
	        ;;

esac
done


BUILD_RAND=$(openssl rand -hex 4)

PLAYBOOK_FILE="playbook-"$BUILD_RAND"-"$ALL_ROLES".yml"


# O.S. Detector
OS=`python -c 'import platform ; print platform.dist()[0]'`


echo
echo "Welcome to SVAuto, the Sandvine Automation!"


echo
echo "Installing SVAuto basic dependencies (Git & Ansible):"

shopt -s nocasematch

case $OS in

	Ubuntu|Debian)

		echo
		sudo apt -y install git ansible
		;;

	RedHat|CentOS)

		echo
		sudo yum --enablerepo=epel-testing -y install git ansible libselinux-python
		;;

	*)

                echo
                echo "Operation System not detected, aborting!"
                exit 1
                ;;

esac


echo


if  [ ! -d ~/svauto ]; then
        echo
        echo "Downloading SVAuto into your home directory..."
        echo

        cd ~
        git clone -b dev https://github.com/tmartinx/svauto.git
else
        echo
        echo "Apparently, you already have SVAuto, enjoy it!"
        echo
fi


if  [ ! -f ~/svauto/svauto.sh ]; then
	echo
	echo "WARNING!"
	echo "SVAuto main script not found, Git clone might have failed."

	echo
	exit 1
fi


echo
echo "Loading SVAuto includes..."
cd ~/svauto
source lib/include-tools.inc


echo
echo "Bootstrapping --base-os=\"$BASE_OS\" via Ansible with the folllwing roles and vars:"
echo
echo "Roles: "$ALL_ROLES"."
echo "Extra Vars: "$ALL_EXTRA_VARS"."


echo
echo "Building Ansible top-level Playbook..."

echo
ansible_playbook_builder --base-os="$BASE_OS" --ansible-hosts="localhost" --roles="$ALL_ROLES" > ansible/tmp/$PLAYBOOK_FILE


echo
echo "Running Ansible with Playbook: \"$PLAYBOOK_FILE\"."

echo
cd ~/svauto/ansible
ansible-playbook -c local "tmp/$PLAYBOOK_FILE" --extra-vars "base_os=$BASE_OS $EXTRA_VARS"
