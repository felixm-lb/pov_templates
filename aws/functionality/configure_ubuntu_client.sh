#!/bin/bash

# Update and install tools
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y linux-modules-extra-aws fio unzip jq nvme-cli


# Load kernel module (and enable on boot)
sudo modprobe nvme_tcp
sudo modprobe nvme_core
sudo modprobe nvme_fabrics

echo nvme_tcp | sudo tee /etc/modules-load.d/nvme_tcp.conf
echo nvme_core | sudo tee /etc/modules-load.d/nvme_core.conf
echo nvme_fabrics | sudo tee /etc/modules-load.d/nvme_fabrics.conf

# Install AWS CLI
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install

# Get system_jwt
SYSTEM_JWT_KEY=`aws s3api list-objects --bucket ${bucket_name} --query "Contents[?contains(Key, 'system_jwt')]" | jq .[0].Key | tr -d '"'`
aws s3api get-object --bucket ${bucket_name} --key $${SYSTEM_JWT_KEY} system_jwt
sudo chmod 755 system_jwt
./system_jwt

# Get hosts
HOSTS=`aws s3api list-objects --bucket ${bucket_name} --query "Contents[?contains(Key, 'hosts')]" | jq .[0].Key | tr -d '"'`
aws s3api get-object --bucket ${bucket_name} --key $${HOSTS} hosts
HOSTS_ARRAY=(`cat hosts | sed -e '1,/etcd\]/d'`)

# Create volume
CREATE_VOL_RESPONSE=`curl -X POST -k -H "Content-Type: application/json" -H "Authorization: Bearer $$LIGHTOS_JWT" https://$${HOSTS_ARRAY[0]}/api/v2/volumes -d '{"name": "demo_vol", "size": "1GiB", "acl": {"values":["demo_acl"]}, "replicaCount": 3, "projectName": "default"}'`
VOL_UUID=`echo $${CREATE_VOL_RESPONSE} | jq .UUID | tr -d '"'`

# Convert hostname to ip
FIRST_HOST=`dig +short $${HOSTS_ARRAY[0]}`

# Connect to cluster
sudo nvme connect-all -t tcp -a $${FIRST_HOST} -q demo_acl