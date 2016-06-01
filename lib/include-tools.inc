#! /bin/bash

source lib/move2webroot.sh

source lib/yum_repo_builder.sh

source lib/packer_build_cs_release.sh
source lib/packer_build_cs.sh
source lib/packer_build_official.sh
source lib/packer_build_sandvine.sh
