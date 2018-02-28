sudo dpkg --configure -a
export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get -q -y install mysql-server