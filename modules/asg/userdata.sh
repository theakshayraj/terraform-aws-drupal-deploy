#!/bin/bash
sudo yum update -y
sudo yum install -y jq
sudo tee /etc/yum.repos.d/mariadb.repo<<EOF
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.5/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
sudo yum makecache
sudo yum repolist 
sudo yum install -y MariaDB-server MariaDB-client
sudo systemctl start mariadb
sudo systemctl enable --now mariadb

sudo yum install -y php-dom php-gd php-simplexml php-xml php-opcache php-mbstring php-pgsql
sudo amazon-linux-extras enable php7.4

export AWS_DEFAULT_REGION=us-east-1

secret=$(aws secretsmanager get-secret-value --secret-id sql-key | jq .SecretString | jq fromjson)
sql_user=$(echo $secret | jq -r .sql-user)
sql_pass=$(echo $secret | jq -r .sql-pass)

secret2=$(aws secretsmanager get-secret-value --secret-id drupal-master-key | jq .SecretString | jq fromjson)
master_user=$(echo $secret2 | jq -r .masteruser)
master_pass=$(echo $secret2 | jq -r .masterpass)

x=$(echo "${rds_endpt}" | cut -d':' -f1)
echo $x
sudo mysql -h "$x" -P 3306 -u ${masteruser} -p${masterpass} -e "CREATE DATABASE drupal; CREATE USER '${sql_user}'@'%' IDENTIFIED BY '${sql_pass}'; GRANT ALL  ON drupal.* TO '${sql_user}'@'%' IDENTIFIED BY '${sql_pass}' WITH GRANT OPTION; FLUSH PRIVILEGES; EXIT;"

cd /tmp && wget https://www.drupal.org/download-latest/tar.gz
sudo tar -zxvf tar*.gz -C /usr/share/nginx/html/ 
cd /usr/share/nginx/html/
sudo mv drupal-9.2.2 drupal
sudo chown -R nginx:nginx /usr/share/nginx/html/
sudo chmod -R 755 /usr/share/nginx/html/

sudo rm /etc/nginx/nginx.*

echo "user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events
{
  worker_connections 1024;
}

http
{
  log_format main '$remote_addr - $remote_user [$time_local] "$request" '
  '$status $body_bytes_sent "$http_referer" '
  '"$http_user_agent" "$http_x_forwarded_for"';

  access_log /var/log/nginx/access.log main;

  sendfile on;
  tcp_nopush on;
  tcp_nodelay on;
  keepalive_timeout 65;
  types_hash_max_size 4096;

  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  # Load modular configuration files from the /etc/nginx/conf.d directory.
  # See http://nginx.org/en/docs/ngx_core_module.html#include
  # for more information.
  include /etc/nginx/conf.d/*.conf;

  server
  {
    listen 80;
    listen [::]:80;
    server_name _;
    root /usr/share/nginx/html/drupal;

    # Load configuration files for the default server block.
    include /etc/nginx/default.d/*.conf;

    location = /favicon.ico
    {
      log_not_found off;
      access_log off;
    }

    location = /robots.txt
    {
      allow all;
      log_not_found off;
      access_log off;
    }

    location ~ \..*/.*\.php$
    {
      return 403;
    }

    location ~ ^/sites/.*/private/
    {
      return 403;
    }

    location ~ (^|/)\.
    {
      return 403;
    }

    location /
    {
      # This is cool because no php is touched for static content
      try_files '$uri' @rewrite;
    }

    location @rewrite
    {
      # You have 2 options here
      # For D7 and above:
      # Clean URLs are handled in drupal_environment_initialize().
      rewrite ^ /index.php;
      # For Drupal 6 and bwlow:
      # Some modules enforce no slash (/) at the end of the URL
      #rewrite ^/(.*)$ /index.php?q='$1';
    }

    location ~ \.php$
    {
      fastcgi_split_path_info ^(.+\.php)(/.+)$;
      include fastcgi_params;
      fastcgi_param SCRIPT_FILENAME '$request_filename';
      fastcgi_intercept_errors on;
      fastcgi_pass unix:/tmp/phpfpm.sock;
    }

    location ~ ^/sites/.*/files/styles/
    {
      try_files '$uri' @rewrite;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$
    {
      expires max;
      log_not_found off;
    }
  }
}" | sudo tee /etc/nginx/nginx.conf

sudo systemctl restart nginx

secret3=$(aws secretsmanager get-secret-value --secret-id drupal-login | jq .SecretString | jq fromjson)
login_user=$(echo $secret3 | jq -r .username)
login_pass=$(echo $secret3 | jq -r .pass)

cd /usr/share/nginx/html/drupal/
sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php
sudo ./composer.phar require --dev drush/drush --no-interaction
sudo ./vendor/bin/drush site-install standard --db-url=mysql://drupaluser:drupalpass@"$x"/drupal --site-name=Example --account-name=${login_user} --account-pass=${login_pass} --yes
sudo chmod 755 sites/ themes/ profiles/ modules/ vendor/ core/
sudo chmod -R 777 sites/default/files/
sudo ./vendor/bin/drush -y config-set system.performance css.preprocess 0
sudo ./vendor/bin/drush -y config-set system.performance js.preprocess 0
sudo ./vendor/bin/drush -y theme:enable bartik
sudo ./vendor/bin/drush -y config:set system.theme default bartik

sudo yum install -y amazon-cloudwatch-agent
sudo aws s3 cp s3://grafana-files-sg/cw-config.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo mkdir -p /usr/share/collectd
sudo touch /usr/share/collectd/types.db
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo systemctl restart amazon-cloudwatch-agent

sudo yum install -y git
sudo ./composer.phar require 'drupal/prometheus_exporter:1.x-dev@dev' --no-interaction
sudo sed -i 's/false/true/g' modules/contrib/prometheus_exporter/config/install/prometheus_exporter.settings.yml
sudo ./vendor/bin/drush en prometheus_exporter -y
sudo ./vendor/bin/drush en prometheus_exporter_token_access

sudo touch /home/ec2-user/Completed.txt