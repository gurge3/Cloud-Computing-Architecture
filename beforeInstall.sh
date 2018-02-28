sudo dpkg --configure -a
export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get -q -y install mysql-server
cd /var/lib/tomcat8/webapps
sudo rm -rf /var/lib/tomcat8/webapps/ROOT