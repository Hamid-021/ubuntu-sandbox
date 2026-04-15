#!/bin/bash

# Emergency user creation (optional utility)

read -p "Username: " username
if id "$username" &>/dev/null; then
    echo "User exists"
    exit 1
fi

read -sp "Password: " password
echo ""

useradd -m -s /bin/bash "$username"
echo "$username:$password" | chpasswd
echo "✓ User '$username' created"

