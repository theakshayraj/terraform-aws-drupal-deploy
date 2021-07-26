#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y

sudo systemctl stop nginx.service
sudo systemctl start nginx.service
sudo systemctl enable nginx.service

#sudo yum install mariadb-server mariadb-client -y
#sudo systemctl stop mariadb.service
#sudo systemctl start mariadb.service
#sudo systemctl enable mariadb.service

sudo amazon-linux-extras install -y php7.2
sudo yum install -y php-dom php-gd php-simplexml php-xml php-opcache php-mbstring php-pgsql
x=$(echo "${rds_endpt}" | cut -d':' -f1)
sudo mysql -u root -pdrupalpass "$x" -e "CREATE DATABASE drupal; CREATE USER 'drupaluser'@'localhost' IDENTIFIED BY 'drupalpass'; GRANT ALL  ON drupal.* TO 'drupaluser'@'localhost' IDENTIFIED BY 'drupalpass' WITH GRANT OPTION; FLUSH PRIVILEGES; EXIT;"

cd /tmp && wget https://ftp.drupal.org/files/projects/drupal-8.3.7.tar.gz
sudo tar -zxvf drupal*.gz -C /usr/share/nginx/html/ 
sudo mv /usr/share/nginx/html/drupal-8.3.7/ /usr/share/nginx/html/drupal/
sudo chown -R nginx:nginx /usr/share/nginx/html/
sudo chmod -R 755 /usr/share/nginx/html/

sudo echo > /etc/nginx/nginx.conf

sudo echo "user nginx;
	worker_processes auto;
	error_log /var/log/nginx/error.log;
	pid /run/nginx.pid;

	# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
	include /usr/share/nginx/modules/*.conf;

	events {
	    worker_connections 1024;
	}

	http {
	    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
	                      '$status $body_bytes_sent "$http_referer" '
	                      '"$http_user_agent" "$http_x_forwarded_for"';

	    access_log  /var/log/nginx/access.log  main;

	    sendfile            on;
	    tcp_nopush          on;
	    tcp_nodelay         on;
	    keepalive_timeout   65;
	    types_hash_max_size 4096;

	    include             /etc/nginx/mime.types;
	    default_type        application/octet-stream;

	    # Load modular configuration files from the /etc/nginx/conf.d directory.
	    # See http://nginx.org/en/docs/ngx_core_module.html#include
	    # for more information.
	    include /etc/nginx/conf.d/*.conf;

	    server {
	        listen       80;
	        listen       [::]:80;
	        server_name  _;
	        root         /usr/share/nginx/html/drupal;

	        # Load configuration files for the default server block.
	        include /etc/nginx/default.d/*.conf;

	        error_page 404 /404.html;
	        location = /404.html {
	        }

	        error_page 500 502 503 504 /50x.html;
	        location = /50x.html {
	        }
	    }
	}" >> /etc/nginx/nginx.conf

sudo systemctl restart nginx