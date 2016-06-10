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

move2webroot()
{

        if [ "$DRY_RUN" == "yes" ]
        then
                echo
                echo "Not creating to web root directory structure! Skipping this step..."
        else

		# Web Public directory details

		# Sandvine Stock images directory:
		WEB_ROOT_STOCK_MAIN=$DOCUMENT_ROOT/images/platform/stock/$RELEASE_CODE_NAME

		WEB_ROOT_STOCK=$WEB_ROOT_STOCK_MAIN/$BUILD_DATE
		WEB_ROOT_STOCK_LAB=$WEB_ROOT_STOCK_MAIN/$BUILD_DATE/lab
		WEB_ROOT_STOCK_RELEASE=$WEB_ROOT_STOCK_MAIN/$BUILD_DATE/to-be-released
#		WEB_ROOT_STOCK_RELEASE_LAB=$WEB_ROOT_STOCK_MAIN/$BUILD_DATE/to-be-released/lab

		# Sandvine Stock mages + Cloud Services directory:
		WEB_ROOT_CS_MAIN=$DOCUMENT_ROOT/images/platform/cloud-services/$RELEASE_CODE_NAME

		WEB_ROOT_CS=$WEB_ROOT_CS_MAIN/$BUILD_DATE
		WEB_ROOT_CS_LAB=$WEB_ROOT_CS_MAIN/$BUILD_DATE/lab
		WEB_ROOT_CS_RELEASE=$WEB_ROOT_CS_MAIN/$BUILD_DATE/to-be-released
#		WEB_ROOT_CS_RELEASE_LAB=$WEB_ROOT_CS_MAIN/$BUILD_DATE/to-be-released/lab


		echo
		echo "Creating web root directory structure..."

		# Creating the Web directory structure:
		mkdir -p $WEB_ROOT_STOCK_LAB
		mkdir -p $WEB_ROOT_STOCK_RELEASE

		mkdir -p $WEB_ROOT_CS_LAB
		mkdir -p $WEB_ROOT_CS_RELEASE

	fi

}
