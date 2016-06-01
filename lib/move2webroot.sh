#! /bin/bash

move2webroot()
{

        if [ "$DRY_RUN" == "yes" ]
        then
                echo
                echo "Not creating to web root directory structure! Skipping this step..."
        else

		# Create a file that contains the build date
		if  [ ! -f build-date.txt ]; then
			echo $TODAY > build-date.txt
			BUILD_DATE=`cat build-date.txt`
		else
			echo
			echo "Warning! Build Date file found, a clean all is recommended..."
			BUILD_DATE=`cat build-date.txt`
		fi


		# Web Public directory details

		# Apache or NGinx DocumentRoot of a Virtual Host:
		DOCUMENT_ROOT="public_dir"

		# Sandvine Stock images directory:
		WEB_ROOT_STOCK_MAIN=$DOCUMENT_ROOT/images/platform/stock

		WEB_ROOT_STOCK=$WEB_ROOT_STOCK_MAIN/$BUILD_DATE
		WEB_ROOT_STOCK_LAB=$WEB_ROOT_STOCK_MAIN/$BUILD_DATE/lab
		WEB_ROOT_STOCK_RELEASE=$WEB_ROOT_STOCK_MAIN/$BUILD_DATE/to-be-released
#		WEB_ROOT_STOCK_RELEASE_LAB=$WEB_ROOT_STOCK_MAIN/$BUILD_DATE/to-be-released/lab

		# Sandvine Stock mages + Cloud Services directory:
		WEB_ROOT_CS_MAIN=$DOCUMENT_ROOT/images/platform/cloud-services

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
