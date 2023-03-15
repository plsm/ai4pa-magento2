FROM "ubuntu:kinetic"

## initialization ##
###############

RUN apt-get update

RUN apt-get install -y --no-install-recommends wget unzip p7zip curl sudo

RUN mkdir /docker-image

ENV TZ=Europe/Lisbon

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get install -y --no-install-recommends tzdata


## apache ##
############

RUN apt-get install -y --no-install-recommends apache2

COPY ./magento-site.conf /etc/apache2/sites-enabled/magento-site.conf

RUN chown root:root /etc/apache2/sites-enabled/magento-site.conf ; \
    chmod 644 /etc/apache2/sites-enabled/magento-site.conf

## php ##
#########

RUN apt-get install -y --no-install-recommends php

# php extensions required by magento2

RUN apt-get install -y --no-install-recommends php libapache2-mod-php php-dev php-bcmath php-intl php-soap php-zip php-curl php-mbstring php-mysql php-gd php-xml

RUN sed -i "s/file_uploads = .*/file_uploads = On/" /etc/php/8.1/apache2/php.ini
RUN sed -i "s/allow_url_fopen = .*/allow_url_fopen = On/" /etc/php/8.1/apache2/php.ini
RUN sed -i "s/short_open_tag = .*/short_open_tag = On/" /etc/php/8.1/apache2/php.ini
RUN sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.1/apache2/php.ini
RUN sed -i "s/upload_max_filesize = .*/upload_max_filesize = 128M/" /etc/php/8.1/apache2/php.ini
RUN sed -i "s/max_execution_time = .*/max_execution_time = 3600/" /etc/php/8.1/apache2/php.ini


## mysql ##
###########

RUN apt-get install -y --no-install-recommends mysql-server

COPY ./setup.sql /docker-image

RUN chown root:root /docker-image/setup.sql ; \
	 chmod 444 /docker-image/setup.sql


## elasticsearch ##
###################

RUN apt-get install -y --no-install-recommends apt-transport-https ca-certificates gnupg2

run wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -

RUN echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list

RUN apt-get update

RUN apt-get install -y --no-install-recommends elasticsearch


## composer ##
##############

RUN wget --quiet --no-check-certificate https://getcomposer.org/installer --output-document /root/composer-setup.php

RUN php /root/composer-setup.php --install-dir=/usr/local/bin --filename=composer


## magento ##
#############

COPY ./composer-auth.json /root/.composer/auth.json

RUN chown root:root /root/.composer/auth.json ; \
    chmod 664 /root/.composer/auth.json

RUN apt-get install -y --no-install-recommends cron


## debug ##
###########

RUN apt-get install -y --no-install-recommends lynx emacs-nox


## entry point ##
#################

COPY ./entrypoint.sh /docker-image

RUN chown root:root /docker-image/entrypoint.sh ; \
    chmod 774 /docker-image/entrypoint.sh

CMD [ "/docker-image/entrypoint.sh" ]
