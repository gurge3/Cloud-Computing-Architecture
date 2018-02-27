ls -al
cd /var/lib/tomcat8/webapps
sudo mysql -u root --password="" < travis.sql
ls -al
cd ~/webapp
sudo npm install
npm install -g @angular/cli@latest
