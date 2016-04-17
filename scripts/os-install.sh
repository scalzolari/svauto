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


FQDN=$(hostname -f)


clear


echo
echo "Welcome to OpenStack Mitaka Deployment!"
echo


echo
echo "Installing Git and Ansible..."
echo
sudo apt -y install git ansible python-pycurl


echo
echo "Downloading SVAuto into your home directory..."
echo
cd ~
git clone -b dev https://github.com/sandvine/svauto.git


echo
echo "Deploying OpenStack..."
echo
echo "Bridge Mode: Open vSwitch"
echo
cd ~/svauto
./os-deploy.sh --br-mode=OVS --use-dummies --base-os=ubuntu16 --base-os-upgrade=yes --openstack-release=mitaka --openstack-installation


echo
echo "Well done!"
echo
echo "Point your browser to http://$FQDN"
echo
echo "The credentials for both admin and demo users are stored at the"
echo "admin-openrc.sh and demo-openrc.sh files located inside your home."
echo
echo "You can now launch your Stacks! Be it a NFV L2 Bridge or just a Wordpress."
echo "There are a few examples here at your home, for example, you can try:"
echo
echo "source ~/demo-openrc.sh"
echo
echo "If you have 8~16G of RAM:"
echo "heat stack-create demo -f ~/svauto/misc/os-heat-templates/sandvine-stack-0.1-centos.yaml"
echo
echo "If you have 2~4G of RAM:"
echo "heat stack-create demo -f ~/svauto/misc/os-heat-templates/nfv-l2-bridge-basic-stack-ubuntu.yaml"
echo
echo "Enjoy it!"
echo
