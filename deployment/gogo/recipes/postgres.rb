################################################################################
# Load application credentials
################################################################################

app_creds = Chef::EncryptedDataBagItem.load("credentials", "app")
ps_creds = app_creds["postgres"]
password = ps_creds["password"]
user = ps_creds["user"]
db = ps_creds["db"]


node.default[:postgresql][:pg_hba] = [
	{
		:type => "local",
		:db => db,
		:user => user,
		:address => "",
		:method => "md5"
	},
	{
		:type => "local",
		:db => "all",
		:user => "postgres",
		:address => "",
		:method => "ident"
	}
]

include_recipe "postgresql::server"
include_recipe "postgresql::contrib"


pg_user user do
	privileges superuser: false, createdb: false, login: true
	password password
end

pg_database db do
	owner user
	encoding "UTF-8"
	template "template0"
	locale "en_US.UTF-8"
end

pg_database_extensions db do
	languages	"plpgsql"
	extensions	["adminpack", "uuid-ossp"]
end