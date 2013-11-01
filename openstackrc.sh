#!/bin/bash

# With the addition of Keystone, to use an openstack cloud you should
# authenticate against keystone, which returns a **Token** and **Service
# Catalog**.  The catalog contains the endpoint for all services the
# user/tenant has access to - including nova, glance, keystone, swift.
#
# *NOTE*: Using the 2.0 *auth api* does not mean that compute api is 2.0.  We
# will use the 1.1 *compute api*
export OS_AUTH_URL=https://identity.api.rackspacecloud.com/v2.0

# OS_TENANT_ID is left blank on purpose because it interferes with swift client
# in rackspace public. If you have a openstack implementation you should set the tenant
# id.
# working.
export OS_TENANT_ID=" "
# export OS_TENANT_NAME="service"
export OS_TENANT_NAME=" "

# In addition to the owning entity (tenant), openstack stores the entity
# performing the action as the **user**.
echo -n "Please enter your Openstack Username: "
read OS_USERNAME
export OS_USERNAME=$OS_USERNAME

# With Keystone you pass the keystone password.
echo -n "Please enter your OpenStack Password: "
read -s OS_PASSWORD_INPUT
export OS_PASSWORD=$OS_PASSWORD_INPUT
echo

# os-region-name
echo -n "Please enter your Region (ORD, DFW, IAD, SYD): "
read OS_REGION_NAME
export OS_REGION_NAME=$OS_REGION_NAME

# HEAT Tenant ID, needed to make this work.
echo -n "Please enter HEAT tenant ID (Rackspace Account ID): "
read HEAT_TENANT_ID
export HEAT_TENANT_ID=${HEAT_TENANT_ID}
export HEAT_URL=https://api.rs-heat.com/v1/${HEAT_TENANT_ID}/

#
# Setup clb cache file for Cloud Load Balancers
#
export CLOUD_SERVERS_USERNAME=$OS_USERNAME
export CLOUD_SERVERS_API_TOKEN=$(keystone token-get | egrep ' id ' | awk '{print $4}')
export CLOUD_SERVERS_API_KEY=$CLOUD_SERVERS_API_TOKEN
export CLOUD_LOADBALANCERS_REGION=$OS_REGION_NAME

#
# Each time this file is sourced recreate clb configuration and API token
#
cat <<EOF > .clb-lastconnection
[connection]
username = $OS_USERNAME
authtoken = $(keystone token-get | egrep ' id ' | awk '{print $4}')
regionurl = https://${OS_REGION_NAME}.loadbalancers.api.rackspacecloud.com/v1.0/${HEAT_TENANT_ID}
timestamp = $(date +"%Y-%m-%d %H:%M:%S")
EOF

#
# Setup API Key
#
export OS_TOKEN=$CLOUD_SERVERS_API_TOKEN
export USERID=$(keystone token-get | grep user_id | awk '{print $4}')
export OS_KEY=$(curl -s ${OS_AUTH_URL}/users/${USERID}/OS-KSADM/credentials/RAX-KSKEY:apiKeyCredentials -H "Content-Type: application/json" -H "X-Auth-Token: $OS_TOKEN" | python -m json.tool | python -c "import json;import sys;print '%s' % json.loads(sys.stdin.read())['RAX-KSKEY:apiKeyCredentials']['apiKey']")

# Set the ruby path so that rumm and ruby can be accessed
# change ruby versions here
export PATH=${PATH}:${HOME}/.rbenv/bin:${HOME}/.rbenv/shims:${HOME}/.rbenv/versions/1.9.3-p448/bin

#
# Setup environment variables and rax credential files for ansible
#
cat <<EOF > .rax_creds_file
[rackspace_cloud]
username = $OS_USERNAME
api_key = $OS_KEY
EOF
export RAX_REGION=$OS_REGION_NAME
export RAX_CREDS_FILE=~/.rax_creds_file

#
# Setup openstack commandline overides for certain command line. Source functions from openstack_cli_functions
#
source ./.openstack_cli_functions.sh
