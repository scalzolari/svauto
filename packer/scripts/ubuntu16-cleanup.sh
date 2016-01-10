#! /bin/bash -eux

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

# Clean yum local cache.
echo 'sandvine' | sudo -S -E apt clean

# Remove persistent net udev rules.
#rm -f /etc/udev/rules.d/70-persistent-net.rules

# Remove ssh host keys.
#rm -f /etc/ssh/ssh_host*

## Zero out the rest of the free space using dd, then delete the written file.
echo 'sandvine' | sudo -S -E dd if=/dev/zero of=/EMPTY bs=1M && /bin/true

echo 'sandvine' | sudo -S -E rm -f /EMPTY

# Add `sync` so Packer doesn't quit too early, before the large file is deleted.
sync
