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

packer_build_sandvine()
{

	if [ "$DRY_RUN" == "yes" ]; then
		export DRY_RUN_OPT="--dry-run"
	fi


	# Linux SVPTS 7.30 on CentOS 7
	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svpts --version=7.30.0351 --product-variant=vpl-1 --operation=sandvine --qcow2 --ova --vhd --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo \
		--packer-max-tries=3


	# Linux SVPTS 7.30 on CentOS 6
#	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svpts --version=7.30.0035 --product-variant=vpl-1 --operation=sandvine --qcow2 --ova --vhd --vm-xml --sha256sum \
#		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo \
#		--packer-max-tries=3


	# Linux SVSDE 7.45 on CentOS 6
	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svsde --version=7.45.0305 --product-variant=vpl-1 --operation=sandvine --qcow2 --ova --vhd --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo \
		--packer-max-tries=3


	# Linux SVSDE 7.45 on CentOS 7
	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svsde --version=7.45.0305 --product-variant=vpl-1 --operation=sandvine --qcow2 --ova --vhd --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo \
		--packer-max-tries=3


	# Linux SVSPB 6.65 on CentOS 6
	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svspb --version=6.65.0019 --product-variant=vpl-1 --operation=sandvine --qcow2 --ova --vhd --vm-xml --sha256sum \
		--roles=cloud-init,bootstrap,grub-conf,svspb,vmware-tools,post-cleanup,power-cycle --disable-autoconf --static-repo --versioned-repo \
		--packer-max-tries=3

}
