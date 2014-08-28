include_recipe "apt"

################################################################################
# Prepare config file for Streambot API server application
################################################################################

config_file = "/vagrant/api.json"

template config_file do 
  source      'config.json.erb'
  owner       'root'
  group       'root'
  mode        '0644'
  variables({
    :config => node[:streambot_api][:config]
  })
end