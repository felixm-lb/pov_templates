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
LIGHTOS_JWT=`cat system_jwt | sed -n -e 's/^.*LIGHTOS_JWT=//p'`

# Get hosts
HOSTS=`aws s3api list-objects --bucket ${bucket_name} --query "Contents[?contains(Key, 'hosts')]" | jq .[0].Key | tr -d '"'`
aws s3api get-object --bucket ${bucket_name} --key $${HOSTS} hosts
HOSTS_ARRAY=(`cat hosts | sed -e '1,/etcd\]/d'`)

# Create volume
CREATE_VOL_RESPONSE=`curl -X POST -k -H "Content-Type: application/json" -H "Authorization: Bearer $${LIGHTOS_JWT}" https://$${HOSTS_ARRAY[0]}/api/v2/volumes -d '{"name": "demo_vol", "size": "1GiB", "acl": {"values":["demo_acl"]}, "replicaCount": 3, "projectName": "default"}'`
VOL_UUID=`echo $${CREATE_VOL_RESPONSE} | jq .UUID | tr -d '"'`

# Convert hostname to ip
FIRST_HOST=`dig +short $${HOSTS_ARRAY[0]}`

# Connect to cluster
sudo nvme connect-all -t tcp -a $${FIRST_HOST} -q demo_acl

##### FIO STUFF
#Find how many CPUs
CPU_COUNT=`sudo nproc`

# Generate FIO scripts
sudo mkdir /home/ubuntu/fio_scripts

# Precondition
sudo tee -a /home/ubuntu/fio_scripts/fio_precondition > /dev/null << EOL
#!/bin/bash

echo "Running FIO - precondition!"
sudo fio --filename=/dev/disk/by-id/nvme-uuid.$${VOL_UUID} --name=test --ioengine=libaio --rw=randrw --bs=64k --direct=1 --rwmixread=0 --numjobs=1 --iodepth=32 --group_reporting
EOL

# 4k Writes
sudo tee -a /home/ubuntu/fio_scripts/fio_4k_writes_qd1_jobs1 > /dev/null << EOL
#!/bin/bash

echo "Running FIO - 4k 100% writes, qd1, jobs1 for 120 seconds!"
sudo fio --filename=/dev/disk/by-id/nvme-uuid.$${VOL_UUID} --runtime=120 --time_based --name=test --ioengine=libaio --rw=randrw --bs=4k --direct=1 --rwmixread=0 --numjobs=1 --iodepth=1 --group_reporting
EOL

# 4k Reads
sudo tee -a /home/ubuntu/fio_scripts/fio_4k_reads_qd1_jobs1 > /dev/null << EOL
#!/bin/bash

echo "Running FIO - 4k 100% read, qd1, jobs1 for 120 seconds!"
sudo fio --filename=/dev/disk/by-id/nvme-uuid.$${VOL_UUID} --runtime=120 --time_based --name=test --ioengine=libaio --rw=randrw --bs=4k --direct=1 --rwmixread=100 --numjobs=1 --iodepth=1 --group_reporting
EOL

# 8k Writes
sudo tee -a /home/ubuntu/fio_scripts/fio_8k_writes_qd1_jobs1 > /dev/null << EOL
#!/bin/bash

echo "Running FIO - 8k 100% writes, qd1, jobs1 for 120 seconds!"
sudo fio --filename=/dev/disk/by-id/nvme-uuid.$${VOL_UUID} --runtime=120 --time_based --name=test --ioengine=libaio --rw=randrw --bs=8k --direct=1 --rwmixread=0 --numjobs=1 --iodepth=1 --group_reporting
EOL

# 8k Reads
sudo tee -a /home/ubuntu/fio_scripts/fio_8k_reads_qd1_jobs1 > /dev/null << EOL
#!/bin/bash

echo "Running FIO - 8k 100% read, qd1, jobs1 for 120 seconds!"
sudo fio --filename=/dev/disk/by-id/nvme-uuid.$${VOL_UUID} --runtime=120 --time_based --name=test --ioengine=libaio --rw=randrw --bs=8k --direct=1 --rwmixread=100 --numjobs=1 --iodepth=1 --group_reporting
EOL

# 64k Writes
sudo tee -a /home/ubuntu/fio_scripts/fio_64k_writes_qd1_jobs1 > /dev/null << EOL
#!/bin/bash

echo "Running FIO - 64k 100% writes, qd1, jobs1 for 120 seconds!"
sudo fio --filename=/dev/disk/by-id/nvme-uuid.$${VOL_UUID} --runtime=120 --time_based --name=test --ioengine=libaio --rw=randrw --bs=64k --direct=1 --rwmixread=0 --numjobs=1 --iodepth=1 --group_reporting
EOL

# 64k Reads
sudo tee -a /home/ubuntu/fio_scripts/fio_64k_reads_qd1_jobs1 > /dev/null << EOL
#!/bin/bash

echo "Running FIO - 64k 100% read, qd1, jobs1 for 120 seconds!"
sudo fio --filename=/dev/disk/by-id/nvme-uuid.$${VOL_UUID} --runtime=120 --time_based --name=test --ioengine=libaio --rw=randrw --bs=64k --direct=1 --rwmixread=100 --numjobs=1 --iodepth=1 --group_reporting
EOL

# 4k Writes - Perf
sudo tee -a /home/ubuntu/fio_scripts/fio_4k_writes_qd1_jobs$${CPU_COUNT} > /dev/null << EOL
#!/bin/bash

echo "Running FIO - 4k 100% writes, qd1, jobs$${CPU_COUNT} for 120 seconds!"
sudo fio --filename=/dev/disk/by-id/nvme-uuid.$${VOL_UUID} --runtime=120 --time_based --name=test --ioengine=libaio --rw=randrw --bs=4k --direct=1 --rwmixread=0 --numjobs=$${CPU_COUNT} --iodepth=1 --group_reporting
EOL

# 4k Reads - Perf
sudo tee -a /home/ubuntu/fio_scripts/fio_4k_reads_qd1_jobs$${CPU_COUNT} > /dev/null << EOL
#!/bin/bash

echo "Running FIO - 4k 100% read, qd1, jobs$${CPU_COUNT} for 120 seconds!"
sudo fio --filename=/dev/disk/by-id/nvme-uuid.$${VOL_UUID} --runtime=120 --time_based --name=test --ioengine=libaio --rw=randrw --bs=4k --direct=1 --rwmixread=100 --numjobs=$${CPU_COUNT} --iodepth=1 --group_reporting
EOL

# 8k Writes - Perf
sudo tee -a /home/ubuntu/fio_scripts/fio_8k_writes_qd1_jobs$${CPU_COUNT} > /dev/null << EOL
#!/bin/bash

echo "Running FIO - 8k 100% writes, qd1, jobs$${CPU_COUNT} for 120 seconds!"
sudo fio --filename=/dev/disk/by-id/nvme-uuid.$${VOL_UUID} --runtime=120 --time_based --name=test --ioengine=libaio --rw=randrw --bs=8k --direct=1 --rwmixread=0 --numjobs=$${CPU_COUNT} --iodepth=1 --group_reporting
EOL

# 8k Reads - Perf
sudo tee -a /home/ubuntu/fio_scripts/fio_8k_reads_qd1_jobs$${CPU_COUNT} > /dev/null << EOL
#!/bin/bash

echo "Running FIO - 8k 100% read, qd1, jobs$${CPU_COUNT} for 120 seconds!"
sudo fio --filename=/dev/disk/by-id/nvme-uuid.$${VOL_UUID} --runtime=120 --time_based --name=test --ioengine=libaio --rw=randrw --bs=8k --direct=1 --rwmixread=100 --numjobs=$${CPU_COUNT} --iodepth=1 --group_reporting
EOL

# 64k Writes - Perf
sudo tee -a /home/ubuntu/fio_scripts/fio_64k_writes_qd1_jobs$${CPU_COUNT} > /dev/null << EOL
#!/bin/bash

echo "Running FIO - 64k 100% writes, qd1, jobs$${CPU_COUNT} for 120 seconds!"
sudo fio --filename=/dev/disk/by-id/nvme-uuid.$${VOL_UUID} --runtime=120 --time_based --name=test --ioengine=libaio --rw=randrw --bs=64k --direct=1 --rwmixread=0 --numjobs=$${CPU_COUNT} --iodepth=1 --group_reporting
EOL

# 64k Reads - Perf
sudo tee -a /home/ubuntu/fio_scripts/fio_64k_reads_qd1_jobs$${CPU_COUNT} > /dev/null << EOL
#!/bin/bash

echo "Running FIO - 64k 100% read, qd1, jobs$${CPU_COUNT} for 120 seconds!"
sudo fio --filename=/dev/disk/by-id/nvme-uuid.$${VOL_UUID} --runtime=120 --time_based --name=test --ioengine=libaio --rw=randrw --bs=64k --direct=1 --rwmixread=100 --numjobs=$${CPU_COUNT} --iodepth=1 --group_reporting
EOL