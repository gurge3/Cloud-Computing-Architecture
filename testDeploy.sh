ls -al
cd /var/lib/tomcat8/webapps
sudo echo "USE mysql;\nUPDATE user SET password=PASSWORD('rootroot') WHERE user='root';\nFLUSH PRIVILEGES;\n" | mysql -u root
sudo mysql -u root --password="rootroot" < travis.sql
ls -al
cd ~/webapp
sudo npm install
npm install -g @angular/cli@latest
