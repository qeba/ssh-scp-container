#!/bin/bash

# Get command line arguments from environment variables
USERNAME=${USERNAME:-"foo"}
PASSWORD=${PASSWORD:-"pass"}
UID_NUM=${UID_NUM:-"1001"}

echo "Creating user: $USERNAME with UID: $UID_NUM"

# Delete user if exists
deluser "${USERNAME}" 2>/dev/null || true

# Create user and set password
adduser -D -u "${UID_NUM}" "${USERNAME}"
echo "${USERNAME}:${PASSWORD}" | chpasswd

# Add user to wheel group
addgroup "${USERNAME}" wheel

# Create and set permissions for SSH directory
mkdir -p "/home/${USERNAME}/.ssh"
chmod 700 "/home/${USERNAME}/.ssh"

# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f "/home/${USERNAME}/.ssh/id_rsa" -N ""
cp "/home/${USERNAME}/.ssh/id_rsa.pub" "/home/${USERNAME}/.ssh/authorized_keys"
chmod 600 "/home/${USERNAME}/.ssh/authorized_keys"

# Create upload directory
mkdir -p "/home/${USERNAME}/upload"

# Set proper ownership
chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}"

# Verify user creation
echo "Verifying user creation:"
id "${USERNAME}"
grep "${USERNAME}" /etc/passwd
#echo "User home directory contents:"
#ls -la "/home/${USERNAME}"

# Generate host keys
ssh-keygen -A

# Enable password authentication explicitly
sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config

echo "Starting SSH daemon..."
exec /usr/sbin/sshd -D -e
