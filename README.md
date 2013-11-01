vagrant-openstack-client
========================

Rackspace Cloud/Openstack Platform

This repo contains the source for the virtualbox https://rax.io/rax_workstation.box the main ingredients for this is:

 - openstack-client.json # The packer build file
 - load-openstackclient.sh # shell provisioner

Below are instructions on using the virtualbox.

vagrant init rax_workstation http://rax.io/rax_workstation.box

This virtualbox contains pretty much all of the Rackspace Pulic Cloud SDKs (Java, Python, Ruby) and command line tools. As our cloud is based on OpenStack you can also configure it to work with your private OpenStack cloud. The platform is an attempt at making it easier to kick the tires of the Rackspace Cloud APIs. It also has Ansible, heat (OpenStack Orchestration) and the rackspace knife plugin installed to try different configuration tools out. Once you login (via vagrant ssh) you source the openstackrc.sh:

```
source openstackrc.sh
```

And it will give you the following prompts:
```
Please enter your Openstack Username: racker
Please enter your OpenStack Password: 
Please enter your Region (ORD, DFW, IAD, SYD): IAD
Please enter HEAT tenant ID (Rackspace Account ID): 999999
```

Once you answer these question it should preconfigure everything so that you can just start looking around. For example running:

```
nova list
trove list
clb list
swift list
heat -k stack-list  # this isn't available yet but when Rackspace releases this feature will it should work out of the gate. The -k option is to not check server certificate against CAs.
```

Should all return cloudservers, database servers, load balancers, containers, and orchestration stacks respectively without any further options. If you wanted to checkout Ansible:

```
ssh-keygen -t rsa -b 2048
nova keypair-add ansible_test --pub-key ~/.ssh/id_rsa.pub
export ANSIBLE_HOST_KEY_CHECKING=False
git clone https://github.com/jyidiego/ansible_rax_demo.git
cd ansible_rax_demo
ansible-playbook -i /home/vagrant/ansible_rax_demo/hosts  rax_example.yml
```

The following commands will spin up a 512MB Standard Instance, and run hostname;touch /tmp/ansible_is_awesome

