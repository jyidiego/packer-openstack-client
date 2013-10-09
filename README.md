vagrant-openstack-client
========================

Rackspace Cloud/Openstack Platform with python/ruby openstack clients, ansible, and docker installed.

When you first do a "vagrant up" you're likely to get an error like this:


The following SSH command responded with a non-zero exit status.
Vagrant assumes that this means the command failed!

mount -t vboxsf -o uid=`id -u vagrant`,gid=`getent group vagrant | cut -d: -f3` /vagrant /vagrant

Stdout from the command:



Stderr from the command:

stdin: is not a tty
/sbin/mount.vboxsf: mounting failed with the error: No such device

Simply run the following command:

/etc/init.d/vboxadd setup

then run:

sync;sync;poweroff

Once you do that run "vagrant up" again. This apparently is caused by a bug in virtualbox that has yet to be resolved:
https://github.com/mitchellh/vagrant/issues/1657

