#!/bin/bash
# session-wrapper.sh — Wraps bash to capture every command typed in the terminal.
# Set as the ForceCommand in sshd_config (or called by shellinabox login).
#
# What it does:
#   1. Generates a unique SESSION_ID for this terminal session
#   2. Logs LOGIN with timestamp, user, source IP
#   3. Runs bash with PROMPT_COMMAND set so every command is appended to the audit log
#   4. Logs LOGOUT with duration when the shell exits

LOG_DIR="/var/log/audit"
SESSION_DIR="$LOG_DIR/sessions"
MAIN_LOG="$LOG_DIR/sessions.log"
mkdir -p "$SESSION_DIR"

# Identity
USER="$(whoami)"
SESSION_ID="$(cat /proc/sys/kernel/random/uuid 2>/dev/null | tr -d '-' | head -c 12 | tr '[:lower:]' '[:upper:]')"
START_TS="$(date '+%Y-%m-%d %H:%M:%S')"
START_EPOCH="$(date +%s)"
PER_SESSION_LOG="$SESSION_DIR/${SESSION_ID}_${USER}.log"

# Helper
log_main() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SESSION:$SESSION_ID] $*" >> "$MAIN_LOG"
}

# Session open 
log_main "LOGIN  user=$USER"
echo "=== SESSION $SESSION_ID | user=$USER | started=$START_TS ===" > "$PER_SESSION_LOG"

# Bash with command logging via PROMPT_COMMAND 
export SESSION_ID PER_SESSION_LOG USER

bash --rcfile <(cat <<'BASHRC'
# Pull in the user's normal rc first (if it exists)
[ -f ~/.bashrc ] && source ~/.bashrc

# Override/extend PS1 to show session tag
export PS1="[\u@sandbox:\w] \$ "

# Log every command to per-session log and main log
_CMD_LOG_hook() {
    local last_cmd
    last_cmd="$(history 1 | sed 's/^[ ]*[0-9]*[ ]*//')"
    local ts="$(date '+%Y-%m-%d %H:%M:%S')"

    # Avoid logging duplicate blank lines or the hook itself
    if [ -n "$last_cmd" ] && [ "$last_cmd" != "$_LAST_LOGGED_CMD" ]; then
        echo "[$ts] CMD: $last_cmd" >> "$PER_SESSION_LOG"
        echo "[$ts] [SESSION:$SESSION_ID] CMD user=$USER cmd=$last_cmd" >> "$MAIN_LOG"
        _LAST_LOGGED_CMD="$last_cmd"
    fi
}

export PROMPT_COMMAND="_CMD_LOG_hook; $PROMPT_COMMAND"
BASHRC
) -i

# Session close 
END_EPOCH="$(date +%s)"
DURATION=$(( END_EPOCH - START_EPOCH ))
DURATION_FMT="$(printf '%02d:%02d:%02d' $((DURATION/3600)) $((DURATION%3600/60)) $((DURATION%60)))"

log_main "LOGOUT user=$USER duration=$DURATION_FMT"
echo "=== SESSION END | duration=$DURATION_FMT ===" >> "$PER_SESSION_LOG"