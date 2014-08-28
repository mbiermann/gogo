root = File.absolute_path(File.dirname(__FILE__))

file_cache_path root
puts root
cookbook_path root + '/berks-cookbooks'
role_path root + '/berks-cookbooks/gogo/roles'
data_bag_path root + '/berks-cookbooks/gogo/data_bags'
