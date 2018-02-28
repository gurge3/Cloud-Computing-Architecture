sudo service tomcat8 stop
cd ~/frontend
sudo ng build --environment=prod
cp dist/* /var/lib/tomcat8/webapps/ROOT
ls -al
cd /var/lib/tomcat8/conf
sudo sed -i 's/port="8080"/port="4200"/' server.xml
sudo service tomcat8 start
cd /var/lib/tomcat8/webapps
sudo nohup sudo java -jar ROOT.war &
ls -al
