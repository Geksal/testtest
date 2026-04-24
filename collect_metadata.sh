#!/bin/bash

# Konfiguracja
S3_URI="s3://applicant-task/instance-101"
FILE_NAME="instance_metadata_report.txt"

# Pobieranie Tokena dla IMDSv2 (wymagane w nowszych instancjach EC2)
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Sprawdzenie czy udało się pobrać token
if [ -z "$TOKEN" ]; then
    echo "Error: Could not retrieve IMDSv2 token."
    exit 1
fi

echo "==========================================" > "$FILE_NAME"
echo "    EC2 INSTANCE METADATA REPORT" >> "$FILE_NAME"
echo "==========================================" >> "$FILE_NAME"
echo "Report Generated: $(date)" >> "$FILE_NAME"
echo "" >> "$FILE_NAME"

echo "--- AWS INSTANCE INFO ---" >> "$FILE_NAME"
INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)
# Security Groups: zamiana nowych linii na przecinki dla lepszej czytelności
SG_GROUPS=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/security-groups | tr '\n' ',' | sed 's/,$//')

echo "Instance ID:      ${INSTANCE_ID:-N/A}" >> "$FILE_NAME"
echo "Public IP:       ${PUBLIC_IP:-N/A}" >> "$FILE_NAME"
echo "Private IP:      ${PRIVATE_IP:-N/A}" >> "$FILE_NAME"
echo "Security Groups: ${SG_GROUPS:-N/A}" >> "$FILE_NAME"
echo "" >> "$FILE_NAME"

echo "--- SYSTEM INFO ---" >> "$FILE_NAME"
OS_NAME=$(grep "PRETTY_NAME" /etc/os-release | cut -d'=' -f2 | tr -d '"')
echo "Operating System: $OS_NAME" >> "$FILE_NAME"

# Użytkownicy z dostępem do shella (bash/sh)
SHELL_USERS=$(grep -E '/bin/bash|/bin/sh' /etc/passwd | cut -d: -f1 | sort | xargs | tr ' ' ',')
echo "Shell Users:      $SHELL_USERS" >> "$FILE_NAME"
echo "" >> "$FILE_NAME"
echo "==========================================" >> "$FILE_NAME"

# Wysyłka do S3
echo "Uploading $FILE_NAME to $S3_URI..."
aws s3 cp "$FILE_NAME" "$S3_URI/$FILE_NAME"

# Status wysyłki
if [ $? -eq 0 ]; then
    echo "Success: File uploaded to S3."
else
    echo "Error: Upload failed. Check AWS CLI configuration and permissions."
    exit 1
fi
