#!/bin/bash

S3_URI="s3://applicant-task/instance-101"
FILE_NAME="instance_metadata_report.txt"

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

echo "==========================================" > $FILE_NAME
echo "   EC2 INSTANCE METADATA REPORT" >> $FILE_NAME
echo "==========================================" >> $FILE_NAME
echo "Report Generated: $(date)" >> $FILE_NAME
echo "" >> $FILE_NAME

echo "--- AWS INSTANCE INFO ---" >> $FILE_NAME
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)
# Security Groups mogą być wieloliniowe, zamieniamy nowe linie na spacje
SG_GROUPS=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/security-groups | tr '\n' ' ')

echo "Instance ID:     $INSTANCE_ID" >> $FILE_NAME
echo "Public IP:       $PUBLIC_IP" >> $FILE_NAME
echo "Private IP:      $PRIVATE_IP" >> $FILE_NAME
echo "Security Groups: $SG_GROUPS" >> $FILE_NAME
echo "" >> $FILE_NAME

echo "--- SYSTEM INFO ---" >> $FILE_NAME
OS_NAME=$(grep "PRETTY_NAME" /etc/os-release | cut -d'=' -f2 | tr -d '"')
echo "Operating System: $OS_NAME" >> $FILE_NAME

SHELL_USERS=$(grep -E '/bin/bash|/bin/sh' /etc/passwd | cut -d: -f1 | sort | xargs)
echo "Shell Users:      $SHELL_USERS" >> $FILE_NAME
echo "" >> $FILE_NAME
echo "==========================================" >> $FILE_
