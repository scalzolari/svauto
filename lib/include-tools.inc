#! /bin/bash

source lib/os-deploy.sh

source lib/move2webroot.sh

source lib/build-yum-repo.sh

source lib/packer_build_cs_release.sh
source lib/packer_build_cs.sh
source lib/packer_build_official.sh
source lib/packer_build_sandvine.sh

source lib/ansible-playbook-builder.sh
