ls -al
cd /var/lib/tomcat8/webapps
sudo service tomcat8 stop
sudo nohup 'sudo java -jar ROOT.war' > java.log &
ls -al
cd ~/frontend
sudo nohup 'sudo ng serve' > out.log &