#!/bin/bash

apt-get -y update
apt-get -y install curl build-essential libxml2-dev libxslt-dev git zlib1g-dev libssl-dev
apt-get -y install linux-headers-generic linux-image-extra-`uname -r`
apt-get -y install python openssh-server python-dev

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
pip install pyrax
pip install ansible
git clone https://github.com/calebgroom/clb.git $HOME/clb;cd $HOME/clb;python setup.py install

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

 This platform comes with the following SDK
 and command line utilities:

 Version Control Tools: git and subversion
 Automation Tools: ansible, chef-client, chef-solo, docker
 Python: pyrax, nova, swift, clb, heat, keystone, and cinder
 Ruby: fog, rumm

 RUN THIS COMMAND TO START: source openstackrc

EOF

#
# Install VBoxLinuxAdditions
#
mount -o loop,ro /root/VBoxGuestAdditions.iso /mnt
/mnt/VBoxLinuxAdditions.run
/etc/init.d/vboxadd setup

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
su - vagrant -c "/home/vagrant/.rbenv/versions/1.9.3-p448/bin/gem install rumm"
su - vagrant -c "/home/vagrant/.rbenv/versions/1.9.3-p448/bin/gem install bundler"

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
curl https://get.docker.io/gpg | apt-key add -

# Add the Docker repository to your apt sources list.
echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list

# install
apt-get -y update
apt-get -y install lxc-docker


#
# Create openstackrc file to source
#
cat <<OPENSTACK > /home/vagrant/openstackrc
#!/bin/bash

# With the addition of Keystone, to use an openstack cloud you should
# authenticate against keystone, which returns a **Token** and **Service
# Catalog**.  The catalog contains the endpoint for all services the
# user/tenant has access to - including nova, glance, keystone, swift.
#
# *NOTE*: Using the 2.0 *auth api* does not mean that compute api is 2.0.  We
# will use the 1.1 *compute api*
export OS_AUTH_URL=https://identity.api.rackspacecloud.com/v2.0/

# OS_TENANT_ID is left blank on purpose because it interferes with swift client
# working.
export OS_TENANT_ID=" "
# export OS_TENANT_NAME="service"

# In addition to the owning entity (tenant), openstack stores the entity
# performing the action as the **user**.
echo -n "Please enter your Openstack Username: "
read OS_USERNAME
export OS_USERNAME=\$OS_USERNAME

# With Keystone you pass the keystone password.
echo -n "Please enter your OpenStack Password: "
read -s OS_PASSWORD_INPUT
export OS_PASSWORD=\$OS_PASSWORD_INPUT
echo

# os-region-name
echo -n "Please enter your Region (ORD, DFW, IAD, SYD): "
read OS_REGION_NAME
export OS_REGION_NAME=\$OS_REGION_NAME

# HEAT Tenant ID, needed to make this work.
echo -n "Please enter HEAT tenant ID: "
read HEAT_TENANT_ID
export HEAT_TENANT_ID=\${HEAT_TENANT_ID}
export HEAT_URL=https://api.rs-heat.com/v1/\${HEAT_TENANT_ID}/

#
# Setup clb cache file for Cloud Load Balancers
#
export CLOUD_SERVERS_USERNAME=\$OS_USERNAME
export CLOUD_SERVERS_API_KEY=\$(keystone token-get | egrep ' id ' | awk '{print \$4}')
export CLOUD_LOADBALANCERS_REGION=\$OS_REGION_NAME

#
# Each time this file is sourced recreate clb configuration and API token
#
cat <<EOF > .clb-lastconnection
[connection]
username = \$OS_USERNAME
authtoken = \$(keystone token-get | egrep ' id ' | awk '{print \$4}')
regionurl = https://\${OS_REGION_NAME}.loadbalancers.api.rackspacecloud.com/v1.0/\${HEAT_TENANT_ID}
timestamp = \$(date +"%Y-%m-%d %H:%M:%S")
EOF

# Finally set the ruby path so that rumm and ruby can be accessed
# change ruby versions here
export PATH=$PATH:$HOME/.rbenv/bin:/home/vagrant/.rbenv/shims:/home/vagrant/.rbenv/versions/1.9.3-p448/bin
OPENSTACK

chown vagrant:vagrant /home/vagrant/openstackrc

