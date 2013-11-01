log_level                :info
log_location             STDOUT
node_name                'vagrant'
client_key               '/home/vagrant/.chef/vagrant.pem'
validation_client_name   'chef-validator'
validation_key           '/home/vagrant/chef-validator.pem'
chef_server_url          'https://openstack-client:443'
syntax_check_cache_path  '/home/vagrant/.chef/syntax_check_cache'
knife[:rackspace_api_username] = "#{ENV['OS_USERNAME']}"
knife[:rackspace_api_key] = "#{ENV['OS_KEY']}"
case "#{ENV['OS_REGION_NAME']}"
when "IAD"
  knife[:rackspace_region] = :iad
when "DFW"
  knife[:rackspace_region] = :dfw
when "LON"
  knife[:rackspace_region] = :lon
when "SYD"
  knife[:rackspace_region] = :syd
when "ORD"
  knife[:rackspace_region] = :ord
end
