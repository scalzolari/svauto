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
	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svpts --version=7.30.0351 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVPTS 7.30 on CentOS 7 - Regular builds
	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svpts --version=7.30.0351 --product-variant=vpl-1 --qcow2 --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify

	# Linux SVPTS 7.30 on CentOS 7 - VMWare hack
	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svpts --version=7.30.0351 --product-variant=vpl-1 --vmdk --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify \
		--setup-default-interface-script


	# Linux SVPTS 7.30 on CentOS 6
#	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svpts --version=7.30.0035 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVPTS 7.30 on CentOS 6
#	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svpts --version=7.30.0035 --product-variant=vpl-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify


	# Linux SVSDE 7.45 on CentOS 6
	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svsde --version=7.45.0205 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVSDE 7.45 on CentSO 6
	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svsde --version=7.45.0205 --product-variant=vpl-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify


	# Linux SVSDE 7.40 on CentOS 6
#	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svsde --version=7.40.0025 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVSDE 7.40 on CentSO 6
#	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svsde --version=7.40.0025 --product-variant=vpl-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify


	# Linux SVSDE 7.40 on CentOS 7
#	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svsde --version=7.40.0025 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVSDE 7.40 on CentSO 7
#	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svsde --version=7.40.0025 --product-variant=vpl-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify


	# Linux SVSDE 7.45 on CentOS 7
#	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svsde --version=7.45.0078 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVSDE 7.45 on CentSO 7
#	./image-factory.sh --release=dev --base-os=centos7 --base-os-upgrade --product=svsde --version=7.45.0078 --product-variant=vpl-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify


	# Linux SVSPB 6.60 on CentOS 6
	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svspb --version=6.60.0530 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svspb,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVSPB 6.60 on CentSO 6
	./image-factory.sh --release=dev --base-os=centos6 --base-os-upgrade --product=svspb --version=6.60.0530 --product-variant=vpl-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svspb,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify

}
