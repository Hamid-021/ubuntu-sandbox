#!/bin/bash

read -p "Username: " user
if id "$user" &>/dev/null; then
    echo "Exists"
    exit
fi

read -sp "Password: " pass
echo ""
useradd -m -s /bin/bash "$user"
echo "$user:$pass" | chpasswd
echo "Done"

