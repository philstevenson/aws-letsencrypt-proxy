#!/bin/bash

if [ "$(whoami)" != "root" ]
then
	sudo su -s "$0"
	exit
fi

service nginx stop

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

VAR_HOSTNAME="${system-name}-$b-inbound-proxy-$id"

# Update hosts file and add hostname
/bin/sed -i -e "s#.*127.0.0.1 localhost.*#127.0.0.1 localhost $VAR_HOSTNAME#g" /etc/hosts

# Update hostname file
echo $VAR_HOSTNAME > /etc/hostname

# Update hostname without restart
hostname $VAR_HOSTNAME

# Download proxy.pac to various locations
# Live PAC Script
aws s3 cp s3://${config-bucket}/config/nginx.conf /etc/nginx/nginx.conf --region ${region}

rm /etc/nginx/sites-enabled/default
aws s3 cp s3://${config-bucket}/config/nginx-acme-challenge /etc/nginx/sites-enabled/nginx-acme-challenge --region ${region}

# create health_check file to enable ELB
mkdir /var/www/html/healthcheck/
cat<<EOF > /var/www/html/healthcheck/index.html
<h1>this is a health check, removing this is bad</h1>
EOF

service nginx start

while [ $(curl --write-out %{http_code} --silent --output /dev/null ${certbot-server}/ready.html) != 200 ]
do
sleep 5s
done

aws s3 cp s3://${cert-bucket}/ /etc/ssl/ --recursive --region ${region}
aws s3 cp s3://${config-bucket}/config/vhosts/ /etc/nginx/sites-enabled/ --recursive --region ${region}

# create cron to check for new certs/domains
aws s3 cp s3://${config-bucket}/scripts/cert-check.sh /etc/cron.daily/cert-check.sh --region ${region}
chmod +x /etc/cron.daily/cert-check.sh

# could add in an error checker and loop until config reloads correctly
service nginx reload
