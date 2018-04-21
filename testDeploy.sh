ls -al
cd /var/lib/tomcat8/webapps
sudo echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH 'root' BY 'rootroot';" | sudo mysql -u root
sudo mysql -u root --password="rootroot" < travis.sql