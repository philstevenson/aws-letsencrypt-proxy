#!/bin/bash

domains=('${frontend-domains}')
email='${email}'
region='${region}'
bucket='${cert-bucket}'

### pull all current certs on boot
aws s3 sync /etc/letsencrypt/live/ s3://$bucket/ --region $region

# get/renew certificates for each domain
for domain in "$${domains[@]}"
do
  letsencrypt certonly --agree-tos --keep-until-expiring -n --webroot -w /var/www/html/ -d $domain -m $email
done

# upload certificates to s3
aws s3 sync /etc/letsencrypt/live/ s3://$bucket/ --region $region
