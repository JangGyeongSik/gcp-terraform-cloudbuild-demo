#!/bin/bash 

### Dependency 
sudo yum -y update
sudo yum -y install httpd httpd-devel make gcc rdate python3 nginx git
sudo rdate -s time.bora.net
sudo pip3 install pip --upgrade
sudo pip install setuptools --upgrade
sudo pip install ansible

### PHP 7.2 Install 
sudo wget -c https://www.php.net/distributions/php-8.2.0.tar.gz
sudo tar xf php-8.2.0.tar.gz
cd php-8.2.0 
sudo yum -y install epel-release
sudo yum -y install sqlite-devel wget gcc gcc-c++ pcre pcre-devel openssl openssl-devel libxml2 libxml2-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel gmp gmp-devel libmcrypt libmcrypt-devel readline readline-devel libxslt libxslt-devel cmake
sudo ./configure --prefix=/usr/local/php \
--with-config-file-path=/etc \
--enable-fpm \
--with-fpm-user=www \
--with-fpm-group=www \
--enable-inline-optimization \
--disable-debug \
--disable-rpath \
--enable-shared \
--enable-soap \
--with-libxml-dir \
--with-xmlrpc \
--with-openssl \
--with-mhash \
--with-pcre-regex \
--with-sqlite3 \
--with-zlib \
--enable-bcmath \
--with-iconv \
--with-bz2 \
--enable-calendar \
--with-curl \
--with-cdb \
--enable-dom \
--enable-exif \
--enable-fileinfo \
--enable-filter \
--with-pcre-dir \
--enable-ftp \
--with-gd \
--with-openssl-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib-dir \
--with-freetype-dir \
--with-gettext \
--with-gmp \
--with-mhash \
--enable-json \
--enable-mbstring \
--enable-mbregex \
--enable-mbregex-backtrack \
--with-onig \
--enable-pdo \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-zlib-dir \
--with-pdo-sqlite \
--with-readline \
--enable-session \
--enable-shmop \
--enable-simplexml \
--enable-sockets \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sysvshm \
--enable-wddx \
--with-libxml-dir \
--with-xsl \
--enable-zip \
--enable-mysqlnd-compression-support \
--with-pear \
--enable-opcache

sudo make && make install
sudo cp php.ini-production /etc/php.ini
sudo cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
# sudo cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf
sudo cat <<EOF > /usr/local/php/etc/php-fpm.d/www.conf
[www]
listen = 0.0.0.0:9000
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.max_children = 128
pm.start_servers = 20
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 10000
rlimit_files = 1024
slowlog = log/$pool.log.slow
EOF
sudo cp sapi/fpm/php-fpm.service /usr/lib/systemd/system
### NoLogin www(user) add 
sudo useradd -s /sbin/nologin www >/dev/null 2>&1
sudo sed -i '/ProtectSystem/s/full/false/' /usr/lib/systemd/system/php-fpm.service
sudo systemctl daemon-reload
sudo systemctl enable php-fpm 
sudo systemctl start php-fpm 
sudo ln -sf /usr/local/php/bin/php /usr/bin/
php -v 

### mod_rpaf clone
cd 
git clone https://github.com/gnif/mod_rpaf
cd mod_rpaf
sudo apxs -i -c -n mod_rpaf.so mod_rpaf.c
cd ..
sudo sed -i 's/Listen 80/Listen 81/g' /etc/httpd/conf/httpd.conf
sudo sed -i 's/^    LogFormat \"\%h/    LogFormat \"\%\{X\-Forwarded\-For\}i - \%h/g' /etc/httpd/conf/httpd.conf
git clone https://github.com/jangjaelee/deploytest.git
cd deploytest
sudo cp index.php /var/www/html/index.php
sudo cp rpaf.conf /etc/httpd/conf.d/rpaf.conf
cd ..
sudo systemctl enable httpd
sudo systemctl enable php-fpm

##OpsAgent Install & Check
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
sudo systemctl status google-cloud-ops-agent"*"

##TimeZone Setting
sudo timedatectl set-timezone Asia/Seoul