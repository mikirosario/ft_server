# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: mrosario <marvin@42.fr>                    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/01/13 20:27:37 by mrosario          #+#    #+#              #
#    Updated: 2020/01/21 19:05:45 by mrosario         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster
MAINTAINER Michael Lucas Rosario <mrosario@student.42madrid.com>

#LEMP Install Routine
RUN apt-get update
RUN apt-get -y install nginx
RUN apt-get -y install mariadb-server
RUN apt-get -y install php-fpm php-mysql
RUN apt-get -y install php-mbstring php-zip \
	php-gd php-xml php-pear php-gettext php-cgi
RUN apt-get -y install libnss3-tools

#Nginx Config
COPY srcs/default etc/nginx/sites-available/default
RUN rm /etc/nginx/sites-enabled/default && \
	ln -s /etc/nginx/sites-available/default etc/nginx/sites-enabled/

#phpMyAdmin Config
COPY srcs/phpMyAdmin-5.0.1-all-languages var/www/html/phpmyadmin
COPY srcs/config.inc.php var/www/html/phpmyadmin/config.inc.php
RUN chmod 660 var/www/html/phpmyadmin/config.inc.php && chown -R www-data:www-data /var/www/html/phpmyadmin


#Wordpress Config
COPY srcs/wordpress var/www/html/wordpress
COPY srcs/wordpressdb.sql ./
COPY srcs/wp-config.php ./var/www/html/wp-config.php
COPY srcs/wordpress.sql ./wordpress.sql

#SSL Config
COPY srcs/mkcert-v1.4.1-linux-amd64 etc/nginx/mkcert/mkcert
RUN  chmod +x /etc/nginx/mkcert/mkcert
RUN cd etc/nginx/mkcert/ && ./mkcert -install && ./mkcert localhost

#Misc Config
COPY srcs/index.html var/www/html/index.html

#Ports Config
EXPOSE 80 3306 443

ENTRYPOINT 	service nginx start && service mysql start && nginx -t && \
			service php7.3-fpm start && mysql -u root < wordpressdb.sql && \
			mysql wordpress -u root --password= < wordpress.sql && bash
