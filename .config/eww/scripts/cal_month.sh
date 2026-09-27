#!/bin/bash
# Emits the current month as JSON for the calendar popup.
#
#   { "title": "September 2026",
#     "days": [ {"n":"1","cur":true,"today":false}, ... ] }
#
# Always 42 cells (6 rows of 7) so the popup never changes height between
# months. Leading and trailing cells come from the neighbouring months and are
# marked cur:false so the stylesheet can drop them back to ink 3.
set -uo pipefail

today=$(date +%-d)
first_dow=$(date -d "$(date +%Y-%m-01)" +%u)   # 1 = Monday
days_in=$(date -d "$(date -d "$(date +%Y-%m-01) +1 month" +%Y-%m-01) -1 day" +%-d)
prev_days=$(date -d "$(date +%Y-%m-01) -1 day" +%-d)

printf '{"title":"%s","days":[' "$(date '+%B %Y')"

lead=$((first_dow - 1))
sep=""
for ((i = lead - 1; i >= 0; i--)); do
	printf '%s{"n":"%d","cur":false,"today":false}' "$sep" $((prev_days - i)); sep=","
done
for ((d = 1; d <= days_in; d++)); do
	t=false; [ "$d" -eq "$today" ] && t=true
	printf '%s{"n":"%d","cur":true,"today":%s}' "$sep" "$d" "$t"; sep=","
done
for ((d = 1; $((lead + days_in + d - 1)) < 42; d++)); do
	printf '%s{"n":"%d","cur":false,"today":false}' "$sep" "$d"; sep=","
done
printf ']}\n'
