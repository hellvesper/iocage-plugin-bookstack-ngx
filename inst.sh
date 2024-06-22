## Packages

### Base
pkg install php83
pkg install php83-composer
pkg install php83-dom
pkg install php83-session php83-tokenizer
pkg install php83-iconv
pkg install php83-simplexml
pkg install php83-xml
pkg install php83-dom
pkg install php83-pdo php83-pdo_mysql

pkg remove mariadb106-client
pkg install mariadb1011-server

### Home
pw groupadd bookstack
pw useradd bookstack -g bookstack -s /bin/sh
mkdir -p /usr/home/bookstack
chown -R bookstack:bookstack /usr/home/bookstack
ln -sf /usr/home /home

### get BookStack App
cd /usr/home/bookstack
git clone https://github.com/BookStackApp/BookStack.git --branch release --single-branch
cd BookStack
composer install --no-dev
PASSWORD=$(openssl rand -base64 12) && mysql -u root -p -e "CREATE DATABASE bookstack; CREATE USER 'bookstack'@'localhost' IDENTIFIED BY '$PASSWORD'; GRANT ALL PRIVILEGES ON bookstack.* TO 'bookstack'@'localhost'; FLUSH PRIVILEGES;" && echo "username: bookstack\npassword: $PASSWORD" > credentials.txt
APP_KEY=$(php artisan key:generate --show)

sed -i '' "s/^APP_KEY=.*/APP_KEY=$APP_KEY/" .env
sed -i '' "s/^APP_URL=.*/APP_URL=http:\/\/$(uname -n).local/" .env
sed -i '' "s/^DB_DATABASE=.*/DB_DATABASE=bookstack/" .env
sed -i '' "s/^DB_USERNAME=.*/DB_USERNAME=bookstack/" .env
sed -i '' "s/^DB_PASSWORD=.*/DB_PASSWORD=$PASSWORD/" .env
sed -i '' "s/^MAIL_FROM=.*/MAIL_FROM=bookstack@$(uname -n).local/" .env
# adjust php.ini default socket location /var/run/mysql/mysql.sock
sed -i '' "s/^pdo_mysql.default_socket=.*/pdo_mysql.default_socket=\/var\/run\/mysql\/mysql.sock/" /usr/local/etc/php.ini
# enable socket instead tcp
sed -i '' "s/^listen = .*/listen = \/var\/run\/php-fpm.sock/" /usr/local/etc/php-fpm.d/www.conf
sed -i '' "s/^listen.owner = .*/listen.owner = www/" /usr/local/etc/php-fpm.d/www.conf
sed -i '' "s/^listen.group = .*/listen.group = www/" /usr/local/etc/php-fpm.d/www.conf
sed -i '' "s/^listen.mode = .*/listen.mode = 0660/" /usr/local/etc/php-fpm.d/www.conf

### migrate db
php artisan migrate --force

cd ~
sudo chown -R vesper:www BookStack
sudo chmod -R 755 BookStack
sudo chmod -R 775 BookStack/storage BookStack/bootstrap/cache BookStack/public/uploads
sudo chmod 640 BookStack/.env



## Services
sysrc php_fpm_enable=YES
sysrc nginx_enable=YES
service php-fpm start
service nginx start
