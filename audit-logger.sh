#!/bin/bash

LOG="/var/log/audit/sessions.log"

if [ "$PAM_SERVICE" = "sshd" ]; then
    if [ "$PAM_TYPE" = "open_session" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] LOGIN: $PAM_USER" >> $LOG
    elif [ "$PAM_TYPE" = "close_session" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] LOGOUT: $PAM_USER" >> $LOG
    fi
fi
