#!/bin/bash

# commit hook to check if serial in SOA RR is updated on all modified zone files

set -euo pipefail

ZONEDIR="bind/namedb"
fix=1
changed=0

function usage() {
  echo "${0##*/} [-f|-n] [-h] [-d <zonedir>"
  echo
  echo "commit hook to check if serial in SOA RR is updated on all modified zone files"
  echo "  -d  specify directory for zone files (default: bind/namedb)"
  echo "  -f  automatically fix/update serial numbers (default)"
  echo "  -n  just check serial numbers"
  echo "  -h  print this help"
  exit 1
}

function serial() {
  git show "$1" |
    sed 's/;.*$//' |
    awk '/^[A-Za-z0-9\-\.]*[\t \.\@]+IN[\t ]+SOA[\t ]+[A-Za-z0-9\-\. \t]+\(/,/\)/' |
    tr -d '\n' |
    awk '{print $7}'
}

while getopts ":d:fnh" opt; do
  case $opt in
    d) ZONEDIR=$OPTARG ;;
    f) fix=1 ;;
    n) fix=0 ;;
    h) usage ;;
    \?) echo "Invalid option -$OPTARG" && usage ;;
  esac
done

for file in $(git diff --staged --name-only --diff-filter=M); do

  # only consider zone files
  [[ -f "$file" && "$file" == "$ZONEDIR"/* ]] || continue

  old_serial=$(serial "@:$file")
  new_serial=$(serial ":$file")

  # skip file if we cannot parse old serial
  [[ "$old_serial" =~ ^[0-9]{10}$ ]] || continue

  # regenerate if we cannot parse new serial
  [[ "$new_serial" =~ ^[0-9]{10}$ ]] || new_serial=""

  # skip file if serial already updated
  [[ "$new_serial" -gt "$old_serial" ]] && continue

  echo "$file modified, but serial not updated."
  changed=$((changed + 1))

  if [[ "$fix" -eq 1 ]]; then
    date=$(date +%Y%m%d)
    old_date=$(cut -c 1-8 <<< "$old_serial")
    old_rev=$(cut -c 9-10 <<< "$old_serial")

    # calculate updated serial
    if [[ "$date" -gt "$old_date" ]]; then
      serial="${date}00"
    elif [[ "$date" -eq "$old_date" ]]; then
      if [[ "$old_rev" -eq 99 ]]; then
        echo "    too many revisions for today to increment \"$old_serial\"."
        continue
      fi
      serial="${date}$(printf "%02d" $((old_rev + 1)))"
    else
      echo "    current serial \"$old_serial\" is in the future, not updating."
      continue
    fi

    sed -e "s-${new_serial}-${serial}-" -i '' "$file"
    echo "    changed serial to $serial"
  fi

done

[[ "$changed" -gt 0 ]] && exit 1
