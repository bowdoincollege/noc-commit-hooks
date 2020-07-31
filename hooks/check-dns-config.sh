#!/bin/bash

set -e
err=0

# pre-commit will set workdir to /src and mount repo there
cd /src

if type named-checkconf >/dev/null 2>&1; then
  for hostdir in * ; do
    if [ -d "${hostdir}" ] && [ "$(basename "${hostdir}")" != "bind" ]; then
      echo -n "checking config for $(basename "${hostdir}")..."
      rm -rf /etc/bind/*
      mkdir -p "/etc/bind"
      cp -dLr "${hostdir}/." /etc/bind
      if OUTPUT=$(named-checkconf -z /etc/bind/named.conf 2>&1); then
        echo "passed"
      else
        echo "FAILED"
        echo
        echo -e "$OUTPUT" | grep -v 'zone .* loaded serial '
        echo
        err=$((err+1))
      fi
    fi
  done
  [ "$err" -ne 0 ] && exit 1
else
  echo "named-checkconf not installed, skipping checks"
fi
exit 0
