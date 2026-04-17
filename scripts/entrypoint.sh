#!/bin/bash
set -e

echo "[entrypoint] Starting SSH daemon..."
/usr/sbin/sshd

echo "[entrypoint] Sandbox ready — Guacamole connects to port 22"
echo "[entrypoint] Users: intern1 / intern2 / intern3"

# Tail audit log so docker logs shows live activity
tail -F /var/log/audit/sessions.log 2>/dev/null || sleep infinity