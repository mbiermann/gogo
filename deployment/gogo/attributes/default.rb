default["gogo"] = {
	:src 	=> "/opt/gogo/gogo-cockpit",
	:port => 8080,
	:log_dir => "/var/log/gogo",
	:stats_prefix => "gogo",
	:env => "",
	:domain => "",
	:ssl_dir => "/opt/gogo/gogo-cockpit",
	:user => "www-data",
	:www_dir => "/var/www",
	:app => "gogo"
}
default['rvm']['default_ruby']      = "ruby-2.1.2"
default['rvm']['user_default_ruby'] = "ruby-2.1.2"
default['rvm']['rubies']      = ["ruby-2.1.2"]
default['rvm']['global_gems'] = [
  { 'name' => 'bundler' },
  { 'name' => 'rake' }
 ]
default['thin_nginx']['thin_version'] = "1.6.2"
default['thin_nginx']['rails_env'] = "production"
