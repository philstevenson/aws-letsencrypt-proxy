#!/bin/bash

region='${region}'
bucket='${cert-bucket}'

### pull all current certs on boot
aws s3 sync /etc/letsencrypt/live/ s3://$bucket/ --region $region
service nginx reload
