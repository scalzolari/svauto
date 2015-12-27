#! /bin/bash


clear


echo
echo "Welcome to Sandvine Platform installation!"
echo


echo
echo "Installing Git and Ansible..."
echo
sudo apt-get install -y git ansible=1.7.2+dfsg-1~ubuntu14.04.1


echo
echo "Cloning Sandvine's Ansible Deployment into your home directory..."
echo
cd ~
git clone -b dev http://gitlab.cs.sandvine.com/octo/sandvine-playbook.git


echo
echo "Deploying Sandvine Platform from its RPM Packages:"
echo
cd ~/sandvine-playbook
./svauto.sh --freebsd-pts=yes --stack=demo
