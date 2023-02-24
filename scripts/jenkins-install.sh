#!/bin/bash -x
exec > >(tee /var/log/userdata.log) 2>&1

# volume setup
# The sudo vgchange -ay command will activate all inactive volume groups on a Linux system.
sudo vgchange -ay

# Set disk device name
DEVICE_NAME=${DEVICE}
DIR="/var/lib/jenkins"
USERNAME="ubuntu"
DEVICE_FS=`blkid -o value -s TYPE ${DEVICE}`

if [ "`echo -n $DEVICE_FS`" == "" ] ; then 
  # wait for the device to be attached
  sleep 30
fi

# Create physical volume
sudo pvcreate $DEVICE_NAME
echo "Physical volume created"

# Create volume group
sudo vgcreate data $DEVICE_NAME
echo "Volume group created"

# Create logical volume
sudo lvcreate -n volume1 -L 10G data
echo "Logical volume created"


# Check if disk is already mounted
if grep -qs "$DEVICE_NAME" /proc/mounts; then
   echo "Disk is already mounted"
   exit 1

else
   # Mount disk
   sudo mkfs.ext4 /dev/data/volume1
   sudo mkdir  -p $DIR
   sudo mount /dev/data/volume1 $DIR
   echo '/dev/data/volume1 /var/lib/jenkins ext4 defaults 0 0' >> /etc/fstab
fi

# install dependencies
sudo apt-get -y update
apt-get install -y openjdk-11-jdk awscli

curl -fsSL ${JENKINS_URL}/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  ${JENKINS_URL} binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get -y update
sudo apt-get -y install jenkins


# Add ubuntu to sudoers file

# Check if the script is being run as root
if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Check if the user exists
if ! id $USERNAME > /dev/null 2>&1; then
    echo "User $USERNAME does not exist"
    exit 1
else
   # Add the user to the sudo group
   usermod -aG sudo $USERNAME
   # Add the user to the sudoers file
   echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# AWS Secrets Manager information
AWS_REGION=${AWS_REGION}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

# echo Jenkin password to aws secrets mamanger
JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

# Store the password as a secret in AWS Secrets Manager
aws secretsmanager create-secret --name "jenkins-admin-password" --secret-string "$JENKINS_PASSWORD" --description "Jenkins secrets to login UI." --region $AWS_REGION