#!/bin/bash 

### Packages install 
# sudo yum -y update
sudo yum -y install httpd httpd-devel rdate nginx git
sudo rdate -s time.bora.net
sudo systemctl enable httpd
sudo systemctl start httpd

##GCP OpsAgent Install & Check
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
sudo systemctl status google-cloud-ops-agent"*"

##TimeZone Setting
sudo timedatectl set-timezone Asia/Seoul
echo $date