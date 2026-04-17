#!/bin/bash
set -e

echo "[entrypoint] Starting SSH daemon..."
/usr/sbin/sshd

echo "[entrypoint] Starting shellinabox on port 8080..."
# NOTE: --ssh-args does NOT exist in shellinabox 2.21 (Ubuntu 22.04).
# SSH client options are set via /etc/ssh/ssh_config in the Dockerfile instead.
shellinaboxd \
    --no-beep \
    --disable-ssl \
    --port=8080 \
    --service=/:"SSH:localhost:22" \
    --background

echo "[entrypoint] Sandbox ready at http://0.0.0.0:8080"

tail -F /var/log/audit/sessions.log 2>/dev/null || sleep infinity