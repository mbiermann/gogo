set -x
set -e

sudo -s <<HEREDOC
apt-get update
apt-get install git -y
wget -O- https://opscode.com/chef/install.sh | sudo bash

apt-get install build-essential -y
apt-get install ruby1.9.1-dev -y
apt-get install libxslt-dev libxml2-dev -y
gem install berkshelf --no-ri --no-rdoc

rm -rf /usr/local/gogo
rm -rf /opt/gogo/deployment/berks-cookbooks /opt/gogo/deployment/gogo/berks-cookbooks
rm -rf /opt/gogo/deployment/gogo/cookbooks*
cd /opt/gogo/deployment/gogo
berks package
berks vendor
mv berks-cookbooks ..
cd ..
chef-solo -c solo.rb -j solo.json
HEREDOC