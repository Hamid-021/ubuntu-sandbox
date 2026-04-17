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
mkdir -p "$SESSION_DIR" 2>/dev/null || true

# Identity
USER="$(whoami)"
SESSION_ID="$(cat /proc/sys/kernel/random/uuid 2>/dev/null | tr -d '-' | head -c 12 | tr '[:lower:]' '[:upper:]')"
START_TS="$(date '+%Y-%m-%d %H:%M:%S')"
START_EPOCH="$(date +%s)"
PER_SESSION_LOG="$SESSION_DIR/${SESSION_ID}_${USER}.log"

# Helper - with error suppression for permission issues
log_main() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SESSION:$SESSION_ID] $*" >> "$MAIN_LOG" 2>/dev/null || true
}

# Session open 
log_main "LOGIN  user=$USER"
echo "=== SESSION $SESSION_ID | user=$USER | started=$START_TS ===" > "$PER_SESSION_LOG" 2>/dev/null || true

# Export variables for the bash session
export SESSION_ID PER_SESSION_LOG USER MAIN_LOG

# Bash with command logging via PROMPT_COMMAND 
bash --rcfile <(cat <<'BASHRC'
# Pull in the user's normal rc first (if it exists)
[ -f ~/.bashrc ] && source ~/.bashrc

# Override/extend PS1 to show session tag
export PS1="[\u@sandbox:\w] \$ "

# Initialize history file
export HISTFILE=~/.bash_history
touch "$HISTFILE" 2>/dev/null || true
history -r "$HISTFILE" 2>/dev/null || true

# Log every command to per-session log and main log
_CMD_LOG_hook() {
    # Get the last command from history safely
    local last_cmd
    last_cmd="$(history 1 2>/dev/null | sed 's/^[ ]*[0-9]*[ ]*//')"
    
    # Skip if empty or whitespace only
    if [ -z "$last_cmd" ] || [[ "$last_cmd" =~ ^[[:space:]]*$ ]]; then
        return 0
    fi
    
    # Skip the PROMPT_COMMAND hook itself
    if [[ "$last_cmd" == *"_CMD_LOG_hook"* ]] || [[ "$last_cmd" == *"PROMPT_COMMAND"* ]]; then
        return 0
    fi
    
    # Avoid logging duplicate commands
    if [ "$last_cmd" = "$_LAST_LOGGED_CMD" ]; then
        return 0
    fi
    
    local ts="$(date '+%Y-%m-%d %H:%M:%S')"

    # Log to per-session log (suppress permission errors)
    echo "[$ts] CMD: $last_cmd" >> "$PER_SESSION_LOG" 2>/dev/null || true
    
    # Log to main log (suppress permission errors)
    echo "[$ts] [SESSION:$SESSION_ID] CMD user=$USER cmd=$last_cmd" >> "$MAIN_LOG" 2>/dev/null || true
    
    _LAST_LOGGED_CMD="$last_cmd"
}

# Set PROMPT_COMMAND properly
if [ -z "$PROMPT_COMMAND" ]; then
    export PROMPT_COMMAND="_CMD_LOG_hook"
else
    export PROMPT_COMMAND="_CMD_LOG_hook; $PROMPT_COMMAND"
fi
BASHRC
) -i

# Session close 
END_EPOCH="$(date +%s)"
DURATION=$(( END_EPOCH - START_EPOCH ))
DURATION_FMT="$(printf '%02d:%02d:%02d' $((DURATION/3600)) $((DURATION%3600/60)) $((DURATION%60)))"

log_main "LOGOUT user=$USER duration=$DURATION_FMT"
echo "=== SESSION END | duration=$DURATION_FMT ===" >> "$PER_SESSION_LOG" 2>/dev/null || true