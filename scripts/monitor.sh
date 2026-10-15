#!/usr/bin/env bash
set -uo pipefail

if [[ $# -ne 1 || ! $1 =~ ^[a-zA-Z0-9_@.:-]+$ || $1 == -* ]]; then
    echo "Usage: $0 <service>" >&2
    exit 2
fi
service=$1
syslog=${SYSLOG_PATH:-/var/log/syslog}
result=0

for command in systemctl journalctl grep awk date; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Missing command: $command" >&2
        exit 2
    fi
done

status=$(systemctl is-active "$service" 2>/dev/null) || true
printf 'Service %s: %s\n' "$service" "${status:-unknown}"
if [[ $status != active ]]; then
    result=1
    echo 'Last 10 journal lines:'
    if ! journalctl -u "$service" -n 10 --no-pager; then
        echo 'Unable to read service journal.' >&2
        result=2
    fi
fi

if [[ ! -r $syslog ]]; then
    echo "Cannot read $syslog; run with sudo or check rsyslog." >&2
    exit 2
fi

# First select error lines, then compare parsed timestamps with the last hour.
# Traditional syslog timestamps use the VM's local timezone and omit the year.
now=$(date +%s)
year=$(date +%Y)
errors=$(grep -Ei '(^|[^[:alnum:]_])(error|err|failed|failure|fatal|critical)([^[:alnum:]_]|$)' "$syslog" |
    awk -v now="$now" -v year="$year" '
    BEGIN {
        split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec", names, " ")
        for (i=1; i<=12; i++) months[names[i]]=i
        count=0
    }
    {
        stamp=0
        if ($1 ~ /^[0-9][0-9][0-9][0-9]-/) {
            # Ubuntu rsyslog ISO format includes local time and an offset.
            stamp=mktime(substr($1,1,4) " " substr($1,6,2) " " substr($1,9,2) " " substr($1,12,2) " " substr($1,15,2) " " substr($1,18,2), 1)
            if (match($1, /[+-][0-9][0-9]:[0-9][0-9]$/)) {
                offset=substr($1, RSTART)
                seconds=(substr(offset,2,2)*60 + substr(offset,5,2))*60
                stamp += (substr(offset,1,1)=="+" ? -seconds : seconds)
            } else if ($1 !~ /Z$/) {
                # Timestamp without an offset is interpreted as local time.
                stamp=mktime(substr($1,1,4) " " substr($1,6,2) " " substr($1,9,2) " " substr($1,12,2) " " substr($1,15,2) " " substr($1,18,2))
            }
        } else if ($1 in months) {
            split($3, clock, ":")
            stamp=mktime(year " " months[$1] " " $2 " " clock[1] " " clock[2] " " clock[3])
            if (stamp > now + 86400)
                stamp=mktime((year-1) " " months[$1] " " $2 " " clock[1] " " clock[2] " " clock[3])
        }
        if (stamp >= now-3600 && stamp <= now) count++
    }
    END { print count }
    ')
pipeline_status=$?
# grep returns 1 for no matches. With pipefail that is a valid zero-error case.
if (( pipeline_status > 1 )); then
    echo 'Failed to read or parse syslog.' >&2
    exit 2
fi
printf 'Errors in %s during the last hour: %s\n' "$syslog" "$errors"
exit "$result"
