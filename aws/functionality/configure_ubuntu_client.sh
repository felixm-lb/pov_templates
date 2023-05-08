#!/bin/bash

# Update and install tools
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y linux-modules-extra-aws nvme-cli fio unzip jq

# Install AWS CLI
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install

# Get system_jwt
SYSTEM_JWT_KEY=`aws s3api list-objects --bucket ${bucket_name} --query "Contents[?contains(Key, 'system_jwt')]" | jq .[0].Key | tr -d '"'`
aws s3api get-object --bucket ${bucket_name} --key $${SYSTEM_JWT_KEY} system_jwt
sudo chmod 755 system_jwt

# 
