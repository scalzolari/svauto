#! /bin/bash

packer_build_sandvine()
{

	if [ "$DRY_RUN" == "yes" ]; then
		export DRY_RUN_OPT="--dry-run"
	fi


	# Linux SVPTS 7.30 on CentOS 7.2
	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svpts --version=7.30.0202 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVPTS 7.30 on CentOS 7.2 - Regular builds
	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svpts --version=7.30.0202 --product-variant=vpl-1 --qcow2 --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify

	# Linux SVPTS 7.30 on CentOS 7.2 - VMWare hack
	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svpts --version=7.30.0202 --product-variant=vpl-1 --vmdk --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify \
		--setup-default-interface-script


	# Linux SVPTS 7.30 on CentOS 6.7
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svpts --version=7.30.0035 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVPTS 7.30 on CentOS 6.7
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svpts --version=7.30.0035 --product-variant=vpl-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svpts,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify


	# Linux SVSDE 7.45 on CentOS 6.7
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.45.0087 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVSDE 7.45 on CentSO 6.7
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.45.0087 --product-variant=vpl-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify


	# Linux SVSDE 7.40 on CentOS 6.7
#	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.40.0025 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVSDE 7.40 on CentSO 6.7
#	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svsde --version=7.40.0025 --product-variant=vpl-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify


	# Linux SVSDE 7.40 on CentOS 7.2
#	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svsde --version=7.40.0025 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVSDE 7.40 on CentSO 7.2
#	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svsde --version=7.40.0025 --product-variant=vpl-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify


	# Linux SVSDE 7.45 on CentOS 7.2
#	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svsde --version=7.45.0078 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVSDE 7.45 on CentSO 7.2
#	./image-factory.sh --release=dev --base-os=centos72 --base-os-upgrade --product=svsde --version=7.45.0078 --product-variant=vpl-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
#		--roles=cloud-init,bootstrap,grub-conf,svsde,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify


	# Linux SVSPB 6.60 on CentOS 6.7
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svspb --version=6.60.0530 --product-variant=vpl-1 --qcow2 --ova --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svspb,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo

	# Linux SVSPB 6.60 on CentSO 6.7
	./image-factory.sh --release=dev --base-os=centos67 --base-os-upgrade --product=svspb --version=6.60.0530 --product-variant=vpl-1 --qcow2 --vmdk --vhd --vm-xml --md5sum --sha1sum \
		--roles=cloud-init,bootstrap,grub-conf,svspb,vmware-tools,post-cleanup --disable-autoconf --static-repo --versioned-repo --labify


}
