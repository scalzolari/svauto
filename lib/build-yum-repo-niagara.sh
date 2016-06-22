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

build_yum_repo_niagara()
{

	#
	# PTS stuff
	#

	./yum-repo-builder.sh --release-code-name=niagara --release=dev --base-os=centos7 --product=svpts --version=7.30.0351 --latest
	./yum-repo-builder.sh --release-code-name=rolling --release=dev --base-os=centos7 --product=svprotocols --version=16.06.2109 --latest

	# Usage Management PTS

	./yum-repo-builder.sh --release-code-name=niagara --release=dev --base-os=centos7 --product=svusagemanagementpts --version=5.20.0201 --latest

	# Experimental

	./yum-repo-builder.sh --release-code-name=niagara --release=dev --base-os=centos6 --product=svpts --version=7.30.0035 --latest
	./yum-repo-builder.sh --release-code-name=rolling --release=dev --base-os=centos6 --product=svprotocols --version=16.06.2109 --latest

	./yum-repo-builder.sh --release-code-name=niagara --release=dev --base-os=centos6 --product=svusagemanagementpts --version=5.20.0201 --latest

	./yum-repo-builder.sh --release-code-name=niagara --release=dev --base-os=centos7 --product=svpts --version=7.40.0052 --latest-of-serie
	./yum-repo-builder.sh --release-code-name=niagara --release=dev --base-os=centos6 --product=svpts --version=7.40.0052 --latest-of-serie


	#
	# SDE stuff
	#

	./yum-repo-builder.sh --release-code-name=niagara --release=dev --base-os=centos7 --product=svsde --version=7.45.0305 --latest
	./yum-repo-builder.sh --release-code-name=niagara --release=dev --base-os=centos6 --product=svsde --version=7.45.0305 --latest

	# Usage Management

	./yum-repo-builder.sh --release-code-name=niagara --release=dev --base-os=centos7 --product=svusagemanagement --version=5.20.0201 --latest
	./yum-repo-builder.sh --release-code-name=niagara --release=dev --base-os=centos6 --product=svusagemanagement --version=5.20.0201 --latest

	# Subscriber Mapping

	./yum-repo-builder.sh --release-code-name=niagara --release=dev --base-os=centos6 --product=svsubscribermapping --version=7.45.0003 --latest
	./yum-repo-builder.sh --release-code-name=niagara --release=dev --base-os=centos7 --product=subscriber_mapping --version=7.45-0003 --latest

	# Experimental

	./yum-repo-builder.sh --release-code-name=niagara --release=dev --base-os=centos7 --product=svsde --version=7.50.0052 --latest-of-serie
	./yum-repo-builder.sh --release-code-name=niagara --release=dev --base-os=centos6 --product=svsde --version=7.50.0052 --latest-of-serie


	#
	# SPB stuff
	#

	./yum-repo-builder.sh --release-code-name=niagara --release=dev --base-os=centos6 --product=svspb --version=6.60.0575 --latest

	# NDS

	./yum-repo-builder.sh --release-code-name=niagara --release=dev --base-os=centos6 --product=svreports --version=6.60.0102 --latest


	# Experimental

	./yum-repo-builder.sh --release-code-name=niagara --release=dev --base-os=centos6 --product=svspb --version=7.00.0037 --latest-of-serie

}
