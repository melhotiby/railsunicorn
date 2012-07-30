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
PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5WD6lGUodB9SehX5E4j1bSETMfEiiLfPgoqol/qQk6okIqv3RPPgx3qjz1yM0naq3rwvs09VvGvxewTE2KZiQfJnpkaBFkt9CIdNmkoJ1ffdt53rEQCq9bpspo0cE4O9AD6D/lM+OXVkTCP6XxqAB2L4ycW65CHsTtylO57UZQ1v7200gQ/6ns4ZDKBkg1nD3GLf81Fhmw7xfgz8miD+xqz0oYRwFfJ32RisU0efNilpx2d/N/8vHcN8OkwT/S9jJRaHylhtmbD8IjUDrbUCG6WXDwWHlSVWef7YaDP3Og0hhc4BmhqIJ3o2dCJBCLfg9OQdVyvZiUlIIcIOgPU23w== hotiby@gmail.com"

echo "Updating and Upgrading installed packages..."
sudo apt-get update && sudo apt-get -y upgrade

echo "Creating the user and adding to the www-data"
# sudo useradd -g www-data -p ${PASSWORD} -m -d ${HOME_BASE}${USER} ${USER}
sudo /usr/sbin/usermod -a -G www-data ${USER}

echo "Installing some of the required packages"
sudo apt-get install build-essential git-core python-software-properties bison openssl libreadline6 libreadline6-dev curl zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev autoconf libxslt-dev libcurl4-openssl-dev mysql-client libmysqlclient-dev -y


echo "Installing Nginx...."
sudo add-apt-repository ppa:nginx/stable 
sudo aptitude update
sudo aptitude install nginx -y

echo "disabling rdoc generation for gem install"
echo "gem: --no-ri --no-rdoc" >> ~/.gemrc
sudo echo "gem: --no-ri --no-rdoc" | sudo tee ~${USER}/.gemrc
sudo chown ${USER}:${USER} ~${USER}/.gemrc

echo "Updaing the Locale...."
sudo /usr/sbin/locale-gen en_US.UTF-8
sudo /usr/sbin/update-locale LANG=en_US.UTF-8

echo "Adding the authorized_keys users..."
cat PUBLIC_KEY >> ~/.ssh/authorized_keys
chown -R ubuntu:ubuntu ~ubuntu/.ssh
chmod 700 ~ubuntu/.ssh
chmod 600 ~ubuntu/.ssh/authorized_keys

sudo mkdir ~deploy/.ssh
sudo cp ~/.ssh/authorized_keys ~deploy/.ssh/authorized_keys
sudo chown -R deploy:deploy ~deploy/.ssh
sudo chmod 700 ~deploy/.ssh
sudo chmod 600 ~deploy/.ssh/authorized_keys

control_c()
{
  echo -en "\n\n**** Exiting the Rails Unicorn install ****\n\n"
  exit 1
}

# trap keyboard interrupt (control-c)
trap control_c SIGINT