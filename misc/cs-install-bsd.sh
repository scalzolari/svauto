#! /bin/bash


clear


echo
echo "Welcome to Sandvine Platform installation!"
echo


echo
echo "Installing Git and Ansible..."
echo
sudo apt -y install git ansible


echo
echo "Cloning Sandvine's Ansible Deployment into your home directory..."
echo
cd ~
git clone -b dev http://github.com/tmartinx/svauto.git


echo
echo "Deploying Sandvine Platform from its RPM Packages:"
echo
cd ~/svauto
./svauto.sh --freebsd-pts=yes --stack=demo
