#!/bin/bash

VAR_LOCATION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
VAR_INSTANCEID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
VAR_DNS=$(curl 169.254.169.254/latest/meta-data/network/interfaces/macs/`curl 169.254.169.254/latest/meta-data/mac/`/vpc-ipv4-cidr-block/ | awk -F. '{ print $1"."$2"."$3".2" }')
/bin/sed -i '/supersede domain-name-servers/d' /etc/dhcp/dhclient.conf
echo "supersede domain-name-servers $VAR_DNS;" >> /etc/dhcp/dhclient.conf

service networking restart

a=$VAR_LOCATION

b=$${a/-/}
b=$${b:2:1}
b=$${a/-*-/$b}

id=$${VAR_INSTANCEID:$${#VAR_INSTANCEID}-6}

VAR_HOSTNAME="${system-name}-$b-inbound-proxy-certbot-$id"

# Update hosts file and add hostname
/bin/sed -i -e "s#.*127.0.0.1 localhost.*#127.0.0.1 localhost $VAR_HOSTNAME#g" /etc/hosts

# Update hostname file
echo $VAR_HOSTNAME > /etc/hostname

# Update hostname without restart
hostname $VAR_HOSTNAME

# download all certs
aws s3 cp s3://${cert-bucket}/ /etc/letsencrypt/live/ --recursive --region ${region}

# create cron to check for new certs/domains
aws s3 cp s3://${config-bucket}/scripts/certbot-check.sh /etc/cron.weekly/certbot-check.sh --region ${region}
chmod +x /etc/cron.weekly/certbot-check.sh

service nginx start

sleep 30s

# maybe add error checking on this to retry
/bin/bash /etc/cron.weekly/certbot-check.sh

# tell the proxy that the certs are ready
echo "<h1>ready</h1>" > /var/www/html/ready.html
