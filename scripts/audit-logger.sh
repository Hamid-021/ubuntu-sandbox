#!/bin/bash
LOG="/var/log/audit/sessions.log"
SESSION_DIR="/var/log/audit/sessions"
mkdir -p "$SESSION_DIR"

TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
USER="${PAM_USER:-unknown}"
RHOST="${PAM_RHOST:-localhost}"

if [ "$PAM_TYPE" = "open_session" ]; then
    # Generate a unique session ID and store it for this user's PID group
    SESSION_ID="$(uuidgen | tr -d '-' | head -c 12 | tr '[:lower:]' '[:upper:]')"
    echo "$SESSION_ID" > "$SESSION_DIR/${USER}_$$.sid"

    echo "[$TIMESTAMP] [SESSION:$SESSION_ID] LOGIN  user=$USER from=$RHOST" >> "$LOG"

elif [ "$PAM_TYPE" = "close_session" ]; then
    # Retrieve the session ID if it was stored
    SID_FILE="$SESSION_DIR/${USER}_$$.sid"
    if [ -f "$SID_FILE" ]; then
        SESSION_ID="$(cat $SID_FILE)"
        rm -f "$SID_FILE"
    else
        SESSION_ID="UNKNOWN"
    fi

    echo "[$TIMESTAMP] [SESSION:$SESSION_ID] LOGOUT user=$USER from=$RHOST" >> "$LOG"
fi