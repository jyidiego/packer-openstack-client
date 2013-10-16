#!/bin/bash

apt-get -y update
apt-get -y install curl build-essential libxml2-dev libxslt-dev git zlib1g-dev libssl-dev subversion
apt-get -y install linux-headers-generic linux-image-extra-`uname -r`
apt-get -y install python openssh-server python-dev software-properties-common ipython

#
# Setup ssh keys for root
#
mkdir /root/.ssh
cat <<EOF >> /root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOF
chmod 400 /root/.ssh/authorized_keys

#
# Install easy_install, pip, and the openstack python libs, and ansible
#
curl https://pypi.python.org/packages/source/s/setuptools/setuptools-1.1.6.tar.gz | tar xvzf -;cd setuptools-1.1.6;python setup.py install
easy_install pip
pip install python-novaclient
pip install python-swiftclient
pip install python-heatclient
pip install python-cinderclient
pip install python-keystoneclient
pip install python-troveclient
pip install pyrax
pip install ansible
git clone https://github.com/calebgroom/clb.git $HOME/clb;cd $HOME/clb;python setup.py install

#
# Install chef client and knife
#
curl -L https://www.opscode.com/chef/install.sh | sudo bash
/opt/chef/embedded/bin/gem --no-rdoc --no-ri knife-rackspace

#
# Create modified sudoers file
#
cat <<SUDO > /etc/sudoers
#
# This file MUST be edited with the 'visudo' command as root.
#
# Please consider adding local content in /etc/sudoers.d/ instead of
# directly modifying this file.
#
# See the man page for details on how to write a sudoers file.
#
Defaults	env_reset
Defaults	exempt_group=admin
Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Host alias specification

# User alias specification

# Cmnd alias specification

# User privilege specification
root	ALL=(ALL:ALL) ALL

# Members of the admin group may gain root privileges
%admin ALL=(ALL) NOPASSWD:ALL

# Allow members of group sudo to execute any command
%sudo	ALL=(ALL:ALL) ALL

# See sudoers(5) for more information on "#include" directives:

#includedir /etc/sudoers.d
SUDO

#
# Create message of the day file
#
cat <<EOF > /etc/motd.tail
 Rackspace Public Cloud/Openstack Automation Platform

 This platform comes with the following Openstack SDKs
 and command line utilities:

 Version Control Tools: git, subversion
 Automation Tools: ansible, chef-client, chef-solo, juju
 Python: pyrax, nova, swift, clb, heat, keystone, cinder, neutron, and trove
 Ruby: fog, rumm

 RUN THIS COMMAND TO START: source openstackrc
EOF

#
# Install VBoxLinuxAdditions
#
apt-get -y update
apt-get -y install dkms
mount -o loop,ro /root/VBoxGuestAdditions.iso /mnt
/mnt/VBoxLinuxAdditions.run

#
# added to mimic vagrant functionality on standard vboxes
#
addgroup admin
addgroup vagrant
adduser --system --disabled-password --shell /bin/bash --ingroup vagrant vagrant
adduser vagrant adm
adduser vagrant cdrom
adduser vagrant sudo
adduser vagrant dip
adduser vagrant plugdev
adduser vagrant lpadmin
adduser vagrant sambashare
adduser vagrant admin

#
# Install and setup ruby
#
su - vagrant -c "git clone https://github.com/sstephenson/rbenv.git /home/vagrant/.rbenv"
su - vagrant -c "git clone https://github.com/sstephenson/ruby-build.git /home/vagrant/.rbenv/plugins/ruby-build"
su - vagrant -c "/home/vagrant/.rbenv/bin/rbenv install 1.9.3-p448"
su - vagrant -c "/home/vagrant/.rbenv/versions/1.9.3-p448/bin/gem install --no-rdoc --no-ri rumm"
su - vagrant -c "/home/vagrant/.rbenv/versions/1.9.3-p448/bin/gem install --no-rdoc --no-ri bundler"

#
# Setup ssh keys
#
mkdir -p /home/vagrant/.ssh
cat <<EOF >> /home/vagrant/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key
EOF
chmod 400 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant
rm -rf /root/.ssh

#
# Setup docker
#

# Add the Docker repository key to your local keychain
# using apt-key finger you can check the fingerprint matches 36A1 D786 9245 C895 0F96 6E92 D857 6A8B A88D 21E9
# curl https://get.docker.io/gpg | apt-key add -

# Add the Docker repository to your apt sources list.
# echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list

# install
# apt-get -y update
# apt-get -y install lxc-docker

#
# Setup juju
#
add-apt-repository -y ppa:juju/stable
apt-get -y update
apt-get -y install juju-core

#
# copy and set permissions for openstack rc file
#
cp /tmp/openstackrc.sh /home/vagrant
cp /tmp/openstack_cli_functions.sh /home/vagrant
chown vagrant:vagrant /home/vagrant/openstackrc.sh /home/vagrant/openstack_cli_functions.sh

#
# Redo the vbox additions
#
/etc/init.d/vboxadd setup
