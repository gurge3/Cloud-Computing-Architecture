cd /var/lib/tomcat8/webapps
sudo apt-get install debconf-utils
sudo export DEBIAN_FRONTEND=noninteractive
debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password_again password root'
apt-get install
sudo -E apt-get -q -y install mysql-server
sudo rm -rf /var/lib/tomcat8/webapps/ROOT