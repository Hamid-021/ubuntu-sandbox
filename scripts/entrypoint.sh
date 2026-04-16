#!/bin/bash
set -e

echo "[entrypoint] Starting SSH daemon..."
/usr/sbin/sshd

echo "[entrypoint] Starting shellinabox on port 8080..."
shellinaboxd \
    --no-beep \
    --disable-ssl \
    --port=8080 \
    --service=/:"SSH:localhost:22" \
    --ssh-args="-o RhostsRSAAuthentication=no -o RSAAuthentication=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null" \
    --background

echo "[entrypoint] Sandbox ready. Web terminal at http://0.0.0.0:8080"

tail -F /var/log/audit/sessions.log 2>/dev/null || sleep infinity