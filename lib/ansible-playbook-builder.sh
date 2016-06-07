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


# Outputs an Ansible top-level Playbook file
ansible_playbook_builder()
{

	for i in "$@"
	do
	case $i in

	        --base-os=*)

	                BASE_OS="${i#*=}"
	                shift
	                ;;

	        --ansible-hosts=*)

	                ANSIBLE_HOSTS="${i#*=}"
	                shift
	                ;;

	        --roles=*)

	                ALL_ROLES="${i#*=}"
	                ROLES="$( echo $ALL_ROLES | sed s/,/\ /g )"
	                shift
	                ;;

	esac
	done


	echo "- hosts: $ANSIBLE_HOSTS"

	case "$BASE_OS" in

	        ubuntu*)
	                echo "  user: sandvine"
	                echo "  become: yes"
	                ;;

	        centos*)
	                echo "  user: root"
	                ;;

	        *)
	                echo
	                echo "Usage: $0 --base-os={ubuntu14|ubuntu16|centos6|centos7}"
	                exit 1
	                ;;

	esac

	echo "  roles:"

	for X in $ROLES; do
	        echo "  - role: "$X""
	done

	if [ "$LABIFY" == "yes" ]
	then
	        echo
	        echo "WARNING!!! Labifying the image on its playbook..."
	        echo "  - role: labify"
	fi

}
