#!/bin/tcsh

# Define the username and other details
set username="bookstack"
set fullname="bookstack-ngx"
set appname="BookStack"
set uid=1000
set gid=1000
set home="/home/bookstack"
# set shell="/bin/bash"

## this for cmd cheatsheet only
# /usr/sbin/pw groupadd ${username}
# /usr/sbin/pw useradd ${username} -n ${fullname} -u ${uid} -g ${gid} -m -s ${shell}
# pw usermod ${username} -u ${uid}
# pw groupmod ${username} -g ${gid}
# Optionally, add the user to a group
#/usr/sbin/pw groupmod staff -m ${username}
## Set a password for the new user
# echo "newuser:password" | /usr/sbin/chpass

## Create the group and user
pw groupadd -g ${gid} -n ${username} && pw useradd -n ${username} -u ${uid} -m -g ${username} -s /bin/sh -d ${home}


### create mount dirs
# mkdir /mnt/storage
# mkdir /mnt/cache
# mkdir /mnt/uploads

# chown -R ${username}:${username} /mnt/storage
# chown -R ${username}:${username} /mnt/cache
# chown -R ${username}:${username} /mnt/uploads
# chmod -R 775 /mnt/storage /mnt/cache /mnt/uploads


### fetch bookstack
cd ${home}

sudo -Hu ${username} git clone https://github.com/BookStackApp/BookStack.git --branch release --single-branch && \
chown -R ${username}:www BookStack
chmod -R 755 BookStack
chmod -R 775 BookStack/storage BookStack/bootstrap/cache BookStack/public/uploads

cd ${appname}
sudo -Hu ${username} cp .env.example .env
chmod 640 .env
sudo -Hu ${username} composer install --no-dev

### before migration we should start mysql server
sysrc -f /etc/rc.conf mysql_enable=YES
service mysql-server start
set PASSWORD=`openssl rand -base64 12` && mysql -u root -e "CREATE DATABASE bookstack; CREATE USER 'bookstack'@'localhost' IDENTIFIED BY '$PASSWORD'; GRANT ALL PRIVILEGES ON bookstack.* TO 'bookstack'@'localhost'; FLUSH PRIVILEGES;" && echo "username: bookstack\npassword: $PASSWORD" > /usr/home/bookstack/credentials.txt
set APP_KEY=`php artisan key:generate --show`

### adjust bookstack config
cd ${home}/${appname}
## for base64 encoded strings use '|'' delimeter in sed as '/'' used by base64
sed -i '' "s|^APP_KEY=.*|APP_KEY=${APP_KEY}|" .env
sed -i '' "s/^APP_URL=.*/APP_URL=http:\/\/`uname -n`.local/" .env
sed -i '' "s/^DB_DATABASE=.*/DB_DATABASE=bookstack/" .env
sed -i '' "s/^DB_USERNAME=.*/DB_USERNAME=bookstack/" .env
sed -i '' "s|^DB_PASSWORD=.*|DB_PASSWORD=${PASSWORD}|" .env
sed -i '' "s/^MAIL_FROM=.*/MAIL_FROM=bookstack@`uname -n`.local/" .env
# adjust php.ini default socket location /var/run/mysql/mysql.sock
cp /usr/local/etc/php.ini-production /usr/local/etc/php.ini
sed -i '' "s/^pdo_mysql.default_socket=.*/pdo_mysql.default_socket=\/var\/run\/mysql\/mysql.sock/" /usr/local/etc/php.ini
# enable socket instead tcp
sed -i '' "s/^listen = .*/listen = \/var\/run\/php-fpm.sock/" /usr/local/etc/php-fpm.d/www.conf
sed -i '' "s/^;listen.owner = .*/listen.owner = www/" /usr/local/etc/php-fpm.d/www.conf
sed -i '' "s/^;listen.group = .*/listen.group = www/" /usr/local/etc/php-fpm.d/www.conf
sed -i '' "s/^;listen.mode = .*/listen.mode = 0660/" /usr/local/etc/php-fpm.d/www.conf

### migrate db
sudo -Hu ${username} php artisan migrate --force


### nginx config tweak
# sed -i '' "s|bookstack|`uname -n`|g" /usr/local/etc/nginx/sites-available/${username}.conf
mkdir -p /usr/local/etc/nginx/sites-enabled/
ln -s /usr/local/etc/nginx/sites-available/${username}.conf /usr/local/etc/nginx/sites-enabled/${username}.conf

### enable services
sysrc -f /etc/rc.conf php_fpm_enable=YES
sysrc -f /etc/rc.conf nginx_enable=YES
sysrc -f /etc/rc.conf mdnsresponderposix_enable=YES
sysrc -f /etc/rc.conf mdnsresponderposix_flags="-f /usr/local/etc/mdnsresponder.conf"

### start services
service php-fpm start
service nginx start
service mdnsresponderposix start

echo "Default username 'admin@admin.com'" >> /root/PLUGIN_INFO
echo "Default password 'password'" >> /root/PLUGIN_INFO
echo "Web interface mDNS URL: http://`uname -n`.local" >> /root/PLUGIN_INFO

echo "Don't forget mount consume dir and optionaly data and media dir if you want download back"
echo "You can mount dirs from FreeBSD terminal or TrueNAS terminal like this:"
echo "sudo iocage fstab -a `uname -n` /path/to/host/dir /mnt/host_dir nullfs rw 0 0"
echo "i.e. sudo iocage fstab -a `uname -n` /Storage/bookstack/storage /mnt/storage nullfs rw 0 0"
echo "Or in TruNAS GUI: Jails -> your_jail click arrow '>' -> Mount points"
echo "Ensure that dirs has write permission"

### mount jail dirs like this
# iocage fstab -a `uname -n` /path/to/host/dir /mnt/host_dir nullfs rw 0 0