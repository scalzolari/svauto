#!/bin/bash -eux

# Copyright 2016, Sandvine Incorporated
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

# Ansible will need sudo without password
echo 'sandvine' | sudo -S -E sed -i -e 's/^%sudo.*/%sudo ALL=NOPASSWD:ALL/' /etc/sudoers

# Updating
echo 'sandvine' | sudo -S -E apt-get update

# Install Ansible 2.0
echo 'sandvine' | sudo -S -E apt-get install -y software-properties-common
echo 'sandvine' | sudo -S -E add-apt-repository -y ppa:ansible/ansible
echo 'sandvine' | sudo -S -E apt-get update
echo 'sandvine' | sudo -S -E apt-get install -y ansible
