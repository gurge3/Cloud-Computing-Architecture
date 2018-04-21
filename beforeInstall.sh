cd /var/lib/tomcat8/webapps
sudo dpkg --configure -a
sudo export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get -q -y install mysql-server
sudo rm -rf /var/lib/tomcat8/webapps/ROOT