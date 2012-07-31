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


# Ask what the name of the site
echo -e "\n"
echo "What is the name of the site that is being deployed?"
read site_name

# Ask what the name of the site
echo -e "\n"
echo "What is your public key?"
read PUBLIC_KEY

ruby_version="1.9.3"
ruby_version_string="1.9.3-p194"
main_path=$(cd && pwd)/railsunicorn
log_file="$railsready_path/install.log"
HOME_BASE='/home/'
USER="deploy20"
TIMEZONE='America/New_York'

echo -e "\n"
echo "Updating and Upgrading installed packages..."
yes | sudo aptitude update
yes | sudo aptitude safe-upgrade -y

echo "Creating the user and adding to the www-data"
# sudo useradd -g www-data -p ${PASSWORD} -m -d ${HOME_BASE}${USER} ${USER}
sudo adduser ${USER}
sudo /usr/sbin/usermod -a -G www-data ${USER}

echo "Installing some of the required packages"
yes | sudo apt-get install build-essential git-core python-software-properties bison openssl libreadline6 libreadline6-dev curl zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev autoconf libxslt-dev libcurl4-openssl-dev mysql-server mysql-client libmysqlclient-dev libmysqlclient16-dev nodejs -y

# sudo debconf-set-selections <<< 'mysql-server-5.1 mysql-server/root_password password your_password'
# sudo debconf-set-selections <<< 'mysql-server-5.1 mysql-server/root_password_again password your_password'
# sudo apt-get -y install mysql-server

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

echo "Updaing the Time Zone...."
sudo echo "${TIMEZONE}" | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata

echo "Adding the authorized_keys users and permissions..."
echo "${PUBLIC_KEY}" >> ~/.ssh/authorized_keys
chown -R ubuntu:ubuntu ~ubuntu/.ssh
chmod 700 ~ubuntu/.ssh
chmod 600 ~ubuntu/.ssh/authorized_keys

sudo mkdir ${HOME_BASE}${USER}/.ssh
sudo cp ~/.ssh/authorized_keys ${HOME_BASE}${USER}/.ssh/authorized_keys
sudo chown -R ${USER}:${USER} ${HOME_BASE}${USER}/.ssh
sudo chmod 700 ${HOME_BASE}${USER}/.ssh
sudo chmod 600 ${HOME_BASE}${USER}/.ssh/authorized_keys

echo -e "\n=> Installing RVM the Ruby Version Manager \n"
sudo su ${USER} -c 'bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)'
RVM_COMMAND='[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"'
echo "${RVM_COMMAND}" | sudo su ${USER} -c 'tee -a "$HOME/.bashrc"' >/dev/null
sudo source ${HOME_BASE}${USER}/.bashrc
sudo su ${USER} -c 'rvm install 1.9.3'
sudo su ${USER} -c 'rvm use --default 1.9.3'
echo "install: --no-rdoc --no-ri" | sudo su ${USER} -c 'tee -a "$HOME/.gemrc"' >/dev/null
echo "update: --no-rdoc --no-ri" | sudo su ${USER} -c 'tee -a "$HOME/.gemrc"' >/dev/null
sudo su ${USER} 'gem install rails --no-rdoc --no-ri'
sudo su ${USER} 'gem install bundler --no-rdoc --no-ri'

control_c()
{
  echo -en "\n\n**** Exiting the Rails Unicorn install ****\n\n"
  exit 1
}

# trap keyboard interrupt (control-c)
trap control_c SIGINT
