#!/bin/bash
sudo yum update
mkdir -p /var/www/html
sudo yum install nfs-common -y
#Mounting Efs
mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_dns_name}:/  /var/www/html
#Making Mount Permanent
echo ${efs_dns_name}:/ /var/www/html nfs4 defaults,_netdev 0 0  | cat >> /etc/fstab
sudo chmod go+rw /var/www/html

x=$(echo "${rds_endpt}" | cut -d':' -f1)
mysql -u drupaladmin -predhat22 -h "$x" -e "CREATE DATABASE drupal1; CREATE USER 'drupal1'@'%' IDENTIFIED BY 'drupalpass'; GRANT ALL PRIVILEGES ON drupal1.* TO 'drupal1'@'%'; FLUSH PRIVILEGES;"
sed -i '172s/.*/        AllowOverride All/' /etc/nginx/nginx.conf
sudo systemctl restart nginx
sudo wget https://www.drupal.org/download-latest/tar.gz -O drupal.tar.gz
tar -xvf drupal.tar.gz
mv drupal-* /var/www/html/drupal
chown -R www-data:www-data /var/www/html/drupal/
chmod -R 755 /var/www/html/drupal/
sudo systemctl restart nginx
echo $? >> /home/ec2-user/testing.txt