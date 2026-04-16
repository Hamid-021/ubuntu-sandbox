#!/bin/bash
# view-logs.sh — Helper to inspect audit logs from your host machine
# Usage: ./view-logs.sh <container-id-or-name> [session-id]
 
CONTAINER="${1:?Usage: ./view-logs.sh <container> [SESSION_ID]}"
SESSION_ID="$2"
 
if [ -n "$SESSION_ID" ]; then
    echo "=== Per-session log for $SESSION_ID ==="
    docker exec "$CONTAINER" bash -c "cat /var/log/audit/sessions/${SESSION_ID}_*.log 2>/dev/null || echo 'Session not found'"
else
    echo "=== Main audit log (all users) ==="
    docker exec "$CONTAINER" cat /var/log/audit/sessions.log
 
    echo ""
    echo "=== Available per-session logs ==="
    docker exec "$CONTAINER" ls /var/log/audit/sessions/ 2>/dev/null || echo "(none yet)"
fi