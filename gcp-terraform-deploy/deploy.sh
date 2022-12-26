#! /bin/bash
#prepare for installs
sudo apt-get -f autoremove -y
sudo apt-get update -y
sudo apt-get upgrade -y

#install nginx
sudo apt install nginx -y

#enable ufw
sudo ufw allow 'Nginx HTTP'
sudo ufw enable

#configure
sudo chown -R $USER:$USER /var/www/html
sudo systemctl start nginx
sudo systemctl enable nginx