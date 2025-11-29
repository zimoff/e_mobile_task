#!/bin/bash

PROC_NAME="test"
TIME_1=""
TIME_2=""
LOG_FILE="/var/log/monitoring.log"
ADDRESS="https://test.com/monitoring/test/api"
#ADDRESS="localhost:80"

if [[ ! -e "$LOG_FILE" ]]
then
    echo "no log file or no access: $LOG_FILE"
    exit 0
fi

if [[ ! -w "$LOG_FILE" ]]
then
    echo "no rights to write log: $LOG_FILE"
    exit 0
fi

while true; do

    TIME_1="$(ps -C "$PROC_NAME" -o etimes --no-headers | head -n 1)"

    if  [[ -n "$TIME_1" ]] && [[ "$TIME_1" =~ ^[\ ]+[0-9]+$ ]] && [[ "$TIME_1" -ge 0 ]]
    then

        if [ -n "$TIME_2" ]
        then
            if [ "$TIME_1" -lt "$TIME_2" ]
            then
                echo "process: $PROC_NAME  restarted |$(date)" >> "$LOG_FILE"
                echo "process restarted"
            fi
            TIME_2="$TIME_1"
        else
            echo  "process first run"
            TIME_2="$TIME_1"
        fi

        curl -s --connect-timeout 5 "$ADDRESS" --fail || echo "request failed | $(date)" >> "$LOG_FILE"

    fi

    sleep 60s
done
