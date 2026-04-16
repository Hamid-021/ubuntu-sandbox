#!/bin/bash
# entrypoint.sh — Container startup
# Starts SSH (bound to 127.0.0.1 only) then shellinabox on 0.0.0.0:8080

set -e

echo "[entrypoint] Starting SSH daemon (localhost only)..."
/usr/sbin/sshd

echo "[entrypoint] Starting shellinabox on port 8080..."
# --disable-ssl     → plain HTTP (handle TLS at your reverse proxy / load balancer)
# --localhost-only  → Removed: we want the container port 8080 reachable from outside
# --service         → /login means shellinabox shows a login prompt at /
# The user's shell is replaced by session-wrapper.sh via ForceCommand in sshd_config
shellinaboxd \
    --no-beep \
    --disable-ssl \
    --port=8080 \
    --service=/:LOGIN \
    --static-file=styles.css:/dev/null \
    --background

echo "[entrypoint] Sandbox ready. Web terminal at http://0.0.0.0:8080"

# Keep container alive and tail the audit log so `docker logs` is useful
tail -F /var/log/audit/sessions.log 2>/dev/null || sleep infinity