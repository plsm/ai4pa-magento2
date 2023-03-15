#!/usr/bin/env bash

/etc/init.d/mysql start

sleep 3

ANS=$(echo "SHOW DATABASES" | mysql | grep magento_db)

if [ "$ANS" != "magento_db" ] ; then
    echo "Creating magento mysql database..."
    cat /docker-image/setup.sql | mysql
    /etc/init.d/mysql restart
    echo "Done!"
else
    echo "Magento mysql database already exists."
fi

/etc/init.d/elasticsearch start

sleep 3

a2enmod rewrite

rm /etc/apache2/sites-enabled/000-default.conf

/etc/init.d/apache2 start

if [ ! -e /var/www/html/magento2.4.5-p1 ] ; then
   echo "Installing magento!" 
   composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=2.4.5-p1 /var/www/html/magento2.4.5-p1
   cd /var/www/html/magento2.4.5-p1
   bin/magento setup:install \
       --admin-firstname=Pedro \
       --admin-lastname=Mariano \
       --admin-email=plsmo@iscte-iul.pt \
       --admin-user=plsm \
       --admin-password="ai4paja/zz" \
       --base-url="http://localhost" \
       --db-host=localhost \
       --db-name=magento_db \
       --db-user=magento_user \
       --db-password=Password
   chown --recursive www-data:www-data /var/www/html/magento2.4.5-p1
   echo "Done!!!"
   /etc/init.d/apache2 restart
else
   echo "Magento is already installed"
fi

cd /var/www/html/magento2.4.5-p1
pwd

php -e -S 127.0.0.1:8082 -t ./pub/ ./phpserver/router.php

