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
# Script for being used as a cronjob to build all available O.S. Images.
#


# SVAuto directory
cd ~/svauto


# Sandvine Cloud Services Images for being released to the public
time ./svauto.sh --packer-build-cs --heat-templates-cs --move2webroot --release
#exit


# Sandvine Cloud Services Images
time ./svauto.sh --packer-build-cs --heat-templates-cs --move2webroot
#exit


# Sandvine Stock Images
time ./svauto.sh --packer-build-official --heat-templates --move2webroot
#exit
