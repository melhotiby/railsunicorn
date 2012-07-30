#!/bin/bash
#
# railsunicorn
#
# Author: Matt Elhotiby <hotiby@gmail.com>
# Licence: MIT
#
#
echo "#############################################"
echo "########## Rails Unicorn ####################"
echo "This script will install rails, unicorn, nginx and rvm"
echo "#############################################"


ruby_version="1.9.3"
ruby_version_string="1.9.3-p194"
main_path=$(cd && pwd)/railsunicorn
log_file="$railsready_path/install.log"
PASSWORD="password"
HOME_BASE='/home/'
USER="deploy"

echo "Updaing the Locale...."
sudo /usr/sbin/locale-gen en_US.UTF-8
sudo /usr/sbin/update-locale LANG=en_US.UTF-8

echo "Updating ubuntu..."
sudo aptitude update

echo "Upgrading installed packages..."
sudo aptitude upgrade

echo "Creating the deploy user"
sudo useradd -g www-data -p ${PASSWORD} -m -d ${HOME_BASE}${USER} ${USER}

echo "Installing some of the required packages"
sudo aptitude install build-essential git-core python-software-properties bison openssl libreadline6 libreadline6-dev curl zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev autoconf libxslt-dev libcurl4-openssl-dev mysql-client libmysqlclient-dev -y


echo "Installing Nginx...."
sudo add-apt-repository ppa:nginx/stable 
sudo aptitude update
sudo aptitude install nginx

echo "disabling rdoc generation for gem install"
echo "gem: --no-ri --no-rdoc" >> ~/.gemrc
sudo echo "gem: --no-ri --no-rdoc" | sudo tee ~${USER}/.gemrc
sudo chown ${USER}:${USER} ~${USER}/.gemrc

control_c()
{
  echo -en "\n\n**** Exiting the Rails Unicorn install ****\n\n"
  exit 1
}

# trap keyboard interrupt (control-c)
trap control_c SIGINT