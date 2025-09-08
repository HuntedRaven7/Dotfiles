


#!/usr/bin/env bash
time1="9/03/2025 10:30AM"
let current=$(date +%s)
timestamp1=$(date -d "$time1" +%s)
time_progression=$((current - timestamp1))
days_done=$((time_progression/ 86400))

echo $days_done

