require 'json'

################################################################################
# Prepare DataDog config for GoGo server application
################################################################################

datadog = Chef::EncryptedDataBagItem.load("credentials", "datadog")
node.default[:datadog][:api_key] = datadog["keys"]["api_key"]
node.default[:datadog][:application_key] = datadog["keys"]["application_key"]

################################################################################
# Install DataDog
################################################################################

dl_url = "https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh"
bash "install_agent" do
	user "root"
	code "DD_API_KEY=#{node[:datadog][:api_key]} bash -c \"$(curl -L #{dl_url})\""
end

################################################################################
# Update configuration with tags
################################################################################

pam_config = "/etc/dd-agent/datadog.conf"
commented_limits = /^tags:[^\n]*\n/
tags = ["env:#{node[:gogo][:env]}"].concat(node[:datadog][:tags])

ruby_block "Update DataDog config" do
  block do
    sed = Chef::Util::FileEdit.new(pam_config)
    sed.search_file_replace(commented_limits, tags.to_json)
    sed.write_file
  end
  only_if { ::File.readlines(pam_config).grep(commented_limits).any? }
end