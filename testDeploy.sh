ls -al
cd /var/lib/tomcat8/webapps
sudo export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get -q -y install mysql-server
sudo echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'rootroot';" | sudo mysql -u root
sudo mysql -u root --password="rootroot" < travis.sql
