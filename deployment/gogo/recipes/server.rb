include_recipe "apt"

package "libmagickcore-dev"
package "imagemagick"
package "libxml2-dev"
package "libxslt1-dev"
package "libpq-dev" # required for google oauth gem's native extension
package "git-core"

################################################################################
# Set up directories
################################################################################

directory node[:gogo][:www_dir] do
  owner node[:gogo][:user]
  group "staff"
  mode  "0644"
  action :create
  recursive true
end

app_dir = "#{node[:gogo][:www_dir]}/#{node[:gogo][:app]}"

directory app_dir do
  owner node[:gogo][:user]
  group "staff"
  mode  "0744"
  action :create
  recursive true
end

bash "copy_sources" do
  user "root"
  code "cp -R #{node[:gogo][:src]}/* #{app_dir}"
end

dirs = [
  node[:gogo][:log_dir],
  node[:gogo][:www_dir]
]
dirs.each do |dir|
  directory dir do
    owner node[:gogo][:user]
    group "staff"
    mode  "0744"
    action :create
    recursive true
  end
end

################################################################################
# Load application credentials
################################################################################

app_creds = Chef::EncryptedDataBagItem.load("credentials", "app")
ps_creds = app_creds["postgres"]

### Put production application configuration file ###

template "#{node[:gogo][:src]}/config/environments/production.rb" do
  source      'production.rb.erb'
  owner       "root"
  group       "root"
  mode        '0644'
  variables({
    :env => node[:gogo][:env],
    :domain => node[:gogo][:domain],
    :mailer => app_creds["mailer"]
  })
end

### Put database configuration file ###

template "#{node[:gogo][:src]}/config/database.yml" do
  source      'database.yml.erb'
  owner       "root"
  group       "root"
  mode        '0644'
  variables({
    :user => ps_creds["user"],
    :password => ps_creds["password"],
    :db => ps_creds["db"],
    :env => node[:gogo][:env]
  })
end

### Put secrets configuration file ###

secret_key_base = ""
128.times { secret_key_base << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
template "#{node[:gogo][:src]}/config/secrets.yml" do
  source      'secrets.yml.erb'
  owner       "root"
  group       "root"
  mode        '0644'
  variables({
    :secret_key_base => secret_key_base,
    :env => node[:gogo][:env]
  })
end

### Put devise configuration file ###

devise_secret_key = ""
128.times { devise_secret_key << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
template "#{node[:gogo][:src]}/config/initializers/devise.rb" do
  source      'devise_initializer.rb.erb'
  owner       "root"
  group       "root"
  mode        '0644'
  variables({
    :devise_secret_key => devise_secret_key.downcase,
    :google => app_creds["google"]
  })
end


################################################################################
# Set up application dependencies
################################################################################

bash "install_rails" do
  user node[:gogo][:user]
  code %{
    source /usr/local/rvm/scripts/rvm
    bundle install --path .bundle
  }
  cwd app_dir
end

bash "migrate_db" do
  code "source /usr/local/rvm/scripts/rvm;rake db:migrate RAILS_ENV=#{node[:gogo][:env]}"
  cwd app_dir
end