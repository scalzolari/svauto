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

WHOAMI=vagrant

HOSTNAME=controller-1
FQDN=controller-1.yourdomain.com
DOMAIN=yourdomain.com


echo
echo "The local configuration:"
echo "You are:" $WHOAMI
echo Hostname: $HOSTNAME
echo FQDN: $FQDN
echo Domain: $DOMAIN


if [ -z $HOSTNAME ]; then
        echo "Hostname not found... Configure the file /etc/hostname with your hostname. ABORTING!"
        exit 1
fi

if [ -z $DOMAIN ]; then
        echo "Domain not found... Configure the file /etc/hosts with your \"IP + FQDN + HOSTNAME\". ABORTING!"
        exit 2
fi

if [ -z $FQDN ]; then
        echo "FQDN not found... Configure your /etc/hosts according. ABORTING!"
        exit 3
fi


echo
echo "Configuring ansible/group_vars/all file based on current environment..."
sed -i -e 's/controller-1.yourdomain.com/'$FQDN'/g' ansible/group_vars/all
sed -i -e 's/yourdomain.com/'$DOMAIN'/g' ansible/group_vars/all


echo
echo "Configuring ansible/group_vars_all with your current "$WHOAMI" user..."
sed -i -e 's/{{ubuntu_user}}/'$WHOAMI'/g' ansible/group_vars/all


DEFAULT_GW_INT=eth0


echo 
echo "Your primary network interface is:"
echo "dafault route via:" $DEFAULT_GW_INT


echo
echo "Preparing Ansible templates based on current default gateway interface..."
sed -i -e 's/eth0/'$DEFAULT_GW_INT'/g' ansible/roles/os_nova_aio/templates/mitaka/nova.conf
sed -i -e 's/eth0/'$DEFAULT_GW_INT'/g' ansible/roles/os_cinder/templates/mitaka/cinder.conf


echo
echo "Running Ansible through Vagrant, deploying OpenStack:"
echo

vagrant up
