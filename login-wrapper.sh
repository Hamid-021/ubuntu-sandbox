#!/bin/bash

# Login wrapper - handles registration on first login and audit logging

AUDIT_LOG="/var/log/audit/sessions.log"
USERNAME=$USER
LOGIN_TIME=$(date '+%Y-%m-%d %H:%M:%S')

# Function to log logout
logout_handler() {
    LOGOUT_TIME=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$LOGOUT_TIME] LOGOUT: User '$USERNAME' logged out" >> $AUDIT_LOG
}

# Set trap for logout
trap logout_handler EXIT

# Check if user already exists
if ! id "$USERNAME" &>/dev/null; then
    clear
    echo "======================================"
    echo "  UBUNTU SANDBOX - USER REGISTRATION"
    echo "======================================"
    echo ""
    echo "Welcome! Create your account."
    echo ""
    
    # Confirm username
    read -p "Confirm username: " confirm_user
    if [ "$confirm_user" != "$USERNAME" ]; then
        echo "❌ Username mismatch."
        exit 1
    fi
    
    # Set password
    while true; do
        read -sp "Set password: " password
        echo ""
        read -sp "Confirm password: " password_confirm
        echo ""
        
        if [ "$password" = "$password_confirm" ]; then
            break
        else
            echo "❌ Passwords don't match. Try again."
        fi
    done
    
    # Create user
    useradd -m -s /bin/bash "$USERNAME" 2>/dev/null
    echo "$USERNAME:$password" | chpasswd
    
    echo ""
    echo "✓ Account created successfully!"
    echo ""
    
    # Log registration
    echo "[$LOGIN_TIME] REGISTER: User '$USERNAME' created" >> $AUDIT_LOG
fi

# Log login
echo "[$LOGIN_TIME] LOGIN: User '$USERNAME' logged in" >> $AUDIT_LOG

# Start bash shell
bash
