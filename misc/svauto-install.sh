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


echo
echo "Welcome to SVAuto, the Sandvine Automation!"
echo


echo
echo "Installing Git..."
echo
sudo apt -y install git


echo
echo "Cloning Sandvine's Ansible Deployment into your home directory..."
echo

cd ~
git clone -b dev http://github.com/tmartinx/svauto.git

echo
echo "You'll need to install all the dependencies for running SVAuto."
echo "Git is already install by this script, it is a dependency as well."
echo
echo "To install everything, run:"
echo
echo "cd ~/svauto"
echo "./svauto.sh --install-dependencies"
echo
