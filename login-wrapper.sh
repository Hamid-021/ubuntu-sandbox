#!/bin/bash

USERNAME=$USER
AUDIT_LOG="/var/log/audit/sessions.log"

trap "echo \"[$(date '+%Y-%m-%d %H:%M:%S')] LOGOUT: $USERNAME\" >> $AUDIT_LOG" EXIT

if ! id "$USERNAME" &>/dev/null; then
    clear
    echo "===== REGISTRATION ====="
    echo ""
    read -p "Confirm username: " confirm_user
    
    if [ "$confirm_user" != "$USERNAME" ]; then
        echo "Mismatch"
        exit 1
    fi
    
    while true; do
        read -sp "Password: " pw1
        echo ""
        read -sp "Confirm: " pw2
        echo ""
        if [ "$pw1" = "$pw2" ]; then
            break
        fi
        echo "No match"
    done
    
    useradd -m -s /bin/bash "$USERNAME"
    echo "$USERNAME:$pw1" | chpasswd
    
    echo "Created!"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] REGISTER: $USERNAME" >> $AUDIT_LOG
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] LOGIN: $USERNAME" >> $AUDIT_LOG
bash
