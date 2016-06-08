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


# The idea is to mirror any repository, in a new architecture, by just passing
# the required values as arguments, for example:


source svauto.conf


for i in "$@"
do
case $i in

        --base-os=*)

                BASE_OS="${i#*=}"
                shift
                ;;

        --product=*)

                PRODUCT="${i#*=}"
		PLATFORM="LNX"
                shift
                ;;

        --version=*)

		VERSION="${i#*=}"
		shift
		;;

	--release=*)

		RELEASE="${i#*=}"
		shift
		;;

	--latest)

		LATEST="yes"
		shift
		;;

	--latest-of-serie)

		LATEST_OF_SERIE="yes"
		shift
		;;

	--dry-run)

		DRY_RUN="yes"
		shift
		;;

esac
done


case "$BASE_OS" in

	centos6)
		BASE_OS="RHEL6-x64"
		OS_DIR="6"
		;;

	centos7)
		BASE_OS="RHEL7-x64"
		OS_DIR="7"
		;;

	*)
                echo
                echo "Usage: $0 --base-os={centos6|centos7}"
                exit 1
                ;;

esac


case "$PRODUCT" in

	svpts)

		PROD_DIR="SVPTS"
		;;

	svprotocols)

		PROD_DIR="PTSD_PROTOCOLS"
		;;

	svspb)

		PROD_DIR="SPB"
		;;

	svsde)

		PROD_DIR="SDE"
		;;

	svusagemanagement)

		PROD_DIR="USAGE_MANAGEMENT"
		;;

	svusagemanagementpts)

		PROD_DIR="USAGE_MANAGEMENT_PTS"
		;;

	svreports)

		PROD_DIR="NDS"
		;;

	svsubscribermapping)

		PROD_DIR="SUBSCRIBER_MAPPING"
		;;

	subscriber_mapping)

		PROD_DIR="RPM_COMMON/SUBSCRIBER_MAPPING"
		;;

	*)
		echo
		echo "You must select a product to mirror..."
		exit 1
		;;

esac


case "$RELEASE" in

        prod)

                UPSTREAM_HOST="$PUBLIC_PACKAGES_SERVER"
                ;;

        dev)

                UPSTREAM_HOST="$PRIVATE_PACKAGES_SERVER"
                ;;

        *)
                echo
                echo "Usage: $0 --release={prod|dev}"
                exit 1
                ;;

esac


MAJOR_VERSION=`echo $VERSION |sed 's/.\{8\}$//'`


# SPB repo subdir < 6 doesn't have "-LNX-" on its name.
if [ "$PRODUCT" == "svspb" ] || [ "$PRODUCT" == "svreports" ] && [ "$MAJOR_VERSION" -le "6" ]
then
	FULL_NAME="$PRODUCT-$VERSION"
else
	FULL_NAME="$PRODUCT-$PLATFORM-$VERSION"
fi


SHORT_NAME="$PRODUCT-$VERSION"

SHORT_VERSION=`echo $VERSION |sed 's/.\{5\}$//'`

VER_DOT=`echo $VERSION | sed 's/\-/\./'`

REPOS_PATH="$PUBLIC_ROOT_DIR/centos/$OS_DIR/svrepos/x86_64"

FULL_PATH="$PUBLIC_ROOT_DIR/centos/$OS_DIR/svrepos/x86_64/$SHORT_NAME"


mkdir -p $FULL_PATH/Packages


# If subscriber_mapping on CentOS 7, the subdirectory and the RPM package
# location are different.
if [ "$PRODUCT" == "subscriber_mapping" ]
then
	wget -c -P $FULL_PATH/Packages ftp://$UPSTREAM_HOST/images/Linux/$BASE_OS/$PROD_DIR/$SHORT_NAME*el7.x86_64.rpm
else
	wget -c -P $FULL_PATH/Packages ftp://$UPSTREAM_HOST/images/Linux/$BASE_OS/$PROD_DIR/$FULL_NAME/*.rpm
fi


createrepo $FULL_PATH


if [ "$PRODUCT" == "subscriber_mapping" ]
then
	mv $REPOS_PATH/$SHORT_NAME $REPOS_PATH/svsubscribermapping-$VER_DOT
	PRODUCT="svsubscribermapping"
	SHORT_NAME="$PRODUCT-$VER_DOT"
fi


if [ "$LATEST_OF_SERIE" == "yes" ]
then
	cd $REPOS_PATH

	[ -L "$PRODUCT-$SHORT_VERSION" ] && rm -f "$PRODUCT-$SHORT_VERSION"
	ln -sf $SHORT_NAME $PRODUCT-$SHORT_VERSION

	cd - &>/dev/null
fi


if [ "$LATEST" == "yes" ]
then
	cd $REPOS_PATH

	[ -L "$PRODUCT-$SHORT_VERSION" ] && rm -f "$PRODUCT-$SHORT_VERSION"
	ln -sf $SHORT_NAME $PRODUCT-$SHORT_VERSION

	[ -L "$PRODUCT" ] && rm -f "$PRODUCT"
	ln -sf $PRODUCT-$SHORT_VERSION $PRODUCT

	cd - &>/dev/null
fi
