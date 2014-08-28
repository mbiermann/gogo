# package "ruby-full"
# # --- Install nginx ---
 
# # First, remove unneeded packages
# %w{ nginx nginx-light nginx-full nginx-extras }.each do |pkg|
#   package pkg do
#     action :remove
#   end
# end
 
# # Install nginx-common (contains the init-scripts) and packages needed for compilation
# %w{ nginx-common build-essential libcurl4-openssl-dev libssl-dev zlib1g-dev libpcre3-dev }.each do |pkg|
#   package pkg
# end
 
# # Install passenger
# gem_package 'passenger' do
#   action :upgrade
#   gem_binary '/usr/bin/gem1.9.1'
#   version node['nginx']['passenger']['version']
# end
 
# remote_file 'download nginx' do
#   action :create_if_missing
#   owner 'root'
#   group 'root'
#   mode '0644'
#   path "/usr/src/nginx-#{node['nginx']['version']}.tar.gz"
#   source "http://nginx.org/download/nginx-#{node['nginx']['version']}.tar.gz"
# end
 
# execute 'extract nginx' do
#   command "tar xvfz nginx-#{node['nginx']['version']}.tar.gz"
#   cwd '/usr/src'
#   not_if do
#     File.directory? "/usr/src/nginx-#{node['nginx']['version']}"
#   end
# end
 
# execute 'build nginx' do
#   command "passenger-install-nginx-module" <<
#     " --auto" <<
#     " --prefix=/opt/nginx-#{node['nginx']['version']}" <<
#     " --nginx-source-dir=/usr/src/nginx-#{node['nginx']['version']}" <<
#     " --extra-configure-flags='--with-ipv6 --with-http_realip_module'"
#   not_if do
#     File.exists?("/opt/nginx-#{node['nginx']['version']}/sbin/nginx") &&
#     File.exists?("/var/lib/gems/1.9.1/gems/passenger-#{node['nginx']['passenger']['version']}/agents/PassengerWatchdog")
#   end
# end
 
# # Setup nginx environment
# link '/usr/sbin/nginx' do
#   to "/opt/nginx-#{node['nginx']['version']}/sbin/nginx"
# end
 
# link '/etc/nginx/logs' do
#   to '/var/log/nginx'
# end
 
# # Configuration files
# template "/etc/#{node[:nginx][:service]}/nginx" do
#   owner 'root'
#   group 'root'
#   mode '0644'
#   source 'nginx.erb'
#   notifies :reload, "service[nginx]"
# end
 
# template '/etc/nginx/nginx.conf' do
#   owner 'root'
#   group 'root'
#   mode '0644'
#   source 'nginx.conf.erb'
#   notifies :reload, "service[nginx]"
# end
 
# service "nginx" do
#   supports :status => true, :restart => true, :reload => true
#   action [ :enable, :start ]
# end

# bash "install_shit" do
#   user "root"
#   code <<-EOH
#     sudo apt-get update
#     curl -L get.rvm.io | bash -s stable
#     source /usr/local/rvm/scripts/rvm
#     rvm requirements
#     rvmsudo /usr/bin/apt-get install -y build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion apt-get install libcurl4-gnutls-dev
#     rvm install 1.9.3
#     rvm use 1.9.3 --default
#     rvm rubygems current
#     gem install rails
#     gem install passenger 
#     rvmsudo passenger-install-nginx-module --auto --prefix=/opt/nginx
#     sudo service nginx start 
#   EOH
# end

# ################################################################################
# # Add Gogo server configuration and enable it
# ################################################################################

# template "/etc/nginx/sites-available/#{node[:nginx][:service]}" do
#   source      "#{node[:nginx][:service]}.nginx.conf.erb"
#   owner       "root"
#   group       "root"
#   mode        '0644'
#   variables({
#     :domain => node[:gogo][:domain],
#     :port => node[:gogo][:port],
#     :root => node[:gogo][:src],
#     :rails_env => "#{node[:gogo][:env]}";
#     :ssl_cert => "#{node[:gogo][:ssl_dir]}/ssl.crt",
#     :ssl_key => "#{node[:gogo][:ssl_dir]}/ssl.key"
#   })
# end

# bash "link_config" do
#   code <<-EOH
#     rm -rf /etc/nginx/sites-enabled/#{node[:nginx][:service]}
#     ln -s /etc/nginx/sites-available/#{node[:nginx][:service]} /etc/nginx/sites-enabled/
#   EOH
#   notifies :restart, 'service[nginx]', :delayed
# end


#this RVM shell will download the thin gem to your local RVM gemset
#then we will install the gem and create a configuration file
#the wrapper must be created to allow thin to boot at start
rvm_shell "install thin" do
  ruby_string "#{node['thin_nginx']['ruby_version']}"
  code %{
source #{node['thin_nginx']['rvm_source']}
gem install thin -v #{node['thin_nginx']['thin_version']}
rvmsudo thin install
/usr/sbin/update-rc.d -f thin defaults
rvmsudo thin config -C /etc/thin/#{node['thin_nginx']['app_name']} -c #{node['thin_nginx']['application_dir']} --servers #{node['thin_nginx']['number_of_thins']} -e #{node['thin_nginx']['rails_env']}
rvmsudo rvm wrapper #{node['thin_nginx']['ruby_version']} bootup thin
}
end
#we are changing the bootup environment to use our new wrapper
ruby_block "changing startup DAEMON for thin" do
original_line = "DAEMON=#{node['thin_nginx']['ruby_path']}/gems/#{node['thin_nginx']['ruby_version']}/bin/thin"
  block do
    daemon_file = Chef::Util::FileEdit.new("/etc/init.d/thin")
    daemon_file.search_file_replace_line(/#{original_line}/, "DAEMON=#{node['thin_nginx']['ruby_path']}/bin/bootup_thin")
    daemon_file.write_file
  end
end
#install nginx from package
apt_package "nginx" do
  action :install
end
#make necessary changes to our nginx.conf file
template '/etc/nginx/nginx.conf' do
  path "/etc/nginx/nginx.conf"
  source 'nginx.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end
# #make changes to our default site file
# template "/etc/nginx/sites-available/#{node['thin_nginx']['app_name']}" do
#   path "/etc/nginx/sites-available/#{node['thin_nginx']['app_name']}"
#   source 'default0.erb'
#   owner 'root'
#   group 'root'
#   mode 0644
#   action :create
# end
#create a symbolic link between two folder
execute "link thin" do
  command "ln -nfs /etc/nginx/sites-available/#{node['thin_nginx']['app_name']} /etc/nginx/sites-enabled/#{node['thin_nginx']['app_name']}"
end
#lets start the nginx service and give it some abilities to etc/init.d
service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
#this will start our webserver for first time use!
rvm_shell "start the webserver" do
  ruby_string "#{node['thin_nginx']['ruby_version']}"
  code %{
rvmsudo /etc/init.d/thin start
rvmsudo /etc/init.d/nginx reload
rvmsudo /etc/init.d/nginx restart
}
end