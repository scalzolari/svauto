#! /bin/bash

for X in /etc/yum.repos.d/Sandvine*; do sed -i -e 's/ftp:.*@ftp/ftp:\/\/{{ftp_username}}:{{ftp_password}}@ftp/g' $X ; sed -i -e 's/^/#/g' $X ; done
